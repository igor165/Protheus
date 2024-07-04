//-------------------------------------------------------------------
/*/{Protheus.doc} PLSATBASE

@description Exibir modal com a informação de carregando, enquanto é verificado se existem guias no status de auditoria e não possuem B53 correspondente.
@author  Thiago Ribas
@version P12
@since   02/0217

/*/
//------------------------------------------------------------------- 
user function PLSATBASE() 

MsAguarde({|| RetRgist()}, "", "Aguarde, carregando...", .T.)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSATBASE

@description Exibir modal para verificação das guias que estão no status de auditoria e não possuem B53 correspondente.
@author  Thiago Ribas
@version P12
@since   02/0217

/*/
//------------------------------------------------------------------- 
function RetRgist()

local aButtons := {} 
local aCriticas := {}
local nQuant
local cnumGui := ""
local aStaCorre := {}
local nAut := 0
local nNeg :=  0
local nTot := 0
local cSQL := "SELECT  BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT GUIA, BEA_STATUS,B53_STATUS, BE2_CODPRO, BE2_STATUS,B53_TIPO,BEA_DATSOL "
	  cSQL += " FROM " + RetSqlName("BEA") + " BEA "
	  cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
	  cSQL += " ON B53.B53_FILIAL = BEA.BEA_FILIAL AND B53.B53_NUMGUI = BEA.BEA_OPEMOV+BEA.BEA_ANOAUT+BEA.BEA_MESAUT+BEA.BEA_NUMAUT AND BEA.D_E_L_E_T_<> '*' "
	  cSQL += " INNER JOIN " + RetSqlName("BE2") 
      cSQL += " ON BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT =  BEA_FILIAL+BEA.BEA_OPEMOV+BEA.BEA_ANOAUT+BEA.BEA_MESAUT+BEA.BEA_NUMAUT "
	  cSQL += " WHERE BEA.BEA_STATUS = '6' AND BEA.BEA_TIPO < '3' "
	  cSQL += " AND BEA.D_E_L_E_T_<> '*' "
	  cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '1' OR B53.B53_TIPO = '2')) "
	  cSQL += " ORDER BY BEA_DATSOL "
		
      cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	
	Count To nQuant
	nTot := nQuant
	  
	  Trb->(dbGoTop())
	  
While ! Trb->(Eof())
		
	If cNumGui != Trb->guia
			
		BE2->(dbSetOrder(1))
		If BE2->(MsSeek(xFilial("BE2") + Trb->guia))
			
			While Trb->guia == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
				
				If BE2->BE2_STATUS == "1"
					nAut++
				ElseIf BE2->BE2_STATUS == "0"
					nNeg++
				EndIf
				
				BE2->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->BEA_STATUS == '6', "Análise",Trb->BEA_STATUS),Trb->BE2_CODPRO,If(Trb->BE2_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"SADT/CONSULTA",STOD(Trb->BEA_DATSOL), aStaCorre[2],"1"})
	
	Trb->(dbSkip())
EndDo


Trb->(DbCloseArea())

//INTERNAÇÃO	
	cNumGui := ""

	  cSQL := "SELECT BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT GUIA, BE4_STATUS,B53_STATUS, BEJ_CODPRO, BEJ_STATUS,B53_TIPO, BE4_DTDIGI "
	  cSQL += " FROM " + RetSqlName("BE4") + " BE4 "
	  cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
	  cSQL += " ON B53.B53_FILIAL = BE4_FILIAL AND B53.B53_NUMGUI = BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT AND BE4.D_E_L_E_T_<> '*' "
	  cSQL += " INNER JOIN " + RetSqlName("BEJ") 
      cSQL += " ON BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT =  BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT "
	  cSQL += " WHERE BE4_STATUS = '6' AND BE4_TIPGUI = '03' "
	  cSQL += " AND BE4.D_E_L_E_T_<> '*' "
	  cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '3')) "
	  cSQL += " ORDER BY BE4_DTDIGI "
		
	
	 cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	
	Count To nQuant
	nTot += nQuant  
	  
	  Trb->(dbGoTop())
	  
While ! Trb->(Eof())
	
	If cNumGui != Trb->guia
		
		BEJ->(dbSetOrder(1))
		If BEJ->(MsSeek(xFilial("BEJ") + Trb->guia))
			
			While Trb->guia == BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)
				
				If BEJ->BEJ_STATUS == "1"
					nAut++
				ElseIf BEJ->BEJ_STATUS == "0"
					nNeg++
				EndIf
				
				BEJ->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->BE4_STATUS == '6', "Análise",Trb->BE4_STATUS),Trb->BEJ_CODPRO,If(Trb->BEJ_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"Internação",STOD(Trb->BE4_DTDIGI),aStaCorre[2],"3"})
	
	Trb->(dbSkip())
EndDo

Trb->(DbCloseArea())

cNumGui := ""

//ANEXOS
cSQL := "SELECT B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT GUIA, B4A_STATUS, B53_STATUS, B4C_CODPRO, B4C_STATUS,B53_TIPO,B4A_DATSOL "
	  cSQL += "FROM " + RetSqlName("B4A") + " B4A "
	  cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
	  cSQL += " ON B53.B53_FILIAL = B4A_FILIAL AND B53.B53_NUMGUI = B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT AND B4A.D_E_L_E_T_<> '*' "
	  cSQL += " INNER JOIN " + RetSqlName("B4C")
      cSQL += " ON B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT =  B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT "
	  cSQL += " WHERE B4A_STATUS = '6' "
	  cSQL += " AND B4A.D_E_L_E_T_<> '*' "
	  cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '6')) "
	  cSQL += " ORDER BY B4A_DATSOL "	
	 
      cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	
	Count To nQuant
	  nTot += nQuant 
	  
	  Trb->(dbGoTop())
	  
While ! Trb->(Eof())
	
	If cNumGui != Trb->guia
	
		B4C->(dbSetOrder(1))
		If B4C->(MsSeek(xFilial("B4C") + Trb->guia))
			
			While Trb->guia == B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT)
				
				If B4C->B4C_STATUS == "1"
					nAut++
				ElseIf B4C->B4C_STATUS == "0"
					nNeg++
				EndIf
				
				B4C->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->B4A_STATUS == '6', "Análise",Trb->B4A_STATUS),Trb->B4C_CODPRO,If(Trb->B4C_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"ANEXOS",STOD(Trb->B4A_DATSOL), aStaCorre[2],"2"})
	
	Trb->(dbSkip())
EndDo


Trb->(DbCloseArea())
	
	cNumGui := ""
	
//PRORROGAÇÃO	
cSQL := "SELECT B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT GUIA, B4Q_STATUS, B53_STATUS, BQV_CODPRO, BQV_STATUS,B53_TIPO,B4Q_DATSOL "
cSQL += " FROM " + RetSqlName("B4Q") + " B4Q "
cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
cSQL += " ON B53.B53_FILIAL = B4Q_FILIAL AND B53.B53_NUMGUI = B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT AND B4Q.D_E_L_E_T_<> '*' "
cSQL += " INNER JOIN " + RetSqlName("BQV")
cSQL += " ON BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT =  B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT "
cSQL += " WHERE B4Q_STATUS = '6' "
cSQL += " AND B4Q.D_E_L_E_T_<> '*' "
cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '11')) "
cSQL += " ORDER BY B4Q_DATSOL "	
 
cSQL := ChangeQuery(cSQL)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)

Count To nQuant
nTot += nQuant 
  
Trb->(dbGoTop())
	  
While ! Trb->(Eof())
	
	If cNumGui != Trb->guia
	
		BQV->(dbSetOrder(1))
		If BQV->(MsSeek(xFilial("BQV") + Trb->guia))
			
			While Trb->guia == BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)
				
				If BQV->BQV_STATUS == "1"
					nAut++
				ElseIf BQV->BQV_STATUS == "0"
					nNeg++
				EndIf
				
				BQV->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->B4Q_STATUS == '6', "Análise",Trb->B4Q_STATUS),Trb->BQV_CODPRO,If(Trb->BQV_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"PRORROGAÇÃO",STOD(Trb->B4Q_DATSOL), aStaCorre[2],"4"})
	
	Trb->(dbSkip())
EndDo

Trb->(DbCloseArea())
	
cNumGui := ""
	
Alert(STR(nTot) + " Registros encontrados.")	
		
Aadd(aButtons, {"HISTORIC",{ || MsAguarde({|| PLAJUBASE(aCriticas)}, "", "Aguarde, Ajustando...", .T.)  },"Status","AJustar base"} )

PLSCRIGEN(aCriticas,{ {"Guia","@C",18}, {"Status guia","@C",1},{"Procedimento","@C",10},{"Status Procedimento","@C",1},{"Status auditoria","@C",1},;
	{"Status Correto","@C",1},{"TIPO DE GUIA","@C",20},{"DATA SOLICITAÇÃO","@D",8}},"Guias",,,,aButtons)


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLAJUBASE

@description Função que realiza o ajuste dos status corretos, tirando da auditoria
@author  Thiago Ribas
@version P12
@since   02/0217

/*/
//------------------------------------------------------------------- 
Function PLAJUBASE(aCri, cJob)

local nI		:= 0
local nLenCri := LEN(aCri)
Local cJobc 	:= Iif(Empty(cJob), .F., cJob)
Local cMsg	  	:= "Ajuste concluido, feche e execute a rotina novamente."

For nI := 1 To nLenCri 
	
	
	If aCri[nI][10] == "1"
	
		BEA->(dbSetOrder(1))
		If BEA->(MsSeek(xFilial("BEA") + aCri[nI][1]))
			BEA->(RecLock("BEA", .F.))
			BEA->BEA_STATUS := aCri[nI][9]
			BEA->BEA_AUDITO := "0"	
			BEA->(MsUnlock())
		EndIf
	
	ElseIf aCri[nI][10] == "2"
		B4A->(dbSetOrder(1))
		If B4A->(MsSeek(xFilial("B4A") + aCri[nI][1]))
			B4A->(RecLock("B4A", .F.))
			B4A->B4A_STATUS := aCri[nI][9]
			B4A->B4A_AUDITO := "0"	
			B4A->(MsUnlock())
		EndIf
	
	ElseIf aCri[nI][10] == "3"
		BE4->(dbSetOrder(2))
		If BE4->(MsSeek(xFilial("BE4") + aCri[nI][1]))
			BE4->(RecLock("BE4", .F.))
			BE4->BE4_STATUS := aCri[nI][9]
			BE4->BE4_AUDITO := "0"	
			BE4->(MsUnlock())
		EndIf
	ElseIf aCri[nI][10] == "4"
		B4Q->(dbSetOrder(1))
		If B4Q->(MsSeek(xFilial("B4Q") + aCri[nI][1]))
			B4Q->(RecLock("B4Q", .F.))
			B4Q->B4Q_STATUS := aCri[nI][9]
			B4Q->B4Q_AUDITO := "0"	
			B4Q->(MsUnlock())
		EndIf
	EndIf
Next

If !cJobc
	msgInfo(cMsg)
Else
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {})
EndIf

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PlsCrAudJB

@description Função que realiza os filtros para montar a query com as guias com status errados, mas sem interface gráfica e ajustado o campo B53_TIP) ==11 para Prorrogação
@author  Renan Martins
@version P12
@since   04/0217

/*/
//------------------------------------------------------------------- 
function PlsCrAudJB()

local aCriticas := {}
local nQuant
local cnumGui := ""
local aStaCorre := {}
local nAut := 0
local nNeg :=  0
local nTot := 0
local cSql	 := ""

	 cSQL := "SELECT  BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT GUIA, BEA_STATUS,B53_STATUS, BE2_CODPRO, BE2_STATUS,B53_TIPO,BEA_DATSOL "
	 cSQL += " FROM " + RetSqlName("BEA") + " BEA "
	 cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
	 cSQL += " ON B53.B53_FILIAL = BEA.BEA_FILIAL AND B53.B53_NUMGUI = BEA.BEA_OPEMOV+BEA.BEA_ANOAUT+BEA.BEA_MESAUT+BEA.BEA_NUMAUT AND BEA.D_E_L_E_T_<> '*' "
	 cSQL += " INNER JOIN " + RetSqlName("BE2") 
	 cSQL += " ON BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT =  BEA_FILIAL+BEA.BEA_OPEMOV+BEA.BEA_ANOAUT+BEA.BEA_MESAUT+BEA.BEA_NUMAUT "
	 cSQL += " WHERE BEA.BEA_STATUS = '6' AND BEA.BEA_TIPO < '3' "
	 cSQL += " AND BEA.D_E_L_E_T_<> '*' "
	 cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '1' OR B53.B53_TIPO = '2')) "
	 cSQL += " ORDER BY BEA_DATSOL "
			
	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	
	Count To nQuant
	nTot := nQuant
	  
	  Trb->(dbGoTop())
	  
While ! Trb->(Eof())
		
	If cNumGui != Trb->guia
			
		BE2->(dbSetOrder(1))
		If BE2->(MsSeek(xFilial("BE2") + Trb->guia))
			
			While Trb->guia == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
				
				If BE2->BE2_STATUS == "1"
					nAut++
				ElseIf BE2->BE2_STATUS == "0"
					nNeg++
				EndIf
				
				BE2->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->BEA_STATUS == '6', "Análise",Trb->BEA_STATUS),Trb->BE2_CODPRO,If(Trb->BE2_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"SADT/CONSULTA",STOD(Trb->BEA_DATSOL), aStaCorre[2],"1"})
	
	Trb->(dbSkip())
EndDo


Trb->(DbCloseArea())

//INTERNAÇÃO	
	cNumGui := ""

	  cSQL := "SELECT BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT GUIA, BE4_STATUS,B53_STATUS, BEJ_CODPRO, BEJ_STATUS,B53_TIPO, BE4_DTDIGI "
	  cSQL += " FROM " + RetSqlName("BE4") + " BE4 "
	  cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
	  cSQL += " ON B53.B53_FILIAL = BE4_FILIAL AND B53.B53_NUMGUI = BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT AND BE4.D_E_L_E_T_<> '*' "
	  cSQL += " INNER JOIN " + RetSqlName("BEJ") 
	  cSQL += " ON BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT =  BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT "
	  cSQL += " WHERE BE4_STATUS = '6' AND BE4_TIPGUI = '03' "
	  cSQL += " AND BE4.D_E_L_E_T_<> '*' "
	  cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '3')) "
	  cSQL += " ORDER BY BE4_DTDIGI "
	
	
	 cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	
	Count To nQuant
	nTot += nQuant  
	  
	  Trb->(dbGoTop())
	  
While ! Trb->(Eof())
	
	If cNumGui != Trb->guia
		
		BEJ->(dbSetOrder(1))
		If BEJ->(MsSeek(xFilial("BEJ") + Trb->guia))
			
			While Trb->guia == BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)
				
				If BEJ->BEJ_STATUS == "1"
					nAut++
				ElseIf BEJ->BEJ_STATUS == "0"
					nNeg++
				EndIf
				
				BEJ->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->BE4_STATUS == '6', "Análise",Trb->BE4_STATUS),Trb->BEJ_CODPRO,If(Trb->BEJ_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"Internação",STOD(Trb->BE4_DTDIGI),aStaCorre[2],"3"})
	
	Trb->(dbSkip())
EndDo

Trb->(DbCloseArea())

cNumGui := ""

//ANEXOS
	  cSQL := "SELECT B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT GUIA, B4A_STATUS, B53_STATUS, B4C_CODPRO, B4C_STATUS,B53_TIPO,B4A_DATSOL "
	  cSQL += "FROM " + RetSqlName("B4A") + " B4A "
	  cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
	  cSQL += " ON B53.B53_FILIAL = B4A_FILIAL AND B53.B53_NUMGUI = B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT AND B4A.D_E_L_E_T_<> '*' "
	  cSQL += " INNER JOIN " + RetSqlName("B4C")
	  cSQL += " ON B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT =  B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT "
	  cSQL += " WHERE B4A_STATUS = '6' "
	  cSQL += " AND B4A.D_E_L_E_T_<> '*' "
	  cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '6')) "
	  cSQL += " ORDER BY B4A_DATSOL "	
	 
      cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	
	Count To nQuant
	  nTot += nQuant 
	  
	  Trb->(dbGoTop())
	  
While ! Trb->(Eof())
	
	If cNumGui != Trb->guia
	
		B4C->(dbSetOrder(1))
		If B4C->(MsSeek(xFilial("B4C") + Trb->guia))
			
			While Trb->guia == B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT)
				
				If B4C->B4C_STATUS == "1"
					nAut++
				ElseIf B4C->B4C_STATUS == "0"
					nNeg++
				EndIf
				
				B4C->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->B4A_STATUS == '6', "Análise",Trb->B4A_STATUS),Trb->B4C_CODPRO,If(Trb->B4C_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"ANEXOS",STOD(Trb->B4A_DATSOL), aStaCorre[2],"2"})
	
	Trb->(dbSkip())
EndDo


Trb->(DbCloseArea())
	
	cNumGui := ""
	
//PRORROGAÇÃO	
	cSQL := "SELECT B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT GUIA, B4Q_STATUS, B53_STATUS, BQV_CODPRO, BQV_STATUS,B53_TIPO,B4Q_DATSOL "
	cSQL += " FROM " + RetSqlName("B4Q") + " B4Q "
	cSQL += " LEFT JOIN " + RetSqlName("B53") + " B53 "
	cSQL += " ON B53.B53_FILIAL = B4Q_FILIAL AND B53.B53_NUMGUI = B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT AND B4Q.D_E_L_E_T_<> '*' "
	cSQL += " INNER JOIN " + RetSqlName("BQV")
	cSQL += " ON BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT =  B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT "
	cSQL += " WHERE B4Q_STATUS = '6' "
	cSQL += " AND B4Q.D_E_L_E_T_<> '*' "
	cSQL += " AND (B53.B53_NUMGUI IS NULL OR B53.B53_STATUS = '1' AND (B53.B53_TIPO = '11')) "
	cSQL += " ORDER BY B4Q_DATSOL "	
 
cSQL := ChangeQuery(cSQL)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)

Count To nQuant
nTot += nQuant 
  
Trb->(dbGoTop())
	  
While ! Trb->(Eof())
	
	If cNumGui != Trb->guia
	
		BQV->(dbSetOrder(1))
		If BQV->(MsSeek(xFilial("BQV") + Trb->guia))
			
			While Trb->guia == BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)
				
				If BQV->BQV_STATUS == "1"
					nAut++
				ElseIf BQV->BQV_STATUS == "0"
					nNeg++
				EndIf
				
				BQV->(dbSkip())
			EndDo
			
		EndIf
			
		If nAut > 0 .ANd. nNeg == 0
			
			aStaCorre := {"Autorizado", '1'}
		ElseIf nAut > 0 .ANd. nNeg > 0
			aStaCorre := {"Autorizado Parcialmente", '2'}
		ElseIf nAut == 0 .ANd. nNeg > 0
			aStaCorre := {"Negado", '3'}
		EndIf
	EndIf	
	
	nAut := 0
	nNeg := 0
	
	cNumGui := Trb->guia
	
	aadd(aCriticas,{Trb->guia,IF(Trb->B4Q_STATUS == '6', "Análise",Trb->B4Q_STATUS),Trb->BQV_CODPRO,If(Trb->BQV_STATUS == "1","Autorizado","Negado"),;
		If(Trb->B53_STATUS == '1',"Aprovado",If(Trb->B53_STATUS == '2', "Aut. Parcial", If(Trb->B53_STATUS == '3', "Negado","Sem B53"))),aStaCorre[1],;
		"PRORROGAÇÃO",STOD(Trb->B4Q_DATSOL), aStaCorre[2],"4"})
	
	Trb->(dbSkip())
EndDo

Trb->(DbCloseArea())
	
cNumGui := ""

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Foram encontrados " + Alltrim(STR(nTot)) + " registros com problemas" , 0, 0, {})
		
//Chamar a funçãod e ajusta, com o array já preenchido
PLAJUBASE(aCriticas, .T.)
return



//-------------------------------------------------------------------
/*/{Protheus.doc} PlsAjAudG

@description Função que chama o job para processar e ajustar as guias erradas.
@author  Renan Martins
@version P12
@since   04/0217

/*/
//------------------------------------------------------------------- 
Function PlsAjAudG(aJob)
 
Private cCodEmp  := aJob[1]
Private cCodFil  := aJob[2]

RpcSetEnv( cCodEmp, cCodFil ,,,'PLS',, )

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Inicio da funcao para ajustar status da Guias em Auditoria - PLSATBASE" , 0, 0, {})

PlsCrAudJB()

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Fim da execução da função PLSATBASE" , 0, 0, {})

Return