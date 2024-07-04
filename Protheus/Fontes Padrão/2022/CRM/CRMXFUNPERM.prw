#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMXFUN.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCALENDARWIDGET.CH"

#DEFINE NTAMCODINT	2

Static __cCRMCodUser	:= ""
Static lInitObserver	:= .F.
Static __aUserRole 		:= {}
Static __aUserData		:= {}
Static __lAZS 			:= Nil
Static lCrmFilEnt		:= Nil
Static __aFilEntCache	:= {"","","",""} 
Static __OnlyBrowseObs	:= .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXCodUser()

Retorna o codigo do usuario logado no CRM.

@sample 	CRMXCodUser()

@Return   	cCodUser ,Caracter ,Codigo do usuário.

@author	Anderson Silva
@since		01/12/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------
Function CRMXCodUser( ) 
	
	Local cCodUser	:= ""
	
	Default lWAIgnore	:= .F.  
	
	If ! Empty( __cCRMCodUser )	// Prioriza usuario logado no CRM setado manualmente pela função CRMXSetUser()
		cCodUser := __cCRMCodUser
	Else	
		//Retorna o usuario logado no Protheus
		cCodUser := RetCodUsr()
		If Empty( cCodUser )				
			//Retorna o usuario logado no Portal
			cCodUser := UsrPrtErp()
		EndIf
	EndIf

Return( cCodUser ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXSetUser()

Define um usuario protheus como logado no CRM.

@sample 	CRMXSetUser( cCodUser )

@param		cCodUser ,Caracter ,Codigo do usuário.

@Return   	lRet ,Logico , Retorna verdadeiro se o codigo do usuario foi definido.

@author	Anderson Silva
@since		01/12/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------
Function CRMXSetUser( cCodUser )

	Local lRet		 := .F.
	Default cCodUser := ""
	
	If !Empty( cCodUser )
		__cCRMCodUser	:= cCodUser
		lRet := .T.
	EndIf

Return( lRet ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXFmtNvl
Retorna os níveis iniciais que podem ser visualizados por um determinado usuário
na estrutura de negócio. 

@param	cID, caracter, ID Inteligente.
@Return aID, Lista de níveis iniciais que popdem ser vistos por um usuário

@author		Anderson Silva
@author		Valdiney V GOMES
@version	12.0 
@since		26/05/2013
/*/
//------------------------------------------------------------------------------
Function CRMXFmtNvl( cID )
	Local aArea	:= GetArea()
	Local aID 		:= {}
	Local cQuery	:= ""
	Local cTemp 	:= GetNextAlias() 
	Local nLevel	:= ( Len( AllTrim( cID ) ) / 2 ) 

	//-------------------------------------------------------------------
	// Monta a instrução SQL.  
	//-------------------------------------------------------------------	
	cQuery := " SELECT"
	cQuery += " 	AO5.AO5_ENTANE," 
	cQuery += " 	AO5.AO5_CODANE,"
	cQuery += " 	AO5.AO5_IDESTN," 
	cQuery += " 	AO5.AO5_NVESTN"
	cQuery += " FROM " 
	cQuery +=		RetSQLName("AO5") + " AO5" 
	cQuery += " WHERE"
	cQuery += " 	( AO5.AO5_ENTANE <> 'USU' AND AO5.AO5_ENTANE <> 'AZS')"	
	cQuery += " 	AND " 
	cQuery += " 	AO5.AO5_NVESTN = '" + cBIStr( nLevel ) + "'"	
	cQuery += " 	AND " 
	
	If ! ( nLevel == 1 )
		cQuery += " AO5.AO5_IDESTN LIKE '" + Left( cID, Len( AllTrim( cID ) ) - 2 ) + "%'" 	
		cQuery += " AND " 	
	EndIf 		

	cQuery += " 	AO5.AO5_FILIAL = '" + xFilial( "AO5" ) + "'"
	cQuery += " 	AND " 
	cQuery += " 	AO5.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Executa a instrução SQL.  
	//-------------------------------------------------------------------	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )
	
	//-------------------------------------------------------------------
	// Lista o ID Inteligente do usuário. 
	//-------------------------------------------------------------------
	aAdd( aID, AllTrim( cID ) )

	//-------------------------------------------------------------------
	// Lista o ID Inteligente dos grupos do mesmo nível da estrutura. 
	//-------------------------------------------------------------------		
	While (cTemp)->( ! Eof() ) 
		aAdd( aID, AllTrim( (cTemp)->AO5_IDESTN ) )
	
		(cTemp)->( DbSkip() )
	Enddo
	
	( cTemp )->( DBCloseArea() )
		
	RestArea( aArea )
	
Return aID

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXTopAdm

Retorna se o usuário destino está acima na estrutura de negocio em relaçao ao usuário origem

@sample 	CRMXTopAdm( cUsrFrom, cUsrTo )

@param		ExpC1 - Codigo do usuário origem
			ExpC2 - Codigo do usuário destino

@Return   	ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		12/10/2013
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXTopAdm(cUsrFrom, cUsrTo)

Local lTopAdm    := .F.
Local aNvlFrom   := {}
Local aNvlTo     := {}

Default cUsrFrom := ""
Default cUsrTo   := ""

If !Empty( cUsrFrom ) .And. !Empty( cUsrTo )
	
	aNvlFrom := CRMXNvlEst( cUsrFrom )
	aNvlTo   := CRMXNvlEst( cUsrTo )
	
	If ( SubStr( aNvlTo[1], 0, Len( aNvlTo[1] ) - 2 ) == SubStr( aNvlFrom[1], 0, Len( aNvlTo[1] ) - 2 ) .And. aNvlTo[2] < aNvlFrom[2] )
		lTopAdm := .T.
	EndIf
EndIf

Return(lTopAdm)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXNvlEst

Retorna codigo inteligente e o nivel do usuario na estrutura de negocio.

@sample 	CRMXNvlEst(cCodUsr)

@param		ExpC1 - Codigo do Usuario

@Return   	ExpA - Nivel da Estrutura
					aNvlEstrut[1] - Nivel
					aNvlEstrut[2] - Código Inteligente

@author		Thiago Tavares
@since		24/03/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXNvlEst(cCodUsr)

Local aArea			:= GetArea()
Local aAreaUSR		:= {}
Local lPosUsr		:= .T.
Local aNvlEstrut	:= {"",0}

Default cCodUsr	:= CRMXCodUser()

If SuperGetMv("MV_CRMUAZS",, .F.)
	If !Empty( __aUserRole ) .And. __aUserRole[USER_PAPER_CODUSR] == cCodUsr 
		aNvlEstrut := { AllTrim( __aUserRole[USER_PAPER_IDESTN] ) , __aUserRole[USER_PAPER_NVESTN] }
	EndIf
Else	
	aAreaUSR := AO3->(GetArea())

	DbSelectArea("AO3")	// Usuarios do CRM
	DbSetOrder(1)       	// AO3_FILIAL + AO3_CODUSR

	If !Empty(cCodUsr)
		lPosUsr := AO3->( DbSeek( xFilial( "AO3" ) + cCodUsr ) )
	EndIf

	If (!Empty(cCodUsr) .AND. lPosUsr)
		aNvlEstrut := {AllTrim(AO3->AO3_IDESTN),AO3->AO3_NVESTN}
	ElseIf (!Empty(cCodUsr) .AND. !lPosUsr)
		aNvlEstrut := {"",0}
	EndIf
	RestArea(aAreaUSR)
EndIf

RestArea(aArea)

Return(aNvlEstrut)
	
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXFilSXB

Filtra as consultas padrao para o CRM.

@sample 	CRMXFilSXB(cAlias)

@param		ExpC1 - Alias Atual

@Return   	ExpC - Codicao do filtro

@author		Anderson Silva
@since		29/10/2013
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXFilSXB(cAliasEnt)
 
Local uFilSXB		:= Nil 
Local cFiltro		:= ""
Local aSX2Ent		:= {}
Local cConcat		:= "+"
Local cChvUnq		:= ""
Local aChvUnq 	:= {}
Local nLenChvUnq	:= 0
Local cSX2UnqSQL	:= ""
Local nX			:= 0
Local cPrxEnt		:= ""

If CRMXGFSXB()
	
	If cAliasEnt == "AD1" .And. IsInCallStack("FT321ATIV")
		uFilSXB := FT321Oport(.F.)
	Else
		cFiltro := CRMXFilEnt(cAliasEnt,.T.)
		uFilSXB := ""

		If !Empty(cFiltro)
			
			aSX2Ent := CRMXGetSX2(cAliasEnt,.T.)
			
			If !Empty(aSX2Ent)
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Define o simbolo de concatenacao de acordo com o banco³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
					cConcat := "||"
				Endif
				
				cPrxEnt	:= PrefixoCpo(cAliasEnt)
				cChvUnq	:= ( cPrxEnt + "_FILIAL+" + aSX2Ent[4] ) 
				aChvUnq 	:= StrTokArr(cChvUnq,"+")
				nLenChvUnq	:= Len(aChvUnq)
				
				For nX := 1 To nLenChvUnq
					If nX <> nLenChvUnqa
						cSX2UnqSQL	+= aChvUnq[nX]+cConcat
					Else
						cSX2UnqSQL	+= aChvUnq[nX]
					EndIf	
				Next nX
				
				If !Empty(cSX2UnqSQL)
					uFilSXB := "@ " + cSX2UnqSQL 
					uFilSXB += " IN ( SELECT AO4_CHVREG FROM " + RetSqlName("AO4") + " AO4"  
					uFilSXB += " WHERE AO4.AO4_FILIAL = '" + xFilial("AO4") + "' AND AO4.D_E_L_E_T_ <> '*'"
					uFilSXB += " AND " + cFiltro + " )"
				EndIf
				
			EndIf
			
		EndIf
	EndIf
Else
	//Tramento para filtrar Atividades do Faturamento.
	If cAliasEnt == "AD1" .And. IsInCallStack("FT321ATIV")
		uFilSXB := FT321Oport(.T.)	
	Else
		uFilSXB := .T.
	EndIf
EndIf

Return(uFilSXB)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXLibReg

Libera o registro caso o usuario possua acesso ao registro pela estrutura de
vendas ou se o mesmo estiver relacionado com o vendedor.

@sample 	CRMXLibReg( cAlias, cChave, nOrdem)

@param		ExpC1 - Alias
			ExpC2 - Chave de pesquisa
			ExpN3 - Ordem de pesquisa

@Return   	ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		31/10/2013
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXLibReg(cAliasEnt, cChave, nOrdem)

Local aArea			:= GetArea()
Local aAreaAO4		:= AO4->(GetArea()) 
Local cAliasAO4		:= GetNextAlias()
Local cFiltro		:= ""
Local lRetorno		:= .T.
Local cSQLLike		:= ""
Local nTam			:= 1

Default cAliasEnt 	:= ""
Default cChave    	:= ""
Default nOrdem    	:= 0

If !Empty(cAliasEnt) .And. nModulo == 73
	
	cFiltro 	:= CRMXFilEnt(cAliasEnt,.T.)
	
	If !Empty(cFiltro)
		
		cFiltro := "%" + cFiltro + "%"
		
		Do Case
			Case cAliasEnt == "AC3"
		 		nTam := TamSX3("AC3_CODCON")[1]
		 	Case cAliasEnt == "AC4"
		 		nTam := TamSX3("AC4_PARTNE")[1]
		 	Case cAliasEnt == "ACH"
		 		nTam := TamSX3("ACH_CODIGO")[1] + TamSX3("ACH_LOJA")[1]
			Case cAliasEnt == "AD1"
		 		nTam := TamSX3("AD1_NROPOR")[1]
		 	Case cAliasEnt == "ADY"
		 		nTam := TamSX3("ADY_PROPOS")[1] + TamSX3("ADY_PREVIS")[1]
		 	Case cAliasEnt == "AO3"
		 		nTam := TamSX3("AO3_CODUSR")[1]
		 	Case cAliasEnt == "AOC"
		 		nTam := TamSX3("AOC_CODIGO")[1]
		 	Case cAliasEnt == "SA1"
		 		nTam := TamSX3("A1_COD")[1] + TamSX3("A1_LOJA")[1]
		 	Case cAliasEnt == "SA2"
		 		nTam := TamSX3("A2_COD")[1] + TamSX3("A2_LOJA")[1]
		 	Case cAliasEnt == "SA3"
		 		nTam := TamSX3("A3_COD")[1]
		 	Case cAliasEnt == "SC5"
		 		nTam := TamSX3("C5_NUM")[1]
		 	Case cAliasEnt == "SU5"
		 		nTam := TamSX3("U5_CODCONT")[1]
		 	Case cAliasEnt == "SUO"
		 		nTam := TamSX3("UO_CODCAMP")[1]
		 	Case cAliasEnt == "SUS"
		 		nTam := TamSX3("US_COD")[1] + TamSX3("US_LOJA")[1]
		 	Case cAliasEnt == "AOH"
		 		nTam := TamSX3("AOH_CODIGO")[1]
		End Case
	
		If Empty(cChave)
			cChave := &(ReadVar())
			cChave := Left(cChave, nTam)
		EndIf
		
		DbSelectArea(cAliasEnt)
		nOrdem := If(nOrdem == 0,IndexOrd(),nOrdem)
		(cAliasEnt)->(DbSetOrder(nOrdem))
		
		DbSelectArea("AO4")		// Controle de Privilegios
		AO4->(DbSetOrder(1))		// AO4_FILIAL + AO4_ENTIDA + AO4_CHVREG + AO4_CODUSR
		
		If !Empty(cChave)
			
			If (cAliasEnt)->(MsSeek(xFilial(cAliasEnt)+cChave)) 
				
				cSQLLike := "%'%" + Alltrim( xFilial(cAliasEnt) + cChave )+ "%'%"
				
				If Select(cAliasAO4) > 0
					(cAliasAO4)->(DbCloseArea())
				EndIf
				
				BeginSql Alias cAliasAO4
					SELECT AO4.AO4_CHVREG
					FROM %Table:AO4% AO4
					WHERE AO4.AO4_FILIAL = %xFilial:AO4% AND %Exp:cFiltro% AND AO4_CHVREG LIKE %Exp:cSQLLike% AND AO4.%NotDel%
				EndSql
					
				lRetorno := !(cAliasAO4)->(Eof())
					
				(cAliasAO4)->(DbCloseArea())
				 
				If !lRetorno
					Help("",1,"CRMLIBREG")
				EndIf
				
			Else
				lRetorno := .F.
				Help("",1,"REGNOIS")
			EndIf
		
		Endif
		
	EndIf
	
EndIf

RestArea(aAreaAO4)
RestArea(aArea)

Return(lRetorno)

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXFilEnt()

Retorna os filtros para as entidades conforme a regra do CRM (Tabela de Privilégio AO4).

@sample 	CRMXFilEnt(cAliasEnt, lExpSql)

@param		ExpC1 - Alias atual
			ExpL2 - Indica como o filtro será montado  .T. - SQL .F. - ADVPL

@Return   	ExpC - Expressao

@author		Thiago Tavares
@since		24/03/2014
@version	12.0
/*/
//--------------------------------------------------------------------------------------
Function CRMXFilEnt(cAliasEnt, lExpSql)

Local aArea			:= {}
Local cFiltro		:= ""
Local cCodUsr		:= ""
Local cIdUserPaper	:= ""
Local lChgUserPaper	:= .F.
Local aNvlEstrut	:= {}
Local aNlvEstFmt	:= {}
Local lExtEstNeg	:= .F.
Local aRetEqUd 		:= {}
Local aPEVar		:= {}
Local nLevel		:= 0
Local nLenNlvEst	:= 0

Default cAliasEnt	:= ""
Default lExpSQL		:= .F.

If nModulo == 73
	aArea := GetArea()
	If !Empty( __aUserRole ) 
		cCodUsr	 	 := __aUserRole[USER_PAPER_CODUSR]
		cIdUserPaper := __aUserRole[USER_PAPER_SEQUEN] + __aUserRole[USER_PAPER_CODPAPER]
	Else
		cCodUsr := CRMXCodUser()
	EndIf 

	If ( cCodUsr <> __aFilEntCache[1] .Or. cIdUserPaper <> __aFilEntCache[2] )
		lChgUserPaper := .T.
	EndIf

	lExtEstNeg	:= SuperGetMv("MV_CRMESTN",.F.,.F.)

	If ( cCodUsr <> "000000" .And. !Empty(cAliasEnt) .And. lExtEstNeg .And. cAliasEnt $ CRMXCtrlEnt() )
		If  ( lChgUserPaper .Or. cAliasEnt <> __aFilEntCache[3] )
			__aFilEntCache[1] := cCodUsr
			__aFilEntCache[2] := cIdUserPaper
			__aFilEntCache[3] := cAliasEnt
			
			aNvlEstrut	:= CRMXNvlEst(cCodUsr)
			aNlvEstFmt	:= CRMXFmtNvl(aNvlEstrut[1])
			aRetEqUd 	:= CRMXVdEqUd(cCodUsr)
			
			If lExpSQL 
				If aNvlEstrut[2] == 0
					cFiltro := " ( AO4_FILIAL ='" + xFilial("AO4") + "' AND AO4_ENTIDA = '" + cAliasEnt + "' AND (" 
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += "( AO4_CODUSR = '" + cCodUsr + "' AND ( AO4_USRPAP = '" + cIdUserPaper + "' OR AO4_USRPAP = ' ' ) ) "
					Else
						cFiltro += "AO4_CODUSR = '" + cCodUsr + "' "
					EndIf
					cFiltro += " AND ( ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = ' ' ) OR AO4_CTRLTT = 'T' ) ) )"
				Else
					cFiltro := " ( AO4_FILIAL ='" + xFilial("AO4") + "' AND AO4_ENTIDA = '" + cAliasEnt + "' AND ("
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += " ( AO4_CODUSR = '" + cCodUsr + "' AND ( AO4_USRPAP = '" + cIdUserPaper + "' OR AO4_USRPAP = ' ' ) ) "
					Else
						cFiltro += " AO4_CODUSR = '" + cCodUsr + "'"
					EndIf
				
					If	Len(aRetEqUd) > 0
						If	!Empty(aRetEqUd[1])
							cFiltro += " OR ( AO4_CODEQP = '"+Alltrim(aRetEqUd[1])+"' ) AND ( ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = '"+Space(08)+"' ) OR AO4_CTRLTT = 'T' ) "
						Endif  
		
						If	!Empty(aRetEqUd[2])
							cFiltro += " OR ( AO4_CODUND = '"+Alltrim(aRetEqUd[2])+"' ) AND ( ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = '"+Space(08)+"' ) OR AO4_CTRLTT = 'T' ) "
						Endif					
					Endif
								
					nLenNlvEst := Len( aNlvEstFmt )
					
					For nLevel := 1 To nLenNlvEst 
						If nLevel == 1
							cFiltro += " OR ( "
						EndIf
						cFiltro += "( AO4_IDESTN LIKE '" + aNlvEstFmt[nLevel] + "%' )"
						If( nLevel < nLenNlvEst ) 
							cFiltro += " OR "
						EndIf 
						If nLevel == nLenNlvEst
							cFiltro += " )  "	
						EndIf
					Next nLevel 
				
					cFiltro += " ) "
						
					cFiltro += " AND ( AO4_CTRLTT = 'T' OR ( AO4_DTVLD >= '" + dTos(MsDate()) + "' OR AO4_DTVLD = ' ' ) )  "
					
					cFiltro += " ) " 
					
				EndIf
			Else
				If aNvlEstrut[2] == 0		
					cFiltro := "( AO4_FILIAL ='" + xFilial("AO4") + "' .AND. AO4_ENTIDA == '" + cAliasEnt + "' .AND. ("
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += "( AO4_CODUSR == '" + cCodUsr + "' .AND. ( AO4_USRPAP == '" + cIdUserPaper + "' .OR. OR AO4_USRPAP == ' ' ) ) "
					Else
						cFiltro += "AO4_CODUSR == '" + cCodUsr + "' "
					EndIf
					cFiltro += ".AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty(AO4_DTVLD) ) .OR. AO4_CTRLTT ) ) )"
				Else
					cFiltro := "( AO4_FILIAL ='" + xFilial("AO4") + "' .AND. AO4_ENTIDA == '" + cAliasEnt + "' .AND. ( ( ("
				
					For nLevel := 1 To Len( aNlvEstFmt )
						cFiltro += " ( AO4_IDESTN == '" + aNlvEstFmt[nLevel] + "' OR SubStr( AO4_IDESTN, 1, " + cBIStr( Len( aNlvEstFmt[nLevel] ) ) + " ) == '" + aNlvEstFmt[nLevel] + "' ) "		
						If( nLevel < Len( aNlvEstFmt ) ) 
							cFiltro += " .OR. "
						EndIf 		
					Next nLevel
				
					cFiltro += " )  "
					If SuperGetMv("MV_CRMUAZS",, .F.)
						cFiltro += " .OR. ( AO4_CODUSR == '" + cCodUsr + "' .AND. ( AO4_USRPAP = '" + cIdUserPaper + "' .OR. OR AO4_USRPAP == ' ' ) ) " "
					Else
						cFiltro += " .OR. AO4_CODUSR == '" + cCodUsr + "' "
					EndIf
					cFiltro += ") .AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty( AO4_DTVLD ) ) .OR. AO4_CTRLTT ) ) "
					 
					If	Len(aRetEqUd) > 0
						If	!Empty(aRetEqUd[1])
							cFiltro += ".OR. ( ( AO4_CODEQP == '"+Alltrim(aRetEqUd[1])+"' ) .AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty(AO4_DTVLD) ) .OR. AO4_CTRLTT  ) ) "					
						Endif  
		
						If	!Empty(aRetEqUd[2])
							cFiltro += ".OR. ( ( AO4_CODUND == '"+Alltrim(aRetEqUd[2])+"' ) .AND. ( ( AO4_DTVLD >= MsDate() .OR. Empty(AO4_DTVLD) ) .OR. AO4_CTRLTT  ) ) " 							
						Endif  
					Endif
					 
					cFiltro += " )"
				EndIf
			EndIf
			
			If lCrmFilEnt == Nil
				lCrmFilEnt := ExistBlock("CRMFILENT")
			EndIf

			If lCrmFilEnt
				aPEVar	:= {cAliasEnt, lExpSql, cFiltro}
				cFilPE := ExecBlock("CRMFILENT", .F., .F.,aPEVar)
				
				If ValType(cFilPE) == "C" .And. !Empty(cFilPE)
					cFiltro := cFilPE
				EndIf 
			EndIf
			
			__aFilEntCache[4] := cFiltro
		Else
			cFiltro := __aFilEntCache[4]
		EndIf
	EndIf
	
	RestArea(aArea)
	
EndIf

Return(cFiltro) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXCpoFil

Retorna os campos que serão utilizados na composicao do filtro no CRM.

@sample 	CRMXCpoFil(cAlias)

@param		ExpC1 - Alias

@return   	ExpA - Campos genericos

@author		Anderson Silva
@since		01/11/2013
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXCpoFil(cAlias)

Local aCampos := {}

If ( cAlias $ "ACH|SUS|SA1|SU5|AD1|AD2|AD5|SC5|SCT|AD7|AD8" )
	
	aAdd(aCampos,"_FILIAL")
	
	If cAlias == "SU5"
		aAdd(aCampos,"_CODSA3")
	ElseIf cAlias == "SC5"
		aAdd(aCampos,"_VEND1")
	Else
		aAdd(aCampos,"_VEND")
	EndIf
	
	If !( cAlias $ "SC5|SCT" )
		aAdd(aCampos,"_IDESTN")
		aAdd(aCampos,"_NVESTN")
	EndIf
	
EndIf

Return(aCampos)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXCRGAO2()

Função efetua a carga na tabela AO2 com as entidades permitidas.

Estrutura do Array para gravar na AO2 {{AO2_ENTID,AO2_ESPEC,AO2_ATIV,AO2_CONEX,AO2_ANOTAC,AO2_MEMAIL,AO2_CEMAIL}}

@sample 	CRMXCRGAO2()

@param		Nenhum

@return		Nenhum

@author		Victor Bitencourt
@since		13/02/2014
@version	12.0
/*/
//---------------------------------------------------------------------
Function CRMXCRGAO2()

Local lCRMCRGA 		:= SuperGetMv("MV_CRMCRGA",,.F.)//Indica se a tabela AO2 deverá receber a carga inicial.
Local aEntidade  	:= {}
Local nX            := 0
Local aAreaAO2      := {}

Private lMsErroAuto	:= .F.

If lCRMCRGA
	
	If Select("AO2") > 0
		aAreaAO2 := AO2->(GetArea())
	Else
		DbSelectArea("AO2")//Controle de Entidades
	EndIf
	
	AO2->(DbSetOrder(1))//AO2_FILIAL+AO2_ENTID
	
	aEntidade := {{"SA1","1","1","1","1","1","1","1"},{"ACH","1","1","1","1","1","1","1"},{"SUS","1","1","1","1","1","1","1"},;
	              {"SU5","1","1","1","1","1","1","1"},{"AD1","1","1","1","1","1","1","1"},{"AD5","1","2","2","2","2","1","1"},;
	              {"AC3","1","1","1","1","1","1","1"},{"SB1","1","2","1","1","2","2","2"},{"SBM","1","2","2","2","2","2","2"},;
	              {"ACU","1","2","2","2","2","2","2"},{"AC1","1","2","1","1","2","1","2"},{"SA3","1","1","1","1","1","1","1"},;
	              {"ADK","1","2","1","1","2","1","2"},{"ACA","1","2","1","1","1","1","2"},{"SUN","1","2","2","2","2","1","2"},;
	              {"DA0","1","2","1","1","2","1","2"},{"SE4","1","2","2","2","2","1","2"},{"ACO","1","2","2","2","2","1","2"},;
	              {"ACD","1","2","2","1","2","1","1"},{"SUZ","1","2","2","2","2","2","2"},{"SUO","1","1","2","1","1","1","1"},;
	              {"AC6","1","2","2","2","2","2","1"},{"AC5","1","2","2","2","2","2","2"},{"SCT","1","2","2","2","2","2","1"},;
	              {"SUM","1","2","2","2","2","1","2"},{"SC5","1","1","1","1","1","1","1"},{"SA2","1","1","1","1","1","1","1"},;
	              {"AC4","1","1","1","1","1","1","1"},{"ADY","1","1","1","1","1","1","2"},{"AC9","2","2","2","1","2","2","2"},;
	              {"AD3","2","2","2","1","2","2","2"},{"AOC","2","1","2","1","1","2","1"},{"SU4","2","2","2","2","1","2","1"},;
	              {"CC2","2","2","2","2","2","1","2"},{"SYA","2","2","2","2","2","1","2"},{"CC3","2","2","2","2","2","1","2"},;
	              {"SUH","2","2","2","2","2","1","2"},{"ACY","2","2","2","2","2","1","2"},{"SA4","2","2","2","2","2","1","1"},;
	              {"ACJ","2","2","2","2","2","1","2"},{"AC2","2","2","2","2","2","1","2"},{"SUM","2","2","2","2","2","1","2"},;
	              {"SM2","2","2","2","2","2","1","2"},{"AO3","2","1","1","1","1","1","1"}}
	
	
	For nX := 1 To Len(aEntidade)
		If !AO2->(DbSeek(xFilial("AO2")+aEntidade[nX,1]))
			aExecAuto := {{"AO2_FILIAL",xFilial("AO2")		,Nil},;
			              {"AO2_ENTID" ,aEntidade[nX,1]	,Nil},;
			              {"AO2_ESPEC" ,aEntidade[nX,2]	,Nil},;
			              {"AO2_ATIV"  ,aEntidade[nX,3]	,Nil},;
			              {"AO2_CONEX" ,aEntidade[nX,4]	,Nil},;
			              {"AO2_ANOTAC",aEntidade[nX,5]	,Nil},;
			              {"AO2_MEMAIL",aEntidade[nX,6]	,Nil},;
			              {"AO2_CEMAIL",aEntidade[nX,7]	,Nil},;
			              {"AO2_WAVIEW",aEntidade[nX,8]	,Nil} }
			CRMA220( aExecAuto, 3 ) // Importar agenda por rotina automatica
		EndIf
	Next nX
	
	PutMv("MV_CRMCRGA",.F.)
	
	If !Empty(aAreaAO2)
		RestArea(aAreaAO2)
	EndIf
	
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXIncRot
Rotina que inclui no aRotina funções que deveram ser permitidas em determinadas entidades.
@sample 	CRMXIncRot(cAlias, aRotina)
@param		ExpC1 - Alias Entidade que está chamando
			ExpA1 - Array contendo as rotinas que Entidade tem acesso
@return	aRotina - Contendo as rotinas adicionadas para essa Entidade
@author		Victor Bitencourt
@since		12/02/2014
@version	12.0
/*/
//---------------------------------------------------------------------
Function CRMXIncRot(cAlias, aRotina)

Local nX			:= 0
Local aArea	    	:= {}
Local aFunctions 	:= {}

Default cALias 		:= ""
Default aRotina  	:= {}

If Select("SX2") > 0 .And. Select("SIX") > 0 .And. !Empty(cAlias)
	aArea := GetArea()
	AO2->( DBSetOrder( 1 ) )//AO2_FILIAL+AO2_ENTID
	If AO2->(DbSeek(xFilial("AO2")+cAlias))
		aAdd(aFunctions,{"AO2_ESPEC" ,"CRMA130()"   ,STR0006})	// Especificacoes
		aAdd(aFunctions,{"AO2_ATIV"  ,"CRMA180()"   ,STR0007})	// Atividades
		aAdd(aFunctions,{"AO2_CONEX" ,"CRMA190()"   ,STR0008})	// Conexoes
		aAdd(aFunctions,{"AO2_ANOTAC","CRMA090()"   ,STR0009})	// Anotacoes
		aAdd(aFunctions,{"AO2_CONEX" ,"CRMA190Con()",STR0010})  // Conectar
		For nX := 1 To Len(aFunctions)
			If AO2->&(aFunctions[nX,1]) == "1"
				If aFunctions[nX,1] == "AO2_ATIV" .AND. nModulo <> 73 .AND. nModulo <> 99
					// 1) Rotina de atividades deve aparecer somente no modulo CRM
					// 2) Os itens do submenu das rotinas das 'Atividades' ficarão disponíveis ao módulo SIGACFG para que seja possível 
					//    a configuração dos privilégios de acesso do usuário quando as opções da rotina CRMA110 forem solicitadas pela
					//    rotina CFGA530 do SIGACFG.
					Loop
				EndIf
				aAdd(aRotina,{aFunctions[nX,3],aFunctions[nX,2], 0 , 8,0 ,.T.})
			EndIf
		Next nX
	EndIf
	RestArea(aArea)
	aSize(aArea,0)
EndIf
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMXObserver

Função que controla o CRUD do browse e consulta padrão

@author 	Jonatas Martins
@since 		24/08/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Function CRMXObserver() 

Local lExtEstNeg	   		:= .F. 
Local oMBrowseObserver	:= Nil 
Local oConPadObserver  	:= Nil

If !lInitObserver
	lExtEstNeg := GetMv("MV_CRMESTN",.F.,.F.)
	If ( nModulo == 73 .And. lExtEstNeg )
		oMBrowseObserver := SIGACRMBrowseAccessObserver():New()
		oConPadObserver  := SIGACRMConPadButtonObserver():New()
	
		PTIMbObserver("BROWSEEXEC",oMBrowseObserver)
		PTConPadObserver("BTNACTIONS",oConPadObserver)
	
		//-------------------------------------------
		//Utilizamos o mesmo Observer que na Conpad
		//-------------------------------------------
		PTLookUpObserver( "BTNACTIONS", oConPadObserver )
		lInitObserver := .T.
		__OnlyBrowseObs := .F.
	Else
		oMBrowseObserver := SIGACRMBrowseAccessObserver():New()
		PTIMbObserver("BROWSEEXEC",oMBrowseObserver)

		lInitObserver := .T.
		__OnlyBrowseObs := .T.
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SIGACRMBrowseAccessObserver

Classe que controla o permissionamento dos browses abertos pelo
modulo SIGACRM.

@author 	Thiago Tavares
@since 		27/03/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Class SIGACRMBrowseAccessObserver From FWObserver
	Method New()
	Method Update()
	Method GetName()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe

@author 	Thiago Tavares
@since 		27/03/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Method New() Class SIGACRMBrowseAccessObserver
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Update

Método chamado quando algo ocorrer no observador.

@author 	Thiago Tavares
@since 		27/03/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Method Update(oObservable, lAccess, cSourceName, cFunction, nOption) Class SIGACRMBrowseAccessObserver

If ( IsInCallStack("CRMA290") .And. !IsInCallStack("CRMA290RFUN") )
	CRM290ClrFil(nOption, .T., cSourceName)
EndIf

If !__OnlyBrowseObs
	lAccess := CRMXBrwF3Acess(oObservable, lAccess, cSourceName, cFunction, nOption)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetName
Necessario ID unico para esse observador.

@author 	Thiago Tavares
@since 		27/03/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Method GetName() Class SIGACRMBrowseAccessObserver
Return("SIGACRMBrowseAccessObserver")

//-----------------------------------------------------------------------------------------------------
// --------------------------------------- CONSULTA PADRAO --------------------------------------------
/*/{Protheus.doc} SIGACRMConPadButtonObserver

Classe que controla o permissionamento das consultas padroes
abertas pelo modulo SIGACRM.

@author Thiago Tavares
@since 27/03/2014
@version P12
/*/
//-------------------------------------------------------------------
Class SIGACRMConPadButtonObserver From FWObserver
	Method New()
	Method Update()
	Method GetName()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe

@author Thiago Tavares
@since 27/03/2014
@version P12
/*/
//-------------------------------------------------------------------
Method New() Class SIGACRMConPadButtonObserver
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetName
Necessario ID unico para esse obsever

@author	Thiago Tavares
@since 		27/03/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Method GetName() Class SIGACRMConPadButtonObserver
Return("SIGACRMConPadButtonObserver")

//-------------------------------------------------------------------
/*/{Protheus.doc} Update
Método chamado quando algo ocorrer no observador.

@author 	Thiago Tavares
@since 		27/03/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Method Update(oObservable, lAccess, cSourceName, nOption) Class SIGACRMConPadButtonObserver

lAccess := CRMXBrwF3Acess(oObservable, lAccess, cSourceName,,nOption)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXAddAct()

Rotina para adicionar rotinas em ações relacionadas dos formulários

@sample 	CRMXAddAct(cAlias, uObj)

@param		ExpU1 - Ojejeto indefinido pode ser (oView) ou (aButtons)

@return		Nenhum

@author		Victor Bitencourt
@since		12/05/2014
@version	12.0
/*/
//---------------------------------------------------------------------
Function CRMXAddAct(cAlias, uObj)

Local nX        := 0
Local nOper		:= 0
Local aButtons	:= {}
Local aEntRelac	:= {}
Local lCRM      := IIF(nModulo == 73 , .T., .F.)
Local oView	    := Nil

Default cAlias	:= ""
Default uObj	:= Nil


// Pegando a operação
Do Case
	Case Type("ALTERA")== "L" .AND. ALTERA
		nOper := 4//Alterar
	Case  Type("INCLUI")== "L" .AND. INCLUI
		nOper := 3//Incluir	
	OtherWise
		nOper := 1//Visualizar
EndCase

If uObJ <> Nil .AND. ValType(uObj) == "O" .AND. !Empty(cAlias)
	
	oView    := uObj
	
	Do Case // Este case é somente para as rotinas que tenha funções especificas pra elas , no 'ações relaciondas'
		Case cAlias == "SUS" //Prospects
			oView:AddUserButton(STR0025,"",{ || Tka260Per() },,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Perfil"
			oView:AddUserButton(STR0026,"",{ || TkLstScr(4,"SUS", SUS->US_COD, SUS->US_LOJA) },,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Scripts De Campanha"			
			oView:AddUserButton(STR0028,"",{ || CRMXNewOpo("SUS",SUS->US_COD,SUS->US_LOJA) } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Nova Oportunidade"
			oView:AddUserButton(STR0029,"",{ || CRMA110() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Todas as Oportunidades"
			oView:AddUserButton(STR0030,"",{ || CRMXNewApo("SUS",SUS->US_COD,SUS->US_LOJA) } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Novo Apontamento"
			oView:AddUserButton(STR0031,"",{ || CRMA330() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Todos os Apontamentos"
			
		Case cAlias == "AOC"//Campanhas rapidas
			oView:AddUserButton(STR0032,"",{ || CRMA260() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Respostas de Campanha"
			oView:AddUserButton(STR0033,"",{ || Tk310Memb() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Membros de Campanha"
			oView:AddUserButton(STR0034,"",{ || CRM250ATIV() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Distribuir Atividades"
			
		Case cAlias == "AOD"//Respostas de Campanha
			oView:AddUserButton(STR0035,"",{ || CRMA260Conv() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Converter Resposta de Campanha"
			
		Case cAlias == "ACH"//Suspects
			oView:AddUserButton(STR0037,"",{ || Tk341Prospect() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Prospect"		
			
		Case cAlias == "SUO"//Campanhas
			oView:AddUserButton(STR0038,"",{ || CRMA260() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Respostas de Campanha"
			oView:AddUserButton(STR0033,"",{ || Tk310Memb() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Membros da Campanha"
			oView:AddUserButton(STR0034,"",{ || Tk310Ativ() } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Distribuir Atividades"
		
		Case cAlias == "SA1"
			If cPaisLoc == "BRA" .And. FindFunction("FSA172VIEW")
				oView:AddUserButton(STR0134,'', {|| FSA172VIEW({"CLIENTE", SA1->A1_COD, SA1->A1_LOJA})},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE}) //"Perfis Tributários"
			EndIf
	EndCase
	
	If lCRM
		
		aEntRelac := CRMXINCROT(cAlias,aEntRelac)
		
		For nX := 1 to Len(aEntRelac)
			Do Case
				Case aEntRelac[nX][2] == "CRMA190Con()"//Conectar
					oView:AddUserButton("Conectar","",{ || CRMA190Con(cAlias) } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Contato"
					
				Case aEntRelac[nX][2] == "CRMA180()"//Atividades
					If cAlias <> "AOC"
						oView:AddUserButton(STR0039,"",{ ||  CRMA180(,,,3,cAlias) } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Nova Atividade"
					EndIf
					oView:AddUserButton(STR0040,"",{ ||  CRMA180(,,,,cAlias)  } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Todas as Atividades"
					
				Case aEntRelac[nX][2] == "CRMA090()" //Anotação
					oView:AddUserButton(STR0041,"",{ || CRMA090(3,cAlias)       } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Contato"
					oView:AddUserButton(STR0042,"",{ || CRMA090(,cAlias)   } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Contato"
					
				Case aEntRelac[nX][2] == "CRMA190()"//Conexoes
					oView:AddUserButton(STR0008,"",{ || CRMA190(cAlias) } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Conexoes"
					
				Case aEntRelac[nX][2] == "CRMA130()"//Especificacoes"
					oView:AddUserButton(STR0006,"",{ || CRMA130(cAlias) } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Especificacoes"
			EndCase
		Next nX
		
		If ! cAlias $ "AC3|AC4|"
			oView:AddUserButton(STR0043,"",{ || CRMA200(cAlias) } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Privilégios"
		EndIf
		
	EndIf
	
	If !cAlias $ "AD1|ADY|AC3|SUO|AOD|AOC"
		oView:AddUserButton(STR0044,"",{ ||  CRMA060( cAlias, (cAlias)->(RecNo()),Iif(nOper <> 1, 4, 1))  } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Contato" 
	EndIf
	
	If !cAlias $ "SUO|AOD|AOC"
		oView:AddUserButton(STR0045,"",{ || MsDocument( cAlias, (cAlias)->(RecNo()),nOper)  } ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Conhecimento"
	EndIf
	
	Asort(oView:aUserButtons,,,{ | x,y | y[1] > x[1] } )
	
	uObj := oView
	
ElseIf uObJ <> Nil .AND. ValType(uObj) == "A" // aButtons
	
	aButtons := Aclone(uObj)
	
	Do Case // Este case é somente para as rotinas que tenha funções especificas pra elas , no 'ações relaciondas'
		Case cAlias == "SA1" //Clientes
			
			Aadd(aButtons,{"", { || CRMXNewOpo("SA1",SA1->A1_COD,SA1->A1_LOJA) } ,STR0028})//"Nova Oportunidade"
			Aadd(aButtons,{"", { || CRMA110() } ,STR0029})//"Nova Oportunidade"
			
			Aadd(aButtons,{"", { || CRMXNewApo("SA1",SA1->A1_COD,SA1->A1_LOJA)} ,STR0030})//"Novo Apontamento"
			Aadd(aButtons,{"", { || CRMA330() } ,STR0031})//"Todos os Apontamentos"
			
			Aadd(aButtons,{"", { || CRMA310(,cAlias) } ,STR0051})//"Cons. Pedido de Venda"
			Aadd(aButtons,{"", { || Mata030Ref("SA1",SA1->(RecNo()), nOper)  } ,STR0050})//"Referencias"
			Aadd(aButtons,{"", { || CRMA120() } ,STR0049})//"SubClientes"			
			Aadd(aButtons,{"", { || A030Per() } ,STR0025})//"Perfil"

			// Não habilitar na inclusão
			If cPaisLoc == "BRA" .And.  FindFunction("FSA172VIEW") .And. nOper <> 3
				Aadd(aButtons,{"", { || FSA172VIEW({"CLIENTE", SA1->A1_COD, SA1->A1_LOJA})} ,"Perfis Tributários"})
			EndIf
			
		Case cAlias == "SU5"//Contatos
			Aadd(aButtons,{"", { || CRMA440() } ,STR0025})//"Perfil"
			Aadd(aButtons,{"", { || CRMA150() } ,STR0049})//"SubContatos"
			
		Case cAlias == "SU4"//Contatos
			If lCRM
				Aadd(aButtons,{"", { || CRMA250() } ,STR0048})//"Campanha Rápida"
			EndIf
			
		Case cAlias == "SB1"//Produtos
			Aadd(aButtons,{"", { || CRMA160() } ,STR0047})//"Adic. Tab. Preço"
			Aadd(aButtons,{"", { || SaveInter(),A010ComPrd(SB1->B1_COD,nOper),RestInter() } ,STR0046})//"Complemento do produto"
			
	EndCase
	
	If lCRM
		
		aEntRelac := CRMXINCROT(cAlias,aEntRelac)
		
		For nX := 1 to Len(aEntRelac)
			Do Case
				Case aEntRelac[nX][2] == "CRMA190Con()"//Conectar
					Aadd(aButtons,{"", { || CRMA190Con(cAlias) } ,"Conectar"})//"Conectar"
				Case aEntRelac[nX][2] == "CRMA180()"//Atividades
					Aadd(aButtons,{"", { || CRMA180(,,,3,cAlias) } ,STR0039})//"Nova Atividade"
					Aadd(aButtons,{"", { || CRMA180(,,,,cAlias) } ,STR0040})//"Todas as Atividades"
					
				Case aEntRelac[nX][2] == "CRMA090()" //Anotação
					Aadd(aButtons,{"", { || CRMA090(3,cAlias) } ,STR0041})//"Nova Anotação"
					Aadd(aButtons,{"", { || CRMA090(,cAlias) } ,STR0042})//"Todas as Anotações"
					
				Case aEntRelac[nX][2] == "CRMA190()"//Conexoes
					Aadd(aButtons,{"", { || CRMA190(cAlias) } ,STR0008})//"Conexoes"
					
				Case aEntRelac[nX][2] == "CRMA130()"//Especificacoes"
					Aadd(aButtons,{"", { || CRMA130(cAlias) } ,STR0006})//"Especificacoes"
			EndCase
		Next nX
		
		If ! cAlias $ "SB1"
			Aadd(aButtons,{"", { || CRMA200(cAlias) } ,STR0043})//"Privilégios"
		EndIf
	EndIf
	
	If !cAlias $ "SC5|SU5|SU4|SB1"
		Aadd(aButtons,{"", { || CRMA060( cAlias, (cAlias)->(RecNo()),Iif(nOper <> 1, 4, 1)) } ,STR0044})//"Contato"
	EndIf
	
	If !cAlias $ "SU5|SU4|"
		Aadd(aButtons,{"", { || MsDocument( cAlias, (cAlias)->(RecNo()),nOper) } ,STR0045})//"Conhecimento"
	EndIf
	
	Asort(aButtons,,,{ | x,y | y[3] > x[3] } )
	uObj := aButtons
	
EndIf

Return(uObj)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXHerdaPer

Funcao para usuario superior da estrutura de negocio, herdar os permissionamentos
de seus subordinados de um determinado registro.

@sample 	CRMXHerdaPer(cAliasEnt, cChave)

@param		ExpC1 - Entidade que possui Controle de Privilegios do Registro.
			ExpC2 - Chave Unica.

@Return   	ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		17/08/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXHerdaPer(cAliasEnt, cChave)

Local cAliasAO4		:= GetNextAlias()
Local cCodUserSub	:= ""
Local cFiltro 		:= ""
Local cFilEnt 		:= ""
Local lCtrlTotal	:= .F.
Local lPerVis		:= .F.
Local lPerEdt		:= .F.
Local lPerExc		:= .F.
Local lPerCom		:= .F.
Local aPerHerdada	:= {}

Default cAliasEnt	:= ""
Default cChave		:= ""

cFilEnt := CRMXFilEnt(cAliasEnt,.T.)
If !Empty(cFilEnt)
	cFiltro := "%" + cFilEnt + "%"
EndIf

If !Empty(cFiltro)
	
	BeginSql Alias cAliasAO4
		SELECT AO4.AO4_CODUSR, AO4.AO4_CTRLTT, AO4.AO4_PERVIS, AO4.AO4_PEREDT, AO4.AO4_PEREXC, AO4.AO4_PERCOM
		FROM %Table:AO4% AO4
			WHERE AO4.AO4_FILIAL = %xFilial:AO4% AND AO4.AO4_CHVREG = %Exp:cChave% AND %Exp:cFiltro% AND AO4.%NotDel%
	EndSql

	While (cAliasAO4)->(!Eof())
		
		TCSetField((cAliasAO4),"AO4_CTRLTT","L",1,0)
		TCSetField((cAliasAO4),"AO4_PERVIS","L",1,0)
		TCSetField((cAliasAO4),"AO4_PEREDT","L",1,0)
		TCSetField((cAliasAO4),"AO4_PEREXC","L",1,0)
		TCSetField((cAliasAO4),"AO4_PERCOM","L",1,0)
		
		cCodUserSub	:= (cAliasAO4)->AO4_CODUSR
		lPerCom	:= (cAliasAO4)->AO4_PERCOM
		
		Do Case
			Case (cAliasAO4)->AO4_CTRLTT
				lCtrlTotal := .T.
			Case ( (cAliasAO4)->AO4_PEREDT .OR. (cAliasAO4)->AO4_PEREXC )
				lPerVis	:= (cAliasAO4)->AO4_PERVIS
				lPerEdt	:= (cAliasAO4)->AO4_PEREDT
				lPerExc	:= (cAliasAO4)->AO4_PEREXC
			Case (cAliasAO4)->AO4_PERVIS
				lPerVis	:= (cAliasAO4)->AO4_PERVIS
		EndCase
		
		aPerHerdada := {cCodUserSub,lCtrlTotal,lPerVis,lPerEdt,lPerExc,lPerCom}
		
		If lCtrlTotal
			Exit
		EndIf
		
		(cAliasAO4)->(DbSkip())
	End

EndIf

Return(aPerHerdada)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXCtrlEnt()

Entidades que será controlada pelo Controle de Privilegios do CRM.

@sample 	CRMXCtrlEnt()

@param		Nenhum

@Return   	ExpC - Lista de Entidades

@author		Anderson Silva
@since		12/09/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXCtrlEnt()

Local lCRMXCtrEnt	:= ExistBlock("CRMXCTRENT")
Local cEntCtrlPri	:= "AC6|ACB|ACD|ACH|AD1|AD5|AIN|AOC|AOD|AOF|AOH|SA1|SC5|SCT|SU4|SU5|SUO|SUS|SUZ|AOJ|"
Local aEntCtrlPri	:= {}
Local aRetorno		:= ""
Local nX			:= 0

If lCRMXCtrEnt
	aEntCtrlPri := StrTokArr(cEntCtrlPri,"|")
	aRetorno := ExecBlock("CRMXCTRENT",.F.,.F.,{ aEntCtrlPri })
	If ValType(aRetorno) == "A" 
		cEntCtrlPri := ""
		For nX := 1 To Len(aRetorno)
			cEntCtrlPri += aRetorno[nX]+"|"
		Next nX	
	EndIf
EndIf

Return(cEntCtrlPri)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXVdEqUd()

Retorna equipe e unidade de venda do vendedor 

@sample 	CRMXCtrlEnt()

@param		ExpC - Codigo do Usuario 

@Return   	ExpA - Codigo da equipe / Codigo da unidade  

@author	Eduardo Gomes Junior 
@since		06/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXVdEqUd(cCodUser)

Local aArea		:= GetArea()
Local aRetorno	:= {"",""}

If SuperGetMv("MV_CRMUAZS",, .F.)
	If ( !Empty( __aUserRole ) .And. __aUserRole[USER_PAPER_CODUSR] == cCodUser )
		aRetorno[1] := __aUserRole[USER_PAPER_CODEQP]
		aRetorno[2] := __aUserRole[USER_PAPER_CODUND]
	EndIf
Else
	dbSelectArea("AO3")
	dbSetOrder(1)
	If	dbSeek(xFilial("AO3")+cCodUser)
		aRetorno[1] := AO3_CODEQP
		aRetorno[2] := AO3_CODUND	
	Endif
EndIf

RestArea(aArea)

Return( aRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXVlPriv()

Retorna a prioridades/privilegios do registro

@sample 	CRMXCtrlEnt()

@param		ExpC1 - Alias da entidade
			ExpC2 - Chave da entidade 
			ExpC3 - Codigo do usuario  

@Return   	ExpA1 - Array contendo prioridades/privilegios do registro 

@author	Eduardo Gomes Junior 
@since		06/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXVlPriv(cAliasEnt,cChave,cCodUsr)

Local aArea			:= GetArea()
Local aAreaAO4		:= AO4->(GetArea())
Local cPrioriza		:= CRMXBsPrio(cAliasEnt,cChave,cCodUsr) //0-Soma / 1-Usuario / 2-Equipe / 3-Unidade
Local cChvApl		:= ""
Local cCdUsrPos		:= ""
Local aPermPri		:= {}
Local aPermSum		:= {}
Local lCtrlTotal	:= .F.
Local lPerVis		:= .F.
Local lPerEdt		:= .F.
Local lPerExc		:= .F.
Local lPerCom		:= .F.
Local aRetEqUd	 	:= CRMXVdEqUd(cCodUsr)
Local nLe			:= 1
Local cSequApl		:= ""
Local nIndexApl		:= 1

If cPrioriza == "0"	// Soma

	DbSelectArea("AO4")
	
	For nLe := 1 To 3
		//-----------------------------------------------------
		// Monta chave e índice de busta do permissionamento   
		//-----------------------------------------------------	
				Do Case
			Case nLe == 1
				nIndexApl := 1	//AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
				If !Empty(cCodUsr)
					cChvApl := cAliasEnt + cChave + cCodUsr
				EndIf
			Case nLe == 2
				nIndexApl := 3	//AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODEQP
				If !Empty( aRetEqUd[1]) 
					cChvApl := cAliasEnt + cChave + aRetEqUd[1]
				EndIf
			Case nLe == 3
				nIndexApl := 4	//AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUND
				If !Empty(aRetEqUd[2])
					cChvApl := cAliasEnt + cChave + aRetEqUd[2]
				EndIf				
				EndCase
				
		AO4->( DbSetOrder(nIndexApl) )

		If !Empty(cChvApl) .And. DbSeek(xFilial("AO4")+cChvApl)
				
			If ( Empty(AO4->AO4_DTVLD) .OR. AO4->AO4_DTVLD >= MsDate() )
	
				lCtrlTotal	:= AO4->AO4_CTRLTT 

				//-----------------------------------------------------------------------
				// Verifica se possui controle total e ignora o resto do processamento
				//-----------------------------------------------------------------------
				If lCtrlTotal
					aPermPri := {lCtrlTotal ,lPerVis, lPerEdt, lPerExc, lPerCom, cCdUsrPos, nIndexApl, cChvApl }
					aPermSum := {} // Limpa array de busca de permissões pois já possui controle total
					Exit
				EndIf
				
				cCdUsrPos	:= AO4->AO4_CODUSR
				lPerVis	:= AO4->AO4_PERVIS 
				lPerEdt	:= AO4->AO4_PEREDT 
				lPerExc	:= AO4->AO4_PEREXC
				lPerCom	:= AO4->AO4_PERCOM
				
				aAdd(aPermSum,{lCtrlTotal, lPerVis, lPerEdt, lPerExc, lPerCom, cCdUsrPos, nIndexApl , cChvApl})
				
			EndIf
			
		EndIf	
		
	Next nLe
	
	//-------------------------
	// Busca maior permissão
	//-------------------------
	If Len(aPermSum) > 0		
		For nLe := 1 To Len(aPermSum)
			lPerVis	:= IIF(nLe==1,aPermSum[nLe][2],aPermSum[nLe][2] .Or. lPerVis)
			lPerEdt	:= IIF(nLe==1,aPermSum[nLe][3],aPermSum[nLe][3] .Or. lPerEdt) 
			lPerExc	:= IIF(nLe==1,aPermSum[nLe][4],aPermSum[nLe][4] .Or. lPerExc)
			lPerCom	:= IIF(nLe==1,aPermSum[nLe][5],aPermSum[nLe][5] .Or. lPerCom)
			cCdUsrPos	:= IIF(Empty(aPermSum[nLe][6]),cCodUsr,aPermSum[nLe][6])
			nIndexApl	:= aPermSum[nLe][7] 
			cChvApl	:= aPermSum[nLe][8] 
		Next nLe
		aPermPri := { lCtrlTotal ,lPerVis, lPerEdt, lPerExc, lPerCom, cCdUsrPos, nIndexApl, cChvApl }				
	EndIf

Else //Prioridade 1-Usuario/2-Equipes/3-Unidades 		

		For nLe:=1 To Len(Alltrim(cPrioriza))
	
			cSequApl := SubsTR(cPrioriza,nLe,1)
		
			If			cSequApl == "1"
						nIndexApl := 1	//AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
						cChvApl := cAliasEnt + cChave + cCodUsr
			ElseIf		cSequApl == "2"
						nIndexApl := 3	//AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODEQP
						cChvApl := cAliasEnt + cChave + aRetEqUd[1]
			Else
						nIndexApl := 4	//AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUND
						cChvApl := cAliasEnt + cChave + aRetEqUd[2]				
						
			Endif
		
			DbSelectArea("AO4")
			DbSetOrder(nIndexApl)

			If DbSeek(xFilial("AO4")+cChvApl)
				If ( Empty(AO4->AO4_DTVLD) .OR. AO4->AO4_DTVLD >= MsDate() )
				
					//-- Privilegios aplicados  
					aadd(aPermPri,AO4->AO4_CTRLTT)	//lCtrlTotal 
					aadd(aPermPri,AO4->AO4_PERVIS)	//lPerVis
					aadd(aPermPri,AO4->AO4_PEREDT)	//lPerEdt
					aadd(aPermPri,AO4->AO4_PEREXC)	//lPerExc
					aadd(aPermPri,AO4->AO4_PERCOM)	//lPerCom	
					
					If	Empty(AO4->AO4_CODUSR)
						aadd(aPermPri,cCodUsr)	//Codigo do usuario
					Else
						aadd(aPermPri,AO4->AO4_CODUSR)	//Codigo do usuario
					Endif						
					
					//-- Chave usada na pesquisa
					aadd(aPermPri,nIndexApl)			//Indice aplicado na pesquisa
					aadd(aPermPri,cChvApl)				//Chave usada na pesquisa
				EndIf
			Endif
		
			If	Len(aPermPri) > 0
				Exit 
			Endif 
		
		Next nLe
	Endif 	

RestArea(aAreaAO4)
RestArea(aArea)

Return(aPermPri)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXBsPrio()

Mencionar detalhes da funcao

@sample 	CRMXBsPrio()

@param		ExpC1 - Alias da entidade
			ExpC2 - Chave da entidade 
			ExpC3 - Codigo do usuario  

@Return   	ExpC1 - Texto contendo a priorizacao do registro 

@author	Eduardo Gomes Junior 
@since		06/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXBsPrio(cAliasEnt,cChave,cCodUsr)

Local aArea 		:= GetArea()
Local cSeqPri		:= ""

dbSelectArea("AO4")
dbSetOrder(1)
If	dbSeek(xFilial("AO4")+cAliasEnt+cChave)
	If Empty(Alltrim(AO4_PRIORI))
		cSeqPri := "0"
	Else
		cSeqPri := Alltrim(AO4_PRIORI)
	EndIf
Endif

RestArea(aArea)

Return(cSeqPri)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXHbPrc()

Habilita/desabilita o campo Sequencia (AO4_SEQPRI).   

@sample 	CRMXHbPrc()

@param		Nenhum  

@Return   	ExpL1 - Habilita campo AO4_SEQPRI (X3_WHEN) 

@author	Eduardo Gomes Junior 
@since		06/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXHbPrc()

Local lRetorno	:= .T.
Local cAliasEnt	:=	FWFldGet("AO4_ENTIDA")
Local cChave	:=	FWFldGet("AO4_CHVREG")
Local cCodUsr	:=	CRMXCodUser()
Local aPermPri	:= {}

If	cCodUsr <> "000000"

	aPermPri := CRMXVlPriv(cAliasEnt,cChave,cCodUsr)
	
	If Len(aPermPri) > 0
		If	!aPermPri[1]	
			lRetorno	:= .F.
		Endif
	EndIf
Endif 	 

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXP360 

Função efetua a carga na tabela AOO com as rotinas Perfil 360
e carga da das tabelas AOP,AOQ,AOR e AOS para o Administrador 

Estrutura do Array para gravar na AOO {{AOO_CODIGO,AOO_DESCRI,AOO_ROTINA,AOO_ALIAS,AOO_TPFUN}}

@sample		CRMXP360()

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		13/04/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CRMXP360()

Local lCRMXP360 := SuperGetMv("MV_CRMP360 ",,.F.)//Indica se a tabela AOO deverá receber a carga inicial.
Local aRotina   := {}
Local nX        := 0
Local aAreaAOO  := {}
Local aExecAOO  := {}
Local lOk		  := .T.

Private lMsErroAuto  := .F.
 
If lCRMXP360

	IF nModulo == 28 // Modulo SIGATEC
		IF MsgNoYes ( STR0102, STR0103 ) //"Deseja efetuar a carga do Perfil 360?"#"Perfil 360"
			lOk := .T.
		ELSE
			lOk := .F.
		ENDIF
	ENDIF
	
	IF lOk

		If Select("AOO") > 0
			aAreaAOO := AOO->(GetArea())	
		Else
			DbSelectArea("AOO")//Rotinas
		EndIf	
		AOO->(DbSetOrder(1))//AOO_FILIAL+AOO_CODIGO 
		 
		aRotina   := {{STR0053/*"Suspect"*/,	 	 "CRMA320","ACH","1"},{STR0080/*"Ordem de Serviços"*/,  "TECA450"  ,"AB6","1"},{STR0085/*"Análise Gerencial das Contas"*/   ,"CRMA390",		"ACH","3"},; 
	                  {STR0054/*"Prospect"*/,	 	 "TMKA260","SUS","1"},{STR0071/*"Titulos a Receber"*/,	"FINA740"  ,"SE1","1"},{STR0086/*"Previsão de Venda"*/				,"CRMA010",		"AO3","3"},; 
	                  {STR0055/*"Clientes"*/,	 	 "MATA030","SA1","1"},{STR0072/*"Nota Fisc de Saida"*/,	"MATA920"  ,"SD2","1"},{STR0072/*"Nota Fiscal de Saida"*/			,"MATC090",		"SF2","3"},; 
	                  {STR0056/*"SubClientes"*/,	 "CRMA120","SA1","1"},{STR0073/*"Análise de Crédito"*/,	"MATA450"  ,"SC9","1"},{STR0087/*"Rastreador de Contas"*/			,"CA600Tracker" ,"AOP","3"},; 
	                  {STR0057/*"Conexões"*/,	 	 "CRMA190","AO7","1"},{STR0074/*"Contatos"*/,			"CRMA060"  ,"AC8","1"},{STR0088/*"Despesas Financeiras"*/			,"CRMA430" 		,"AD5","2"},; 
	                  {STR0058/*"Atividades"*/, 	 "CRMA180","AOF","1"},{STR0089/*"Metas X Realizado"*/,	"FATR050"  ,"SCT","2"},; 
	                  {STR0059/*"Anotações"*/,	 	 "CRMA090","AOB","1"},{STR0081/*"Privilégios"*/,	 	"CRMA200"  ,"ACB","1"},{STR0060/*"Oportunidades"*/					,"CRMA420"  	,"AIJ","2"},; 
	                  {STR0060/*"Oportunidades"*/,	 "CRMA110","AD1","1"},{STR0077/*"Conhecimento"*/,		"MSDOCUMENT"  ,"AC9","1"},{STR0090/*"Processos de Vendas"*/			,"FATR020" 		,"AC1","2"},; 
	                  {STR0091/*"OporX Pr.Venda"*/  ,"CRMA450","AD1","2"},{STR0068/*"Lista de Marketing"*/ ,"CRMA530"  ,"SU4","1"},; 
					  {STR0107/*"Painel de Propostas"*/, "CRMA801","ADY","1"},;  
	                  {STR0062/*"Pedido de Vendas"*/,"CRMA310","SC5","1"},{STR0079/*"Serviços"*/,			"TECA030"  ,"AA5","1"},{STR0092/*"Posição Títulos a Receber"*/		,"FINC040" 		,"SE1","3"},;
	                  {STR0063/*"Contratos"*/,		 "CNTA300","CN9","1"},{STR0082/*"Perfil"*/,			    "TK010Con" ,"AGK","3"},{STR0066/*"Campanhas Rápidas"*/				,"CRMA250"		,"AOC","1"},;
	                  {STR0064/*"Apontamentos"*/,	 "CRMA330","AD5","1"},{STR0083/*"Posição do Cliente"*/, "A450F4Con","SA1","3"},;
	                  {STR0065/*"Campanhas"*/,		 "CRMA360","SUO","1"},{STR0084/*"Funil de Venda"*/,	    "CRMA080"  ,"AO3","3"},;
	                  {STR0101/*"Vínculo de Benefícios"*/, "AT352ASA1","SA1","1"},;  
					  {STR0108/*"SubSegmentos"*/, "CRMA620","SA1","1"}}	
	                  
		For nX := 1 To Len(aRotina)
			If !AOO->(DbSeek(xFilial("AOO")+aRotina[nX,1]))
			   aExecAOO := {{"AOO_FILIAL",xFilial("AOO")	,Nil},;
			    			   {"AOO_DESCRI" ,aRotina[nX,1]	,Nil},;
							   {"AOO_ROTINA" ,aRotina[nX,2]	,Nil},;
							   {"AOO_ALIAS" ,aRotina[nX,3]	,Nil},;
							   {"AOO_TPFUN"  ,aRotina[nX,4]	,Nil}}
			   CRMA590( aExecAOO, 3 ) // Importar agenda por rotina automatica
			EndIf   
		Next nX
		
		CRMXCRG360()
		
		PutMv("MV_CRMP360",.F.)	
	
		If !Empty(aAreaAOO)
			RestArea(aAreaAOO)
		EndIf
		
		IF nModulo == 28 // Modulo SIGATEC
			MSGINFO( STR0104, STR0103 )// "Carga Finalizada"#"Perfil 360"
		ENDIF
	ENDIF
EndIf    

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXCRG360 

Função efetua a carga da das tabelas AOP,AOQ,AOR e AOS para o Administrador 

@sample		CRMXCRG360()

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		13/04/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CRMXCRG360()

Local oModel360 	:= FWLoadModel("CRMA600") //Recarrega o Model do Papel Perfil 360
Local oModelAOP	:= oModel360:GetModel("AOPMASTER")
Local oModelAOQ	:= oModel360:GetModel("AOQDETAIL")
Local oModelAOR	:= oModel360:GetModel("AORDETAIL")
Local oModelG 	:= oModel360:GetModel("AOSDETAIL_G")
Local oModelU		:= oModel360:GetModel("AOSDETAIL_U")

Local nNewLine    := 0
Local cItem       := ''

oModel360:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
oModel360:Activate()
oModelAOP:SetValue("AOP_DESCRI", STR0069 ) //Habilita gravação AOP

nNewLine := oModelAOQ:AddLine()
oModelAOQ:GoLine(nNewLine)
cItem := Soma1(oModelAOQ:GetValue("AOQ_CODIGO",oModelAOQ:Length())) 

oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0093 /*"Conta"*/ )  

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0053),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0054),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0055),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0056),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0057),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0108),"AOO_CODIGO")))
oModelAOQ:AddLine()


cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0058 /*"Atividades"*/ )   //Habilita gravação AOQ

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0058),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0059),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0067),"AOO_CODIGO")))
oModelAOQ:AddLine()

cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0094 /*"Vendas"*/ )   
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0107),"AOO_CODIGO")))
oModelAOR:AddLine()

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0060),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0063),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0061),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0062),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0064),"AOO_CODIGO")))

oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0095 /*"Marketing"*/ )   

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0065),"AOO_CODIGO")))
oModelAOR:AddLine() 
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0066),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0068),"AOO_CODIGO")))

oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0096 /*"Financeiro"*/) 

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0071),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0072),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0073),"AOO_CODIGO")))

oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0074 /*"Contatos"*/) 

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0074),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0075),"AOO_CODIGO")))
oModelAOR:AddLine()


oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0077  /*"Conhecimento"*/) 

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0077),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0076),"AOO_CODIGO")))

oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0097   /*"Servicos"*/) 

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0078),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0079),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0080),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0101),"AOO_CODIGO"))) // "Vínculo de Benefícios"

oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0098    /*"Proprietarios"*/) 

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"1"+Alltrim(STR0081),"AOO_CODIGO")))

oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0099    /*"Consultas"*/)
 
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0082),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0083),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0084),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0085),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0086),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0072),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0087),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"3"+Alltrim(STR0092),"AOO_CODIGO")))

oModelAOQ:AddLine()
cItem := Soma1(cItem) 
oModelAOQ:LoadValue("AOQ_CODIGO", cItem )    //Habilita gravação AOQ
oModelAOQ:SetValue("AOQ_DESCRI", STR0100    /*"Relatorios"*/)

oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"2"+Alltrim(STR0088),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"2"+Alltrim(STR0089),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"2"+Alltrim(STR0060),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"2"+Alltrim(STR0090),"AOO_CODIGO")))
oModelAOR:AddLine()
oModelAOR:SetValue("AOR_CODROT" ,AOO->(Posicione("AOO",2,xFilial("AOO")+"2"+Alltrim(STR0091),"AOO_CODIGO")))

oModelU:SetValue("AOS_CODPAP"	,oModelAOP:GetValue("AOP_CODIGO"))
oModelU:SetValue("AOS_CODIGO"	,"000000")
oModelU:SetValue("AOS_TIPO"	,"2")  

oModelG:SetValue("AOS_CODPAP"	,oModelAOP:GetValue("AOP_CODIGO"))
oModelG:SetValue("AOS_CODIGO"	,"000000")
oModelG:SetValue("AOS_TIPO"	,"1")  

If oModel360:VldData()
   	oModel360:CommitData()
Else
	lRet := .F.
    cLog := cValToChar(oModel360:GetErrorMessage()[4]) + ' - '
    cLog += cValToChar(oModel360:GetErrorMessage()[5]) + ' - '
    cLog += cValToChar(oModel360:GetErrorMessage()[6])        	      
    Help( ,,"M030VALID",,cLog, 1, 0 )
Endif
oModel360:DeActivate()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMXREstrNeg
Retorna os superiores ou subordinados do usuário de acordo com a estrutura de negócios 

@param cCodUser	, caracter	, codigo do usuario 
@param cCargo		, caracter	, codigo do cargo para pesquisa 
@param cOrdem		, caracter	, ordem para realizar a pesquisa S=Superior / branco ou I=Inferior
@param cSeqPaper	, caracter	, Sequencia + Papel ( Default: Considera o papel do usuario logado.)
@param nTopUsers	, numerico	, Quantidade de superiores ou subordinados ( 0 = Todos ).

 
@return aDados		, array		, Retorna array com dados do superior.

@author  Thamara Villa Jacomo 
@author  Anderson Silva 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Function CRMXREstrNeg( cCodUser, cCargo, cOrdem, cSeqPaper, nTopUsers ) 

Local aArea		:= GetArea()
Local aDados 	:= {}
Local aNvlEstrut:= {} 
Local cTable  	:= GetNextAlias()
Local nTamId	:= 0 
Local cIdFrom	:= ""
Local cIdTo		:= ""
Local cConcat	:= IIF(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")
Local cTpStruc	:= SuperGetMv("MV_CRMESTR",.F.,"1") //1-AO3 / 2-vendedor / 3-Papel
Local cAO3_CDHIER := ""
Local nAO3_NVHIER := 0

Local nLevel	:= 0
Local cFilEstNeg:= ""  
Local cFilCargo	:= ""
Local cByOrdem	:= "" 
Local nCount	:= 0

Default cCodUser:= "" 
Default cCargo	:= "" 
Default cOrdem	:= "S" 
Default nTopUsers:= 0	

If	!Empty( cCodUser ) .And. !Empty( cSeqPaper )
 	 
	If Select( cTable ) > 0
		DbSelectArea( cTable )
		( cTable )->( DbCloseArea() ) 
	EndIf
	
	aNvlEstrut	:= CRMXNvlEst(cCodUser) 
	 
	If !Empty( aNvlEstrut[1] ) 
		
		If	cOrdem == "S" 
		
			nTamId :=  Len( aNvlEstrut[1] )
			
			//Usuarios filhos nao será necessario, utilizar o Id inteligente. 
			If nTamId == 4
				cFilEstNeg := " AO5.AO5_NVESTN = 1 "	
			//Usuarios netos utilizar o id inteligente para encontrar os superiores.
			ElseIf nTamId > 4  
			
				//Não considera os usuarios do mesmo nivel.
				nTamId := ( nTamId - 2 ) 
				
				cFilEstNeg += "( "
				
				While (  nTamId > 2 )
					
					nTamId := ( nTamId - 2 ) 
					
					If nTamId >= 2
						cIdFrom	:= SubStr( aNvlEstrut[1]	, 1, nTamId )  
						cIdTo		:= cIdFrom + "ZZ"
						nLevel 	:=  Len(cIdTo) / 2
						cFilEstNeg += "( AO5.AO5_IDESTN BETWEEN '"+ cIdFrom + "' AND '" + cIdTo	+"' AND AO5.AO5_NVESTN = " + cValToChar( nLevel ) + " ) OR "
					EndIf 
					 
				End
				
				cFilEstNeg += "AO5.AO5_NVESTN = 1 )"	
				
				cByOrdem	:= "ORDER BY AO5.AO5_NVESTN DESC"
			EndIf
			
		Else
			
			aNlvEstFmt	:= CRMXFmtNvl( aNvlEstrut[1] )
			
			For nLevel := 1 To Len( aNlvEstFmt )
				cFilEstNeg += " AO5.AO5_IDESTN LIKE '" + aNlvEstFmt[nLevel] + "%'"
				
				If( nLevel < Len( aNlvEstFmt ) ) 
					cFilEstNeg += " OR " 
				EndIf 		
			Next nLevel
			
			cByOrdem		:= "ORDER BY AO5.AO5_IDESTN"
		
		Endif
		
		If !Empty( cFilEstNeg )
		
			If !Empty(cCargo)
			
				If cTpStruc == "1" 
			
					cFilCargo	:= "AO3.AO3_CARGO ='"+ cCargo +"'" 
				
				Else
					
					cFilCargo	:= "SA3.A3_CARGO ='"+ cCargo +"'"
				
				EndIf
				
			Else
				
				If cTpStruc == "1"
				
					cFilCargo	:= "AO3.AO3_CARGO BETWEEN '      ' AND 'ZZZZZZ'"
				
				Else
					
					cFilCargo	:= "SA3.A3_CARGO BETWEEN '      ' AND 'ZZZZZZ'"
					
				EndIf
							
			Endif
			
			
			cQuery := " SELECT AO5.AO5_FILIAL, AO5.AO5_CODANE, AO3.AO3_CODUSR, " 
			If AO3->(FieldPos("AO3_CDHIER")) > 0
				cQuery += " AO3.AO3_CDHIER, "
			EndIf
			If AO3->(FieldPos("AO3_NVHIER")) > 0
				cQuery += " AO3.AO3_NVHIER, "
			EndIf
			cQuery += " AZS.AZS_VEND, AZS.AZS_IDESTN, AZS.AZS_NVESTN, SUM.UM_CARGO, SUM.UM_DESC, SUM.UM_CRGSUP "
			cQuery += " FROM " + RetSqlName("AO5") + " AO5 LEFT JOIN " + RetSqlName("AZS") + " AZS ON AZS.AZS_FILIAL = '" + xFilial("AZS") + "' AND AO5.AO5_CODANE = AZS.AZS_CODUSR " + cConcat + " AZS.AZS_SEQUEN " + cConcat + " AZS.AZS_PAPEL AND AZS.D_E_L_E_T_ = ' ' " 
			cQuery += " LEFT JOIN "+ RetSqlName("AO3") + " AO3 ON AO3.AO3_CODUSR = AZS.AZS_CODUSR AND AZS.D_E_L_E_T_ = ' ' "
			
			If cTpStruc == "2"
				cQuery += " LEFT JOIN "+ RetSqlName("SA3") + " SA3 ON SA3.A3_FILIAL = '" + xFilial("SA3") + "' AND SA3.A3_COD = AZS.AZS_VEND AND SA3.D_E_L_E_T_ = ' ' "	
			EndIf	
			
			cQuery += " LEFT JOIN "+ RetSqlName("SUM") + " SUM ON SUM.UM_FILIAL = '" + xFilial("SUM") + "' AND SUM.D_E_L_E_T_ = ' ' "
					
			If cTpStruc == "1"
				cQuery += " AND SUM.UM_CARGO = AO3.AO3_CARGO "			
			Else
				cQuery += " AND SUM.UM_CARGO = SA3.A3_CARGO "	
			EndIf	
			
			cQuery += " WHERE AO5.AO5_ENTANE = 'AZS'  "
			cQuery += " AND " + cFilEstNeg
			cQuery += " AND " + cFilCargo
			cQuery += " AND AZS.D_E_L_E_T_ = ' ' "
			
			cQuery += cByOrdem
						
			cQuery := ChangeQuery( cQuery )			
			//-------------------------------------------------------------------
			// Executa a instrução. 
			//-------------------------------------------------------------------		
			DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cTable, .T., .T. )
						
			While ( cTable )->( !Eof() )
			
				If ( nTopUsers > 0 .And. nCount == nTopUsers )
					Exit
				EndIf
				
				cAO3_CDHIER := ""
				nAO3_NVHIER := 0
				If AO3->(FieldPos("AO3_CDHIER")) > 0
					cAO3_CDHIER := ( cTable )->AO3_CDHIER
				EndIf
				If AO3->(FieldPos("AO3_NVHIER")) > 0
					nAO3_NVHIER := ( cTable )->AO3_NVHIER
				EndIf
				aAdd( aDados, {( cTable )->AO3_CODUSR							,;	// 1 - Usuário
							     CRMXLoadUser( ( cTable )->AO3_CODUSR )[4]	,; 	// 2 - Nome
							    ( cTable )->UM_CARGO							,; 	// 3 - Cargo
							    ( cTable )->UM_DESC								,; 	// 4 - Descrição
							    ( cTable )->AZS_IDESTN							,; 	// 5 - Id da Estrutura
							    ( cTable )->AZS_NVESTN							,;	// 6 - Nível da estrutura
							    ( cTable )->UM_CRGSUP  							,; 	// 7 - Cargo Superior
							    cAO3_CDHIER										,;	// 8 - Código da Hierarquia de cargo
							    nAO3_NVHIER										,;	// 9 - Código do nível
							    ( cTable )->AZS_VEND							,;	// 10 - Codigo do Vendedor 
							    ( cTable )->AO5_CODANE	 } )   				  	// 11 - Codigo do Usuário + Sequencia + Papel								     
				
				nCount++ 				     
						    
				( cTable )->( DbSkip() )
			EndDo
			
			( cTable )->( DbCloseArea() )
			
			//Retira o usuario avaliado da lista dos superiores ou subordinados.
			nPosUser := aScan( aDados, {|z| z[11] == cCodUser + cSeqPaper } )
			
			If nPosUser > 0
				aDel(aDados,nPosUser)
				aSize(aDados,Len(aDados)-1)
			EndIf
			
		EndIf
		
	EndIf 

EndIf

RestArea( aArea )

Return( aDados )


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXSup

Retorna os superiores do usuário de acordo com a estrutura de negócios 

@sample		CRMXSup( cUser )

@param		ExpC = Usuário subordinado
				 
@return		ExpA = Retorna array com dados do superior, sendo:
			1 - Usuário do Superior
			2 - Nome do Superior
			3 - Cargo 
			4 - Descrição
			5 - Id da estrutura
			6 - Cargo do superior do superior	

@author	Thamara Villa Jacomo
@since		15/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMXSup( cUser )

Local aDados 	:= {}
Local aNivel	:= {}
Local cCodInt	:= ""
Local cTabel  := GetNextAlias() 

Default cUser  := ""

If AO5->AO5_ENTANE == "USU" .Or. !Empty( cUser )
 	 
	If Select( cTabel ) > 0
		DbSelectArea( cTabel )
		( cTabel )->( DbCloseArea() )
	EndIf
	
	//-----------------------------------------------------------------------------------
	//  **Ex. da lógica do superior De estrutura de negócios (Utilizando apenas USU)**
	// 
	// ( Gerente1 ) - Cod. Int = 02010201 Nível = 4                    
	// ( Gerente2 ) - Cod. Int = 02010202 Nível = 4                        	
	//	   ( Vendedor1 ) - Cod. Int = 0201020402 Nível = 5
	//
	//  **Ao retirar os 3 últimos dígitos do usuário que está sendo verificado, temos a 
	//sequência exata do código inteligente que é comum a todos, feito isso, comparamos
	//o nível. O nível do superior será sempre menor do que o do usuário verificado.
	// IMPORTANTE: A query irá retornar TODOS os superiores do usuário verificado, 
	// 		independente do cargo. 
	//-----------------------------------------------------------------------------------   
	If !Empty( cUser )
		aNivel := CRMXNvlEst( cUser )
	Else 
		aNivel := CRMXNvlEst( AO5->AO5_CODANE )
	EndIf
            
	cCodInt := ( SubStr( aNivel[1], 0, Len( aNivel[1] ) - 3 ) )

	BeginSQL Alias cTabel
	
		SELECT AO5_FILIAL, AO5_CODANE, AO3_CARGO, UM_DESC, AO5_IDESTN, AO5_NVESTN, UM_CRGSUP
		
		FROM %Table:AO5% AO5
		
		INNER JOIN %Table:AO3% AO3 ON  AO3_FILIAL = %xFilial:AO3% AND AO5_CODANE = AO3_CODUSR
		INNER JOIN %Table:SUM% SUM ON UM_FILIAL = %xFilial:SUM% AND AO3_CARGO = UM_CARGO
		
		WHERE AO5.AO5_ENTANE = 'USU'
		  AND AO5.AO5_IDESTN < %exp:aNivel[1]% AND AO5.AO5_IDESTN >  %exp:cCodInt%
		  AND AO5.AO5_NVESTN < %exp:aNivel[2]%
		  AND AO5.%NotDel%
		  AND AO3.%NotDel%
		  AND SUM.%NotDel%
		  		
	EndSql
	
	While ( cTabel )->( !Eof() )
			aAdd( aDados, { ( cTabel )->AO5_CODANE					,; // 1 - Usuário
						     UsrRetName( ( cTabel )->AO5_CODANE ) ,; // 2 - Nome
						    ( cTabel )->AO3_CARGO					,; // 3 - Cargo
						    ( cTabel )->UM_DESC						,; // 4 - Descrição
						    ( cTabel )->AO5_IDESTN					,; // 5 - Id da Estrutura
						    ( cTabel )->AO5_NVESTN					,; // 6 - Nível da estrutura
						    ( cTabel )->UM_CRGSUP } )				  	   // 7 - Cargo Superior
			( cTabel )->( DbSkip() )
	EndDo
	
	( cTabel )->( DbCloseArea() )

EndIf

Return( aDados )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXCpoSup

Retorna os superiores do usuário de acordo com a estrutura de negócios 
*Rotina utilizada para inicialização de campos virtuais

@sample		CRMXSup( nRet  )

@param		ExpN = Determina se o retorno deve ser o 1 = Usuário ou 2 = Nome
				 
@return		ExpC = Retorno conforme ExpN, se 1 = retorna o código do usuário
			superior, se 2 = retorna o nome do superior

@author	Thamara Villa Jacomo
@since		15/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMXCpoSup( nRet )
	
Local aArea	 := GetArea()
Local aAreaSUM := {}
Local aSuper 	 := CRMXSup()
Local cCrgSup	 := ""
Local cRet		 := ""
Local nTam		 := 0
Local nX		 := 0
Local nPos		 := 1
	
Default nRet	 := 0

If !Empty( aSuper )
	//-------------------------------------------------------------------------------
	// Verifica se o ID da estrutura é o mesmo do usuário posicionado, se não for,
	// busca o próximo, pois pode ser que retorne 2 superiores com o mesmo cargo.
	//-------------------------------------------------------------------------------
	nTam := Len( aSuper )
		
	If nTam > 1
		aAreaSUM := SUM->( GetArea() )
				
		cCodUsr := AO5->AO5_CODANE
		If AO5->AO5_ENTANE == "AZS"
			AZS->( DBSetOrder( 1 ) )
	
			If ( AZS->( MSSeek( xFilial("AZS") + AO5->AO5_CODANE  ) ) )
				cCodUsr := AZS->AZS_CODUSR
			EndIf				
		EndIf

		If ! Empty(cCodUsr)
			cCargo := Posicione( "AO3", 1, xFilial( "AO3" ) + cCodUsr, "AO3_CARGO" )
			DbSelectArea( "SUM" )
			DbSetOrder( 1 )
			If DbSeek( xFilial( "SUM" ) + cCargo )
				cCrgSup := UM_CRGSUP
			EndIf
				
			For nX := 1 To nTam
				If aSuper[nX][3] == cCrgSup
					nPos := 1
					If Substr( aSuper[nX][5], 1, 5 ) == SubStr( AO5->AO5_IDESTN, 1, 5 )
						nPos++
						Exit
					EndIf
				EndIf
			Next( nX )
			
			RestArea( aAreaSUM )	
		EndIf
		//-------------------------------------------------------------------------------
		// Retorna o código do usuário superior, senão, retorna o nome do superior
		//-------------------------------------------------------------------------------
		If nRet == 1
			cRet := aSuper[nPos][1]
		Else
			cRet := aSuper[nPos][2]
		EndIf
	EndIf
		
EndIf

RestArea( aArea )

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMXBrwF3Acess

Retorna a permissao do acesso para o metodo UPDATE ( Class SIGACRMBrowseAccessObserver / Class SIGACRMConPadButtonObserver)

@author 	Eduardo Gomes Junior 
@since 		10/07/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CRMXBrwF3Acess(oObservable, lAccess, cSourceName, cFunction, nOption)
Local aArea			:= {}
Local aPerHerdada	:= {}
Local aPermPri		:= {}
Local aSX2			:= {}
Local cAliasEnt		:= Alias()
Local cSX2Unico		:= ""
Local cChave		:= ""
Local cCodUsr		:= CRMXCodUser()
Local cPrxEnt		:= PrefixoCpo(cAliasEnt)
Local lCtrlTotal	:= .F.
Local lPerVis		:= .F.
Local lPerEdt		:= .F.
Local lPerExc		:= .F.

Default oObservable	:= Nil
Default lAccess		:= .T.
Default cSourceName	:= ""
Default cFunction 	:= ""
Default nOption		:= 1 

If ( nModulo == 73 .And. lAccess .And. (cAliasEnt)->(!Eof()) .And. cCodUsr <> "000000" .And. Str( nOption, 1 ) $ "2|4|5" .And.;
	 !( cFunction $ "CRMA200|TK341PROSPECT|FTCONTATO" ) .And. cAliasEnt $ CRMXCtrlEnt() )
	
	aArea	:= GetArea()
	aSX2 	:= CRMXGetSX2(cAliasEnt)
	
	If ( !Empty( aSX2 ) .And. !Empty( aSX2[1] ) )
		
		cSX2Unico	:= aSX2[1]
		cChave		:= PadR((cAliasEnt)->&(cPrxEnt + "_FILIAL+" + cSX2Unico),TAMSX3("AO4_CHVREG")[1]) 
		
		aPermPri := CRMXVlPriv(cAliasEnt,cChave,cCodUsr)
		
		If	Len(aPermPri) > 0
			lCtrlTotal	:= aPermPri[1]
			lPerVis	:= aPermPri[2]
			lPerEdt	:= aPermPri[3] 
			lPerExc	:= aPermPri[4]
		EndIf
		
		If Len(aPermPri) == 0
			
			aPerHerdada	:= CRMXHerdaPer(cAliasEnt,cChave)
			
			If Len(aPerHerdada) > 0
				lCtrlTotal	:= aPerHerdada[PERM_CONTROLE_TOTAL]
				lPerVis	:= aPerHerdada[PERM_VISUALIZAR]
				lPerEdt	:= aPerHerdada[PERM_EDITAR]
				lPerExc	:= aPerHerdada[PERM_EXCLUIR]
			EndIf
			
		EndIf
		
		// Aplica o permissionamento se o usuario nao tiver o controle total sobre o registro.
		If !lCtrlTotal
			
			Do Case
				// Verifica se o usuario tem permissao para visualizar o registro.
				Case ( nOption == 2 .And. !( lPerVis .Or. lPerEdt .Or. lPerExc ) )
					MsgStop(STR0017)		// "Você não tem permissão para Visualizar esse registro."
					lAccess := .F.
					// Verifica se o usuario tem permissao para editar o registro.
				Case ( nOption == 4 .And. !lPerEdt )
					MsgStop(STR0018)		// "Você não tem permissão para Alterar esse registro."
					lAccess := .F.
					// Verifica se o usuario tem permissao para excluir o registro.
				Case ( nOption == 5 .And. !lPerExc )
					MsgStop(STR0019)		// "Você não tem permissão para Excluir esse registro."
					lAccess := .F.
			EndCase
			
		EndIf
		
	EndIf

	RestArea(aArea)
	aSize(aArea,0)
	aArea := Nil

EndIf

aPerHerdada	:= aSize(aPerHerdada	,0)
aPerHerdada	:= Nil
aPermPri	:= aSize(aPermPri		,0)
aPermPri	:= Nil
aSX2		:= aSize(aSX2			,0)
aSX2		:= Nil

Return(lAccess)

//------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXLoadUser( )

Retorna os dados do usuario logado.

@sample 	CRMXLoadUser( cCodUser )

@param		cCodUser	,caracter	,Código do usuário

@Return   	aUserData	, array 	, Retorna os dados do usuario logado sendo:
			[1] Id da tabela de usuários
           	[2] Id do usuário
            [3] Login do Usuário
            [4] Nome do usuário
            [5] Email do usuário
            [6] XML
            [7] Método de found. 1=Login;2=Mail;3=Id do usuário;4=SSingOn;5=RecNo;6=AD

@author	Anderson Silva
@since		01/12/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------------------------------
Function CRMXLoadUser( cCodUser )

	Local aUserData := {0,"","","","","",0}
	
	Default cCodUser := ""
	
	If !Empty( cCodUser )
		
		If ( Empty( __aUserData ) .Or. ( __aUserData[2] <> cCodUser ) )
			__aUserData := FWSFLoadUser(AllTrim( cCodUser ),,,3)
		EndIf
		
		If !Empty( __aUserData )
			aUserData := aClone( __aUserData )
		EndIf
	
	EndIf 

Return( aUserData )

//-----------Gestão de Papéis

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXSetRole

Define como logado um determinado papel do usuario.

@sample	CRMXSetRole( cIdUserRole )

@param		cIdUserRole	, caracter	, Id do papel do usuario sendo: Código do usuario + Sequencia + Papel
		
@return		lOk		, logico	, Retorna verdadeiro se id do papel do usuario foi definido como logado.

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMXSetRole(cIdUserRole)
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cTipoDB 	:= AllTrim( Upper( TcGetDb() ) )
	Local cConcat	:= ""
	Local cTemp 	:= GetNextAlias() 
	Local lOk		:= .F. 

	//-------------------------------------------------------------------
	// Define o operador de concatenação.  
	//-------------------------------------------------------------------			
	cConcat	:= IIF(cTipoDB = "MSSQL","+","||") //Sinal de concatenação  

	//-------------------------------------------------------------------
	// Monta a instrução SQL.  
	//-------------------------------------------------------------------	
	cQuery := " SELECT"
	cQuery += " 	AZS.AZS_CODUSR," 
	cQuery += " 	AZS.AZS_SEQUEN,"
	cQuery += " 	AZS.AZS_PAPEL," 
	cQuery += " 	AZS.AZS_CODUND,"
	cQuery += " 	AZS.AZS_CODEQP,"	
	cQuery += " 	AZS.AZS_VEND,"
	cQuery += " 	AZS.AZS_IDESTN,"
	cQuery += " 	AZS.AZS_NVESTN"
	cQuery += " FROM " 
	cQuery +=		RetSQLName("AZS") + " AZS" 
	cQuery += " WHERE"
	cQuery += " 	AZS.AZS_FILIAL = '" + xFilial( "AZS" ) + "'"
	cQuery += " 	AND " 
	cQuery += " 	AZS.AZS_CODUSR " + cConcat + " AZS.AZS_SEQUEN  " + cConcat + " AZS.AZS_PAPEL= '" + cIdUserRole + "'"
	cQuery += " 	AND " 
	cQuery += " 	AZS.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Executa a instrução SQL.  
	//-------------------------------------------------------------------	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )

	//-------------------------------------------------------------------
	// Lista o ID Inteligente dos grupos do mesmo nível da estrutura. 
	//-------------------------------------------------------------------		
	lOk :=  ! ( (cTemp)->(  Eof() )  )
	
	If( lOk )
		__aUserRole	:= {}
		
		aAdd( __aUserRole, (cTemp)->( AZS_CODUSR ) )
		aAdd( __aUserRole, (cTemp)->( AZS_SEQUEN ) )		
		aAdd( __aUserRole, (cTemp)->( AZS_PAPEL ) )
		aAdd( __aUserRole, (cTemp)->( AZS_CODUND ) )
		aAdd( __aUserRole, (cTemp)->( AZS_CODEQP ) )
		aAdd( __aUserRole, (cTemp)->( AZS_VEND ) )
		aAdd( __aUserRole, (cTemp)->( AZS_IDESTN ) )
		aAdd( __aUserRole, (cTemp)->( AZS_NVESTN ) )
	EndIf 

	( cTemp )->( DBCloseArea() ) 
	
	RestArea( aArea )

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXSetPaper

Função Legado

@author	Squad CRM/Faturamento
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMXSetPaper( cIdUserRole )
Return CRMXSetRole( cIdUserRole )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetRole()

Retorna os dados do papel do usuario logado no CRM.

@sample	CRMXGetRole()()

@param		Nenhum
 
@return	aUserRole	, array	, Retorna os dados do papel do usuario logado sendo:
			[1] Codigo do Usuario
           	[2] Sequencia
            [3] Papel
            [4] Codigo da Unidade de Venda
            [5] Codigo da Equipe
            [6] Codigo do Vendedor
            [7] Identificador inteligente da Estrutura de Negocio
            [8] Nivel da Estrutura de Negocio

@author	Anderson Silva
@since		12/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Function CRMXGetRole()
Return __aUserRole

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetPaper

Função Legado 

@author	Squad CRM/Faturamento
@since		12/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Function CRMXGetPaper()
Return CRMXGetRole()

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXAllRoles

Retorna todos os dados dos papeis do usuario logado no CRM.

@sample	CRMXAllRoles()

@param		Nenhum
 
@return	aAllRoles	, array	, Retorna todos os dados dos papeis do usuario logado sendo:
			[n][1] Codigo do Usuario
           	[n][2] Sequencia
            [n][3] Papel
            [n][4] Codigo da Unidade de Venda
            [n][5] Codigo da Equipe
            [n][6] Codigo do Vendedor
            [n][7] Identificador inteligente da Estrutura de Negocio
            [n][8] Nivel da Estrutura de Negocio

@author	Anderson Silva
@since		12/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Function CRMXAllRoles()
	Local aAreaAO3		:= {}
	Local aAreaAZS		:= {}
	Local aAllRoles		:= {}
	Local cCodUser 		:= CRMXCodUser()
	Local cFilAZS		:= xFilial("AZS") 
	
	If !Empty( cCodUser )
		aAreaAO3	:= AO3->( GetArea() )
		
		// AO3_FILIAL+AO3_CODUSR
		AO3->( DBSetOrder( 1 ) )
		
		If AO3->( DBSeek( xFilial("AO3") + cCodUser ) ) .And. AO3->AO3_MSBLQL != "1"
			aAreaAZS	:= AZS->( GetArea() )

			AZS->( DBSetOrder(1) ) //AZS_FILIAL + AZS_CODUSR + AZS_SEQUEN + AZS_PAPEL
			
			If AZS->( DbSeek( cFilAZS + cCodUser ) )	
				While ( ! AZS->( Eof() ) .And. AZS->AZS_FILIAL == cFilAZS .And. AZS->AZS_CODUSR == cCodUser )
					
					aAdd( aAllRoles, {	AZS->AZS_CODUSR 	,;
					AZS->AZS_SEQUEN	,;
					AZS->AZS_PAPEL 	,;
					AZS->AZS_CODUND ,;
					AZS->AZS_CODEQP ,;
					AZS->AZS_VEND 	,;
					AZS->AZS_IDESTN	,;
					AZS->AZS_NVESTN  } )	
					AZS->( DbSkip() )
					
				EndDo
			EndIf

			RestArea( aAreaAZS )
		
		EndIf
		
		
		RestArea( aAreaAO3 )
	EndIf
	
Return aAllRoles

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXAllPapers

Função Legado 

@author	Squad CRM/Faturamento
@since		12/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Function CRMXAllPapers()
Return CRMXAllRoles()
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXUIRole()

Interface de escolha para definir um papel do usuario como logado.

@sample	CRMXUIRole( cCodUser, lAllUsers, cTitle, lBtnClose, lBtnNewRole )

@param		cCodUser		,caracter	,Código do usuário
			lAllUsers		,logico	,Apresenta no browse todos os usuarios
			cTitle			,caracter	,Titulo da Interface 
			lBtnClose		,logico	,Habilita o botão fechar. (Default Habilitado)
			lBtnNewRole	,logico	,Habilita o botão para inclusão do Novo Papel. (Default Desabilitado)
 
@return	cIdUserRole	,caracter	,Código do Usuário + Sequencia + Papel 

@author	Anderson Silva
@since		12/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Function CRMXUIRole( cCodUser, lAllUsers, cTitle, lBtnClose, lBtnNewRole )
	Local aFieldsAO3	:= {"AO3_CODUSR","AO3_NOMUSR"}
	Local aAreaAO3		:= AO3->(GetArea())
	Local aAreaAZS		:= AZS->(GetArea())
	Local oDlgRole		:= Nil
	Local oPnlRole		:= Nil 
	Local oBrwAO3		:= Nil
	Local oBrwAZS		:= Nil
	Local oPanelMain	:= Nil
	Local oPanelTop		:= Nil
	Local oPanelBut		:= Nil
	Local oRelation		:= Nil
	Local cIdUserRole	:= ""
	Local aUISize		:= {220,450}
	Local cFilDef		:= ""
	Local cFilUsr		:= ""
	Local lFilUSR		:= ExistBlock("CRMXFILPAP")
	Local lAZS			:= SuperGetMv("MV_CRMUAZS",, .F.)
	
	Default cCodUser		:= CRMXCodUser()
	Default lAllUsers		:= .F.
	Default cTiTle			:= STR0120		//"Papeis do Usuário"
	Default lBtnClose		:= .T.
	Default lBtnNewRole		:= .F.
	
	If lAllUsers
		aUISize := {300,450}
	EndIf

	oDlgRole := FWDialogModal():New()
	oDlgRole:SetBackground(.T.)				 
	oDlgRole:SetTitle( cTitle )
	
	If !lBtnClose
		oDlgRole:SetCloseButton() 
		oDlgRole:SetEscClose(.F.)
	EndIf
	
	oDlgRole:SetSize(aUISize[1],aUISize[2]) 
	oDlgRole:EnableFormBar(.T.) 
	oDlgRole:CreateDialog()
	oDlgRole:CreateFormBar()
	
	//Pega o Id do Papel do Usuario posicionado.
	oDlgRole:AddButton( STR0121 ,{|| cIdUserRole := CRMXUIGRole(lAZS), IIF( !Empty( cIdUserRole ), oDlgRole:DeActivate(), Nil )  }, STR0121, , .T., .F., .T. ) //"Confirmar"
	
	If lBtnClose
		oDlgRole:AddButton( STR0122 ,{|| oDlgRole:DeActivate() }, STR0122, , .T., .F., .T. ) //"Fechar"
	EndIf
	
	If lBtnNewRole
		oDlgRole:AddButton( STR0127 ,{|| CRMXNewRole( oDlgRole, oBrwAZS  ) }, STR0127, , .T., .F., .T. ) //"Novo Papel"
	EndIf
	
	oPnlRole := oDlgRole:GetPanelMain()
	
	oPanelMain := TPanel():New(000,000,,oPnlRole,,,,,,100,100) 
	oPanelMain:Align := CONTROL_ALIGN_ALLCLIENT
	
	If lAllUsers 
		If lAZS
			oPanelTop := TPanel():New(000,000,,oPanelMain ,,,,,,000,( oPanelMain:nHeight * 0.60 ))
			oPanelTop:Align := CONTROL_ALIGN_TOP
		EndIf
	
		oBrwAO3 := FWMBrowse():New()
		oBrwAO3:SetMenuDef("")
		oBrwAO3:SetIgnoreARotina(.T.)
		oBrwAO3:SetAlias( "AO3" )
		oBrwAO3:SetOwner(If(lAZS, oPanelTop, oPanelMain))
		oBrwAO3:SetOnlyFields(aFieldsAO3)
		oBrwAO3:SetDescription(STR0123) //"Usuários do CRM"
		oBrwAO3:DisableDetails()
		oBrwAO3:SetProfileID("USERS_CRM")
		oBrwAO3:Activate()
	EndIf
	
	If lAZS
		oPanelBut := TPanel():New(000,000,,oPanelMain ,,,,,,000,000)
		oPanelBut:Align := CONTROL_ALIGN_ALLCLIENT
		
		oBrwAZS := FWMBrowse():New()
		oBrwAZS:SetMenuDef("")
		oBrwAZS:SetIgnoreARotina(.T.)
		oBrwAZS:SetAlias( "AZS" )
		oBrwAZS:SetOwner(oPanelBut)
		oBrwAZS:SetDescription(STR0124) //"Papéis do Usuário"
		oBrwAZS:SetProfileID("USER_PAPERS")
		oBrwAZS:DisableDetails()
		oBrwAZS:AddLegend( "!Empty( AZS->AZS_IDESTN )", "BR_VERDE"		, STR0131 ) //"Papel vinculado com a estrutura de negócio"	
		oBrwAZS:AddLegend( "Empty( AZS->AZS_IDESTN ) ", "BR_VERMELHO"	, STR0130 ) //"Papel não vinculado com a estrutura de negócio"
		
		cFilDef := "AZS_CODUSR == '" + cCodUser + "'"
		
		If lFilUsr
			cFilUSR		:= ExecBlock("CRMXFILPAP")
			If ValType( cFilUSR ) == "C" .and. !Empty(cFilUSR)
				cFilDef += cFilUSR
			EndIf
		EndIf
		
		If ! ( lAllUsers )
			oBrwAZS:SetFilterDefault( cFilDef )
		EndIf
		
		oBrwAZS:Activate()
	EndIf
	 
	If lAllUsers .And. lAZS
		oRelation := FWBrwRelation():New() 
		oRelation:AddRelation(oBrwAO3,oBrwAZS,{{"AZS_CODUSR","AO3_CODUSR"}})
		oRelation:Activate()
		//Faz um refresh no browse de papeis para posicionar no registro.
		oBrwAZS:Refresh()
	EndIf
	
	oDlgRole:Activate()
		
	RestArea(aAreaAO3)
	RestArea(aAreaAZS)
		
Return cIdUserRole

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXUIPaper()

Função Legado

@author	Squad CRM/Faturamento
@since		12/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Function CRMXUIPaper( cCodUser, lAllUsers, cTitle, lBtnClose, lBtnNewRole )
Return CRMXUIRole( cCodUser, lAllUsers, cTitle, lBtnClose, lBtnNewRole )
	
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXUIGRole()

Retorna somente o papel do usuario caso seu cadastro de usuario do CRM não esteja
bloqueado.

@sample	CRMXUIGRole()

@param		Nenhum
 
@return	cIdUserRole	,caracter	,Código do Usuário + Sequencia + Papel 

@author	Anderson Silva
@since		28/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Static Function CRMXUIGRole(lAZS)
	Local aAreaAO3		:= AO3->( GetArea() )
	Local cIdUserRole	:= ""
	Local lSeek			:= .T.

	If lAZS
		If AZS->AZS_CODUSR <> AO3->AO3_CODUSR
			// AO3_FILIAL+AO3_CODUSR
			AO3->( DBSetOrder( 1 ) )
			lSeek := AO3->( DBSeek( xFilial("AO3") + AZS->AZS_CODUSR ) )
		EndIf
			
		If lSeek .And. AO3->AO3_MSBLQL != "1"
			cIdUserRole := AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL
		Else
			ApMsgAlert(STR0132)	//"Usuário Bloqueado!"
		EndIf
	Else
		cIdUserRole := AO3->AO3_CODUSR
	EndIf

	RestArea( aAreaAO3 )

Return cIdUserRole

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXNewRole()

Interface para inclusão de um novo papel de usuario.

@sample	CRMXNewRole( oDlgRole )

@param		oDlgRole		,objeto	,Janela principal Papel de Usuarios.

@return	Nenhum

@author	Anderson Silva
@since		14/01/2016
@version	12
	/*/
//-----------------------------------------------------------------------------
Static Function CRMXNewRole( oDlgRole, oBrwAZS )
	FWExecView (STR0127,"VIEWDEF.CRMA210",MODEL_OPERATION_UPDATE,/*oDlg*/,{||.T.},/*bOk*/ ,60,/*aEnableButtons*/,/*bCancel*/)
	oBrwAZS:Refresh()	
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXChgRole()

Interface de escolha para definir um papel do usuario como logado.

@sample	CRMXChgRole()

@param		Nenhum
 
@return	lRet ,logico ,Retorna verdadeiro se o papel foi trocado.

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMXChgRole()
	Local lRet 			:= .F.
	Local cCodUser		:= CRMXCodUser()
	Local cIdUserRole	:= ""
	
	If !Empty( cCodUser )
		FwMsgRun(,{|| cIdUserRole := CRMXUIRole( cCodUser, .F., STR0125 ) },Nil,STR0126) //"Trocar Papel"###"Localizando os papéis..."
		If !Empty( cIdUserRole ) 
			lRet := CRMXSetRole( cIdUserRole )
		EndIf	
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXChgPaper()
Função Legado
@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMXChgPaper()
Return CRMXChgRole()

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXInitRole

Inicializa o papel do usuario durante a inicialização do modulo.

@sample	CRMXInitRole()

@param		Nenhum
 
@return	Nenhum

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMXInitRole()
	Local cIdUserRole	:= ""
	Local cCodUser 		:= CRMXCodUser()
	Local cMainRole		:= "1"	//Sempre inicializa o papel principal;
	Local nCount		:= 0
	Local cFilAZS		:= xFilial( "AZS") 

	If !Empty( cCodUser )
		
		// AO3_FILIAL+AO3_CODUSR
		AO3->( DBSetOrder( 1 ) )
		
		If AO3->( DBSeek( xFilial("AO3") + cCodUser ) )
		
			//Não seta papel para usuario bloqueado.
			If AO3->AO3_MSBLQL != "1"
				
				AZS->( DBSetOrder(1) ) //AZS_FILIAL + AZS_CODUSR + AZS_SEQUEN + AZS_PAPEL
				
				If !AZS->( DbSeek( cFilAZS + cCodUser ) )
					cIdUserRole := CRMA240Role("USU", cCodUser )
				Else
					
					AZS->( DbSetOrder(2) ) //AZS_FILIAL + AZS_CODUSR + AZS_PAPPRI
					
					If AZS->( DbSeek( cFilAZS + cCodUser + cMainRole ) )
						cIdUserRole := AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL
					Else
						
						AZS->( DbSetOrder(1) ) //AZS_FILIAL+AZS_CODUSR+AZS_SEQUEN+AZS_PAPEL
						
						If AZS->( DbSeek( cFilAZS + cCodUser ) )
							//Se tiver mais de um papel e não tiver um principal chama interface para definir um papel
							While ( ! AZS->( Eof() ) .And. AZS->AZS_FILIAL == cFilAZS .And. AZS->AZS_CODUSR == cCodUser )
								
								cIdUserRole	:= AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL
								
								nCount += 1
								
								If nCount > 1
									cIdUserRole := ""
									Exit
								EndIf
								
								AZS->( DbSkip() )
								
							End
						EndIf
						
					EndIf
					
					If Empty( cIdUserRole )
						cIdUserRole := CRMXUIRole( cCodUser, .F.,STR0128, .F. ) //"Selecione um papel..."
					EndIf
				EndIf
				
				
				If !Empty( cIdUserRole )
					CRMXSetRole( cIdUserRole )
				EndIf
				
			EndIf
		EndIf
	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXInitPaper

Função Legada

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMXInitPaper()
Return CRMXInitRole()
