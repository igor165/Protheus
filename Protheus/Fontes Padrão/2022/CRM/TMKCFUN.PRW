#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKCFUN.CH"
#INCLUDE "TMKDEF.CH"

Static TamCdCli := TAMSX3("A1_COD")[1]
Static TamCdLoj := TAMSX3("A1_LOJA")[1]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TkCPainel        ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados que serao impressos no painel de informacoes  ³±±
±±³          ³ do contato e da empresa a ser avaliada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao e Logica ³±±
±±³          ³        ³      ³                                            	  ³±±
±±³          ³        ³      ³                                            	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkCEmpCont( aCont, nEntidade, cEnt, cCodLoj, lDadosEnt, lFiltroCRM)

Local aArea		:= GetArea()		// Salva a area atual
Local aEmpCont	:= {}				// Dados do contato e da empresa
Local aRet		:= {}				// Array de retorno da funcao
Local lPerfCli	:= .F.				// Indica se a consulta sera por perfil de cliente (nao obriga escolha de contato)
Local cAlias	:= GetNextAlias()
Local cFilSA1	:= ""
Local cFilSUS	:= ""
Local cFilACH	:= ""

Local cOperConc := "%" + IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+") + "%"

#IFDEF TOP
	Local cQuery	:= ""			// Select da Query
	Local cQryFil	:= ""
#ENDIF

Default cEnt		:= ""				// Entidade
Default cCodLoj	:= ""				// Cliente+Loja
Default lDadosEnt	:= .F.

lPerfCli := !Empty(cEnt) .AND. !Empty(cCodLoj)

If Len(aCont) == 0 .AND. !lDadosEnt
	DbSelectArea("AC8")
	If lPerfCli
		DbSetorder(2)
		If !MsSeek(xFilial("AC8") + cEnt + XFilial("AC8") + cCodLoj)
			Return(aCont)
		Endif	
	Else
		DbSetorder(1)
		If !MsSeek(xFilial("AC8") + SU5->U5_CODCONT)
			Return(aCont)
		Endif
	EndIf

	DbSelectArea("AC8")
	DbSetOrder(1)
	#IFDEF TOP                         
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Traz os contatos do perfil do cliente no SIGACRM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPerfCli .And. nModulo == 73
			cQuery :=	" SELECT AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_CODENT " +;
						" FROM	 " + RetSqlName("AC8") +;
						" WHERE	 AC8_FILIAL = '" + xFilial("AC8") + "' AND " +;
						" AC8_ENTIDA = '"+cEnt+"' AND AC8_CODENT='"+cCodLoj + "' AND " +;
						" 		 D_E_L_E_T_ = '' " +;
						" ORDER BY	" + SqlOrder(IndexKey())
			cQuery := ChangeQuery( cQuery )	
			Iif( Select( cAlias ) > 0, ( cAlias )->( DbCloseArea() ), Nil )
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
		
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Traz os contatos do perfil do Contato no SIGACRM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    ElseIf !lPerfCli .And. nModulo == 73 
    	    
    	    //Aplica os filtros de acesso SIGACRM
			cCodCont := SU5->U5_CODCONT
			
			If lFiltroCRM
				cFilSA1 := "%"+IIf(!Empty(CRMXFilEnt("SA1",.T.)),CRMXFilEnt("SA1",.T.)+" AND AC8.D_E_L_E_T_= ' ' ","")+"%"
				cFilSUS := "%"+IIf(!Empty(CRMXFilEnt("SUS",.T.)),CRMXFilEnt("SUS",.T.)+" AND AC8.D_E_L_E_T_= ' ' ","")+"%"
				cFilACH := "%"+IIf(!Empty(CRMXFilEnt("ACH",.T.)),CRMXFilEnt("ACH",.T.)+" AND AC8.D_E_L_E_T_= ' ' ","")+"%"
			Else
				cFilSA1	:= "%AC8.D_E_L_E_T_= ' '%"
				cFilSUS	:= "%AC8.D_E_L_E_T_= ' '%"
				cFilACH	:= "%AC8.D_E_L_E_T_= ' '%"
			EndIf

			BEGINSQL ALIAS cAlias
				SELECT AC8.AC8_FILIAL, AC8.AC8_CODCON, AC8.AC8_ENTIDA, AC8.AC8_CODENT 
				FROM %Table:AC8% AC8
					LEFT JOIN %Table:SA1% SA1
					INNER JOIN %Table:AO4% AO4 ON (SA1.A1_FILIAL %Exp:cOperConc% SA1.A1_COD %Exp:cOperConc% SA1.A1_LOJA) = AO4.AO4_CHVREG 
					ON SA1.A1_FILIAL = %Exp:xFilial( "SA1" )% 
						AND SA1.A1_COD %Exp:cOperConc% SA1.A1_LOJA = AC8.AC8_CODENT 
						AND SA1.%NotDel%
				WHERE  
					AC8.AC8_FILIAL = %Exp:xFilial( "AC8" )% 
					AND AC8.AC8_CODCON = %Exp:cCodCont% 
					AND %Exp:cFilSA1%
					 							
				UNION 					
				SELECT AC8.AC8_FILIAL, AC8.AC8_CODCON, AC8.AC8_ENTIDA, AC8.AC8_CODENT 
				FROM %Table:AC8% AC8
					LEFT JOIN %Table:SUS% SUS
					INNER JOIN %Table:AO4% AO4 ON (SUS.US_FILIAL %Exp:cOperConc% SUS.US_COD %Exp:cOperConc% SUS.US_LOJA) = AO4.AO4_CHVREG 
					ON SUS.US_FILIAL = %Exp:xFilial( "SUS" )% 
						AND SUS.US_COD %Exp:cOperConc% SUS.US_LOJA = AC8.AC8_CODENT 
						AND SUS.%NotDel%
				WHERE  
					AC8.AC8_FILIAL = %Exp:xFilial( "AC8" )% 
					AND AC8.AC8_CODCON = %Exp:cCodCont% 
					AND %Exp:cFilSUS% 			
				UNION 		
				SELECT AC8.AC8_FILIAL, AC8.AC8_CODCON, AC8.AC8_ENTIDA, AC8.AC8_CODENT 
					FROM %Table:AC8% AC8
						LEFT JOIN %Table:ACH% ACH 
						INNER JOIN %Table:AO4% AO4 ON (ACH.ACH_FILIAL %Exp:cOperConc% ACH.ACH_CODIGO %Exp:cOperConc% ACH.ACH_LOJA) = AO4.AO4_CHVREG
						ON ACH.ACH_FILIAL = %Exp:xFilial( "ACH" )% 
					   		AND ACH.ACH_CODIGO %Exp:cOperConc%  ACH.ACH_LOJA = AC8.AC8_CODENT 
					   		AND ACH.%NotDel%
					WHERE
						AC8.AC8_FILIAL = %Exp:xFilial( "AC8" )% 
						AND AC8.AC8_CODCON = %Exp:cCodCont% 
						AND %Exp:cFilACH%
						
				ORDER BY  AC8_CODCON, AC8_ENTIDA, AC8_CODENT		
			ENDSQL     
			cQryFil := GetLastQuery()[ 2 ]	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Traz os contatos do perfil do Cliente/Contato no SIGAFAT ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else 
			cQuery :=	" SELECT AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_CODENT " +;
						" FROM	 " + RetSqlName("AC8") +;
						" WHERE	 AC8_FILIAL = '" + xFilial("AC8") + "' AND " +;
						Iif(!lPerfCli," AC8_CODCON = '" + SU5->U5_CODCONT," AC8_ENTIDA = '"+cEnt+"' AND AC8_CODENT='"+cCodLoj) + "' AND " +;			
						" 		 D_E_L_E_T_ = '' " +;
						" ORDER BY	" + SqlOrder(IndexKey())
				cQuery := ChangeQuery( cQuery )	
				Iif( Select( cAlias ) > 0, ( cAlias )->( DbCloseArea() ), Nil )
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
		EndIf

		DbSelectArea( cAlias )
		DbGoTop()
		While ( cAlias )->( !EOF() ) .And. ;
		      ( cAlias )->AC8_FILIAL == xFilial( "AC8" )	.And. ;
				Iif(lPerfCli,Trim(( cAlias )->AC8_ENTIDA+( cAlias )->AC8_CODENT) == Trim(cEnt+cCodLoj),( cAlias )->AC8_CODCON == SU5->U5_CODCONT)
										
			cTipoEnt := TRIM(Posicione("SX2",1,TRIM(( cAlias )->AC8_ENTIDA),"X2NOME()"))
	
			DbSelectArea("SU5")
			DbSetOrder(1)
			MsSeek(XFilial("SU5")+( cAlias )->AC8_CODCON)
			
			AAdd(aCont,{ ALLTRIM(( cAlias )->AC8_ENTIDA),;													// Entidade
						 ALLTRIM(( cAlias )->AC8_CODENT),;													// Chave
						 cTipoEnt,;																			// Tipo entidade
						 TkEntidade(ALLTRIM(( cAlias )->AC8_ENTIDA),ALLTRIM(( cAlias )->AC8_CODENT),1),;	// Nome
						 TkEntidade(ALLTRIM(( cAlias )->AC8_ENTIDA),ALLTRIM(( cAlias )->AC8_CODENT),2),;	// Endereco
						 TkEntidade(ALLTRIM(( cAlias )->AC8_ENTIDA),ALLTRIM(( cAlias )->AC8_CODENT),3),;	// Cidade
						 TkEntidade(ALLTRIM(( cAlias )->AC8_ENTIDA),ALLTRIM(( cAlias )->AC8_CODENT),4),;	// Estado
						 TkEntidade(ALLTRIM(( cAlias )->AC8_ENTIDA),ALLTRIM(( cAlias )->AC8_CODENT),6),;	// Telefone
						 SU5->U5_CODCONT,;																	// Codigo Contato
						 SU5->U5_CONTAT,;																	// Nome Contato
						 SU5->U5_EMAIL })																	// Email
			
			DbSelectArea( cAlias )
			DbSkip()
		End
		DbSelectArea( cAlias )
		DbCloseArea()
		ChKFile( cAlias )
	#ENDIF
Else
	//Para perfil do cliente não serão exibidos os dados de contato.
	If lPerfCli
		AAdd(aEmpCont, {"CONTATO",	"CODIGO"	,	""	})
		AAdd(aEmpCont, {"CONTATO",	"NOME"		,	""	})
		AAdd(aEmpCont, {"CONTATO",	"FUNCAO"	,	""	})
		AAdd(aEmpCont, {"CONTATO",	"DDD"		,	""	})
		AAdd(aEmpCont, {"CONTATO",	"TELEFONE"	,	""	})
		AAdd(aEmpCont, {"CONTATO",	"E-MAIL"	,	""	})
		AAdd(aEmpCont, {"CONTATO",	"MUNICIPIO",	""	})
		AAdd(aEmpCont, {"CONTATO",	"ESTADO"	,	""	})
	/*
		Relacao dos campos da funcao TKENTIDADE
				01  A1_NOME 
				02  A1_END        
				03  A1_MUN 
				04  A1_EST 
				05  A1_CEP 
				06  A1_TEL                     
				07  A1_EMAIL                     
				08  A1_HPAGE   
				09  A1_DDD  
	*/
		AAdd(aEmpCont, {"ENTIDADE","ENTIDADE"	,	cEnt} )
		AAdd(aEmpCont, {"ENTIDADE","CHAVE"		,	cCodLoj} )
		AAdd(aEmpCont, {"ENTIDADE","NOME"		,	TkEntidade(cEnt,cCodLoj,1)} )
		AAdd(aEmpCont, {"ENTIDADE","ENDERECO"	,	TkEntidade(cEnt,cCodLoj,2)} )
		AAdd(aEmpCont, {"ENTIDADE","TELEFONE"	,	TkEntidade(cEnt,cCodLoj,6)} )
		AAdd(aEmpCont, {"ENTIDADE","MUNICIPIO"	,	TkEntidade(cEnt,cCodLoj,3)} )
		AAdd(aEmpCont, {"ENTIDADE","ESTADO"	,	TkEntidade(cEnt,cCodLoj,4)} )	
	Else
		If Len(aCont[nEntidade]) >= 9 .AND. Trim(aCont[nEntidade][9]) != "" //Se perfil da entidade escolhendo contato posiciona
			DbSelectArea("SU5")
			DbSetOrder(1)
			DbSeek(xFilial("SU5")+aCont[nEntidade][9])		
		EndIf 
		
		DbSelectArea("SUM")
		DbSetOrder(1)
		MsSeek(xFilial("SUM") + SU5->U5_FUNCAO)
	
		AAdd(aEmpCont, {"CONTATO",	"CODIGO"	,	SU5->U5_CODCONT	})
		AAdd(aEmpCont, {"CONTATO",	"NOME"		,	SU5->U5_CONTAT	})
		AAdd(aEmpCont, {"CONTATO",	"FUNCAO"	,	SUM->UM_DESC	})
		AAdd(aEmpCont, {"CONTATO",	"DDD"		,	SU5->U5_DDD		})
		AAdd(aEmpCont, {"CONTATO",	"TELEFONE"	,	SU5->U5_FONE	})
		AAdd(aEmpCont, {"CONTATO",	"E-MAIL"	,	SU5->U5_EMAIL	})
		AAdd(aEmpCont, {"CONTATO",	"MUNICIPIO",	SU5->U5_MUN		})
		AAdd(aEmpCont, {"CONTATO",	"ESTADO"	,	SU5->U5_EST		})
	/*
		Relacao dos campos da funcao TKENTIDADE
				01  A1_NOME 
				02  A1_END        
				03  A1_MUN 
				04  A1_EST 
				05  A1_CEP 
				06  A1_TEL                     
				07  A1_EMAIL                     
				08  A1_HPAGE   
				09  A1_DDD  
	*/
		AAdd(aEmpCont, {"ENTIDADE","ENTIDADE"	,	aCont[nEntidade,1]} )
		AAdd(aEmpCont, {"ENTIDADE","CHAVE"		,	aCont[nEntidade,2]} )
		AAdd(aEmpCont, {"ENTIDADE","NOME"		,	TkEntidade(aCont[nEntidade,1],aCont[nEntidade,2],1)} )
		AAdd(aEmpCont, {"ENTIDADE","ENDERECO"	,	TkEntidade(aCont[nEntidade,1],aCont[nEntidade,2],2)} )
		AAdd(aEmpCont, {"ENTIDADE","TELEFONE"	,	TkEntidade(aCont[nEntidade,1],aCont[nEntidade,2],6)} )
		AAdd(aEmpCont, {"ENTIDADE","MUNICIPIO"	,	TkEntidade(aCont[nEntidade,1],aCont[nEntidade,2],3)} )
		AAdd(aEmpCont, {"ENTIDADE","ESTADO"	,	TkEntidade(aCont[nEntidade,1],aCont[nEntidade,2],4)} )
	EndIf
	
Endif

If LEN(aEmpCont) == 0
	aRet := aClone(aCont)
Else
	aRet := aClone(aEmpCont)
Endif

RestArea(aArea)

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP01       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP01(aSerie, aEmpCont)

Local aArea  	:= GetArea()
Local aFiliais	:= {}
Local dCorte 	:= STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])
Local lProsp 	:= .F.
Local nX		:= 0
Local bEvFil	:= Nil
Local cFilAtu	:= cFilAnt

#IFDEF TOP
	Local cQuery	:= ""
#ENDIF 

#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| SUC->UC_FILIAL  == xFilial("SUC") }
#ENDIF

If ALLTRIM(aEmpCont[9][3]) == "SUS"
	lProsp := .T.
Endif

DbSelectArea("SUC")
DbSetOrder(6)
#IFDEF TOP
	cQuery :=	" SELECT UC_FILIAL, UC_CODCONT, UC_DATA, UC_ENTIDAD, UC_CHAVE, UC_STATUS " +;
				" FROM 	" + RetSqlName("SUC") +;
				" WHERE	" +;
				Iif(lTodasFil,"","UC_FILIAL = '" + xFilial("SUC") + "' AND ") +;				
				Iif(Trim(aEmpCont[1][3])=="",""," 		UC_CODCONT = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
				" 		UC_ENTIDAD = '" + ALLTRIM(aEmpCont[9][3]) + "' AND " +;
				" 		UC_CHAVE = '" + ALLTRIM(aEmpCont[10][3]) + "' AND " +;
				" 		UC_DATA >= '" + DTOS(dCorte) + "' AND " +;
				" 		D_E_L_E_T_ = '' " +;
				" ORDER BY	" + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("SUC")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUC', .F., .T.)
	
	TCSetField('SUC', 'UC_DATA'   , 'D')

#ELSE

	If lTodasFil .AND. X2ModAcess("SUC") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		If Trim(aEmpCont[1][3])==""
			DbSetOrder(2)
			MsSeek(xFilial("SUC") + aEmpCont[9][3]+aEmpCont[10][3])
		Else		
			MsSeek(xFilial("SUC") + ALLTRIM(aEmpCont[1][3]))
		EndIf		
#ENDIF	
		
While	!Eof() 			.AND.;
		Eval(bEvFil)	.AND.;
		IIf(Trim(aEmpCont[1][3])=="",SUC->UC_ENTIDADE+SUC->UC_CHAVE == aEmpCont[9][3]+aEmpCont[10][3],SUC->UC_CODCONT == ALLTRIM(aEmpCont[1][3]))
	
	#IFNDEF TOP
		If SUC->UC_DATA < dCorte
			DbSkip()
			Loop
		Endif
		
		If ALLTRIM(SUC->UC_ENTIDAD) <> ALLTRIM(aEmpCont[9][3])
			DbSkip()
			Loop
		Endif
		
		If ALLTRIM(SUC->UC_CHAVE) <> ALLTRIM(aEmpCont[10][3])
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[1][2] ++                 	// Total de atendimento
	aSerie[2][2] ++                 	// Total de telemarketing

	If VAL(SUC->UC_STATUS) == ENCERRADA
		aSerie[5][2] ++        			// Encerrados
	Else
		aSerie[6][2] ++                 // Pendentes
	Endif
	
    DbSelectarea("SUC")
	DbSkip()
End
#IFDEF TOP
	DbSelectArea("SUC")
	DbCloseArea()
	ChKFile("SUC")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| SUA->UA_FILIAL  == xFilial("SUA") }
#ENDIF

DbSelectArea("SUA")
DbSetOrder(6)
#IFDEF TOP
	cQuery :=	" SELECT UA_FILIAL, UA_CLIENTE, UA_LOJA, UA_EMISSAO, UA_CODCONT, UA_STATUS " +;
				" FROM	 " + RetSqlName("SUA") +;                               
				" WHERE	"+;         
				Iif(lTodasFil,"","UA_FILIAL = '" + xFilial("SUA") + "' AND ") +;
				Iif(Trim(aEmpCont[1][3])=="",""," 		 UA_CODCONT = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
				" 		 UA_CLIENTE = '" + SubStr(ALLTRIM(aEmpCont[10][3]),1,TamCdCli) + "' AND " +;
				" 		 UA_LOJA = '" + SubStr(ALLTRIM(aEmpCont[10][3]),TamCdCli+1,TamCdLoj) + "' AND " +;
				" 		 UA_EMISSAO >= '" + DTOS(dCorte) + "' AND " +;
				" 		 UA_PROSPEC = '" + If(lProsp,"T","F") + "' AND " +;
				" 		 D_E_L_E_T_ = '' " +;
				" ORDER BY	" + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("SUA")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUA', .F., .T.)
	
	TCSetField("SUA", "UA_EMISSAO" , "D")
#ELSE

	If lTodasFil .AND. X2ModAcess("SUA") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		DbSeek(xFilial("SUA") + aEmpCont[10][3])		// Cliente + Loja

#ENDIF	

While	!Eof() 			.AND.;
		Eval(bEvFil)	.AND.;
		AllTrim(SUA->UA_CLIENTE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))	.AND.;
		AllTrim(SUA->UA_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))
	
	#IFNDEF TOP
		If SUA->UA_EMISSAO < dCorte
			DbSkip()
			Loop
		Endif
		
		If SUA->UA_CODCONT <> ALLTRIM(aEmpCont[1][3]) .AND. aEmpCont[1][3] <> "" // Quando perfil do cliente, totaliza por todos os contatos.
			DbSkip()
			Loop
		Endif
		
		If lProsp .AND. !SUA->UA_PROSPEC
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[1][2] ++                 	// Total de atendimento
	aSerie[3][2] ++                  	// Total de televendas
	
	If SUA->UA_STATUS == "NF." .OR. SUA->UA_STATUS == "RM."
		aSerie[5][2] ++					// Encerrados
	ElseIf SUA->UA_STATUS <> "CAN"
		aSerie[6][2] ++					// Pendentes
	Endif
	
	DbSelectarea("SUA")
	DbSkip()
End           

#IFDEF TOP
	DbSelectArea("SUA")
	DbCloseArea()
	ChKFile("SUA")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF
         
#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| ACF->ACF_FILIAL == xFilial("ACF") }
#ENDIF

DbSelectArea("ACF")
DbSetOrder(2)
#IFDEF TOP
	cQuery :=	" SELECT ACF_FILIAL, ACF_CLIENT, ACF_LOJA, ACF_DATA, ACF_CODCON, ACF_PENDEN " +;
				" FROM	 " + RetSqlName("ACF") +;
				" WHERE "+;
				Iif(lTodasFil,"","ACF_FILIAL = '" + xFilial("ACF") + "' AND ") +;
				Iif(Trim(aEmpCont[1][3])=="","","		 ACF_CODCON = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
				"		 ACF_CLIENT = '" + SubStr(ALLTRIM(aEmpCont[10][3]),1,TamCdCli) + "' AND " +;
				"		 ACF_LOJA = '" + SubStr(ALLTRIM(aEmpCont[10][3]),TamCdCli+1,TamCdLoj) + "' AND " +;
				"		 ACF_DATA >= '" + DTOS(dCorte) + "' AND " +;
				"		 D_E_L_E_T_ = '' " +;
				" ORDER BY	" + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("ACF")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACF', .F., .T.)
	
	TCSetField('ACF', 'ACF_DATA', 'D')
	TCSetField('ACF', 'ACF_PENDEN', 'D')
#ELSE

	If lTodasFil .AND. X2ModAcess("ACF") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		DbSeek(xFilial("ACF") + aEmpCont[10][3])
#ENDIF	

While	!Eof() 			.AND.;
		Eval(bEvFil)	.AND.;
		ACF->ACF_CLIENT == SubStr(aEmpCont[10][3],1,6)	.AND.;
		ACF->ACF_LOJA   == SubStr(aEmpCont[10][3],7,2)
	
	#IFNDEF TOP
		If ACF->ACF_DATA < dCorte
			DbSkip()
			Loop
		Endif
	
		If ACF->ACF_CODCON <> ALLTRIM(aEmpCont[1][3]) .AND. Trim(aEmpCont[1][3]) <> "" // Quando perfil do cliente totaliza por todos os contatos
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[1][2] ++                   		// Total de atendimento
	aSerie[4][2] ++                   		// Total de telecobranca
	
	If Empty(ACF->ACF_PENDEN)
		aSerie[5][2] ++                  	// Encerrados
	Else
		aSerie[6][2] ++                  	// Pendentes
	Endif
	
	DbSelectarea("ACF")
	DbSkip()
End                      

#IFDEF TOP
	DbSelectArea("ACF")
	DbCloseArea()
	ChKFile("ACF")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

RestArea(aArea)

Return(aSerie)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP03       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP03(aSerie, aEmpCont)

Local aArea     := GetArea()																// Salva a area atual
Local dCorte    := STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Flag com a data de pesquisa	
Local aFiliais	:= {}    																	// Array de filiais consideradas
Local nX		:= 0																		// Auxiliar de loop
Local bEvFil	:= Nil																		// Avaliacao da filial no while
Local cFilAtu	:= cFilAnt																	// Armazena filial atual

#IFDEF TOP
	Local cQuery := ""	// Select da Query
#ENDIF

#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| SUC->UC_FILIAL  == xFilial("SUC") }
#ENDIF

DbSelectArea("SUC")
DbSetOrder(6)

#IFDEF TOP
	cQuery :=	" SELECT UC_FILIAL, UC_CODCONT, UC_DATA, UC_ENTIDAD, UC_CHAVE, UC_STATUS, UC_OPERACA, UC_PENDENT " +;
				" FROM 	 " + RetSqlName("SUC") +;
				" WHERE "+;
				Iif(lTodasFil,"","UC_FILIAL = '" + xFilial("SUC") + "' AND ") +;
				Iif(Trim(aEmpCont[1][3])=="",""," 		 UC_CODCONT = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
				" 		 UC_ENTIDAD = '" + ALLTRIM(aEmpCont[9][3]) + "' AND " +;
				" 		 UC_CHAVE = '" + ALLTRIM(aEmpCont[10][3]) + "' AND " +;
				" 		 UC_DATA >= '" + DTOS(dCorte) + "' AND " +;
				" 		 D_E_L_E_T_ = '' " +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("SUC")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUC', .F., .T.)
	
	TCSetField("SUC", "UC_DATA"	  , "D")
	TCSetField("SUC", "UC_PENDENT", "D")
#ELSE 
	If lTodasFil .AND. X2ModAcess("SUC") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		If Trim(aEmpCont[1][3]) == ""
			DbSetOrder(2)
			MsSeek(xFilial("SUC") + aEmpCont[9][3]+aEmpCont[10][3])
		Else
			DbSeek(xFilial("SUC") + ALLTRIM(aEmpCont[1][3]))
		EndIf
#ENDIF	

While	!Eof() 			.AND.;
		Eval(bEvFil)	.AND.;
		IIf(Trim(aEmpCont[1][3])=="",SUC->UC_ENTIDADE+SUC->UC_CHAVE == aEmpCont[9][3]+aEmpCont[10][3],SUC->UC_CODCONT == ALLTRIM(aEmpCont[1][3]))
	
	#IFNDEF TOP
		If SUC->UC_DATA < dCorte
			DbSkip()
			Loop
		Endif
		
		If (ALLTRIM(SUC->UC_ENTIDAD) <> ALLTRIM(aEmpCont[9][3])) .AND. (ALLTRIM(SUC->UC_CHAVE) == ALLTRIM(aEmpCont[10][3]))
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[1][2] ++		//  Atendimento (Soma todos)
	
	If VAL(SUC->UC_STATUS) == PLANEJADA		// 	Planejado (Soma somente os atendimentos planejados)
		aSerie[2][2] ++ 
	Endif
	
	If VAL(SUC->UC_STATUS) == ENCERRADA		// Encerrado (Soma somente os atendimentos encerrados)
		aSerie[3][2] ++
	Endif
	
	If VAL(SUC->UC_STATUS) == PENDENTE		// Pendente (Soma somente os atendimentos Pendentes)
		aSerie[4][2] ++
	Endif
	
	If VAL(SUC->UC_OPERACA) == ATIVO		// Ativo (Soma somente os atendimentos ativos)
		aSerie[5][2] ++
	Endif
	
	If VAL(SUC->UC_OPERACA) == RECEPTIVO	// Receptivos (Soma somente os atendimentos receptivos)
		aSerie[6][2] ++
	Endif

	If !Empty(SUC->UC_PENDENT) 				// Follow Up
		aSerie[7][2] ++
	Endif
	
	DbSelectarea("SUC")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SUC")
	DbCloseArea()
	ChKFile("SUC")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

RestArea(aArea)

Return(aSerie)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC01DadosCamp   ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC01DadosCamp(aSerie, aEmpCont, nPanel, cPanel)

Local aArea  := GetArea()             													// Salva area atual
Local dCorte := STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Data de corte
Local aFiliais	:= {}    																	// Array de filiais consideradas
Local nX		:= 0																		// Auxiliar de loop
Local cFilAtu	:= cFilAnt																	// Armazena filial atual

#IFDEF TOP
	Local cQuery := ""		// Select para a query
#ENDIF

If lTodasFil .AND. X2ModAcess("ACI") == "E"
    aFiliais := aFils
Else
	aFiliais := {cFilAnt}
EndIf

DbSelectArea("ACI")
DbSetOrder(2)

For nX := 1 to Len(aFiliais) 

	cFilAnt := aFiliais[nX]

	#IFDEF TOP
		If (cPanel == P_TLC_VENCIDA .OR. (cPanel == "" .AND. nPanel == 28)) .OR. Trim(aEmpCont[1][3]) == ""
			cQuery :=	" SELECT 	ACI_FILIAL, ACI_DATA, ACI_CODCON, ACI_ENTIDA, ACI_CHAVE, ACI_CODCAM " +;
						" FROM 		" + RetSqlName("ACI") +;
						" WHERE 	ACI_FILIAL = '" + xFilial("ACI") + "' AND " +;
						" 			ACI_DATA >= '" + DTOS(dCorte) + "' AND " +;
						Iif(Trim(aEmpCont[1][3])=="",""," 			ACI_CODCON = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
						" 			ACI_ENTIDA = '" + ALLTRIM(aEmpCont[9][3]) + "' AND " +;
						" 			ACI_CHAVE = '" + ALLTRIM(aEmpCont[10][3]) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
		Else
			cQuery :=	" SELECT 	ACI_FILIAL, ACI_DATA, ACI_CODCON, ACI_CODCAM " +;
						" FROM 		" + RetSqlName("ACI") +;
						" WHERE 	ACI_FILIAL = '" + xFilial("ACI") + "' AND " +;
						" 			ACI_DATA >= '" + DTOS(dCorte) + "' AND " +;
						" 			ACI_CODCON = '" + ALLTRIM(aEmpCont[1][3]) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
		Endif
		
		cQuery := ChangeQuery(cQuery)
		// MemoWrite("TMKCFUN.SQL", cQuery)
		DbSelectArea("ACI")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACI', .F., .T.)
		
		TCSetField("ACI", "ACI_DATA", "D")
	#ELSE
		If Trim(aEmpCont[1][3]) <> ""		
			MsSeek(xFilial("ACI") + aEmpCont[1][3])
		EndIf
	
	#ENDIF	
	
	While !Eof() .AND. ACI->ACI_FILIAL == xFilial("ACI")
		
		#IFNDEF TOP
			If ACI->ACI_DATA < dCorte
				DbSkip()
				Loop
			Endif
			
			If cPanel == P_CAMP_ANSCRIPT .OR. (cPanel == "" .AND.  nPanel == 13)
				If ACI->ACI_CodCon <> aEmpCont[1][3] .AND. Trim(aEmpCont[1][3]) <> "" // Quando perfil do Cliente totaliza por todos
					DbSkip()
					Loop
				Endif
			Endif
			
			If cPanel == P_TLC_VENCIDA .OR. (cPanel == "" .AND.  nPanel == 28)
				If ACI->ACI_ENTIDA <> aEmpCont[9][3] .AND. ACI->ACI_CHAVE <> aEmpCont[10][3]
					DbSkip()
					Loop
				Endif
			Endif
		#ENDIF
		
		aSerie[2][2] ++		//  Campanhas que o contato participou
		
		DbSelectArea("SUO")
		DbSetOrder(1)
		If DbSeek(xFilial("SUO") + ACI->ACI_CODCAM)
			Do Case
				Case Val(SUO->UO_ATENDIM) == TELEMARKETING
					aSerie[3][2] ++
					
				Case Val(SUO->UO_ATENDIM) == TELEVENDAS
					aSerie[4][2] ++
					
				Case Val(SUO->UO_ATENDIM) == TELECOBRANCA
					aSerie[5][2] ++
					
				Otherwise				//	"4" - Todos os atendimentos
					aSerie[3][2] ++		//  TMK
					aSerie[4][2] ++		//  TLV
					aSerie[5][2] ++		//  TLC
					
			EndCase
		Endif
		
		DbSelectArea("ACI")
		DbSkip()
	End
	
	DbSelectArea("SUO")
	aSerie[1][2] := RecCount()	// Total de campanhas
	
	#IFDEF TOP
		DbSelectArea("ACI")
		DbCloseArea()
		ChKFile("ACI")
	#ENDIF
Next nX

cFilAnt := cFilAtu

RestArea(aArea)

Return(aSerie)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP17       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP17(aSerie, aEmpCont)

Local aArea  := GetArea()																// Salva a area atual
Local dCorte := STOD(aEmpCont[Ascan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Flag com a data de pesquisa
Local lProsp := .F.																		// Flag que indica se e um PROSPECT
Local aFiliais	:= {}
Local nX		:= 0
Local bEvFil	:= Nil
Local bEvFil2	:= Nil
Local cFilAtu	:= cFilAnt
Local cBonusTs	:= SuperGetMv("MV_BONUSTS")

#IFDEF TOP
	Local cQuery	:= ""	// Select para a Query
#ENDIF

If Left(cBonusTs,1) == "'" .Or. Left(cBonusTs,1) == '"'
	cBonusTs := &cBonusTs
EndIf

If ALLTRIM(aEmpCont[9][3]) == "SUS"
	lProsp := .T.
Endif 

#IFDEF TOP
	bEvFil 	:= {|| .T. }
	bEvFil2	:= {|| .T. }
#ELSE
	bEvFil 	:= {|| SUA->UA_FILIAL  == xFilial("SUA") }
	bEvFil2	:= {|| SUB->UB_FILIAL  == xFilial("SUB") }
#ENDIF

DbSelectArea("SUA")
DbSetOrder(6)
#IFDEF TOP
	cQuery :=	" SELECT	UA_FILIAL, UA_NUM, UA_CLIENTE, UA_LOJA, UA_EMISSAO, UA_CODCONT, UA_OPER, UA_STATUS, UA_NUMSL1 " +;
				" FROM		" + RetSqlName("SUA") +;
				" WHERE "+;
				Iif(lTodasFil,"","UA_FILIAL = '" + xFilial("SUA") + "' AND ") +;
				Iif(Trim(aEmpCont[1][3])=="",""," 			UA_CODCONT = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
				" 			UA_CLIENTE = '" + SubStr(ALLTRIM(aEmpCont[10][3]),1,TamCdCli) + "' AND " +;
				" 			UA_LOJA = '" + SubStr(ALLTRIM(aEmpCont[10][3]),TamCdCli+1,TamCdLoj) + "' AND " +;
				" 			UA_EMISSAO >= '" + DTOS(dCorte) + "' AND " +;
				" 			UA_PROSPEC = '" + If(lProsp,"T","F") + "' AND " +;
				" 			D_E_L_E_T_ = '' " +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("SUA")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUA', .F., .T.)
	
	TCSetField('SUA', 'UA_EMISSAO' , 'D')
#ELSE 

	If lTodasFil .AND. X2ModAcess("SUA") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]   
   		DbSeek(xFilial("SUA") + aEmpCont[10][3])		// Cliente + Loja
	
#ENDIF	

While	!Eof() .AND. Eval(bEvFil) .AND.;
		AllTrim(SUA->UA_CLIENTE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))	.AND.;
		AllTrim(SUA->UA_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))
	
	#IFNDEF TOP
		If SUA->UA_EMISSAO < dCorte
			DbSkip()
			Loop
		Endif
	
		If SUA->UA_CODCONT <> ALLTRIM(aEmpCont[1][3]) .AND. Trim(aEmpCont[1][3]) <> "" // Quando perfil do cliente totaliza por todos
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[1][2] ++									//  Televendas

	If VAL(SUA->UA_OPER) == ORCAMENTO
		aSerie[2][2] ++								//  Orcamento (soma todos os atendimentos com operacao ORCAMENTO)
	Endif

	If VAL(SUA->UA_OPER) == FATURAMENTO
		aSerie[3][2] ++           					//  Faturamento (soma todos os atendimentos com operacao FATURAMENTO)
	Endif

	If VAL(SUA->UA_OPER) == ATENDIMENTO				//  Atendimento (soma todos os atendimentos com operacao ATENDIMENTO)
		aSerie[4][2] ++
	Endif

	If ALLTRIM(SUA->UA_STATUS) == "CAN"				// Cancelado (soma todos os atendimentos cancelados)
		aSerie[5][2] ++								
	Endif

	If !Empty(SUA->UA_NUMSL1)						// SigaLoja (soma todos os atendimentos que geraram SL1)
		aSerie[6][2] ++
	Endif
	
	DbSelectArea("SUB")
	DbSetOrder(1)
	#IFDEF TOP
		cQuery :=	" SELECT	UB_FILIAL, UB_NUM, UB_TES " +;
					" FROM 		" + RetSqlName("SUB") +;
					" WHERE "
					
		If lTodasFil .AND. X2ModAcess("SUB") == "E"
			cQuery += "	   		UB_FILIAL = '" + SUA->UA_FILIAL + "' AND " 
		Else
			cQuery += "		  	UB_FILIAL = '" + xFilial("SUB") + "' AND "
		EndIf
		
		cQuery += 	" 			UB_NUM = '" + SUA->UA_NUM + "' AND " +;
					" 			UB_TES = '" + cBonusTs + "' AND " +;
					" 			D_E_L_E_T_ = '' " +;
					" ORDER BY " + SqlOrder(IndexKey())
		
		cQuery := ChangeQuery(cQuery)
		// MemoWrite("TMKCFUN.SQL", cQuery)
		DbSelectArea("SUB")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUB', .F., .T.)
	#ELSE
		MsSeek(xFilial("SUB") + SUA->UA_NUM)
	#ENDIF	
	
	While	!Eof() .AND. Eval(bEvFil2) .AND.;
			SUB->UB_NUM == SUA->UA_NUM

		If SUB->UB_TES == cBonusTs
			aSerie[7][2] ++		//  Bonus (soma todos os bonus)
			Exit
		Endif

        DbSelectarea("SUB")
    	DbSkip()
    End
	
	#IFDEF TOP
		DbSelectArea("SUB")
		DbCloseArea()
		ChKFile("SUB")
	#ENDIF
	
	DbSelectArea("SUA")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SUA")
	DbCloseArea()
	ChKFile("SUA")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

RestArea(aArea)

Return(aSerie)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP26       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP26(aSerie, aEmpCont)

Local aArea 	 := GetArea()																// Salva a area atual
Local dCorte 	:= STOD(aEmpCont[Ascan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Flag com a data de pesquisa
Local aFiliais	:= {}
Local nX		:= 0
Local bEvFil	:= Nil
Local bEvFil2	:= Nil
Local cFilAtu	:= cFilAnt
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

#IFDEF TOP
	Local cQuery	:= ""		// Conteudo para a Select da Query
#ENDIF

#IFDEF TOP
	bEvFil 	:= {|| .T. }
	bEvFil2	:= {|| .T. }
#ELSE
	bEvFil 	:= {|| ACF->ACF_FILIAL  == xFilial("ACF") }
	bEvFil2	:= {|| ACG->ACG_FILIAL  == xFilial("ACG") }
#ENDIF

DbSelectArea("ACF")
DbSetOrder(2)
#IFDEF TOP
	cQuery :=	" SELECT 	ACF_FILIAL, ACF_CLIENT, ACF_LOJA, ACF_DATA, ACF_CODCON, ACF_PENDEN, ACF_CODIGO " +;
				" FROM 		" + RetSqlName("ACF") +;
				" WHERE "+;
				Iif(lTodasFil,"","ACF_FILIAL = '" + xFilial("ACF") + "' AND ") +;
				Iif(Trim(aEmpCont[1][3])=="",""," 			ACF_CODCON = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
				" 			ACF_CLIENT = '" + SubStr(ALLTRIM(aEmpCont[10][3]),1,TamCdCli) + "' AND " +;
				" 			ACF_LOJA = '" + SubStr(ALLTRIM(aEmpCont[10][3]),TamCdCli+1,TamCdLoj) + "' AND " +;
				" 			ACF_DATA >= '" + DTOS(dCorte) + "' AND " +;
				" 			D_E_L_E_T_ = '' " +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("ACF")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ACF", .F., .T.)
	
	TCSetField("ACF", "ACF_DATA"	, "D")
	TCSetField("ACF", "ACF_PENDEN"	, "D")
#ELSE

	If lTodasFil .AND. X2ModAcess("ACF") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]  
		DbSeek(xFilial("ACF") + aEmpCont[10][3])		// Cliente + Loja

#ENDIF	

While	!Eof() .AND. Eval(bEvFil) .AND.;
		ACF->ACF_CLIENT == SubStr(aEmpCont[10][3],1,6)	.AND.;
		ACF->ACF_LOJA   == SubStr(aEmpCont[10][3],7,2)
	
	#IFNDEF TOP
		If ACF->ACF_DATA < dCorte
			DbSkip()
			Loop
		Endif
		
		If ACF->ACF_CODCON <> ALLTRIM(aEmpCont[1][3]) .AND. Trim(aEmpCont[1][3]) <> "" // Quando perfil do cliente totaliza por todos
			DbSkip()
			Loop
		Endif
	#ENDIF

	aSerie[1][2] ++						  // Total de telecobrancas
	
	If !Empty(ACF->ACF_PENDEN)
		aSerie[2][2] ++					  // Negociacoes  (soma os atendimentos que foram negociados)

		DbSelectArea("ACG")
		DbSetOrder(1)
		#IFDEF TOP
			cQuery :=	" SELECT 	ACG_FILIAL, ACG_CODIGO, ACG_PREFIX, ACG_TITULO " +;
						" FROM 		" + RetSqlName("ACG") +;
						" WHERE " 
						
			If lTodasFil .AND. X2ModAcess("ACG") == "E"
				cQuery += "	   	ACG_FILIAL = '" + ACF->ACF_FILIAL + "' AND " 
			Else
				cQuery += "	  	ACG_FILIAL = '" + xFilial("ACG") + "' AND "
			EndIf
			
			cQuery +=	" 			ACG_CODIGO = '" + ACF->ACF_CODIGO + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("ACG")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACG', .F., .T.)
		#ELSE
			MsSeek(xFilial("ACG") + ACF->ACF_CODIGO)
		#ENDIF	
		
		While	!Eof() 	.AND. Eval(bEvFil2)	.AND.;
				ACG->ACG_CODIGO == ACF->ACF_CODIGO
			
			DbSelectArea("SE1")
			DbSetOrder(1) 
			
			If lSE1Exc .AND. cFilAnt <> ACF->ACF_FILIAL
				cFilAnt := ACF->ACF_FILIAL
			EndIf
			
			If DbSeek(xFilial("SE1") + ACG->ACG_PREFIX + ACG->ACG_TITULO)
				If SE1->E1_SALDO == 0
					aSerie[3][2] ++  // Recebimentos
				Else
					aSerie[4][2] ++  // Nao recebidos
				Endif
			Endif
			
			cFilAnt := cFilAtu
			
			DbSelectArea("ACG")
			DbSkip()
		End

		#IFDEF TOP
			DbSelectArea("ACG")
			DbCloseArea()
			ChKFile("ACG")
		#ENDIF

	Endif
	
	If ACF->ACF_PENDEN < dDataBase
		aSerie[5][2] ++			  // Cobrancas vencidas (soma todas as cobrancas vencidas)
	Endif
	
	DbSelectArea("ACF")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("ACF")
	DbCloseArea()
	ChKFile("ACF")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

#IFDEF TOP
	bEvFil 	:= {|| .T. }
#ELSE
	bEvFil 	:= {|| SE1->E1_FILIAL  == xFilial("SE1") }
#ENDIF

DbSelectArea("SE1")
DbSetOrder(2) 

#IFDEF TOP
	cQuery :=	" SELECT 	E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_VENCREA " +;
				" FROM 		" + RetSqlName("SE1") +;
				" WHERE "+;
				Iif(lTodasFil,"","E1_FILIAL = '" + xFilial("SE1") + "' AND ") +;
				" 			E1_CLIENTE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
				" 			E1_LOJA    = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
				" 			E1_VENCREA >= '" + DTOS(dCorte) + "' AND " +;
				" 			D_E_L_E_T_ = '' " +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("SE1")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SE1", .F., .T.)
	
	TCSetField("SE1", "E1_VENCREA", "D")
#ELSE

	If lTodasFil .AND. X2ModAcess("SE1") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX] 
		DbSeek(xFilial("SE1") + aEmpCont[10][3])	// Cliente + Loja

#ENDIF	

While	!Eof() .AND. Eval(bEvFil) .AND.;
		AllTrim(SE1->E1_CLIENTE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))	.AND.;
		AllTrim(SE1->E1_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))
	
	#IFNDEF TOP
		If SE1->E1_VENCREA < dCorte
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[6][2] ++					 			// Titulos vencidos a cobrar (soma todos)
	
	DbSelectarea("SE1")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SE1")
	DbCloseArea()
	ChKFile("SE1")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

RestArea(aArea)

Return(aSerie)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP32       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP32(aSerie, aEmpCont)

Local aArea  := GetArea()																// Salva a area atual
Local dCorte := STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Flag com a data de corte
Local nX		:= 0																	// Auxiliar de loop
Local aFiliais	:= {}																	// Lista de filiais consideradas (DBF)
Local bEvFil	:= Nil  																// Criterio de avaliacao da filial
Local cFilAtu	:= cFilAnt																// Filial corrente (backup)

#IFDEF TOP
	Local cQuery := ""	// Conteudo com a Select para a Query
#ENDIF

#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| SE1->E1_FILIAL  == xFilial("SE1") }
#ENDIF

DbSelectArea("SE1")
DbSetOrder(2)
#IFDEF TOP
	cQuery :=	" SELECT	E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_SALDO, E1_VENCREA, " +;
				"			E1_BAIXA, E1_SITUACA " +;
				" FROM		" + RetSqlName("SE1") +;
				" WHERE "+;
				Iif(lTodasFil,"","E1_FILIAL = '" + xFilial("SE1") + "' AND ") +;
				" 			E1_CLIENTE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
				" 			E1_LOJA    = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
				"			E1_EMISSAO >= '" + DTOS(dCorte) + "' AND " +;
				" 			D_E_L_E_T_ = '' " +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("SE1")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)
	
	TCSetField("SE1", "E1_VENCREA"	, "D")
	TCSetField("SE1", "E1_BAIXA"	, "D")
	TCSetField("SE1", "E1_EMISSAO"	, "D")
	TCSetField("SE1", "E1_SALDO"	, "N", 14, 2)
#ELSE

	If lTodasFil .AND. X2ModAcess("SE1") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf

	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
  		DbSeek(xFilial("SE1") + aEmpCont[10][3])	// Cliente + Loja

#ENDIF	

While	!Eof() .AND. Eval(bEvFil) .AND.;
		AllTrim(SE1->E1_CLIENTE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))	.AND.;
		AllTrim(SE1->E1_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))
	
	#IFNDEF TOP
		If SE1->E1_EMISSAO < dCorte
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[1][2] ++									// Total de Titulos
	If SE1->E1_SALDO == 0
		aSerie[2][2] ++								// Pagos
	Else
		aSerie[3][2] ++								// Aberto
	Endif
	
	If SE1->E1_VENCREA < dDataBase
		aSerie[4][2] ++								// Vencidos
	Else
		aSerie[5][2] ++								// A Vencer
	Endif
	
	If SE1->E1_BAIXA > SE1->E1_VENCREA				// Pago com atraso
		aSerie[6][2] ++
	Endif
	
	If SE1->E1_SITUACA == "6"
		aSerie[7][2] ++								// Protestado
		If SE1->E1_SALDO == 0
			aSerie[8][2] ++							// Pago em cartorio
		Endif
	Endif
	
	DbSelectarea("SE1")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SE1")
	DbCloseArea()
	ChKFile("SE1")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

RestArea(aArea)

Return(aSerie)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP39       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP39(aSerie, aEmpCont)

Local aArea 	:= GetArea()																// Salva a area atual	
Local dCorte	:= STOD(aEmpCont[Ascan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Flag com a data de corte
Local nX		:= 0																		// Auxiliar de loop
Local aFiliais	:= {}																		// Lista de filiais consideradas (DBF)
Local bEvFil	:= Nil  																	// Criterio de avaliacao da filial
Local bEvFil2	:= Nil																		// Criterio de avaliacao da filial
Local cFilAtu	:= cFilAnt																	// Filial corrente (backup)

#IFDEF TOP
	Local cQuery:= "" // Conteudo com a Select para a Query
#ENDIF

#IFDEF TOP
	bEvFil 	:= {|| .T. }
	bEvFil2	:= {|| .T. }
#ELSE
	bEvFil 	:= {|| SU4->U4_FILIAL == xFilial("SU4") }
	bEvFil2	:= {|| SU6->U6_FILIAL == xFilial("SU6") }
#ENDIF

DbSelectArea("SU4")
DbSetOrder(3)
#IFDEF TOP
	cQuery :=	" SELECT 	U4_FILIAL, U4_DATA, U4_LISTA, U4_FORMA " +;
				" FROM 		" + RetSqlName("SU4") +;
				" WHERE "+;
				Iif(lTodasFil,"","U4_FILIAL = '" + xFilial("SU4") + "' AND ") +;
				" 			U4_DATA >= '" + DTOS(dCorte) + "' AND " +;
				" 			D_E_L_E_T_ = '' " +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("SU4")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU4', .F., .T.)
	
	TCSetField("SU4", "U4_DATA", "D")
#ELSE          

	If lTodasFil .AND. X2ModAcess("SU4") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX] 
   		DbSeek(xFilial("SU4") + DTOS(dCorte), .T.)
	
#ENDIF	

While	!Eof()	.AND. Eval(bEvFil)	.AND.;
		SU4->U4_DATA   >= dCorte
	
	DbSelectArea("SU6")
	DbSetOrder(1)
	#IFDEF TOP
		cQuery :=	" SELECT	U6_FILIAL, U6_LISTA, U6_CONTATO, U6_ENTIDA, U6_CODENT " +;
					" FROM 		" + RetSqlName("SU6") +;
					" WHERE "
					
		If lTodasFil .AND. X2ModAcess("SU6") == "E"
			cQuery += "	   		U6_FILIAL = '" + SU4->U4_FILIAL + "' AND " 
		Else
			cQuery += "		  	U6_FILIAL = '" + xFilial("SU6") + "' AND "
		EndIf
		
		cQuery += 	" 			U6_LISTA = '" + SU4->U4_LISTA + "' AND " +;
					Iif(Trim(aEmpCont[1][3])=="",""," 			U6_CONTATO = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
					" 			U6_ENTIDA  = '" + ALLTRIM(aEmpCont[9][3]) + "' AND " +;
					" 			U6_CODENT  = '" + ALLTRIM(aEmpCont[10][3]) + "' AND " +;
					" 			D_E_L_E_T_ = '' " +;
					" ORDER BY " + SqlOrder(IndexKey())
		
		cQuery := ChangeQuery(cQuery)
		// MemoWrite("TMKCFUN.SQL", cQuery)
		DbSelectArea("SU6")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU6', .F., .T.)
	#ELSE
	
		MsSeek(xFilial("SU6") + SU4->U4_LISTA)
		
	#ENDIF	

	While	!Eof() 	.AND. Eval(bEvFil2)	.AND.;
			SU6->U6_LISTA  == SU4->U4_LISTA
		
		If	(SU6->U6_CONTATO == aEmpCont[1][3] .OR. Trim(aEmpCont[1][3])=="").AND.;
			SU6->U6_ENTIDA  == aEmpCont[9][3] .AND.;
			ALLTRIM(SU6->U6_CODENT) == ALLTRIM(aEmpCont[10][3])
			
			aSerie[1][2] ++									// Total da lista
			
			Do Case
				Case Val(SU4->U4_FORMA) == VOZ
					aSerie[2][2] ++		// Voz

				Case Val(SU4->U4_FORMA) == 2		// Tipo fax e mantido apenas para comp. ver 7.10
					aSerie[3][2] ++		// Fax

				Case Val(SU4->U4_FORMA) == CROSSPOSTING
					aSerie[4][2] ++		// Cross Posting

				Case Val(SU4->U4_FORMA) == MALADIRETA
					aSerie[5][2] ++		// Mala Direta

				Case Val(SU4->U4_FORMA) == PENDENCIA
					aSerie[6][2] ++    // Pendencia

				Case Val(SU4->U4_FORMA) == WEBSITE
					aSerie[7][2] ++	   // Web Site
		    
		    EndCase
			Exit
		Endif
		
		DbSelectarea("SU4")
		DbSkip()
	End

	#IFDEF TOP
		DbSelectArea("SU6")
		DbCloseArea()
		ChKFile("SU6")
	#ENDIF
	
	DbselectArea("SU4")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SU4")
	DbCloseArea()
	ChKFile("SU4")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

RestArea(aArea)

Return(aSerie)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP43       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP43(aSerie, aEmpCont)

Local aArea		:= GetArea()																// Salva a area atual
Local dCorte	:= STOD(aEmpCont[Ascan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Flag com a data de corte da pesquisa
Local nX		:= 0																		// Auxiliar de loop
Local aFiliais	:= {}																		// Lista de filiais consideradas (DBF)
Local bEvFil	:= Nil  																	// Criterio de avaliacao da filial
Local cFilAtu	:= cFilAnt																	// Filial corrente (backup)
Local lAchou	:= .F.																		// Retorno da busca no SUC

#IFDEF TOP
	Local cQuery:= ""	// Conteudo da Query
#ENDIF

#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| SE1->E1_FILIAL  == xFilial("SE1") }
#ENDIF	

DbSelectArea("AB1")
DbSetOrder(2)
#IFDEF TOP
	cQuery :=	" SELECT 	AB1_FILIAL, AB1_CODCLI, AB1_LOJA, AB1_EMISSA, AB1_NUMTMK, AB1_STATUS " +;
				" FROM 		" + RetSqlName("AB1") +;
				" WHERE "+;
				Iif(lTodasFil,"","AB1_FILIAL = '" + xFilial("AB1") + "' AND ") +;
				" 			AB1_CODCLI = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
				" 			AB1_LOJA = '" 	+ SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
				" 			AB1_EMISSA >= '"+ DTOS(dCorte) + "' AND " +;
				" 			D_E_L_E_T_ = '' " +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKCFUN.SQL", cQuery)
	DbSelectArea("AB1")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "AB1", .F., .T.)
	
	TCSetField("AB1", "AB1_EMISSA", "D")
#ELSE 
	If lTodasFil .AND. X2ModAcess("AB1") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf

	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
   		DbSeek(xFilial("AB1") + aEmpCont[10][3])		// Cliente + Loja
#ENDIF	

While	!Eof() .AND. Eval(bEvFil).AND.;
		AB1->AB1_CODCLI == SubStr(aEmpCont[10][3],1,6)	.AND.;
		AB1->AB1_LOJA   == SubStr(aEmpCont[10][3],7,2)
	
	#IFNDEF TOP
		If AB1->AB1_EMISSA < dCorte
			DbSkip()
			Loop
		Endif
	#ENDIF
	
	aSerie[1][2] ++									// Total geral
	
	DbSelectArea("SUC")
	DbSetOrder(1)
	
	If lTodasFil .AND. X2ModAcess("SUC") == "E"
		lAchou := DbSeek(AB1->AB1_FILIAL + AB1->AB1_NUMTMK)
	Else
		lAchou := DbSeek(xFilial("SUC") + AB1->AB1_NUMTMK)
	EndIf	
	
	If lAchou
		If SUC->UC_DATA > dCorte

			If SUC->UC_CODCONT == aEmpCont[1][3]
				aSerie[3][2] ++                    		// Total deste contato

			    If AB1->AB1_STATUS == "A"
					aSerie[4][2] ++                   	// Aberto deste contato
			    Else
					aSerie[5][2] ++                   	// Fechado deste contato
			    Endif
			Else
				aSerie[2][2] ++                   		// Total outros contatos
			Endif
		Endif
	Else
		If AB1->AB1_EMISSA > dCorte
			aSerie[6][2] ++                   			// Total filds diretos
		Endif
	Endif
	
	DbSelectArea("AB1")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("AB1")
	DbCloseArea()
	ChKFile("AB1")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

RestArea(aArea)
Return(aSerie)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010VP44ºAutor  ³Vendas CRM          º Data ³  29/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acumulado de vendas do sigaloja e faturamento               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKC010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010VP44(aSerie, aEmpCont)

Local aArea		:= GetArea()																// Salva a area atual
Local dCorte	:= STOD(aEmpCont[Ascan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])	// Flag com a data de corte da pesquisa
Local cFilSC5	:= ""
Local cFilSC6	:= ""
Local cFilSF4	:= ""
Local nX		:= 0
Local bEvFil	:= Nil
Local cFilAtu	:= cFilAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao de vendas via Loja³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	Local cQuery:= ""	// Conteudo da Query
#ENDIF	

#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| SL1->L1_FILIAL == xFilial("SL1") }
#ENDIF

DbSelectArea("SL1")
DbSetOrder(6) //L1_FILIAL+L1_CLIENTE+L1_LOJA

#IFDEF TOP

	cQuery := "SELECT L1_FILIAL,L1_CLIENTE,L1_LOJA,SUM(L1_VLRTOT) AS L1_VLRTOT FROM " + RetSqlName("SL1")
	cQuery += " WHERE "
	cQuery += Iif(lTodasFil,"","L1_FILIAL = '" + xFilial("SL1") + "' AND ")
	cQuery += " L1_CLIENTE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "'"
	cQuery += " AND L1_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND D_E_L_E_T_ = ''"
	cQuery += " AND L1_EMISSAO >= '" + DtoS(dCorte) + "' AND L1_DOC <> ''"
	cQuery += " GROUP BY L1_FILIAL,L1_CLIENTE,L1_LOJA"
	
	cQuery := ChangeQuery(cQuery)

	DbSelectArea("SL1")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SL1", .F., .T.)
	
#ELSE
	If lTodasFil .AND. X2ModAcess("SL1") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		DbSeek(xFilial("SL1") + aEmpCont[10][3])		// Cliente + Loja
#ENDIF	

While !Eof() .AND. Eval(bEvFil) .AND.;
	SL1->L1_CLIENTE== SubStr(aEmpCont[10][3],1,6)	.AND.;
	SL1->L1_LOJA   == SubStr(aEmpCont[10][3],7,2)	

	#IFNDEF TOP
		//Limite da consulta
		If SL1->L1_EMISSAO < dCorte
			DbSkip()
			Loop
		Endif
		
		//Ignora orcamentos
		If Empty(SL1->L1_DOC)
			DbSkip()
			Loop
		Endif

	#ENDIF
	
	aSerie[1][2] += SL1->L1_VLRTOT
	
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SL1")
	DbCloseArea()
	ChKFile("SL1")
#ELSE
	Next nX	
	cFilAnt := cFilAtu
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao de vendas via faturamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lTodasFil .AND. X2ModAcess("SC5") == "E"
    aFiliais := aFils
Else
	aFiliais := {cFilAnt}
EndIf

For nX := 1 to Len(aFiliais) 

	cFilAnt := aFiliais[nX]    
	
	cFilSC5	:= xFilial("SC5")
	cFilSC6	:= xFilial("SC6")
	cFilSF4	:= xFilial("SF4")

	#IFDEF TOP
	
		cQuery := "SELECT C6_FILIAL,C6_CLI,C6_LOJA,SUM(C6_VALOR) AS C6_VALOR FROM " + RetSqlName("SC6") + " SC6"
		cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = '" + cFilSC5 + "'"
		cQuery += " 	AND C5_NUM = C6_NUM AND C5_CLIENTE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "'"
		cQuery += "		AND C5_LOJACLI = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "'"
		cQuery += "		AND C5_EMISSAO >= '" + DtoS(dCorte) + "' AND C5_TIPO = 'N' AND SC5.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '" + cFilSF4 + "'"
		cQuery += "		AND F4_CODIGO = C6_TES AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ''"
		cQuery += " WHERE C6_FILIAL = '" + cFilSC6 + "' AND SC6.D_E_L_E_T_ = ''"
		cQuery += " GROUP BY C6_FILIAL,C6_CLI,C6_LOJA"
	
		cQuery := ChangeQuery(cQuery)
	
		DbSelectArea("SC6")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SC6", .F., .T.)
		
	#ELSE
		DbSelectArea("SC5")
		DbSetOrder(1)
		
		DbSelectArea("SF4")
		DbSetOrder(1)
		
		DbSelectArea("SC6")
		DbSetOrder(5) //C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SERIORI+C6_ITEMORI
				
		DbSeek(xFilial("SC6") + aEmpCont[10][3])		// Cliente + Loja
	#ENDIF	
	
	While !Eof() 										.AND.;
		SC6->C6_FILIAL == cFilSC6		 				.AND.;
		SC6->C6_CLI    == SubStr(aEmpCont[10][3],1,6)	.AND.;
		SC6->C6_LOJA   == SubStr(aEmpCont[10][3],7,2)	
	
		#IFNDEF TOP
			If SC5->(DbSeek(cFilSC5+SC6->C6_NUM))
				//Limite de data
				If SC5->C5_EMISSAO < dCorte
					SC6->(DbSkip())
					Loop
				Endif
				//Tipo Normal
				If SC5->C5_TIPO <> "N"
					SC6->(DbSkip())
					Loop
				Endif
			Else
				SC6->(DbSkip())
				Loop
			EndIf
			
			If SF4->(DbSeek(cFilSF4+SC6->C6_TES))
				//Tes que nao gera financeiro
				If SF4->F4_DUPLIC <> 'S'
					SC6->(DbSkip())
					Loop
				EndIf
			Else
				SC6->(DbSkip())
				Loop
			EndIf
	
		#ENDIF
		
		aSerie[2][2] += SC6->C6_VALOR
		
		DbSkip()
	End
	
	#IFDEF TOP
		DbSelectArea("SC6")
		DbCloseArea()
		ChKFile("SC6")
	#ENDIF

Next nX	 

cFilAnt := cFilAtu

RestArea(aArea)
Return(aSerie)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKCListBox       ³Autor  ³Armando M. Tessaroli³ Data ³ 12/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K.³11/10/03³710   ³-Revisao da Notacao,Sintaxe e Documentacao  	  ³±±
±±³          ³        ³      ³Ensaio da Qualidade                         	  ³±±
±±³          ³        ³      ³                                            	  ³±±
±±³          ³        ³      ³                                            	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKCListBox(cAlias, aEmpCont, nPanel, aFiltro, cPanel)

Local aArea     := GetArea() 	// Salva a area atual      		
Local dCorte    := CTOD("//")	// Data de corte da selecao de dados
Local aDados    := {}			// Retorno da selecao de dados
Local cFilEntid := ""			// Filial da entidade escolhida (SU5,SA1,...)
Local cEntidade := ""			// Alias da entidad escolhida
Local cCodigo   := ""			// Codigo primario de busca
Local cDesc     := ""			// Descricao de resultado 
Local lBonus    := .F.			// Flag que identifica se existe bonus ou nao (Cenario de Vendas) para as consultas de Vendas
Local nPProd		:= 0			// Posicao do Produto no array de retorno
Local cForma    := ""			// Forma de contato da lista de contatos		
Local cTpFone   := ""			// Tipo de telefone da lista de contatos
Local cNomeEnt  := ""			// Nome da entidade usada na Lista de Contatos
Local lProsp    := .F.			// Flag que indica prospect ou nao
Local nPos 		:= 0			// Contador auxiliar
Local cDescAux1	:= ""			// Descricao auxiliar para resultado de campos (Exemplo:Tipo de atendimento)
Local cDescAux2	:= ""			// Descricao auxiliar para resultado de campos (Exemplo:Tipo de atendimento)
Local cDescAux3	:= ""			// Descricao auxiliar para resultado de campos (Exemplo:Tipo de atendimento)
Local cDescAux4	:= ""			// Descricao auxiliar para resultado de campos (Exemplo:Tipo de atendimento)
Local cFiltro		:= ""			// Variavel de busca das tabelas filhas (Exemplo: SU6)	
Local aPeds		:= {}			// Lista de pedidos de venda
Local lFiltSE1	:= ExistBlock("TK10CSE1")	// Indicador de presenta de Ponto de entrada
Local lRetPE	:= .T.
Local aFiliais:= {}
Local nX		:= 0
Local bEvFil	:= Nil
Local bEvFil2	:= Nil
Local cFilAtu	:= cFilAnt 
Local cBonusTs:= SuperGetMv("MV_BONUSTS")
Local cFilBk	:= ""			// Armazena a filial corrente para backup  
Local lAchou	:= .F.			// Resultado do DbSeek
Local aCampos	:= {}			// Campos do X3 usados para montar o listbox
Local aLinha	:= {}			// Linha com conteudo dos campos
Local cCliente:= ""

#IFDEF TOP
	Local cQuery := ""			// Conteudo da Select para a Query
#ENDIF
             
DEFAULT aFiltro	:= {""}
DEFAULT cPanel	:= "" // Para release 11.7 o controle nao sera pelo numero, mas pelo nome do painel

//Proteção Para funcionar pelo nome do panel apenas no release 11.7 caso algum fonte seja atualizado pontualmente
cPanel := cPanel

//Quando ativado perfil do release 11.7, se nao passado nome seta indefinido para nao utilizar comportamento antigo (por nPanel)
cPanel := Iif(cPanel == "",P_UNDEF,cPanel)

If Left(cBonusTs,1) == "'" .Or. Left(cBonusTs,1) == '"'
	cBonusTs := &cBonusTs
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida o conteudo de busca da variavel aFiltro  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Valtype(aFiltro) == "A"
	If Len(aFiltro) > 0
		cFiltro := aFiltro[1]
	Endif
ElseIf Valtype(aFiltro) == "C"
	If !Empty(TRIM(aFiltro))
		cFiltro := aFiltro
    Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura a data final da consulta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan(aEmpCont, {|x| TRIM( x[1] ) == "CORTE"} )
If nPos > 0 
	dCorte := STOD(aEmpCont[nPos][3])		// Converte de String para Data
Else
	dCorte := dDataBase
Endif	
             
Do Case

	Case cAlias == "MBO" // Cartão Fidelidade
		
		cCliente := Substr(aEmpCont[10][3],1,TamSX3("F2_CLIENTE")[1])
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		MsSeek("MBO")		
		While !SX3->(Eof()) .AND. X3_ARQUIVO == "MBO" 
			If (X3Uso(X3_USADO,12) .OR. X3_CAMPO == "MBO_FILIAL") .AND. MBO->(FieldPos(SX3->X3_CAMPO)) > 0 //12 = sigaloja	
				AAdd(aCampos,X3_CAMPO)
			End
			DbSkip()
		End
		
		DbSelectArea("MBO")
		DbSetOrder(3) // MBO_FILIAL+MBO_CODCLI

		If lTodasFil .AND. X2ModAcess("MBO") == "E"
		    aFiliais := aFils
		Else
			aFiliais := {cFilAnt}
		EndIf
		
		For nX := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nX]		
		
			MsSeek(XFilial("MBO") + Trim(aEmpCont[10][3]))	
		
			While	!Eof()								.AND.;
				MBO->MBO_FILIAL  == XFilial("MBO")	.AND.;
				Trim(MBO->MBO_CODCLI) == cCliente
				
				aLinha := {}
				For nPos := 1 To Len(aCampos)
					AAdd(aLinha,&("MBO->"+aCampos[nPos]))
				Next nPos
				
				AAdd(aDados,aLinha)
				DbSkip()															
			End						
		Next nX
			
		cFilAnt := cFilAtu
		
	Case cAlias == "MEI" // Desconto Varejo
	
		DbSelectArea("SX3")
		DbSetOrder(1)
		MsSeek("MEI")		
		While !SX3->(Eof()) .AND. X3_ARQUIVO == "MEI" 
			If (X3Uso(X3_USADO,12) .OR. X3_CAMPO == "MEI_FILIAL") .AND. MEI->(FieldPos(SX3->X3_CAMPO)) > 0 //12 = sigaloja	
				AAdd(aCampos,X3_CAMPO)
			End
			DbSkip()
		End
		
		DbSelectArea("MEI")
		DbSetOrder(4) // MEI_FILIAL+MEI_CODCLI+MEI_LOJA

		If lTodasFil .AND. X2ModAcess("MEI") == "E"
		    aFiliais := aFils
		Else
			aFiliais := {cFilAnt}
		EndIf
		
		For nX := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nX]		
		
			MsSeek(XFilial("MEI") + Trim(aEmpCont[10][3]))	
		
			While	!Eof()								.AND.;
				MEI->MEI_FILIAL  == XFilial("MEI")	.AND.;
				Trim(MEI->MEI_CODCLI+MEI->MEI_LOJA) == Trim(aEmpCont[10][3])
				
				aLinha := {}
				For nPos := 1 To Len(aCampos)
					AAdd(aLinha,&("MEI->"+aCampos[nPos]))
				Next nPos
				
				AAdd(aDados,aLinha)
				DbSkip()															
			End						
		Next nX
			
		cFilAnt := cFilAtu
		
	Case cAlias == "SUC"	// Telermaketing 
	
		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| SUC->UC_FILIAL  == xFilial("SUC") }
		#ENDIF

		DbSelectArea("SUC")
		DbSetOrder(6)
		
		#IFDEF TOP
			cQuery :=	" SELECT	UC_FILIAL, UC_CODCONT, UC_DATA, UC_ENTIDAD, UC_CHAVE, UC_STATUS, UC_CODCAMP, " +;
						" 			UC_OPERACA, UC_CODIGO, UC_OPERADO, UC_MIDIA, UC_TIPO, UC_PENDENT, UC_HRPEND " +;
						" FROM 		" + RetSqlName("SUC") +;
						" WHERE " +;
						Iif(lTodasFil,"","UC_FILIAL = '" + xFilial("SUC") + "' AND ") +;
						Iif(Trim(aEmpCont[1][3])=="",""," 			UC_CODCONT = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
						" 			UC_ENTIDAD = '" + ALLTRIM(aEmpCont[9][3]) + "' AND " +;
						" 			UC_CHAVE = '"   + ALLTRIM(aEmpCont[10][3]) + "' AND " +;
						" 			UC_DATA >= '"   + DTOS(dCorte) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("SUC")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUC', .F., .T.)
			
			TCSetField("SUC", "UC_DATA" , 'D')
			TCSetField("SUC", "UC_PENDENT" , 'D')
		#ELSE
			If lTodasFil .AND. X2ModAcess("SUC") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
				If Trim(aEmpCont[1][3])=="" //Perfil do Cliente
					DbSetOrder(2)
					MsSeek(xFilial("SUC") + ALLTRIM(aEmpCont[9][3])+ ALLTRIM(aEmpCont[10][3]))
				Else
		   			MsSeek(xFilial("SUC") + ALLTRIM(aEmpCont[1][3]))
		   		EndIf
		#ENDIF	

		While	!Eof()			.AND.;
				Eval(bEvFil)	.AND.;
				Iif(Trim(aEmpCont[1][3])<>"",;
				SUC->UC_CODCONT == ALLTRIM(aEmpCont[1][3]),;
				((SUC->UC_ENTIDAD <> aEmpCont[9][3]) .AND. (ALLTRIM(SUC->UC_CHAVE) <> ALLTRIM(aEmpCont[10][3]))))				
			
			#IFNDEF TOP
				If SUC->UC_DATA < dCorte
					DbSkip()
					Loop
				Endif
		
				If (SUC->UC_ENTIDAD <> aEmpCont[9][3]) .AND. (ALLTRIM(SUC->UC_CHAVE) <> ALLTRIM(aEmpCont[10][3]))
					DbSkip()
					Loop
				Endif
			#ENDIF
			
			Do Case
				Case cPanel == P_TMK_ENCERRADOS .OR. (cPanel == "" .AND. nPanel == 4)	// Encerrados
					If VAL(SUC->UC_STATUS) <> ENCERRADA
						DbSkip()
						Loop
					Endif

				Case cPanel == P_TMK_ATIVOS .OR. (cPanel == "" .AND. nPanel == 5)	// Ativos
					If VAL(SUC->UC_OPERACA) <> ATIVO
						DbSkip()
						Loop
					Endif
					
				Case cPanel == P_TMK_RECEPTIVOS .OR. (cPanel == "" .AND. nPanel == 6)	// Receptivos
					If VAL(SUC->UC_OPERACA) <> RECEPTIVO
						DbSkip()
						Loop
					Endif                  
					
				Case cPanel == P_TMK_FOLLOW .OR. (cPanel == "" .AND. nPanel == 7)	// Follow Up
					If Empty(SUC->UC_PENDENT) .AND. Empty(SUC->UC_HRPEND)
						DbSkip()
						Loop
					Endif

				Case cPanel == P_TMK_PENDENCIAS .OR. (cPanel == "" .AND. nPanel == 8)	// Pendencias
					If VAL(SUC->UC_STATUS) <> PENDENTE
						DbSkip()
						Loop
					Endif
					
				Case cPanel == P_TMK_CHAMADO .OR. (cPanel == "" .AND. nPanel == 9)	// Chamado tecnico
					DbSelectArea("AB1")
					DbSetOrder(5)  
					
					If X2ModAcess("AB1") == "E"
						lAchou := DbSeek(SUC->UC_FILIAL + SUC->UC_CODIGO)
					Else
						lAchou := DbSeek(xFilial("AB1") + SUC->UC_CODIGO)
					EndIf 
					
					If ! lAchou
						DbSelectArea("SUC")
						DbSkip()
						Loop
					Else
						DbSelectArea("SUC")
					Endif
				
	        EndCase
			
			cDescAux1 := ""
			If VAL(SUC->UC_OPERACA) == ATIVO
				cDescAux1 := STR0001		// Ativo
			Else
				cDescAux1 := STR0002 		// Receptivo
			Endif

			cDescAux2 := ""
			Do Case
				Case VAL(SUC->UC_STATUS) == PLANEJADA
					cDescAux2 := STR0003	// Planejada
					
				Case VAL(SUC->UC_STATUS) == PENDENTE					
					cDescAux2 := STR0004	// Pendente
						
				Case VAL(SUC->UC_STATUS) == ENCERRADA
					cDescAux2 := STR0005	// Encerrada
			Endcase
			
			cFilBk := cFilAnt
			
			If X2ModAcess("SUC") == "E" .AND. SUC->UC_FILIAL <> cFilant
				cFilAnt := SUC->UC_FILIAL
			EndIf
						
			AAdd(aDados, {	SUC->UC_CODIGO,;														// 01 - Codigo	
							DTOC(SUC->UC_DATA),;													// 02 - Data
							Posicione("SU7",1,xFilial("SU7") + SUC->UC_OPERADO,"SU7->U7_NOME"),;	// 03 - Operador
							Posicione("SUH",1,xFilial("SUH") + SUC->UC_MIDIA,"SUH->UH_DESC"),;		// 04 - Midia
							cDescAux1,; 															// 05 - Tipo (Ativo,Receptivo)
							cDescAux2,;																// 06 - Status 
							Posicione("SUL",1,xFilial("SUL") + SUC->UC_TIPO,"SUL->UL_DESC"),;		// 07 - Tipo
							Posicione("SUO",1,xFilial("SUO") + SUC->UC_CODCAMP,"SUO->UO_DESC"),;	// 08 - Campanha
							DTOC(SUC->UC_PENDENT) + " - "+ SUC->UC_HRPEND ,;						// 09 - Retorno/Hora
							SUC->UC_FILIAL } )														// 10 - Filial
			
			cFilAnt := cFilBk
			
	    	DbSelectArea("SUC")
	    	DbSkip()
	    End

		If Len(aDados) > 0
			Asort( aDados,,, { |x,y| CTOD(x[2]) > CTOD(y[2]) } )
		Endif

		#IFDEF TOP
			DbSelectArea("SUC")
			DbCloseArea()
			ChKFile("SUC")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF
	
	Case cAlias == "ACB"
		If (cPanel == P_CAMP .OR. (cPanel == "" .AND. nPanel == 11)) .AND. Trim(aEmpCont[1][3]) <> "" // Quando Perfil do Cliente exibe por entidade
			cFilEntid := xFilial("SU5")
			cEntidade := "SU5"
			cCodigo   := aEmpCont[1][3]
		Else
			cFilEntid := xFilial(aEmpCont[9][3])
			cEntidade := aEmpCont[9][3]
			cCodigo   := aEmpCont[10][3]
		Endif
		
		DbSelectArea("AC9")
		DbSetOrder(2)
		#IFDEF TOP
			cQuery :=	" SELECT 	AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ " +;
						" FROM 		" + RetSqlName("AC9") +;
						" WHERE 	AC9_FILIAL = '" + xFilial("AC9") + "' AND " +;
						" 			AC9_ENTIDA = '" + cEntidade + "' AND " +;
						" 			AC9_FILENT = '" + cFilEntid + "' AND " +;
						" 			AC9_CODENT = '" + cCodigo + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("AC9")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'AC9', .F., .T.)
		#ELSE
			MsSeek(xFilial("AC9") + cEntidade + cFilEntid + cCodigo)
		#ENDIF	

		While	!Eof() 								.AND.;
				AC9->AC9_FILIAL == xFilial("AC9") 	.AND.;
				AC9->AC9_ENTIDA == cEntidade 		.AND.;
				AC9->AC9_FILENT == cFilEntid 		.AND.;
				ALLTRIM(AC9->AC9_CODENT) == cCodigo
			
			DbSelectArea("ACB")
			DbSetOrder(1)
			If MsSeek(xFilial("ACB") + AC9->AC9_CODOBJ)
				AAdd(aDados, {	ACB->ACB_CODOBJ,;
								ACB->ACB_OBJETO,;
								ACB->ACB_DESCRI;
								 				} )
				
			Endif
			
			DbSelectArea("AC9")
			DbSkip()
		End
		
		#IFDEF TOP
			DbSelectArea("AC9")
			DbCloseArea()
			ChKFile("AC9")
		#ENDIF
        
	Case cAlias == "SUZ"		// Script Dinamico 
		DbSelectArea("SUW")
		DbSetOrder(1)
		#IFDEF TOP
			cQuery :=	" SELECT UW_FILIAL, UW_CODCAMP, UW_CODSCRI " +;
						" FROM 	 " + RetSqlName("SUW") +;
						" WHERE  UW_FILIAL = '" + xFilial("SUW") + "' AND " +;
						" 		 UW_CODCAMP = '" + cFiltro + "' AND " +;
						" 		 D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("SUW")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUW', .F., .T.)
		#ELSE
			MsSeek(xFilial("SUW") + cFiltro)
		#ENDIF	
		
		While	!Eof()								.AND.;
				SUW->UW_FILIAL  == xFilial("SUW")	.AND.;
				SUW->UW_CODCAMP == cFiltro
			cDescAux1 := ""
			Do Case
			    case VAL(SUZ->UZ_TIPO) == RECEPTIVO
			    	cDescAux1 := STR0002	// RECEPTIVO 

			    case VAL(SUZ->UZ_TIPO) == ATIVO
			    	cDescAux1 := STR0001  	// ATIVO

			    case SUZ->UZ_TIPO == "3"	//AMBOS
			    	cDescAux1 := STR0007
			Endcase
		                   
			cDescAux2 := ""
			If SUZ->UZ_FORMATO == "1"
				cDescAux2 := STR0008		// ATENDIMENTO
			Else
				cDescAux2 := STR0009		// PESQUISA
			Endif	
		
		    If !Empty(SUW->UW_CODSCRI)
			    DbSelectArea("SUZ")
			    DbSetOrder(1)
			    If MsSeek(xFilial("SUZ") + SUW->UW_CODSCRI)
					AAdd(ADADOS, {	SUZ->UZ_CODSCRI,;                               // 01 - Codigo do Script
									SUZ->UZ_DESC,;									// 02 - Descricao do Script
									SUZ->UZ_TEMPO,;									// 03 - TMA do script
									cDescAux1,; 								  	// 04 - Tipo (RECEPTIVO,ATIVO,AMBOS)
									cDescAux2,; 									// 05 - Formato (ATENDIMENTO,PESQUISA)
									IIF(SUZ->UZ_ARMRESP == "1",STR0010,STR0011),; 	// 06 - Armazena resultado (SIM,NAO)
									SUZ->UZ_SCORMIN,;								// 07 - Score Minimo
									SUZ->UZ_PROCMIN,;								// 08 - Processo para o score minimo
									SUZ->UZ_SCORMAX,;								// 09 - Score Maximo
									SUZ->UZ_PROCMAX })								// 10 - Processo para o score maximo
			    Endif
		    Endif
			
			DbSelectArea("SUW")
			DbSkip()
		End
		
		#IFDEF TOP
			DbSelectArea("SUW")
			DbCloseArea()
			ChKFile("SUW")
		#ENDIF


	Case cAlias == "SUA" 
	
		If ALLTRIM(aEmpCont[9][3]) == "SUS"
			lProsp := .T.
		Endif

		#IFDEF TOP
			bEvFil 	:= {|| .T. }
			bEvFil2	:= {|| .T. }
		#ELSE
			bEvFil 	:= {|| SUA->UA_FILIAL  == xFilial("SUA") }
			bEvFil2	:= {|| SUB->UB_FILIAL  == xFilial("SUB") }
		#ENDIF
		
		DbSelectArea("SUA")
		DbSetOrder(6)
		
		#IFDEF TOP
			cQuery :=	" SELECT 	UA_FILIAL, UA_CLIENTE, UA_LOJA, UA_EMISSAO, UA_CODCONT, UA_OPER, " +;
						" 			UA_NUMSL1, UA_NUM, UA_OPERADO, UA_TABELA, UA_MIDIA, UA_VEND, UA_CODCAMP, " +;
						" 			UA_CODLIG, UA_CONDPG, UA_FORMPG, UA_TRANSP, UA_STATUS " +;
						" FROM 		" + RetSqlName("SUA") +;
						" WHERE "+;
						Iif(lTodasFil,"","UA_FILIAL = '" + xFilial("SUA") + "' AND ") +;
						Iif(Trim(aEmpCont[1][3])=="",""," 			UA_CODCONT = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
						" 			UA_CLIENTE = '" + SubStr(ALLTRIM(aEmpCont[10][3]),1,TamCdCli) + "' AND " +;
						" 			UA_LOJA = '" + SubStr(ALLTRIM(aEmpCont[10][3]),TamCdCli+1,TamCdLoj) + "' AND " +;
						" 			UA_EMISSAO >= '" + DTOS(dCorte) + "' AND " +;
						" 			UA_PROSPEC = '" + If(lProsp,"T","F") + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("SUA")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUA', .F., .T.)
			
			TCSetField('SUA', 'UA_EMISSAO' , 'D')
		#ELSE 
			If lTodasFil .AND. X2ModAcess("SUA") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
				DbSeek(xFilial("SUA") + aEmpCont[10][3])		// Cliente + Loja
		#ENDIF	
		While	!Eof() .AND. Eval(bEvFil) .AND.;
				AllTrim(SUA->UA_CLIENTE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))	.AND.;
				AllTrim(SUA->UA_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))
			
			#IFNDEF TOP
				If SUA->UA_EMISSAO < dCorte
					DbSkip()
					Loop
				Endif
				
				If SUA->UA_CODCONT <> ALLTRIM(aEmpCont[1][3]) .AND. Trim(aEmpCont[1][3])<>"" // Quando perfil do cliente totaliza por todos.
					DbSkip()
					Loop
				Endif
			#ENDIF
			
			Do Case
				Case cPanel == P_TLV_ORCAMENTO .OR. (cPanel == "" .AND. nPanel == 16)	// Orcamentos
					If VAL(SUA->UA_OPER) <> ORCAMENTO
						DbSkip()
						Loop
					Endif

				Case cPanel == P_TLV_FATURAMENTO .OR. (cPanel == "" .AND. nPanel == 17)	// Faturamento
					If VAL(SUA->UA_OPER) <> FATURAMENTO
						DbSkip()
						Loop
					Endif

				Case cPanel == P_TLV_CANCELADO .OR. (cPanel == "" .AND. nPanel == 18)	// Cancelado
					If SUA->UA_STATUS <> "CAN"
						DbSkip()
						Loop
					Endif

				Case cPanel == P_TLV_SIGALOJA .OR. (cPanel == "" .AND. nPanel == 19)	// SigaLoja
					If Empty(SUA->UA_NUMSL1)
						DbSkip()
						Loop
					Endif

				Case cPanel == P_TLV_BONUS .OR. (cPanel == "" .AND. nPanel == 20)	// Bonus
					lBonus := .F.
					DbSelectArea("SUB")
					DbSetOrder(1)

					#IFDEF TOP
						cQuery :=	" SELECT 	UB_FILIAL, UB_NUM, UB_TES " +;
									" FROM 		" + RetSqlName("SUB") +;
									" WHERE "   
									
						If lTodasFil .AND. X2ModAcess("SUB") == "E"
							cQuery += 	"	  	UB_FILIAL = '" + SUA->UA_FILIAL + "' AND " 
						Else
							cQuery += 	"	  	UB_FILIAL = '" + xFilial("SUB") + "' AND "
						EndIf
						
						cQuery += 	" 			UB_NUM = '" + SUA->UA_NUM + "' AND " +;
									" 			UB_TES = '" + cBonusTs + "' AND " +;
									" 			D_E_L_E_T_ = '' " +;
									" ORDER BY " + SqlOrder(IndexKey())
						
						cQuery := ChangeQuery(cQuery)
						// MemoWrite("TMKCFUN.SQL", cQuery)
						DbSelectArea("SUB")
						DbCloseArea()
						DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUB', .F., .T.)
					#ELSE
						DbSeek(xFilial("SUB") + SUA->UA_NUM)
					#ENDIF	

					While	!Eof() .AND. Eval(bEvFil2)	.AND.;
							SUB->UB_NUM == SUA->UA_NUM
				
						If SUB->UB_TES == cBonusTs
							lBonus := .T.				//  Bonus
							Exit
						Endif
				    	DbSkip()
				    End
				    
					#IFDEF TOP
						DbSelectArea("SUB")
						DbCloseArea()
						ChKFile("SUB")
					#ENDIF
					
					If !lBonus
						DbSelectArea("SUA")
						DbSkip()
						Loop
					Endif
			EndCase

			Do case
				Case SUA->UA_STATUS == "NF."
			  		 cDesc := STR0013 //"NF Emitida"
			
				Case SUA->UA_STATUS == "RM."
			  		 cDesc := STR0042 //"Merc.Enviada"
			
				Case SUA->UA_STATUS == "SUP"
			  		 cDesc := STR0014 //"Pedido Bloqueado"
			
				Case SUA->UA_STATUS == "CAN"
			  		 cDesc := STR0015 //"Cancelado"
			
				Case SUA->UA_STATUS == "LIB"
			  		 cDesc := STR0016 //"Liberado"
			  
				Otherwise
					 cDesc := STR0017 //"Or‡amento"
			Endcase

            cDescAux1 := ""
			Do Case
				Case VAL(SUA->UA_OPER) == ORCAMENTO
					cDescAux1 := STR0018             	// ORCAMENTO
					
				Case VAL(SUA->UA_OPER) == FATURAMENTO
					cDescAux1 := STR0019				// FATURAMENTO

				Case VAL(SUA->UA_OPER) == ATENDIMENTO					
					cDescAux1 := STR0008			 	// ATENDIMENTO
			Endcase
			
			cFilBk := cFilAnt
						
			If X2ModAcess("SUA") == "E" .AND. SUA->UA_FILIAL <> cFilant
				cFilAnt := SUA->UA_FILIAL
			EndIf
			                                         	
			AAdd(aDados, {	SUA->UA_NUM,;   															// 01 - Codigo
							Posicione("SU7",1,xFilial("SU7") + SUA->UA_OPERADO,"SU7->U7_NOME"),;		// 02 - Operador
							Posicione("DA0",1,xFilial("DA0") + SUA->UA_TABELA,"DA0->DA0_DESCRI"),;		// 03 - Tabela de Preco
							cDescAux1,; 																// 04 - Operacao (ORCAMENTO,FATURAMENTO,ATENDIMENTO)
							Posicione("SUH",1,xFilial("SUH") + SUA->UA_MIDIA,"SUH->UH_DESC"),;			// 05 - Midia de comunicacao
							Posicione("SA3",1,xFilial("SA3") + SUA->UA_VEND,"SA3->A3_NOME"),;			// 06 - Cadastro de vendedores
							SUA->UA_EMISSAO,;                                                           // 07 - Emissao
							Posicione("SUO",1,xFilial("SUO") + SUA->UA_CODCAMP,"SUO->UO_DESC"),;		// 08 - Descricao da Campanha
							Posicione("SU9",1,xFilial("SU9") + SUA->UA_CODLIG,"SU9->U9_DESC"),;		// 09 - Descricao da ocorrencias
							Posicione("SE4",1,xFilial("SE4") + SUA->UA_CONDPG,"SE4->E4_COND"),;		// 10 - Condicoes de pagamento
							Posicione("SX5",1,xFilial("SX5") + "24" + SUA->UA_FORMPG ,"X5DESCRI()"),;	// 11 - Forma de pagamento
							cDesc,;                                                                     // 12 - Status
							Posicione("SA4",1,xFilial("SA4") + SUA->UA_TRANSP,"SA4->A4_NOME"),;		// 13 - Condicoes de pagamento
							SUA->UA_FILIAL })															// 14 - Filial do sistema
			
			cFilAnt := cFilBk
			
			DbSelectArea("SUA")
			DbSkip()
		End
		#IFDEF TOP
			DbSelectArea("SUA")
			DbCloseArea()
			ChKFile("SUA")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF

	Case cAlias == "SF1"   
	
		DbSelectArea("SF1")
		DbSetOrder(2) //F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC

		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| SF1->F1_FILIAL  == xFilial("SF1") }
		#ENDIF

		#IFDEF TOP
			cQuery :=	" SELECT 	F1_FILIAL, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DOC, F1_SERIE, F1_EST," +;
						" F1_FRETE, F1_DESPESA,F1_VALMERC,F1_VALBRUT,F1_ESPECIE " +;
						" FROM 		" + RetSqlName("SF1") +;
						" WHERE "+;
						Iif(lTodasFil,"","F1_FILIAL = '" + xFilial("SF1") + "' AND ") +;
						" 			F1_FORNECE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
						" 			F1_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
						" 			F1_EMISSAO >= '" + DTOS(dCorte) + "' AND " +;
						"			F1_TIPO = 'D' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)

			DbSelectArea("SF1")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF1', .F., .T.)
			
			TCSetField('SF1', 'F1_EMISSAO', 'D')
		#ELSE
			If lTodasFil .AND. X2ModAcess("SF1") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
		   		DbSeek(xFilial("SF1") + aEmpCont[10][3])
		#ENDIF	

		While	!Eof() .AND. Eval(bEvFil) .AND.;
				AllTrim(SF1->F1_FORNECE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))		.AND.;
				AllTrim(SF1->F1_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))

			#IFNDEF TOP
				If SF1->F1_EMISSAO < dCorte
					DbSkip()
					Loop                                        
				Endif
				
				If SF1->F1_TIPO <> "D"
					DbSkip()
					Loop                                        
				Endif
			#ENDIF
			
			aAdd(aDados,{	SF1->F1_DOC		,;
							SF1->F1_SERIE	,;
							SF1->F1_EMISSAO	,;
							SF1->F1_EST		,;
							SF1->F1_FRETE	,;
							SF1->F1_DESPESA	,;
							SF1->F1_VALMERC	,;
							SF1->F1_VALBRUT	,;
							SF1->F1_ESPECIE	,;
							SF1->F1_FORNECE	,;
							SF1->F1_LOJA	,;
							SF1->F1_FILIAL	})
		
			SF1->(DbSkip())
		End
	
		#IFDEF TOP
			DbSelectArea("SF1")
			DbCloseArea()
			ChKFile("SF1")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF
	
	Case cAlias == "SF2"

		DbSelectArea("SF2")
		DbSetOrder(2)

		#IFDEF TOP
			bEvFil 	:= {|| .T. }
			bEvFil2	:= {|| .T. }
		#ELSE
			bEvFil 	:= {|| SF2->F2_FILIAL  == xFilial("SF2") }
			bEvFil2 := {|| SD2->D2_FILIAL  == xFilial("SD2") }
		#ENDIF

		#IFDEF TOP
			cQuery :=	" SELECT 	F2_FILIAL, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_DOC, F2_SERIE, F2_VEND1 " +;
						" FROM 		" + RetSqlName("SF2") +;
						" WHERE "+;
						Iif(lTodasFil,"","F2_FILIAL = '" + xFilial("SF2") + "' AND ") +;
						" 			F2_CLIENTE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
						" 			F2_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
						" 			F2_EMISSAO >= '" + DTOS(dCorte) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)

			DbSelectArea("SF2")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF2', .F., .T.)
			
			TCSetField('SF2', 'F2_EMISSAO', 'D')
		#ELSE
			If lTodasFil .AND. X2ModAcess("SF2") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
				DbSeek(xFilial("SF2") + aEmpCont[10][3])
		#ENDIF	
		
		While	!Eof() .AND. Eval(bEvFil) .AND.;
				AllTrim(SF2->F2_CLIENTE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))		.AND.;
				AllTrim(SF2->F2_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))

			#IFNDEF TOP
				If SF2->F2_EMISSAO < dCorte
					DbSkip()
					Loop                                        
				Endif
			#ENDIF
			
			DbSelectArea("SD2")
			DbSetOrder(3)
			#IFDEF TOP
				cQuery :=	" SELECT 	D2_FILIAL, D2_ITEM, D2_DOC, D2_SERIE, D2_COD, D2_QUANT, D2_UM, D2_PRCVEN " +;
							" FROM 		" + RetSqlName("SD2") +;
							" WHERE "
							
				If lTodasFil .AND. X2ModAcess("SD2") == "E"
					cQuery += "D2_FILIAL = '" + SF2->F2_FILIAL + "' AND " 
				Else
					cQuery += "D2_FILIAL = '" + xFilial("SD2") + "' AND "
				EndIf
							
				cQuery += 	" 			D2_DOC = '" + SF2->F2_DOC + "' AND " +;
							" 			D2_SERIE = '" + SF2->F2_SERIE + "' AND " +;
							" 			D_E_L_E_T_ = '' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
				// MemoWrite("TMKCFUN.SQL", cQuery)
				DbSelectArea("SD2")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SD2', .F., .T.)
				
				TCSetField('SD2', 'D2_QUANT', 'N', 11, 2)
				TCSetField('SD2', 'D2_PRCVEN', 'N', 14, 2)
			#ELSE
				MsSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
			#ENDIF	

			While	!Eof() .AND. Eval(bEvFil2) .AND.;
					SD2->D2_DOC    == SF2->F2_DOC 		.AND.;
					SD2->D2_SERIE  == SF2->F2_SERIE
				
				cFilBk := cFilAnt
				
				If X2ModAcess("SD2") == "E" .AND. SD2->D2_FILIAL <> cFilant
					cFilAnt := SD2->D2_FILIAL
				EndIf

				nPosProd := Ascan(aDados, {|x| x[1] == SD2->D2_COD .AND. x[9] == SD2->D2_FILIAL} )
				
				If nPosProd > 0
					aDados[nPosProd][4] += SD2->D2_QUANT				// Quantidade

					If aDados[nPosProd][6] < SF2->F2_EMISSAO
						aDados[nPosProd][3] := SD2->D2_UM									// Unidade de Medida
						aDados[nPosProd][5] := Transform(SD2->D2_PRCVEN, "@E 999,999.99")	// Ultimo preco realizado
						aDados[nPosProd][6] := SF2->F2_EMISSAO								// Ultima compra

						If aDados[nPosProd][7] <> SF2->F2_VEND1
							aDados[nPosProd][7] := SF2->F2_VEND1							// Ultimo vendedor
							aDados[nPosProd][8] := Posicione("SA3",1,xFilial("SA3") + SF2->F2_VEND1,"SA3->A3_NOME")		// Nome do ultimo vendedor
						Endif
					Endif

				Else
					AAdd(aDados, {	SD2->D2_COD,;														// 01 - Codigo do Produto
									Posicione("SB1",1,xFilial("SB1") + SD2->D2_COD,"SB1->B1_DESC"),;	// 02 - Descricao do produto
									SD2->D2_UM,;														// 03 - Unidade de Medida
									SD2->D2_QUANT,;														// 04 - Quantidade
									Transform(SD2->D2_PRCVEN, "@E 999,999.99"),;						// 05 - Ultimo preco realizado
									SF2->F2_EMISSAO,;													// 06 - Ultima Compra
									SF2->F2_VEND1,;														// 07 - Ultimo vendedor
									Posicione("SA3",1,xFilial("SA3") + SF2->F2_VEND1,"SA3->A3_NOME"),;	// 08 - Cadastro de vendedores
									SD2->D2_FILIAL													})	// 09 - Filial
			    Endif
				
				cFilAnt := cFilBk
				
				DbSelectArea("SD2")
				DbSkip()
			End
			#IFDEF TOP
				DbSelectArea("SD2")
				DbCloseArea()
				ChKFile("SD2")
			#ENDIF
			Asort( aDados,,, { |x,y| x[4] > y[4] } )
		
			DbSelectArea("SF2")
			DbSkip()
		End
		
		#IFDEF TOP
			DbSelectArea("SF2")
			DbCloseArea()
			ChKFile("SF2")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF
		
	Case cAlias == "ACF"

		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| ACF->ACF_FILIAL  == xFilial("ACF") }
		#ENDIF

		DbSelectArea("ACF")
		DbSetOrder(2)
		#IFDEF TOP
			cQuery :=	" SELECT 	ACF_FILIAL, ACF_CLIENT, ACF_LOJA, ACF_CODCON, ACF_CODIGO, ACF_DATA,  " +;
						" 			ACF_PENDEN, ACF_HRPEND, ACF_OPERA, ACF_OPERAD, ACF_MOTIVO " +;
						" FROM 		" + RetSqlName("ACF") +; 
						" WHERE "+;
						Iif(lTodasFil,"","ACF_FILIAL = '" + xFilial("ACF") + "' AND ") +;
						Iif(Trim(aEmpCont[1][3])=="",""," 			ACF_CODCON = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
						" 			ACF_CLIENT = '" + SubStr(ALLTRIM(aEmpCont[10][3]),1,TamCdCli) + "' AND " +;
						" 			ACF_LOJA = '" + SubStr(ALLTRIM(aEmpCont[10][3]),TamCdCli+1,TamCdLoj) + "' AND " +;
						" 			ACF_DATA >= '" + DTOS(dCorte) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("ACF")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACF', .F., .T.)
			
			TCSetField("ACF", "ACF_DATA", "D")
			TCSetField("ACF", "ACF_PENDEN", "D")
		#ELSE
			If lTodasFil .AND. X2ModAcess("ACF") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
		   		DbSeek(xFilial("ACF") + aEmpCont[10][3])
		#ENDIF
			
		While	!Eof() .AND. Eval(bEvFil) .AND.;
				ACF->ACF_CLIENT == SubStr(aEmpCont[10][3],1,6)	.AND.;
				ACF->ACF_LOJA   == SubStr(aEmpCont[10][3],7,2)
			
			#IFNDEF TOP
				If ACF->ACF_CODCON <> aEmpCont[1][3] .AND. Trim(aEmpCont[1][3])<>"" // Quando perfil do cliente totaliza por todos.
					DbSkip()
					Loop
				Endif
				
				If ACF->ACF_DATA < dCorte
					DbSkip()
					Loop
				Endif
			#ENDIF
			
			If (cPanel == P_TLC_NEGOCIA .OR. (cPanel == "" .AND. nPanel == 26)) .AND. Empty(ACF->ACF_PENDEN)
				DbSkip()
				Loop
			Endif
			
			If (cPanel == P_TLC_OCORR .OR. (cPanel == "" .AND. nPanel == 27))  .AND. Ascan(aFiltro, {|x| x[1] == ACF->ACF_FILIAL .AND. x[2] == ACF->ACF_CODIGO} ) == 0
				DbSkip()
				Loop
			Endif

			If (cPanel == P_TLC_VENCIDA .OR. (cPanel == "" .AND. nPanel == 28)) .AND. ACF->ACF_PENDEN > dDataBase
				DbSkip()
				Loop
			Endif

			cDescAux1 := ""
			If ACF->ACF_OPERA == "1" 		//Ativo
				cDescAux1 := STR0001
			Else
				cDescAux1 := STR0002		//Receptivo 
			Endif	
			
			cFilBk := cFilAnt
			
			If X2ModAcess("ACF") == "E" .AND. ACF->ACF_FILIAL <> cFilant
				cFilAnt := ACF->ACF_FILIAL
			EndIf

			AAdd(aDados,{	ACF->ACF_CODIGO,;												  		// 01 - Codigo da cobranca
							ACF->ACF_DATA,;													   		// 02 - Data
							DTOC(ACF->ACF_PENDEN),;											   		// 03 - Retorno
							ACF->ACF_HRPEND,;												   		// 04 - Hora retorno
							cDescAux1,;														   		// 05 - Operacao (ATIVO,RECEPTIVO)
							ACF->ACF_OPERAD,;												   		// 06 - Nome do Operador
							Posicione("SU7",1,XFILIAL("SU7") + ACF->ACF_OPERAD,"SU7->U7_NOME"),;	// 07 - Nome operador
							ACF->ACF_MOTIVO,;												  		// 08 - Codigo da Ocorrencia
							Posicione("SU9",1,XFILIAL("SU9") + ACF->ACF_MOTIVO,"SU9->U9_DESC"),;	// 09 - Descricao da Ocorrencia
							ACF->ACF_FILIAL	})														// 10 - Filial
			
			cFilAnt := cFilBk
			
			DbSelectArea(cAlias)
			DbSkip()
		End
		#IFDEF TOP
			DbSelectArea("ACF")
			DbCloseArea()
			ChKFile("ACF")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF

	Case cAlias == "ACG" 
	
		#IFDEF TOP
			bEvFil  := {|| .T. }
			bEvFil2 := {|| .T. }
		#ELSE
			bEvFil  := {|| ACF->ACF_FILIAL == xFilial("ACF") }
			bEvFil2 := {|| ACG->ACG_FILIAL == xFilial("ACG") }
		#ENDIF

		DbSelectArea("ACF")
		DbSetOrder(2)

		#IFDEF TOP
			cQuery :=	" SELECT 	ACF_FILIAL, ACF_CLIENT, ACF_LOJA, ACF_CODCON, ACF_DATA, ACF_CODIGO " +;
						" FROM 		" + RetSqlName("ACF") +;
						" WHERE "+;
						Iif(lTodasFil,"","ACF_FILIAL = '" + xFilial("ACF") + "' AND ") +;
						Iif(Trim(aEmpCont[1][3])=="",""," 			ACF_CODCON = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
						" 			ACF_CLIENT = '" + SubStr(ALLTRIM(aEmpCont[10][3]),1,TamCdCli) + "' AND " +;
						" 			ACF_LOJA = '" + SubStr(ALLTRIM(aEmpCont[10][3]),TamCdCli+1,TamCdLoj) + "' AND " +;
						" 			ACF_DATA >= '" + DTOS(dCorte) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("ACF")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACF', .F., .T.)
			
			TCSetField('ACF', 'ACF_DATA', 'D')
		#ELSE
			If lTodasFil .AND. X2ModAcess("ACF") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
				DbSeek(xFilial("ACF") + aEmpCont[10][3])		// Cliente + Loja
		#ENDIF	
		
		While	!Eof() .AND. Eval(bEvFil) .AND.;
				ACF->ACF_CLIENT == SubStr(aEmpCont[10][3],1,6)	.AND.;
				ACF->ACF_LOJA   == SubStr(aEmpCont[10][3],7,2)

			#IFNDEF TOP
				If ACF->ACF_CODCON <> aEmpCont[1][3] .AND. Trim(aEmpCont[1][3])<>"" // Quando perfil do cliente totaliza por todos.
					DbSkip()
					Loop
				Endif
				
				If ACF->ACF_DATA < dCorte
					DbSkip()
					Loop
				Endif
            #ENDIF
            
			DbSelectArea("ACG")
			DbSetOrder(1)
			#IFDEF TOP
				cQuery :=	" SELECT 	ACG_FILIAL, ACG_CODIGO, ACG_TITULO, ACG_PREFIX, ACG_PARCEL, ACG_TIPO, ACG_NATURE, " +;
							" 			ACG_DTVENC, ACG_DTREAL, ACG_VALOR, ACG_ACRESC, ACG_DECRES, ACG_STATUS, ACG_OPERAD " +;
							" FROM 		" + RetSqlName("ACG") +;
							" WHERE "
							
				If lTodasFil .AND. X2ModAcess("ACG") == "E"
					cQuery += 	"  	ACG_FILIAL = '" + ACF->ACF_FILIAL + "' AND " 
				Else
					cQuery += 	"  	ACG_FILIAL = '" + xFilial("ACG") + "' AND "
				EndIf
				
				cQuery += 	" 		ACG_CODIGO = '" + ACF->ACF_CODIGO + "' AND " +;
							" 		D_E_L_E_T_ = '' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
				// MemoWrite("TMKCFUN.SQL", cQuery)
				DbSelectArea("ACG")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACG', .F., .T.)
				
				TCSetField('ACG', 'ACG_DTVENC', 'D')
				TCSetField('ACG', 'ACG_DTREAL', 'D')
				TCSetField('ACG', 'ACG_VALOR', 'N', 9, 2)
				TCSetField('ACG', 'ACG_ACRESC', 'N', 9, 2)
				TCSetField('ACG', 'ACG_DECRES', 'N', 9, 2)
			#ELSE
				MsSeek(xFilial("ACG") + ACF->ACF_CODIGO)
			#ENDIF	
			While	!Eof() .AND. Eval(bEvFil2)	.AND.;
					ACG->ACG_CODIGO == ACF->ACF_CODIGO
				
				nPosTitulo := Ascan(aDados, {|x| x[1] == ACG->ACG_TITULO} )
				If nPosTitulo > 0
					AAdd(aDados[nPosTitulo][len(aDados[1])], ACF->ACF_CODIGO)
				Else

                    cDescAux1 := ""
					Do Case	
						Case ACG->ACG_STATUS == "1"
							cDescAux1 := STR0020		//PAGO

						Case ACG->ACG_STATUS == "2"
							cDescAux1 := STR0021 		//NEGOCIADO
							
						Case ACG->ACG_STATUS == "3"	
							cDescAux1 := STR0022		//CARTORIO
					Endcase
					
					cFilBk := cFilAnt
					
					If X2ModAcess("ACG") == "E" .AND. ACG->ACG_FILIAL <> cFilant
						cFilAnt := ACG->ACG_FILIAL
					EndIf
										
					cDescAux2 := ""
					cDescAux2 := Posicione("SU7",1,xFilial("SU7") + ACG->ACG_OPERAD,"SU7->U7_NOME")		
 	
					AAdd(aDados, {	ACG->ACG_PREFIX,;									// 01-Prefixo
									ACG->ACG_TITULO,;									// 02-Numero do titulo
									ACG->ACG_PARCEL,;									// 03-Parcela
									ACG->ACG_TIPO,;										// 04-Tipo
									ACG->ACG_NATURE,;									// 05-Natureza
									DTOC(ACG->ACG_DTVENC),;								// 06-Vencimento
									DTOC(ACG->ACG_DTREAL),;								// 07-Vencimento real
									Transform(ACG->ACG_VALOR, "@E 999,999.99"),;		// 08-Valor
									Transform(ACG->ACG_ACRESC, "@E 999,999.99"),;		// 09-Acrescimo
									Transform(ACG->ACG_DECRES, "@E 999,999.99"),;		// 10-Desconto
									cDescAux1,;											// 11-Status (PAGO,NEGOCIADO,CARTORIO)
									ACG->ACG_OPERAD,;									// 12-Responsavel
									cDescAux2,;											// 13-Nome do operador
									{{ACG->ACG_FILIAL, ACF->ACF_CODIGO}},;				// 14-Todos os codigos de cobranca deste titulo
									ACG->ACG_FILIAL })									// 15-Filial do sistema

					cFilAnt := cFilBk
					
			    Endif

				DbSelectArea("ACG")
				DbSkip()
            End
			#IFDEF TOP
				DbSelectArea("ACG")
				DbCloseArea()
				ChKFile("ACG")
			#ENDIF
            
        	DbSelectArea("ACF")
        	DbSkip()
		End
		
		#IFDEF TOP
			DbSelectArea("ACF")
			DbCloseArea()
			ChKFile("ACF")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF
		
		Asort( aDados,,, { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )

	Case cAlias == "SE1"

		DbSelectArea("SE1")
		DbSetOrder(2)

		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| SE1->E1_FILIAL  == xFilial("SE1") }
		#ENDIF

		#IFDEF TOP
			cQuery :=	"SELECT	E1_BAIXA, E1_CLIENTE, E1_DATABOR, E1_EMISSAO, E1_FILIAL, E1_IRRF, E1_ISS, " +;
						" 		E1_LOJA, E1_NATUREZ, E1_NUM, E1_NUMBOR, E1_PARCELA, E1_PORTADO, E1_PREFIXO, " +;
						" 		E1_SALDO, E1_SITUACA, E1_TIPO, E1_VALOR, E1_VENCORI, E1_VENCREA, E1_VENCTO " +;
						" FROM " + RetSqlName("SE1") +;
						" WHERE "+;
						Iif(lTodasFil,"","E1_FILIAL = '" + xFilial("SE1") + "' AND ") +;
						" 		E1_CLIENTE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
						" 		E1_LOJA    = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
						" 		E1_VENCREA >= '" + DTOS(dCorte) + "' AND " +;
						" 		D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)

			DbSelectArea("SE1")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)
			
			TCSetField("SE1", "E1_VENCREA"	, "D")
			TCSetField("SE1", "E1_BAIXA"	, "D")
			TCSetField("SE1", "E1_DATABOR"	, "D")
			TCSetField("SE1", "E1_EMISSAO"	, "D")
			TCSetField("SE1", "E1_VENCORI"	, "D")
			TCSetField("SE1", "E1_VENCTO"	, "D")
			TCSetField("SE1", "E1_IRRF"		, "N", 14, 2)
			TCSetField("SE1", "E1_ISS"		, "N", 14, 2)
			TCSetField("SE1", "E1_SALDO"	, "N", 14, 2)
			TCSetField("SE1", "E1_VALOR"	, "N", 14, 2)
		#ELSE
			If lTodasFil .AND. X2ModAcess("SE1") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
				DbSeek(xFilial("SE1") + aEmpCont[10][3])	// Cliente + Loja
		#ENDIF	
		
		While	!Eof() .AND. Eval(bEvFil) .AND.;
				AllTrim(SE1->E1_CLIENTE) == AllTrim(SubStr(aEmpCont[10][3],1,TamCdCli))	.AND.;
				AllTrim(SE1->E1_LOJA)    == AllTrim(SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para que o usuario desconsidere algum registro do SE1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFiltSE1

				lRetPe := ExecBlock("TK10CSE1", .F., .F., {nPanel} )

				If ValType(lRetPe) == "L" .AND. !lRetPe
					DbSkip()
					Loop
				EndIf

			EndIf
			
			#IFNDEF TOP
				If SE1->E1_EMISSAO < dCorte
					DbSkip()
					Loop
				Endif
			#ENDIF
		    
			Do Case
				Case cPanel == P_ANF_VENCIDO .OR. (cPanel == "" .AND. nPanel == 31)
					If SE1->E1_VENCREA >= dDataBase	// Nao Vencidos
						DbSkip()
						Loop
					Endif

				Case cPanel == P_ANF_VENCER .OR. (cPanel == "" .AND. nPanel == 32)
					If SE1->E1_VENCREA < dDataBase	// Nao A Vencer
						DbSkip()
						Loop
					Endif

				Case cPanel == P_ANF_ATRASO .OR. (cPanel == "" .AND. nPanel == 33)
					If SE1->E1_BAIXA <= SE1->E1_VENCREA		// Nao Pago com atraso
						DbSkip()
						Loop
					Endif

				Case cPanel == P_ANF_CARTORIO .OR. (cPanel == "" .AND. nPanel == 34)
					If SE1->E1_SITUACA <> "6" .OR. Empty(SE1->E1_BAIXA)	// Nao pago em cartorio
						DbSkip()
						Loop
					Endif

				Case cPanel == P_ANF_PROTESTADO .OR. (cPanel == "" .AND. nPanel == 35)
					If SE1->E1_SITUACA <> "6"	// Nao protestado
						DbSkip()
						Loop
					Endif

				Case cPanel == P_ANF_NCC .OR. (cPanel == "" .AND. nPanel == 37)
					If SE1->E1_TIPO <> "NCC" .OR. (SE1->E1_TIPO == "NCC" .AND. SE1->E1_SALDO <= 0)	// Nao se trata de NCC ou a NCC nao possui saldo
						DbSkip()
						Loop
					Endif

			End Case
			
			DbSelectArea("SED")
			DbSetOrder(1)

			If X2ModAcess("SED") == "E"
				DbSeek(SE1->E1_FILIAL + SE1->E1_NATUREZ)
			Else
				DbSeek(xFilial("SED") + SE1->E1_NATUREZ)
			EndIf
			
			DbSelectArea("SA6")
			DbSetOrder(1)
			
			If X2ModAcess("SA6") == "E"
				DbSeek(SE1->E1_FILIAL + SE1->E1_PORTADO)
			Else
				DbSeek(xFilial("SE6") + SE1->E1_PORTADO)
			EndIf			
			
			AAdd(aDados, {	SE1->E1_PREFIXO,;
							SE1->E1_NUM,;
							SE1->E1_PARCELA,;
							SE1->E1_TIPO,;
							SE1->E1_NATUREZ,;
							SED->ED_DESCRIC,;
							SE1->E1_PORTADO,;
							SA6->A6_NOMEAGE,;
							DTOC(SE1->E1_EMISSAO),;
							DTOC(SE1->E1_VENCTO),;
							DTOC(SE1->E1_VENCREA),;
							DTOC(SE1->E1_VENCORI),;
							Transform(SE1->E1_VALOR	, "@E 999,999.99"),;
							Transform(SE1->E1_SALDO	, "@E 999,999.99"),;
							Transform(SE1->E1_IRRF	, "@E 999,999.99"),;
							Transform(SE1->E1_ISS	, "@E 999,999.99"),;
							SE1->E1_NUMBOR,;
							DTOC(SE1->E1_DATABOR),;
							SE1->E1_FILIAL	})

			DbSelectArea("SE1")
			DbSkip()
		End
		#IFDEF TOP
			DbSelectArea("SE1")
			DbCloseArea()
			ChKFile("SE1")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF

	Case cAlias == "ACI"

		If lTodasFil .AND. X2ModAcess("ACI") == "E"
		    aFiliais := aFils
		Else
			aFiliais := {cFilAnt}
		EndIf
		
		For nX := 1 to Len(aFiliais)
			
			cFilAnt := aFiliais[nX]
			
			DbSelectArea("ACI")
			DbSetOrder(2) 
			
			#IFDEF TOP
				cQuery :=	" SELECT 	ACI_FILIAL, ACI_CODCON, ACI_ENTIDA, ACI_CHAVE, ACI_DATA, ACI_CODCAM " +;
							" FROM 		" + RetSqlName("ACI") +;
							" WHERE 	ACI_FILIAL = '" + xFilial("ACI") + "' AND " +;
							" 			ACI_ENTIDA = '" + aEmpCont[9][3] + "' AND " +;
							" 			ACI_CHAVE = '" + aEmpCont[10][3] + "' AND " +;
							" 			ACI_DATA >= '" + DTOS(dCorte) + "' AND " +;
							Iif(Trim(aEmpCont[1][3])=="",""," 			ACI_CODCON = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
							" 			D_E_L_E_T_ = '' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
				// MemoWrite("TMKCFUN.SQL", cQuery)
				DbSelectArea("ACI")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACI', .F., .T.)
				
				TCSetField('ACI', 'ACI_DATA', 'D')
			#ELSE
				If Trim(aEmpCont[1][3])<>""
					MsSeek(xFilial(cAlias) + aEmpCont[1][3] + aEmpCont[9][3] + aEmpCont[10][3])
				EndIf
			#ENDIF	
	
			While	!Eof()								.AND.;
					ACI->ACI_FILIAL == xFilial(cAlias) 	.AND.;
					Iif(Trim(aEmpCont[1][3])<>"" ,ACI->ACI_CODCON == aEmpCont[1][3],.T.) .AND.;
					ACI->ACI_ENTIDA == aEmpCont[9][3] 	.AND.;
					ALLTRIM(ACI->ACI_CHAVE) == aEmpCont[10][3]
				
				#IFNDEF TOP
					If ACI->ACI_DATA < dCorte
						DbSkip()
						Loop
					Endif
				#ENDIF
				
				nPosCamp := Ascan(aDados, {|x| x[1] == ACI->ACI_CODCAM .AND. x[21] == xFilial("SUO")} )
				
				If nPosCamp == 0
					DbSelectArea("SUO")
					DbSetORder(1)
					If DbSeek(xFilial("SUO") + ACI->ACI_CODCAM)
	
						AAdd(aDados, {	SUO->UO_CODCAMP,;
										SUO->UO_DESC,;
										SUO->UO_OBJETIV,;
										DTOC(SUO->UO_DTINI),;
										DTOC(SUO->UO_DTFIM),;
										SUO->UO_TIPO,;
										SUO->UO_ATENDIM,;
										SUO->UO_PUBALVO,;
										Posicione("SX5",1,xFilial("SX5")+"T6"+SUO->UO_PUBALVO,"X5DESCRI()"),;
										SUO->UO_RESP,;
										SUO->UO_COORDEN,;
										SUO->UO_DEPTO,;
										Transform(SUO->UO_META  	, "@E 999.99"),;
										Transform(SUO->UO_METAOP	, "@E 999.99"),;
										Transform(SUO->UO_CUSTO 	, "@E 999,999.99"),;
										Transform(SUO->UO_PREVEND	, "@E 999,999.99"),;
										Transform(SUO->UO_RETORNO	, "@E 999,999.99"),;
										Transform(SUO->UO_PRELEAD	, "@E 999.99"),;
										Transform(SUO->UO_TOTSUC	, "@E 999.99"),;
										Transform(SUO->UO_TOTFRA	, "@E 999.99"),;
										SUO->UO_FILIAL							 })
					Endif
				Endif
				
				DbSelectArea(cAlias)
				DbSkip()
			End
			#IFDEF TOP
				DbSelectArea("ACI")
				DbCloseArea()
				ChKFile("ACI")
			#ENDIF
        
		Next nX           
		
		cFilAnt := cFilAtu

	Case cAlias == "SU4"
	
		DbSelectArea("SU4")
		DbSetOrder(3)	//U4_FILIAL+DTOS(U4_DATA)+U4_STATUS
		DbSeek(xFilial("SU4"))

		#IFDEF TOP
			bEvFil 	:= {|| .T. }
			bEvFil2	:= {|| .T. }
		#ELSE
			bEvFil 	:= {|| SU4->U4_FILIAL == xFilial("SU4") }
			bEvFil2 := {|| SU6->U6_FILIAL == xFilial("SU6") }
		#ENDIF
		
		#IFDEF TOP
			cQuery :=	" SELECT 	U4_FILIAL, U4_DATA, U4_LISTA, U4_FORMA, U4_TIPOTEL, U4_DESC, U4_TIPO, " +;
						" 			U4_OPERAD, U4_CONFIG, U4_TIPOEND, U4_MALADIR, U4_LABEL, U4_ETIQUET, " +;
						" 			U4_CODCAMP, U4_SCRIPT, U4_EVENTO, U4_ASSUNTO " +;
						" FROM 		" + RetSqlName("SU4") +;
						" WHERE "+;
						Iif(lTodasFil,"","U4_FILIAL = '" + xFilial("SU4") + "' AND ") +;
						" 			U4_DATA >= '" + DTOS(dCorte) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("SU4")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU4', .F., .T.)
			
			TCSetField("SU4", "U4_DATA", "D")
		#ELSE

			If lTodasFil .AND. X2ModAcess("SU4") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
		  		DbSeek(xFilial("SU4") + DTOS(dCorte), .T.)
		#ENDIF	

		While	!Eof() .AND. Eval(bEvFil) .AND.;
				SU4->U4_DATA   >= dCorte
			
			DbSelectArea("SU6")
			DbSetOrder(1)
			#IFDEF TOP
				cQuery :=	" SELECT 	U6_FILIAL, U6_LISTA, U6_CONTATO, U6_ENTIDA, U6_CODENT, U6_CONTATO " +;
							" FROM 		" + RetSqlName("SU6") +;
							" WHERE "
	
				If lTodasFil .AND. X2ModAcess("SU6") == "E"
					cQuery += "U6_FILIAL = '" + SU4->U4_FILIAL + "' AND " 
				Else
					cQuery += "U6_FILIAL = '" + xFilial("SU6") + "' AND "
				EndIf							
							
				cQuery +=	" 			U6_LISTA = '" + SU4->U4_LISTA + "' AND " +;
							Iif(Trim(aEmpCont[1][3])=="",""," 			U6_CONTATO = '" + ALLTRIM(aEmpCont[1][3]) + "' AND ") +;
							" 			U6_ENTIDA = '" + ALLTRIM(aEmpCont[9][3]) + "' AND " +;
							" 			U6_CODENT = '" + ALLTRIM(aEmpCont[10][3]) + "' AND " +;
							" 			D_E_L_E_T_ = '' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
				// MemoWrite("TMKCFUN.SQL", cQuery)
				DbSelectArea("SU6")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SU6", .F., .T.)
			#ELSE
				MsSeek(xFilial("SU6") + SU4->U4_LISTA)
			#ENDIF	

			While	!Eof() .AND. Eval(bEvFil2) .AND.;
		    		SU6->U6_LISTA == SU4->U4_LISTA
				
				If	(SU6->U6_CONTATO == aEmpCont[1][3] .OR. Trim(aEmpCont[1][3])=="")	.AND.;
					SU6->U6_ENTIDA == aEmpCont[9][3] 	.AND.;
					ALLTRIM(SU6->U6_CODENT) == ALLTRIM(aEmpCont[10][3])
					
					If cPanel == P_CONT_RESULTADO .OR. (cPanel == "" .AND. nPanel == 46)
						DbSelectArea("SU8")
						DbSetOrder(1)
						If !MsSeek(xFilial("SU8") + SU4->U4_LISTA + SU6->U6_CONTATO)
							DbSelectArea("SU4")
							DbSkip()
							Exit
						Endif
					Endif
					
					Do Case
						Case Val(SU4->U4_FORMA) == VOZ
							cForma := STR0024 //"Voz"

						Case Val(SU4->U4_FORMA) ==  2		// Tipo fax e mantido apenas para comp. ver 7.10
							cForma := STR0025 //"Fax"

						Case Val(SU4->U4_FORMA) == CROSSPOSTING
							cForma := STR0026 //"Cross Posting"

						Case Val(SU4->U4_FORMA) == MALADIRETA
							cForma := STR0027 //"Mala Direta"

						Case Val(SU4->U4_FORMA) == PENDENCIA
							cForma := STR0028 //"Pendencia"

						Case Val(SU4->U4_FORMA) == WEBSITE
							cForma := STR0029 //"Website"
					EndCase
					
					Do Case
						Case SU4->U4_TIPOTEL == "1"
							cTpFone := STR0030 //"Residencial"

						Case SU4->U4_TIPOTEL == "2"
							cTpFone := STR0031 //"Celular"

						Case SU4->U4_TIPOTEL == "3"
							cTpFone := STR0025 //"Fax"

						Case SU4->U4_TIPOTEL == "4"
							cTpFone := STR0032 //"Comercial 1"

						Case SU4->U4_TIPOTEL == "5"
							cTpFone := STR0033 //"Comercial 2"
					
					EndCase
					

					cDescAux1 := ""
					Do Case
						Case (SU4->U4_TIPO == "1")
							cDescAux1 := STR0034	// MARKETING	

						Case (SU4->U4_TIPO == "2")
							cDescAux1 := STR0035	// COBRANCA

						Case (SU4->U4_TIPO == "3")
							cDescAux1 := "VENDAS"	// VENDAS
					Endcase
                    
                    cDescAux2 := ""                     
					cDescAux2 := Posicione("SU7",1,xFilial("SU7") + SU4->U4_OPERAD,"SU7->U7_NOME")
					
					cDescAux3 := ""
					If SU4->U4_TIPOEND == "1" 
						cDescAux3 := STR0030	//"residencial"
					Else
						cDescAux3 := STR0036 	//"comercial"	
					Endif
					
					cDescAux4 := ""
					If SU4->U4_LABEL == "1"
						cDescAux4 := STR0010	//"sim"
					Else
						cDescAux4 := STR0011	//"nao"	
					Endif	

					AAdd(aDados, {	SU4->U4_LISTA,;						// 01 - Codigo da Lista de contato
									SU4->U4_DESC,;						// 02 - Descricao da Lista
									DTOC(SU4->U4_DATA),;				// 03 - Data da Lista
									cDescAux1,; 						// 04 - Tipo da Lista (MARKETING,COBRANCA)
									cForma,;							// 05 - Forma de contato da Lista 
									SU4->U4_OPERAD,;					// 06 - Codigo do Operador
									cDescAux2,;							// 07 - Nome do operador
									SU4->U4_CONFIG,;					// 08 - Codigo da configuracao de TMK
									cTpFone,;							// 09 - Tipo de Telefone			
									cDescAux3,; 						// 10 - Endereco (RESIDENCIAL/COMERCIAL)
									SU4->U4_MALADIR,;					// 11 - Mala direta	
									cDescAux4,; 						// 12 - Gera Etiqueta (SIM,NAO)
									SU4->U4_ETIQUET,;					// 13 - Nome da Etiqueta
									SU4->U4_CODCAMP,;					// 14 - Codigo da Campanha
									SU4->U4_SCRIPT,;					// 15 - Codigo do Script
									SU4->U4_EVENTO,;					// 16 - Codigo do Evento
									SU4->U4_ASSUNTO,;					// 17 - Assunto do email
									SU4->U4_FILIAL	})					// 18 - Filial
					// Se os itens tem o contato e a entidade entao carrega a cabeca e para de ler os itens
					Exit	
				Endif

				DbselectArea("SU6")
				DbSkip()
			End
			
			DbselectArea("SU4")
			DbSkip()
			
			#IFDEF TOP
				DbSelectArea("SU6")
				DbCloseArea()
				ChKFile("SU6")
			#ENDIF
		End

		AAdd(aDados, {	CRIAVAR("U4_LISTA"	,.F.),;			// 01 - Codigo da Lista de contato
						CRIAVAR("U4_DESC"	,.F.),;			// 02 - Descricao da Lista
						CRIAVAR("U4_DATA"	,.F.),;			// 03 - Data da Lista
						CRIAVAR("U4_TIPO"	,.F.),;			// 04 - Tipo da Lista (MARKETING,COBRANCA)
						CRIAVAR("U4_FORMA"	,.F.),;			// 05 - Forma de contato da Lista 
						CRIAVAR("U4_OPERAD"	,.F.),;			// 06 - Codigo do Operador
						CRIAVAR("U7_NOME"	,.F.),;			// 07 - Nome do operador
						CRIAVAR("U4_CONFIG"	,.F.),;			// 08 - Codigo da configuracao de TMK
						CRIAVAR("U4_TIPOTEL",.F.),;			// 09 - Tipo de Telefone			
						CRIAVAR("U4_TIPOEND",.F.),;			// 10 - Endereco (RESIDENCIAL/COMERCIAL)
						CRIAVAR("U4_MALADIR",.F.),;			// 11 - Mala direta	
						CRIAVAR("U4_LABEL"	,.F.),;			// 12 - Gera Etiqueta (SIM,NAO)
						CRIAVAR("U4_ETIQUET",.F.),;			// 13 - Nome da Etiqueta
						CRIAVAR("U4_CODCAMP",.F.),;			// 14 - Codigo da Campanha
						CRIAVAR("U4_SCRIPT"	,.F.),;			// 15 - Codigo do Script
						CRIAVAR("U4_EVENTO"	,.F.),;			// 16 - Codigo do Evento
						CRIAVAR("U4_ASSUNTO",.F.),;			// 17 - Assunto do email
						CRIAVAR("U4_FILIAL" ,.F.)})			// 18 - Filial
						
		#IFDEF TOP
			DbSelectArea("SU4")
			DbCloseArea()
			ChKFile("SU4")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF

	Case cAlias == "SU6"
	
		DbSelectArea("SU4")
		DbSetOrder(1) //U4_FILIAL+U4_LISTA+DTOS(U4_DATA)
		If DbSeek(xFilial("SU4") + cFiltro )
			
			DbSelectArea("SU6")
			DbSetOrder(1)	//U6_FILIAL+U6_LISTA+U6_CODIGO
			#IFDEF TOP
				cQuery :=	" SELECT U6_FILIAL, U6_LISTA, U6_ENTIDA, U6_CODIGO, U6_ORIGEM, U6_CONTATO, U6_DATA, U6_HRINI, U6_HRFIM, U6_STATUS " +;
							" FROM 	 " + RetSqlName("SU6") +;
							" WHERE  U6_FILIAL = '" + xFilial("SU6") + "' AND " +;
							" 		 U6_LISTA = '" + SU4->U4_LISTA + "' AND " +;
							" 		 D_E_L_E_T_ = '' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
				// MemoWrite("TMKCFUN.SQL", cQuery)
				DbSelectArea("SU6")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SU6", .F., .T.)
				
				TCSetField("SU6", "U6_DATA", "D")
			#ELSE

				MsSeek(xFilial("SU6") + cFiltro )
			
			#ENDIF	
			While	!Eof()								.AND.;
			    	SU6->U6_FILIAL == xFilial(cAlias)	.AND.;
			    	SU6->U6_LISTA == SU4->U4_LISTA
				
				cNomeEnt := ""
				cNomeEnt := ALLTRIM(Posicione("SX2",1,ALLTRIM(SU6->U6_ENTIDA),"X2NOME()"))
				cNomeEnt := SubStr(cNomeEnt,13,LEN(cNomeEnt)-13)

				cDescAux1 := ""
				Do Case
					case SU6->U6_ORIGEM == "1"
						cDescAux1 := STR0037		//"Lista"

					case SU6->U6_ORIGEM =="2"
						cDescAux1 :=  STR0038		//"Manual"
						
					case SU6->U6_ORIGEM =="2"
						cDescAux1 :=  STR0008		//"Atendimento"
				Endcase

				cDescAux2 := ""
				Do Case
					case SU6->U6_STATUS == "1"
						cDescAux2 := STR0039		//"Nao Enviado"

					case SU6->U6_STATUS == "2"
						cDescAux2 :=  STR0040		//"Em Uso"
						
					case SU6->U6_STATUS == "3"
						cDescAux2 :=  STR0041		//"Enviado"
				Endcase

				AAdd(aDados, {	SU6->U6_CODIGO,;		// 01 - Codigo do item da Lista
								cNomeEnt,;				// 02 - Nome da Entidade
								aEmpCont[11][3],;		// 03 - Nome da Empresa
								cDescAux1,; 			// 04 - Tipo da Lista (Lista/Manual/Atendimento)
								SU6->U6_CONTATO,;		// 05 - Codigo do Contato
								aEmpCont[2][3],;		// 06 - Nome do contato
								SU6->U6_DATA,;          // 07 - Data da lista
								SU6->U6_HRINI,;			// 08 - Hora de inicio
								SU6->U6_HRFIM,;			// 09 - Hora de fim
								cDescAux2 } ) 			// 10 - Status (Nao Enviado/Em Uso/Enviado)

				DbSelectarea("SU6")
				DbSkip()
			End 

			#IFDEF TOP
				DbSelectArea("SU6")
				DbCloseArea()
				ChKFile("SU6")
			#ENDIF
		Endif

		If Len(aDados) == 0
			AAdd(aDados, {	CriaVar("U6_CODIGO"	,.F.),;		// 01 - Codigo do item da Lista
							"",;							// 02 - Nome da Entidade
							"",;							// 03 - Nome da Empresa
							CriaVar("U6_ORIGEM"	,.F.),;		// 04 - Tipo da Lista (Lista/Manual/Atendimento)
							CriaVar("U6_CONTATO",.F.),;		// 05 - Codigo do Contato
							"",;                         	// 06 - Nome do contato	
							CriaVar("U6_DATA"	,.F.),;		// 07 - Data da lista
							CriaVar("U6_HRINI"	,.F.),;		// 08 - Hora de inicio
							CriaVar("U6_HRFIM"	,.F.),;		// 09 - Hora de fim
							CriaVar("U6_STATUS"	,.F.) })	// 10 - Status (Nao Enviado/Em Uso/Enviado)
		Endif

	Case cAlias == "SU8"  
	
		DbSelectArea("SU6")
		DbSetOrder(1)		//U6_FILIAL+U6_LISTA+U6_CODIGO
		If MsSeek(xFilial("SU6") + cFiltro)
			
			DbSelectArea("SU8")
			DbSetOrder(1)	//U8_FILIAL+U8_CRONUM+U8_CONTATO
			#IFDEF TOP
				cQuery :=	" SELECT 	U8_FILIAL, U8_CRONUM, U8_DATA, U8_HROCOR, U8_OCODISC, U8_STATUS, U8_CONTATO " +;
							" FROM 		" + RetSqlName("SU8") +;
							" WHERE 	U8_FILIAL = '" + xFilial("SU8") + "' AND " +;
							" 			U8_CRONUM = '" + SU6->U6_LISTA + "' AND " +;
							" 			D_E_L_E_T_ = '' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
				// MemoWrite("TMKCFUN.SQL", cQuery)
				DbSelectArea("SU8")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU8', .F., .T.)
				TCSetField("SU8", "U8_DATA", "D")
			#ELSE

				MsSeek(xFilial("SU8") + cFiltro)

			#ENDIF	

			While	!Eof()								.AND.;
			    	SU8->U8_FILIAL == xFilial(cAlias)	.AND.;
			    	SU8->U8_CRONUM == SU6->U6_LISTA


                cDescAux1 := ""
                Do Case
                	case SU8->U8_STATUS == "1"
                		cDescAux1 := "OCUPADO"
                		
                	case SU8->U8_STATUS == "2"
                		cDescAux1 := "ERRO"
                		
                	case SU8->U8_STATUS == "3"
                		cDescAux1 := "FALHA"
                		
                	case SU8->U8_STATUS == "4"
                		cDescAux1 := "SEM LINHA"
                		
                	case SU8->U8_STATUS == "5"
                		cDescAux1 := "EXECUTADO"
                		
                	case SU8->U8_STATUS == "6"
                		cDescAux1 := "EXCLUIDO"
                		
                	case SU8->U8_STATUS == "7"
                		cDescAux1 := "ENVIADO"
                		
                	case SU8->U8_STATUS == "8"
                		cDescAux1 := "IMPRESSO"
                Endcase
								
				AAdd(aDados, {	SU8->U8_CRONUM,;  			// 01 - Codigo da Lista
								SU8->U8_CONTATO,;			// 02 - Item da Lista
								SU8->U8_DATA,;				// 03 - Data da tentativa de contato
								SU8->U8_HROCOR,;			// 04 - Hora da tentativa
								SU8->U8_OCODISC,;			// 05 - Resultado da tentativa
								cDescAux1	} )				// 06 - Status 
				
				DbSkip()
			End
			#IFDEF TOP
				DbSelectArea("SU8")
				DbCloseArea()
				ChKFile("SU8")
			#ENDIF
		Endif
		
		If Len(aDados) == 0
			AAdd(aDados, {	CriaVar("U8_CRONUM"	,.F.),;
							CriaVar("U8_CONTATO",.F.),;
							CriaVar("U8_DATA"	,.F.),;
							CriaVar("U8_HROCOR"	,.F.),;
							CriaVar("U8_OCODISC",.F.),;
							CriaVar("U8_STATUS"	,.F.) })
		Endif

	Case cAlias == "AB1" .AND. aEmpCont[9][3] == "SA1"
	
		DbSelectArea("AB1")
		DbSetOrder(2)
		
		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| AB1->AB1_FILIAL == xFilial("AB1") }
		#ENDIF
		
		#IFDEF TOP
			cQuery :=	" SELECT 	AB1_FILIAL, AB1_CODCLI, AB1_LOJA, AB1_EMISSA, AB1_NRCHAM, AB1_HORA, AB1_HORAF, " +;
						" 			AB1_CONTAT, AB1_ATEND, AB1_STATUS, AB1_OK, AB1_REGIAO " +;
						" FROM 		" + RetSqlName("AB1") +;
						" WHERE "+;
						Iif(lTodasFil,"","AB1_FILIAL = '" + xFilial("AB1") + "' AND ") +;
						" 			AB1_CODCLI = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
						" 			AB1_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
						" 			AB1_EMISSA >= '" + DTOS(dCorte) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)
			// MemoWrite("TMKCFUN.SQL", cQuery)
			DbSelectArea("AB1")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'AB1', .F., .T.)
			
			TCSetField('AB1', 'AB1_EMISSA', 'D')
		#ELSE 
			If lTodasFil .AND. X2ModAcess("AB1") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
		   		DbSeek(xFilial("AB1") + aEmpCont[10][3])		// Cliente + Loja
		#ENDIF	

		While	!Eof() .AND. Eval(bEvFil)  .AND.;
				AB1->AB1_CODCLI == SubStr(aEmpCont[10][3],1,6)	.AND.;
				AB1->AB1_LOJA   == SubStr(aEmpCont[10][3],7,2)
			
			#IFNDEF TOP
				If AB1->AB1_EMISSA < dCorte
					DbSkip()
					Loop
				Endif
			#ENDIF
			
			AAdd(aDados, {	AB1->AB1_NRCHAM,;		// 01 -
							AB1->AB1_EMISSA,;		// 02 -
							AB1->AB1_HORA,;			// 03 -
							AB1->AB1_HORAF,;		// 04 -
							AB1->AB1_CONTAT,;		// 05 -
							AB1->AB1_ATEND,;		// 06 -
							AB1->AB1_STATUS,;		// 07 -
							AB1->AB1_OK,;			// 08 -
							AB1->AB1_REGIAO,;		// 09 -
							AB1->AB1_FILIAL	} )		// 10 - Filial
			DbSkip()
		End
		#IFDEF TOP
			DbSelectArea("AB1")
			DbCloseArea()
			ChKFile("AB1")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF
		
	Case cAlias == "AB6" .AND. aEmpCont[9][3] == "SA1"
	
		DbSelectArea("AB6")
		DbSetOrder(2) 
		
		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| AB6->AB6_FILIAL == xFilial("AB6") }
		#ENDIF
		
		#IFDEF TOP
			cQuery :=	" SELECT 	AB6_FILIAL, AB6_CODCLI, AB6_LOJA, AB6_EMISSA, AB6_NUMOS, AB6_HORA, AB6_CONPAG, " +;
						" 			AB6_ATEND, AB6_STATUS, AB6_OK, AB6_REGIAO " +;
						" FROM 		" + RetSqlName("AB6") +;
						" WHERE "+;
						Iif(lTodasFil,"","AB6_FILIAL = '" + xFilial("AB6") + "' AND ") +;
						" 			AB6_CODCLI = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
						" 			AB6_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
						" 			AB6_EMISSA >= '" + DTOS(dCorte) + "' AND " +;
						" 			D_E_L_E_T_ = '' " +;
						" ORDER BY " + SqlOrder(IndexKey())
			
			cQuery := ChangeQuery(cQuery)

			DbSelectArea("AB6")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'AB6', .F., .T.)
			
			TCSetField('AB6', 'AB6_EMISSA', 'D')
		#ELSE 
		
			If lTodasFil .AND. X2ModAcess("AB6") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
				DbSeek(xFilial("AB6") + aEmpCont[10][3])		// Cliente + Loja
		#ENDIF	

		While	!Eof() .AND. Eval(bEvFil) .AND.;
				AB6->AB6_CODCLI == SubStr(aEmpCont[10][3],1,6)	.AND.;
				AB6->AB6_LOJA   == SubStr(aEmpCont[10][3],7,2)
			
			#IFNDEF TOP
				If AB6->AB6_EMISSA < dCorte
					DbSkip()
					Loop
				Endif
			#ENDIF
			
			AAdd(aDados, {	AB6->AB6_NUMOS	,;
							AB6->AB6_EMISSA	,;
							AB6->AB6_HORA	,;
							AB6->AB6_CONPAG	,;
							AB6->AB6_ATEND	,;
							AB6->AB6_STATUS	,;
							AB6->AB6_OK		,;
							AB6->AB6_REGIAO	,;
							AB6->AB6_FILIAL })
			DbSkip()
		End
		#IFDEF TOP
			DbSelectArea("AB6")
			DbCloseArea()
			ChKFile("AB6")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF

	Case cAlias == "SC6"
		
		DbSelectArea("SF4")
		DbSetOrder(1)
				
		DbSelectArea("SC6")
		DbSetOrder(5) //C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SERIORI+C6_ITEMORI
		
		#IFDEF TOP
			
			cQuery	:= "SELECT C6_FILIAL,C6_NUM,C6_QTDENT,C6_QTDVEN,C6_ENTREG,C6_CLI,C6_LOJA "
			cQuery	+= "FROM " + RetSqlName("SC6") + " SC6 "
			cQuery	+= "INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '"+xFilial("SF5")+"' "
			cQuery	+= 		"AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ = '' AND F4_DUPLIC = 'S' "
			cQuery	+= "WHERE C6_FILIAL = '" + xFilial("SC6") + "' AND C6_CLI = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' "
			cQuery	+= "AND C6_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' "
			cQuery	+= "AND C6_ENTREG >= '" + DtoS(dCorte) + "' "
			cQuery	+= 		"AND C6_QTDENT < C6_QTDVEN AND SC6.D_E_L_E_T_ = '' "
			cQuery	+= "ORDER BY C6_NUM,C6_ITEM"
			
			cQuery := ChangeQuery(cQuery)
			DbSelectArea("SC6")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SC6', .F., .T.)
			
			TCSetField('SC6', 'C6_ENTREG', 'D')

		#ELSE
			MsSeek(xFilial("SC6") + aEmpCont[10][3])		// Cliente + Loja
		#ENDIF
		
		While !SC6->(Eof())						.AND.;
			SC6->C6_FILIAL 	== xFilial("SC6")	.AND.;
			SC6->C6_CLI	 	== SubStr(aEmpCont[10][3],1,TamCdCli) .AND.;
			SC6->C6_LOJA   	== SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj)
		
			#IFNDEF TOP               
			    
				//Limita pela data de entrega
				If SC6->C6_ENTREG < dCorte
					SC6->(DbSkip())
					Loop
				Endif
				
				//Salta itens entregues
				If SC6->C6_QTDENT == SC6->C6_QTDVEN
					SC6->(DbSkip())
					Loop
				EndIf
				
				If SF4->(DbSeek( xFilial("SF4") + SC6->C6_TES )) .AND. SF4->F4_DUPLIC <> "S"
					SC6->(DbSkip())
					Loop
				EndIf				

			#ENDIF
			
			AAdd(aDados, SC6->C6_NUM )
			
			SC6->(DbSkip())
		End

		#IFDEF TOP
			DbSelectArea("SC6")
			DbCloseArea()
			ChKFile("SC6")
		#ENDIF

	Case cAlias == "SC5"

		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| SC5->C5_FILIAL == xFilial("SC5") }
		#ENDIF
		
		bAdSC5 := {|| AAdd(aDados,{	SC5->C5_NUM		,;
									SC5->C5_CLIENTE	,;
									SC5->C5_LOJACLI	,;
									SC5->C5_CLIENT	,;
									SC5->C5_LOJAENT	,;
									SC5->C5_TRANSP	,;
									SC5->C5_TIPOCLI	,;
									SC5->C5_CONDPAG	,;
									SC5->C5_TABELA	,;
									SC5->C5_EMISSAO	,;
									SC5->C5_NOTA	,;
									SC5->C5_SERIE	,;
									SC5->C5_FILIAL	})}
		
	   	#IFDEF TOP
			
			cQuery	:= "SELECT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_CLIENT,C5_LOJAENT,C5_TRANSP,C5_TIPOCLI,C5_CONDPAG,"
			cQuery	+= "C5_TABELA,C5_EMISSAO,C5_NOTA,C5_SERIE "
			cQuery	+= "FROM " + RetSqlName("SC5") + " "
			cQuery	+= "WHERE "
			cQuery	+= Iif(lTodasFil,"","C5_FILIAL = '" + xFilial("SC5") + "' AND ")
			cQuery	+= " C5_CLIENTE = '"+SubStr(aEmpCont[10][3],1,TamCdCli)+"' "
			cQuery	+= "AND C5_LOJACLI = '"+SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj)+"' "
			cQuery	+= "AND C5_EMISSAO >= '" + DtoS(dCorte) + "' "
			
			If !Empty(cFiltro)
				cQuery	+= "AND C5_NUM IN " + FormatIn(cFiltro,"/") + " "
			EndIf
			
			cQuery	+= "AND C5_TIPO = 'N' AND D_E_L_E_T_ = ''"
			
			cQuery := ChangeQuery(cQuery)
			DbSelectArea("SC5")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SC5', .F., .T.)
			
			TCSetField('SC5', 'C5_EMISSAO', 'D')
			
			While !SC5->(Eof())
				Eval(bAdSC5)
				SC5->(DbSkip())
			End

			DbSelectArea("SC5")
			DbCloseArea()
			ChKFile("SC5")

		#ELSE

			If lTodasFil .AND. X2ModAcess("SC5") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				
				cFilAnt := aFiliais[nX]
			
				DbSelectArea("SC5")
	
				If Empty(cFiltro)
					
					DbSetOrder(3) //C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
					DbSeek(xFilial("SC5")+aEmpCont[10][3])
					
					While !Eof() .AND. Eval(bEvFil) .AND. SC5->C5_EMISSAO >= dCorte
						If SC5->C5_TIPO == "N" .AND. SC5->C5_EMISSAO >= dCorte
							Eval(bAdSC5)
						EndIf
						SC5->(DbSkip())
					End
					
				Else
	
					DbSetOrder(1) //C5_FILIAL+C5_NUM
		
					aPeds := StrToKArr(cFiltro,"/")
			
					For nPos := 1 to Len(aPeds)
						If DbSeek(xFilial("SC5")+aPeds[nPos]) .AND. SC5->C5_TIPO == "N"
							Eval(bAdSC5)
						EndIf
					Next nPos
					
				EndIf 
			
			Next nX	 
			
			cFilAnt := cFilAtu       
			
	 	#ENDIF
	
	Case cAlias == "SL1" 
	
		DbSelectArea("SL1")
		DbSetOrder(6) //L1_FILIAL+L1_CLIENTE+L1_LOJA   
		
		#IFDEF TOP
			bEvFil := {|| .T. }
		#ELSE
			bEvFil := {|| SL1->L1_FILIAL == xFilial("SL1") }
		#ENDIF
		
		#IFDEF TOP
		
			cQuery := "SELECT L1_FILIAL,L1_CLIENTE,L1_LOJA,L1_NUM,L1_VEND,L1_EMISSAO,L1_VLRTOT,L1_DESCONT,L1_VLRLIQ,L1_DTLIM,"
			cQuery += "L1_DOC,L1_SERIE,L1_PDV,L1_EMISNF,L1_VALBRUT,L1_VALMERC,L1_OPERADO "
			cQuery += " FROM " + RetSqlName("SL1")
			cQuery += " WHERE "
			cQuery += Iif(lTodasFil,"","L1_FILIAL = '" + xFilial("SL1") + "' AND ")
			cQuery += " L1_CLIENTE = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "'"
			cQuery += " AND L1_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND D_E_L_E_T_ = ''"
			cQuery += " AND L1_EMISSAO >= '" + DtoS(dCorte) + "' AND L1_DOC <> ''"
			
			cQuery := ChangeQuery(cQuery)
		
			DbSelectArea("SL1")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SL1", .F., .T.)
			
			TCSetField('SL1', 'L1_EMISSAO'	, 'D')
			TCSetField('SL1', 'L1_DTLIM'	, 'D')
			TCSetField('SL1', 'L1_EMISNF'	, 'D')
			
		#ELSE  
			If lTodasFil .AND. X2ModAcess("SL1") == "E"
			    aFiliais := aFils
			Else
				aFiliais := {cFilAnt}
			EndIf
			
			For nX := 1 to Len(aFiliais)
				cFilAnt := aFiliais[nX]
				DbSeek(xFilial("SL1") + aEmpCont[10][3])		// Cliente + Loja
		#ENDIF	
		
		While !Eof() .AND.	Eval(bEvFil) .AND.;
			SL1->L1_CLIENTE== SubStr(aEmpCont[10][3],1,6)	.AND.;
			SL1->L1_LOJA   == SubStr(aEmpCont[10][3],7,2)	
		
			#IFNDEF TOP
				//Limite da consulta
				If SL1->L1_EMISSAO < dCorte
					DbSkip()
					Loop
				Endif
				
				//Ignora orcamentos
				If Empty(SL1->L1_DOC)
					DbSkip()
					Loop
				Endif
		
			#ENDIF
			
			AAdd(aDados,{	SL1->L1_NUM		,;
							SL1->L1_VEND	,;
							SL1->L1_EMISSAO	,;
							SL1->L1_VLRTOT	,;
							SL1->L1_DESCONT	,;
							SL1->L1_VLRLIQ	,;
							SL1->L1_DTLIM	,;
							SL1->L1_DOC		,;
							SL1->L1_SERIE	,;
							SL1->L1_PDV		,;
							SL1->L1_EMISNF	,;
							SL1->L1_VALBRUT	,;
							SL1->L1_VALMERC	,;
							SL1->L1_OPERADO	,;
							SL1->L1_FILIAL	})
			
			DbSkip()
		End
		
		#IFDEF TOP
			DbSelectArea("SL1")
			DbCloseArea()
			ChKFile("SL1")
		#ELSE
			Next nX	
			cFilAnt := cFilAtu
		#ENDIF
	
	Case cAlias == "ABB" .AND. aEmpCont[9][3] == "SA1"
	
		DbSelectArea("ABB")
		DbSetOrder(3) //ABB_FILIAL+ABB_NUMOS

		DbSelectArea("AB6")
		DbSetOrder(2) 
		
		If lTodasFil .AND. X2ModAcess("AB6") == "E"
		    aFiliais := aFils
		Else
			aFiliais := {cFilAnt}
		EndIf
		
		For nX := 1 to Len(aFiliais)
			
			cFilAnt := aFiliais[nX]
						
			#IFDEF TOP
				cQuery :=	" SELECT 	AB6_FILIAL, AB6_CODCLI, AB6_LOJA, AB6_EMISSA, AB6_NUMOS, AB6_HORA, AB6_CONPAG, " +;
							" 			AB6_ATEND, AB6_STATUS, AB6_OK, AB6_REGIAO " +;
							" FROM 		" + RetSqlName("AB6") +;
							" WHERE 	AB6_FILIAL = '" + xFilial("AB6") + "' AND " +;
							" 			AB6_CODCLI = '" + SubStr(aEmpCont[10][3],1,TamCdCli) + "' AND " +;
							" 			AB6_LOJA = '" + SubStr(aEmpCont[10][3],TamCdCli+1,TamCdLoj) + "' AND " +;
							" 			AB6_EMISSA >= '" + DTOS(dCorte) + "' AND " +;
							" 			D_E_L_E_T_ = '' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
	
				DbSelectArea("AB6")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'AB6', .F., .T.)
				
				TCSetField('AB6', 'AB6_EMISSA', 'D')
			#ELSE
				MsSeek(xFilial("AB6") + aEmpCont[10][3])		// Cliente + Loja
			#ENDIF	
	
			While	!Eof()											.AND.;
					AB6->AB6_FILIAL == xFilial("AB6")				.AND.;
					AB6->AB6_CODCLI == SubStr(aEmpCont[10][3],1,6)	.AND.;
					AB6->AB6_LOJA   == SubStr(aEmpCont[10][3],7,2)
				
				#IFNDEF TOP
					If AB6->AB6_EMISSA < dCorte
						DbSkip()
						Loop
					Endif
				#ENDIF
				
				If ABB->(DbSeek(xFilial("ABB")+AB6->AB6_NUMOS))
				 
					While !ABB->(Eof()) .AND. ABB->ABB_FILIAL == xFilial("ABB") .AND.;
						ABB->ABB_NUMOS == AB6->AB6_NUMOS
							
							If ABB->ABB_DTINI >= dCorte
							
								AAdd(aDados, {	ABB->ABB_NUMOS	,;
												ABB->ABB_CODTEC	,;
												Posicione("AA1",1,xFilial("AA1")+ABB->ABB_CODTEC,"AA1_NOMTEC"),;
												ABB->ABB_DTINI	,;
												ABB->ABB_HRINI	,;
												ABB->ABB_DTFIM	,;
												ABB->ABB_HRFIM	,;
												ABB->ABB_HRTOT	,;
												ABB->ABB_OBSERV	,;
												X3Combo( "ABB_SACRA", ABB->ABB_SACRA ),;
												X3Combo( "ABB_CHEGOU",ABB->ABB_CHEGOU),;
												X3Combo( "ABB_ATENDE",ABB->ABB_ATENDE),;
												ABB->ABB_FILIAL })
							EndIf
	
						ABB->(DbSkip())
					End
				EndIf
							
				DbSkip()
			End
			#IFDEF TOP
				DbSelectArea("AB6")
				DbCloseArea()
				ChKFile("AB6")
			#ENDIF 
			
		Next nX           
		
		cFilAnt := cFilAtu 
		
EndCase

RestArea(aArea)

Return(aDados)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010Brow       ³Autor  ³Armando M. Tessaroli³ Data ³ 24/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna as matrizes aHeader e o aCols para o MSGetDados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010Brow( cAlias, cTipo, cCodigo, oTree, aCodigo )

Local aArea     := GetArea()  	// Salva a area atual
Local nCntFor   := 0			// Contador
Local cFiltro	:= ""			// Filtro de busca
Local nRet		:= 0			// Retorno
Local nI		:= 0			// Contador auxiliar
Local nFim		:= 0 			// Contador final	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader, Cabecalho do browser                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "H"					// aHeader

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa o aHeader³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader	:={}

	DbSelectArea("SX3")
	DbSetOrder(1)
	MsSeek(cAlias)
	While !Eof() .AND. SX3->X3_ARQUIVO == cAlias

		If X3Uso(SX3->X3_USADO) .AND. (cNivel >= X3_NIVEL)
		
			AAdd(aHeader,{  ALLTRIM(SX3->X3_TITULO),;		// 1
									SX3->X3_CAMPO,;         // 2
									SX3->X3_PICTURE,;       // 3
									SX3->X3_TAMANHO,;       // 4
									SX3->X3_DECIMAL,;       // 5
									SX3->X3_VALID,;         // 6
									SX3->X3_USADO,;         // 7
									SX3->X3_TIPO,;          // 8
									SX3->X3_ARQUIVO,;       // 9
									SX3->X3_CONTEXT,;	    // 10
									SX3->X3_PROPRI } )		// 11
	
		Endif
		
		DbSelectArea("SX3")
		DbSkip()
	End
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols, Itens do browser                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "C"		// aCols

	Do Case
		Case cAlias == "SUD"
			DbSelectArea(cAlias)
			cFiltro := "SUD->UD_FILIAL == '" + xFilial(cAlias) + "' .AND. SUD->UD_CODIGO == '" + cCodigo + "'"

		Case cAlias == "ACC"
			DbSelectArea(cAlias)
			cFiltro := "ACC->ACC_FILIAL == '" + xFilial(cAlias) + "' .AND. ACC->ACC_CODOBJ == '" + cCodigo + "'"

		Case cAlias == "SUB"
			DbSelectArea(cAlias)
			cFiltro := "SUB->UB_FILIAL == '" + xFilial(cAlias) + "' .AND. SUB->UB_NUM == '" + cCodigo + "'"

		Case cAlias == "SU6"
			DbSelectArea(cAlias)
			cFiltro := "SU6->U6_FILIAL == '" + xFilial(cAlias) + "'"
			If !Empty(TRIM(cCodigo))
				cFiltro += " .AND. SU6->U6_LISTA == '" + cCodigo + "'"
			Endif	

		Case cAlias == "SU8"
			DbSelectArea(cAlias)
			cFiltro := "SU8->U8_FILIAL == '" + xFilial(cAlias) + "' .AND. SU8->U8_CRONUM == '" + cCodigo + "'"

		Case cAlias == "AB2"
			DbSelectArea(cAlias)
			cFiltro := "AB2->AB2_FILIAL == '" + xFilial(cAlias) + "' .AND. AB2->AB2_NRCHAM == '" + cCodigo + "'"
	EndCase

	If aCodigo == Nil
		nFim := 1
	Else
		nFim := len(aCodigo)
	Endif

	aCols := {}
	For nI := 1 to nFim
		DbSelectArea(cAlias)
		DbSetOrder(1)

		If aCodigo <> Nil
			cCodigo := aCodigo[nI]
			cFiltro := "ACF->ACF_FILIAL == '" + xFilial(cAlias) + "' .AND. ACF->ACF_CODIGO == '" + cCodigo + "'"
		Endif

		If MsSeek(xFilial(cAlias) + cCodigo)
			While !Eof() .AND. &cFiltro
			
				AAdd( aCols, Array(len(aHeader) + 1) )
			
				For nCntFor := 1 To len(aHeader)
					
					If ( aHeader[nCntFor][10] != "V" )
						aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
					Else
						aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
					Endif   
					
				Next nCntFor
			
				aCols[Len(aCols)][len(aHeader)+1] := .F.
				DbSelectArea(cAlias)
				DbSkip()
			End
		Else
			AAdd( aCols, Array(LEN(aHeader) + 1) )
			TkHeader(cAlias,NIL,@aCols,aHeader)
		Endif

	Next nI
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do conteudo do objeto tree³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "S" .OR. cTipo == "R"		// oTree de (S)cript e Script com (R)espostas

	oTree:Reset()	// Limpa o tree
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o tree atraves da base com todas as perguntas e respostas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUP")
	DbSetOrder(1)
	#IFDEF TOP
		cQuery :=	" SELECT 	UP_FILIAL, UP_CODCAMP, UP_IDTREE, UP_CARGO, UP_TIPOOBJ, UP_DESC " +;
					" FROM 		" + RetSqlName("SUP") +;
					" WHERE 	UP_FILIAL = '" + xFilial("SUP") + "' AND " +;
					" 			UP_CODCAMP = '" + cCodigo + "' AND " +;
					" 			D_E_L_E_T_ = '' " +;
					" ORDER BY " + SqlOrder(IndexKey())
		
		cQuery := ChangeQuery(cQuery)
		// MemoWrite("TMKCFUN.SQL", cQuery)
		DbSelectArea("SUP")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUP', .F., .T.)
	#ELSE
		MsSeek(xFilial("SUP") + cCodigo)
	#ENDIF	

	While	!Eof()								.AND.;
			SUP->UP_FILIAL  == xFilial("SUP")	.AND.;
			SUP->UP_CODCAMP == cCodigo
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao das perguntas no tree. O setimo parametro indica o nivel  do tree. 1-Mesmo nivel, ³
		//³ 2-um nivel abaixo.             															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Empty(SUP->UP_TIPOOBJ)
			If oTree:TreeSeek(SUP->UP_IDTREE)
				oTree:AddItem(SUP->UP_DESC,SUP->UP_CARGO, "FOLDER12","FOLDER13", , ,2)
			Else
				oTree:AddItem(SUP->UP_DESC,SUP->UP_CARGO, "FOLDER12","FOLDER13", , ,1)
			Endif                  
			
		Else
			
			If oTree:TreeSeek(SUP->UP_IDTREE)
				oTree:AddItem(SUP->UP_DESC,SUP->UP_CARGO, "FOLDER5","FOLDER6", , ,2)
			Else
				oTree:AddItem(SUP->UP_DESC,SUP->UP_CARGO, "FOLDER5","FOLDER6", , ,1)
			Endif
			
		Endif
		
		DbSelectArea(cAlias)
		DbSkip()
	End                             
	
	#IFDEF TOP
		DbSelectArea("SUP")
		DbCloseArea()
		ChKFile("SUP")
	#ENDIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do conteudo do objeto tree³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "E"					// Posiciona no registro para carregar a Enchoice
	DbSelectArea(cAlias)
	DbSetOrder(1)
	If MsSeek(xFilial(cAlias) + cCodigo)
		nRet := RecNo()
	Else
		nRet := 0
	Endif
Endif

RestArea(aArea)
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKCFUN   ºAutor  ³Microsiga           º Data ³  03/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function X2ModAcess(cTab)

Local aArea		:= {}
Local aAreaSX2	:= {}
Local cModo 	:= ""
Local aSX2Info	:= {}

If	GetRpoRelease() >= "12.1.027"
	aSX2Info    := FwSX2Util():GetSX2Data(cTab /*cAlias*/, {"X2_MODO"} /*aFields*/, /*lQuery*/)
	cModo		:= aSX2Info[01,02]
Else
	aArea		:= GetArea()
	aAreaSX2	:= SX2->(GetArea())
	SX2->(DbSetOrder(1))
	SX2->(DbSeek(cTab))

	cModo		:= SX2->X2_MODO

	RestArea(aAreaSX2)
	RestArea(aArea)
	aSize(aAreaSX2,0)
	aSize(aArea,0)
EndIf
FreeObj(aSX2Info)
Return cModo



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP51       ³Autor  ³Vendas & CRM                 ³ 13/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP51(aEmpCont)

Local aAreaSF2	:= SF2->(GetArea())
Local aArea		:= GetArea()
Local aFiliais	:= {}
Local aSerie		:= {}
Local aMedia		:= {}
Local aMediaFat	:= {}
Local aMediaLoja	:= {}
Local aDatas		:= {} // Datas do Filtro
Local dCorte		:= STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])
Local dLoop		:= dCorte
Local nX			:= 0
Local nJ			:= 0
Local bEvFil		:= Nil
Local cFilAtu		:= cFilAnt
Local cAlias		:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local cWhere		:= ""
Local nAno			
Local nMes		


#IFDEF TOP
	Local cQuery	:= ""
#ENDIF 

#IFDEF TOP
	bEvFil := {|| .T. }
#ELSE
	bEvFil := {|| SF2->F2_FILIAL  == xFilial("SF2") }
#ENDIF

cCliente	:= Substr(aEmpCont[10][3],1,TamSX3("F2_CLIENTE")[1])
cLoja		:= PadR(Substr(Rtrim(aEmpCont[10][3]),TamSX3("F2_CLIENTE")[1]+1),TamSX3("F2_LOJA")[1])

//Monta as Datas inicio e Fim para filtro na query, iniciando pelo dia escolhido do mes da data de corte até atual.
While dLoop <= dDatabase 
	nAno := Year(dLoop)
	nMes := Month(dLoop)			
	
	If nMes == 12
		nAno += 1
		nMes := 1
	Else
		nMes += 1
	EndIf									
	
		AAdd(aDatas,{;
			StrZero(Month(dLoop),2)+"/"+StrZero(Year(dLoop),4),;
			cToD(Iif(dCorte == dLoop,Str(Day(dLoop)),"01")+"/"+Str(Month(dLoop))+"/"+Str(Year(dLoop))),;
			cToD("01/"+Str(nMes)+"/"+Str(nAno))-1,;
			0,; // Soma
			0,; // Count			
		})
		
		dLoop := cToD("01/"+Str(nMes)+"/"+Str(nAno))
				
End


#IFDEF TOP
	For nX := 1 To Len(aDatas)
				
		// Total Loja
		cWhere := (Iif(!lTodasFil,"% SL1.L1_FILIAL='"+XFilial("SL1")+"' AND %","% %"))
		BeginSql alias 'SL1PFCON'
			SELECT 
				SUM(SL1.L1_VLRTOT) SOMA,
				COUNT(*) TOT
			FROM %table:SL1% SL1
			WHERE 
				%exp:cWhere%	
				L1_CLIENTE = %exp:cCliente% AND L1_LOJA = %exp:cLoja% AND				
				L1_EMISSAO BETWEEN %exp:DToS(aDatas[nX][2])% AND %exp:DToS(aDatas[nX][3])% AND 		
				L1_DOC <> %exp:''% AND		
				SL1.%notDel%
		EndSql		
		
		DbSelectArea("SL1PFCON")
				
		If SL1PFCON->(EOF()) .OR. SL1PFCON->TOT == 0
			AAdd(aMediaLoja,{aDatas[nX][1],0})
		Else
			AAdd(aMediaLoja,{aDatas[nX][1],SL1PFCON->SOMA})
		EndIf			
		
		DbCloseArea()		
	
		// Total Faturamento		
		cWhere		:= Iif(!lTodasFil,"% SF2.F2_FILIAL='"+XFilial("SF2")+"' AND %","% %")
		BeginSql alias 'SF2PFCON'
			SELECT
	    	SUM(F2_VALBRUT) SOMA,
	    	COUNT(*) TOT            
	    	FROM %table:SF2% SF2        
	    	WHERE 
	     		%exp:cWhere%                 
	           SF2.F2_CLIENTE = %exp:cCliente% AND SF2.F2_LOJA = %exp:cLoja% AND
	           SF2.F2_EMISSAO BETWEEN %exp:DToS(aDatas[nX][2])% AND %exp:DToS(aDatas[nX][3])% AND
	           SF2.F2_ECF = %exp:Space(TamSX3("F2_ECF")[1])% AND
	           SF2.F2_PDV = %exp:Space(TamSX3("F2_PDV")[1])% AND		          
	           SF2.%notDel%
		EndSql
		
		DbSelectArea("SF2PFCON")
				
		If SF2PFCON->(EOF()) .OR. SF2PFCON->TOT == 0
			AAdd(aMediaFat,{aDatas[nX][1],0})
		Else
			AAdd(aMediaFat,{aDatas[nX][1],SF2PFCON->TOT})
		EndIf			
		
		DbCloseArea()
		
	Next nX
				
#ELSE

	//Total Faturamento
	
	If lTodasFil .AND. X2ModAcess("SF2") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf		
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		DbSelectArea("SF2")
		DbSetOrder(2) // Filial+Cliente+Loja
		MsSeek(xFilial("SF2") + cCliente+cLoja)
		
		While !Eof() .AND. SF2->F2_CLIENTE+SF2->F2_LOJA == cCliente+cLoja
			//Verifica se nao veio do loja e esta no intervalo das datas.
			If SF2->F2_ECF == Space(TamSX3("F2_ECF")[1]) .AND. SF2->F2_PDV == Space(TamSX3("F2_PDV")[1]) .AND.;
			(nJ := AScanX(aDatas,{|aVar| SF2->F2_EMISSAO >= avar[2] .AND. SF2->F2_EMISSAO <= avar[3] })) > 0
				aDatas[nJ][4] += SF2->F2_VALBRUT // Soma
				aDatas[nJ][5] += 1	// Count				
			EndIf  									
			DbSkip()
		End		
		
	Next nX			
	cFilAnt := cFilAtu
	
	//Calcula Medias para Datas
	For nX := 1 To Len(aDatas)
		If aDatas[nX][5] == 0
			AAdd(aMediaFat,{aDatas[nX][1],0})
		Else	
			AAdd(aMediaFat,{aDatas[nX][1],aDatas[nX][4]/aDatas[nX][5]})
		EndIf
		//Zera totalizadores para totalizar a parte do loja
		aDatas[nX][4] := 0
		aDatas[nX][5] := 0
	Next nX
	
	// Total Loja		
	
	If lTodasFil .AND. X2ModAcess("SL1") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		DbSelectArea("SL1")
		DbSetOrder(6) //L1_FILIAL+L1_CLIENTE+L1_LOJA
		MsSeek(xFilial("SL1") + cCliente+cLoja)
		
		While !Eof() .AND. SL1->L1_CLIENTE+SL1->L1_LOJA == cCliente+cLoja
			//Verifica se foi efetivada a venda e esta no intervalo de datas.
			If Trim(SL1->L1_DOC) != "";
			.AND. (nJ := AScanX(aDatas,{|aVar| SL1->L1_EMISSAO >= avar[2] .AND. SL1->L1_EMISSAO <= avar[3] })) > 0			
				aDatas[nJ][4] += SL1->L1_VLRTOT // Soma
				aDatas[nJ][5] += 1	// Count				
			EndIf  									
			DbSkip()
		End		
		
	Next nX			
	cFilAnt := cFilAtu
	
	//Calcula Medias para Datas
	For nX := 1 To Len(aDatas)
		If aDatas[nX][5] == 0
			AAdd(aMediaLoja,{aDatas[nX][1],0})
		Else	
			AAdd(aMediaLoja,{aDatas[nX][1],aDatas[nX][4]})
		EndIf
		//Zera totalizadores
		aDatas[nX][4] := 0
		aDatas[nX][5] := 0
	Next nX			
	
#ENDIF

//Soma Totais Loja+Fat
For nX := 1 To Len(aMediaFat)
	AAdd(aMedia,{aMediaFat[nX][1],aMediaFat[nX][2]+aMediaLoja[nX][2]})
Next nX

AAdd(aSerie,{4,aMedia,STR0043}) //"Ticket Médio"
AAdd(aSerie,{4,aMediaFat,STR0044}) //"Ticket Faturamento"
AAdd(aSerie,{4,aMediaLoja,STR0045}) //"Ticket Loja"

RestArea(aAreaSF2)
RestArea(aArea)

Return(aSerie)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP52       ³Autor  ³Vendas & CRM                 ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP52(aEmpCont,nTipo)

Local aAreaSD2	:= SD2->(GetArea())
Local aArea		:= GetArea()
Local aFiliais	:= {}
Local aSerie		:= {}
Local dCorte		:= STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])
Local dLoop		:= dCorte
Local cFilAtu		:= cFilAnt
Local cCliente	:= ""
Local cLoja		:= ""
Local cWhere		:= ""
Local nPos			:= 0
Local lSoma		:= .F.
Local nX			:= 0

cCliente	:= Substr(aEmpCont[10][3],1,TamSX3("F2_CLIENTE")[1])
cLoja		:= PadR(Substr(Rtrim(aEmpCont[10][3]),TamSX3("F2_CLIENTE")[1]+1),TamSX3("F2_LOJA")[1])


#IFDEF TOP
	cWhere := (Iif(!lTodasFil,"% SD2.D2_FILIAL='"+XFilial("SD2")+"' AND %","% %"))
	If nTipo == 1 // Faturamento por Categoria de Produto
		BeginSql alias 'FATGRPPROD'			
			SELECT 
				SUM(SD2.D2_TOTAL) SOMA, ACU.ACU_DESC DESCRI
				FROM %table:SD2% SD2       
				JOIN %table:ACV% ACV ON (ACV.ACV_CODPRO=SD2.D2_COD)
				JOIN %table:ACU% ACU ON (ACU.ACU_COD=ACV.ACV_CATEGO)
				JOIN %table:SF2% SF2 ON (SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_TIPO=SD2.D2_TIPO)		
			WHERE    
	     		%exp:cWhere%
	           SD2.D2_CLIENTE = %exp:cCliente% AND SD2.D2_LOJA = %exp:cLoja% AND
	           SD2.D2_EMISSAO >= %exp:DToS(dCorte)% AND		          
	           SD2.%notDel% AND
	           ACV.%notDel% AND
	           ACU.%notDel%
			GROUP BY ACU.ACU_DESC
		EndSql
	Else // Faturamento por Categoria de Grupo de Produto
		BeginSql alias 'FATGRPPROD'
			SELECT 
				SUM(SD2.D2_TOTAL) SOMA, ACU.ACU_DESC DESCRI
			FROM %table:SD2% SD2 
			JOIN %table:SB1% SB1 ON (SB1.B1_COD=SD2.D2_COD)
			JOIN %table:ACV% ACV ON (ACV.ACV_GRUPO=SB1.B1_GRUPO AND RTRIM(ACV.ACV_GRUPO) != %exp:Space(TamSX3("ACV_GRUPO")[1])%)
			JOIN %table:ACU% ACU ON (ACU.ACU_COD=ACV.ACV_CATEGO)
			JOIN %table:SF2% SF2 ON (SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_TIPO=SD2.D2_TIPO)
			WHERE    
	     		%exp:cWhere%                 
	           SD2.D2_CLIENTE = %exp:cCliente% AND SD2.D2_LOJA = %exp:cLoja% AND
	           SD2.D2_EMISSAO >= %exp:DToS(dCorte)% AND		          
	           SD2.%notDel% AND
	           ACV.%notDel% AND
	           ACU.%notDel%
			GROUP BY ACU.ACU_DESC
		EndSql	
	EndIf
	
	DbSelectArea("FATGRPPROD")
			
	While !FATGRPPROD->(EOF())		
		AAdd(aSerie,{4,FATGRPPROD->SOMA,FATGRPPROD->DESCRI})
		DbSkip()
	End
	
	DbCloseArea()
				
#ELSE
	
	If lTodasFil .AND. X2ModAcess("SD2") == "E"
	    aFiliais := aFils
	Else
		aFiliais := {cFilAnt}
	EndIf		
	
	For nX := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nX]
		DbSelectArea("SD2")
		DbSetOrder(9) // Filial+Cliente+Loja e outros
		MsSeek(xFilial("SD2") + cCliente+cLoja)
		
		While !Eof() .AND. SD2->D2_CLIENTE+SD2->F2_LOJA == cCliente+cLoja
			//Verifica se esta no intervalo das datas.						
			If (AScanX(aDatas,{|aVar| SD2->D2_EMISSAO >= avar[2] .AND. SD2->F2_EMISSAO <= avar[3] }) > 0)
				lSoma := .F. 			
				If nTipo == 1 // Total Por Produto X Categoria 
					DbSelectArea("ACV")
					DbSetOrder(5) //Filial+cod produto
					If MsSeek(XFilial("ACV")+SD2->D2_COD)					
						DbSelectArea("ACU")
						DbSetOrder(1) //Filial+Codigo
						If MsSeek(XFilial("ACU")+ACV->ACV_CATEGO)							
							lSoma := .T.													
						EndIf													
					EndIf				
				Else // Total Por Grupo de Produto X Categoria									
					DbSelectArea("SB1")
					DbSetOrder(1) // filial+cod
					MsSeek(XFilial("SB1")+SD2->D2_COD)					
					If Trim(SB1->B1_GRUPO) <> ""					
						DbSelectArea("ACV")
						DbSetOrder(4) //Filial+grupo
						If MsSeek(XFilial("ACV")+SB1->B1_GRUPO)					
							DbSelectArea("ACU")
							DbSetOrder(1) //Filial+Codigo
							If MsSeek(XFilial("ACU")+ACV->ACV_CATEGO)							
								lSoma := .T.
							EndIf																		
						EndIf													
					EndIf
				EndIf
				If lSoma
					If (nPos := AscanX(aSerie,{|x| x[3] == ACU->ACU_DESC})) > 0
						aSerie[nPos][2] += SD2->D2_TOTAL
					Else
						AAdd(aSerie,{4,SD2->D2_TOTAL,ACU->ACU_DESC})
					EndIf
				EndIf																		
			EndIf  			
			DbSelectArea("SD2")						
			DbSkip()
		End		
		
	Next nX			
	cFilAnt := cFilAtu
	
#ENDIF

RestArea(aAreaSD2)
RestArea(aArea)

Return(aSerie)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP53       ³Autor  ³Vendas & CRM                 ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP53(aEmpCont)

Local aCores		:= StaticCall(LOJA701,Lj7DefLeg)
Local aLegenda	:=  Lj7CorLege()
Local aRegras		:= {}
Local aSeries		:= {}
Local nX			:= 0
Local nJ			:= 0
Local nPos			:= 0
Local aArea		:= GetArea()
Local aFiliais	:= {}
Local cFilAtu		:= cFilAnt
Local cCliente	:= ""
Local cLoja		:= ""

cCliente	:= Substr(aEmpCont[10][3],1,TamSX3("F2_CLIENTE")[1])
cLoja		:= PadR(Substr(Rtrim(aEmpCont[10][3]),TamSX3("F2_CLIENTE")[1]+1),TamSX3("F2_LOJA")[1])

For nX := 1 To Len(aCores)
	If (nPos := AScanX(aLegenda,{|x| Trim(Upper(x[1])) == Trim(Upper(aCores[nX][2]))})) > 0
		AAdd(aSeries,{4,0,aLegenda[nPos][2]})
		AAdd(aRegras,aCores[nX][1])
	EndIf
Next nX

If lTodasFil .AND. X2ModAcess("SD2") == "E"
    aFiliais := aFils
Else
	aFiliais := {cFilAnt}
EndIf		
	
For nX := 1 To Len(aFiliais)
	cFilAnt := aFiliais[nX]
	DbSelectArea("SL1")
	DbSetOrder(6) // Filial+Cliente+Loja
	MsSeek(XFilial("SL1")+cCliente+Cloja)
	
	While !Eof() .AND. SL1->L1_CLIENTE+SL1->L1_LOJA == cCliente+cLoja
		For nJ := 1 To Len(aRegras)			
			If &(aRegras[nJ]) //Verifica se atende a regra da legenda para incrementar a serie
				aSeries[nJ][2]++ //As series sao criadas na mesma ordem das regras.
				Exit
			EndIf
		Next nJ
		DbSkip()
	End		
Next nX

cFilAnt := cFilAtu
RestArea(aArea)

Return aSeries
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP55       ³Autor  ³Vendas & CRM                 ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP55(aEmpCont,nTipo,cPanel)

Local aSeries		:= {}
Local nX			:= 0
Local aArea		:= GetArea()
Local aFiliais	:= {}
Local cFilAtu		:= cFilAnt
Local cCliente	:= ""
Local cLoja		:= ""
Local nPos			:= 0
Local cCampo		:= "MBR_MOTIVO"
Local dCorte 	:= STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])

cCliente	:= Substr(aEmpCont[10][3],1,TamSX3("L1_CLIENTE")[1])
cLoja		:= PadR(Substr(Rtrim(aEmpCont[10][3]),TamSX3("L1_CLIENTE")[1]+1),TamSX3("L1_LOJA")[1])

If lTodasFil .AND. X2ModAcess("SD2") == "E"
    aFiliais := aFils
Else
	aFiliais := {cFilAnt}
EndIf		
	
For nX := 1 To Len(aFiliais)
	cFilAnt := aFiliais[nX]
	
	DbSelectArea("MBR")
	DbSetOrder(4) // Filial+Cliente+Loja+Produto 
	MsSeek(cFilAnt+cCliente+cLoja)
									
	While !Eof() .AND. MBR->MBR_CODCLI+MBR->MBR_LOJA == cCliente+cLoja
		If MBR->MBR_EMISSA >= dCorte
			If nTipo == 1 // Total por Motivo				
				cCampo := "MBR_MOTIVO"
			ElseIf nTipo == 2 // Total por Produto
				cCampo := "MBR_PROD"
			EndIf		
			
			If (nPos := AScanX(aSeries,{|x| x[3] == MBR->&(cCampo)})) > 0
				aSeries[nPos][2]++
			Else
				AAdd(aSeries,{4,1,MBR->&(cCampo),MBR->&(cCampo)})
			EndIf
		EndIf
		
		DbSkip()				
	End
			
	//Replace Do Codigo pela descrição
	For nPos := 1 To Len(aSeries)
		If nTipo == 1 // Total por Motivo	
			aSeries[nPos][3] := Posicione("MBQ",1,XFilial("MBQ")+aSeries[nPos][3],"MBQ_DSCVEP")
		ElseIf nTipo == 2 //Total por Produto
			aSeries[nPos][3] := Posicione("SB1",1,XFilial("SB1")+aSeries[nPos][3],"B1_DESC")
		EndIf 		
	Next nPos
			
Next nX
cFilAnt := cFilAtu
RestArea(aArea)

Return aSeries


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKC010VP56       ³Autor  ³Vendas & CRM                 ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TKC010VP56(aEmpCont,aSerie,cPanel)

Local aList		:= {{},{}}
Local nX			:= 0
Local nJ			:= 0
Local aArea		:= GetArea()
Local aFiliais	:= {}
Local cFilAtu		:= cFilAnt
Local lTemLoja	:= .T.
Local aArmazens	:= {}
Local nPos			:= 0
Local cCampo		:= "MBR_MOTIVO"
Local dCorte 	:= STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3])

//Monta o Cabecalho com o Titulo dos Campos
aList[1] := {"B1_COD","B1_DESC","B2_QATU","LJ_NOME","LJ_CODIGO"}
DbSelectArea("SX3")
DbSetOrder(2)
For nX := 1 To Len(aList[1])
	If MsSeek(aList[1][nX])
		aList[1][nX] := X3Titulo()
	End
Next nX

//Monta os Itens 
If lTodasFil .AND. X2ModAcess("SD2") == "E"
    aFiliais := aFils
Else
	aFiliais := {cFilAnt}
EndIf		
	
For nX := 1 To Len(aFiliais)
	cFilAnt := aFiliais[nX]		
		
	DbSelectArea("SB2")
	DbSetOrder(1) // Filial+B2_COD+B2_LOCAL
	For nJ := 1 To Len(aSerie)	
		If MsSeek(XFilial("SB2")+aSerie[nJ][4]) .AND. SB2->B2_QATU > 0 // Indice 4 é o codigo do produto na serie do grafico 2
			DbSelectArea("SB1")
			DbSetOrder(1)
			MsSeek(XFilial("SB1")+SB2->B2_COD)
			DbSelectArea("SLJ")			
			DbSetOrder(1)			
			lTemLoja := .F.
			While !SLJ->(EOF())
				If Trim(SB2->B2_LOCAL) $ Trim(SLJ->LJ_LOCAL)
					lTemLoja := .T.
					AAdd(aList[2],{SB1->B1_COD,SB1->B1_DESC,SB2->B2_QATU,SLJ->LJ_NOME,SLJ->LJ_CODIGO})
				EndIf
				DbSkip()
			End
			If !lTemLoja // Se nao encontrar o armazem em alguma loja, imprime sem loja
				AAdd(aList[2],{SB1->B1_COD,SB1->B1_DESC,SB2->B2_QATU,"",""})
			EndIf				
			DbSelectArea("SB2")
			DbSkip()		
		EndIf
	Next nJ			
Next nX

cFilAnt := cFilAtu
RestArea(aArea)

Return aList
