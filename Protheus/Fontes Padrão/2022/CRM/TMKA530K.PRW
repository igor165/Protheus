#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออัอออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPersistSla        ณAutor: Vendas Clientes     ณData:08/01/08บฑฑ
ฑฑฬออออออออออุออออออออออออออออออฯอออออออออออออออออออออออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse abstrata contemplando as funcionalidades comuns uti- บฑฑ
ฑฑบ          ณlizadas no acesso ao banco de dados.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class PersistSla From Persist

Method save(obj)
Method delete(obj)

EndClass


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณsave      บAutor  ณVendas Clientes     บ Data ณ  10/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method save(obj) Class PersistSla
Local aRegNo    := {}						//Array com os Recnos dos registros
Local lGravou   := .F.						//Indica se gravou registro
Local lTravou   := .T.						//Indica se o registro esta travado para alteracao
Local cQuery    := ""						//Guarda a expresso da query a ser executada
Local cCursor   := "TMKA530K"				//Alias temporario da query 
Local nX        := 0						//Usada em lacos For...Next
Local nY        := 0						//Usada em lacos For...Next
Local nUsadoEnt := Len(obj:aHeadEnt)		//Nr. de campos no aHeader de Entidades
Local nUsadoSev := Len(obj:aHeadSev)		//Nr. de campos no aHeader de Severidades


BEGIN TRANSACTION 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava o Cabecalho do SLA (SK6)                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SK6")
dbSetOrder(1)
If DbSeek(xFilial("SK6")+obj:id)
	RecLock("SK6",.F.)
Else
	RecLock("SK6",.T.)
EndIf
SK6->K6_FILIAL 	:= xFilial("SK6")
If Empty(obj:id)
	SK6->K6_CODSLA 	:= GetSx8Num("SK6","K6_CODSLA")
Else
	SK6->K6_CODSLA 	:= obj:id
EndIf
SK6->K6_NOME 	:= obj:name
SK6->K6_DESCRI	:= obj:description
SK6->K6_PRIORID	:= obj:priorid
SK6->K6_CODRESP	:= obj:responsible
SK6->K6_MODWF	:= obj:codTemplate	
SK6->K6_INIVIG	:= obj:iniValidity	
SK6->K6_FIMVIG	:= obj:finValidity	
SK6->K6_STATUS	:= obj:status
SK6->K6_DSUTEIS	:= obj:utilDates
SK6->K6_TURNO	:= obj:timeshift

MsUnLock()
SK6->(FkCommit(.T.))

obj:id := SK6->K6_CODSLA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGuarda os registro para reaproveita-los                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFDEF TOP
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += "FROM "+RetSqlName("SK7")+" SK7 "
	cQuery += "WHERE SK7.K7_FILIAL='"+xFilial("SK7")+"' AND "
	cQuery += "SK7.K7_CODSLA='"+ obj:id +"' AND "
	cQuery += "SK7.D_E_L_E_T_=' ' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor)
	While !Eof()
		aAdd(aRegNo,(cCursor)->RECNO)
		DbSelectArea(cCursor)
		DbSkip()
	EndDo
	DbSelectArea(cCursor)
	DbCloseArea()
	DbSelectArea("SK7")
#ELSE
	DbSelectArea("SK7")
	DbSetOrder(1)
	DbSeek(xFilial("SK7")+SK6->K6_CODSLA)
	While ( !Eof() .And. xFilial("SK7") == SK7->K7_FILIAL .And. obj:id == SK7->K7_CODSLA )
		aadd(aRegNo,RecNo())
		DbSelectArea("SK7")
		DbSkip()
	EndDo
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava os itens do SK7                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 To Len(obj:aColsEnt)
	lTravou := .F.
	If nX <= Len(aRegNo)
		DbSelectArea("SK7")
		DbGoto(aRegNo[nX])
		RecLock("SK7")
		lTravou := .T.
	EndIf
	If ( !obj:aColsEnt[nX][nUsadoEnt+1] )
		If !lTravou
			RecLock("SK7",.T.)
		EndIf
		For nY := 1 to Len(obj:aHeadEnt)
			If obj:aHeadEnt[nY][10] <> "V"
				SK7->(FieldPut(FieldPos(obj:aHeadEnt[nY][2]), obj:aColsEnt[nX][nY]))
			EndIf
		Next nY
		SK7->K7_FILIAL := xFilial("SK7")
		SK7->K7_CODSLA := obj:id
		MsUnLock()
		lGravou := .T.
	Else
		If lTravou
			SK7->(dbDelete())
		EndIf
	EndIf
	MsUnLock()
Next nX
	
aRegNo := {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGuarda os registro para reaproveita-los                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFDEF TOP
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += "FROM "+RetSqlName("SK9")+" SK9 "
	cQuery += "WHERE SK9.K9_FILIAL='"+xFilial("SK9")+"' AND "
	cQuery += "SK9.K9_CODSLA='"+obj:id+"' AND "
	cQuery += "SK9.D_E_L_E_T_=' ' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor)
	While !Eof()
		aadd(aRegNo,(cCursor)->RECNO)
		dbSelectArea(cCursor)
		dbSkip()
	EndDo		
	dbSelectArea(cCursor)
	dbCloseArea()
	dbSelectArea("SK9")
#ELSE
	dbSelectArea("SK9")
	dbSetOrder(1)
	DbSeek(xFilial("SK9")+obj:id)
	While ( !Eof() .And. xFilial("SK9") == SK9->K9_FILIAL .And. obj:id == SK9->K9_CODSLA )
		aadd(aRegNo,RecNo())
		dbSelectArea("SK9")
		dbSkip()
	EndDo
#ENDIF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava os itens do SK9                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 To Len(obj:aColsSev)
	lTravou := .F.
	If nX <= Len(aRegNo)
		dbSelectArea("SK9")
		dbGoto(aRegNo[nX])
		RecLock("SK9")
		lTravou := .T.
	EndIf
	If ( !obj:aColsSev[nX][nUsadoSev+1] )
		If !lTravou
			RecLock("SK9",.T.)
		EndIf
		For nY := 1 to Len(obj:aHeadSev)
			If obj:aHeadSev[nY][10] <> "V"
				SK9->(FieldPut(FieldPos(obj:aHeadSev[nY][2]),obj:aColsSev[nX][nY]))
			EndIf
		Next nY
		SK9->K9_FILIAL := xFilial("SK9")
		SK9->K9_CODSLA := obj:id
		MsUnLock()
		lGravou := .T.
	Else
		If lTravou
			SK9->(dbDelete())
		EndIf
	EndIf
	MsUnLock()
Next nX	

END TRANSACTION 

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณdelete    บAutor  ณVendas Clientes     บ Data ณ  14/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method delete(obj) Class PersistSla
Local lRet := .F.		//Indica retorno da funcao

BEGIN TRANSACTION
	DbSelectArea("SK6")
	DbSetOrder(1) 
	If DbSeek(xFilial("SK6")+obj:id)
		Reclock( "SK6" ,.F.,.T.)
		DbDelete()
		MsUnlock()		   
		lRet := .T.
	EndIf
	
	DbSelectArea("SK7") 
	DbSetOrder(2) //K7_FILIAL+K7_CODSLA
	If DbSeek(xFilial("SK7")+obj:id)
		While !Eof() .AND. SK7->K7_FILIAL == xFilial("SK7") .AND.;
							SK7->K7_CODSLA == obj:id
			Reclock("SK7" ,.F.,.T.)
			DbDelete()
			MsUnlock()	
			DbSkip()
		End	
	EndIf	
	
	DbSelectArea("SK9")
	DbSetOrder(2) //K9_FILIAL+K9_CODSLA
	If DbSeek(xFilial("SK9")+obj:id)
		While !Eof() .AND. SK9->K9_FILIAL == xFilial("SK9") .AND.;
							SK9->K9_CODSLA == obj:id
			Reclock("SK9" ,.F.,.T.)
			DbDelete()
			MsUnlock()	
			DbSkip()
		End	
	EndIf	
		
END TRANSACTION

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_TMKA530K     บAutor  ณVendas Clientes บ Data ณ  08/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao dummy apenas para o programa aparecer no inspetor de บฑฑ
ฑฑบ          ณobjetos                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION _TMKA530K()
RETURN NIL
