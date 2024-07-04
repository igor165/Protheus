#include "protheus.ch"
#include "pmslpgl.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmsLOnl01 ³ Autor ³ Ana Paula N. Silva    ³ Data ³ 15/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recursos com mais horas apontadas no mes                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PmsLOnl01                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1] = Texto da coluna                           ³±±
±±³          ³ aRetPanel[n][2] = Valor a ser exibido                       ³±±
±±³			 | aRetPanel[n][3] = Cor do valor no formato RGB               ³±±
±±³          | aRetPanel[n][4] = Bloco de codigo p/ executar no click      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function PMSLOnl01()

	Local aArea     := GetArea()
	Local cAliasQRY := GetNextAlias()
	Local aRetPanel := {}
	Local cSqlExp   := ""  // Expressao SQL
	Local cPerg     := "PMSOL1"
	Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01 - Ranking de ?                                      ³
	//³ mv_par02 - Status do projeto ? Em aberto/Encerrado/Todos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)
		
	//Expressao SQL para filtrar as alocação apenas do mes vigente
	cSqlExp := " AND AFU.AFU_DATA >= '" + DtoS(FirstDay(dDataBase)) + "'"
	cSqlExp += " AND AFU.AFU_DATA <= '" + DtoS(LastDay(dDataBase))  + "'"

	If mv_par02=1
		cSqlExp += " AND AF8.AF8_ENCPRJ = '2' "
	ElseIf mv_par02=2
		cSqlExp += " AND AF8.AF8_ENCPRJ = '1' "
	EndIf
	
	cSqlExp := "%" + cSqlExp + "%"

	BeginSql Alias cAliasQRY
	SELECT AE8_RECURS, AE8_DESCRI, SUM(AFU_HQUANT) AS AFU_HQUANT  
		FROM %Table:AE8% AE8, %Table:AFU% AFU, %Table:AF8% AF8
		WHERE AE8.AE8_FILIAL = %xFilial:AE8%   		
			AND AE8.%NotDel%                  
  			AND AFU.AFU_FILIAL = %xFilial:AFU% 
			AND AFU.AFU_RECURS = AE8.AE8_RECURS
			AND AFU.%NotDel% 
			AND AF8.AF8_FILIAL = %xFilial:AF8%
			AND AF8.AF8_PROJET = AFU.AFU_PROJET
			AND AF8.AF8_REVISA = AFU.AFU_REVISA
			AND AF8.%NotDel% 
			%exp:cSqlExp%
  		GROUP BY AE8_RECURS, AE8_DESCRI
		ORDER BY AFU_HQUANT DESC
	EndSql

	// Lista a quantidade de recursos de acordo com o que for inserido no parametro
	While (cAliasQRY)->(!EOF()) .And. Len(aRetPanel)<mv_par01
		AADD (aRetPanel,{ALLTRIM(AE8_RECURS) + " : " + IIF(Empty(cObfNRecur),ALLTRIM(AE8_DESCRI),cObfNRecur),Transform(AFU_HQUANT,PesqPict("AFU","AFU_HQUANT"))+" "+STR0003,NIL,NIL}) //HR
		(cAliasQRY)->(dbSkip())
	EndDo		

	(cAliasQRY)->(dbCloseArea())
	RestArea(aArea)

	FATPDLogUser("PMSLONL01")

Return aRetPanel     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmsLOnl02 ³ Autor ³ Ana Paula N. Silva    ³ Data ³ 16/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Projetos com data de entrega próxima - painel tipo 1        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PmsLOnl02                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1] = Texto da coluna                           ³±±
±±³          ³ aRetPanel[n][2] = Valor a ser exibido                       ³±±
±±³			 | aRetPanel[n][3] = Cor do valor no formato RGB               ³±±
±±³          | aRetPanel[n][4] = Bloco de codigo p/ executar no click      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function PMSLOnl02()

	Local aArea     := GetArea()
	Local cAliasQRY := GetNextAlias()
	Local aRetPanel := {}    
	Local cPerg     := "PMSOL2"
	
	BeginSql Alias cAliasQRY
	SELECT AF8_PROJET, AF8_DESCRI, AF8_START, AF8_FINISH
		FROM %Table:AF8% AF8
		WHERE AF8.AF8_FILIAL = %xFilial:AF8%   		
			AND AF8.%NotDel% 
			AND AF8_FINISH >= %Exp:DtoS(dDataBase)%
			AND AF8_ENCPRJ = '2'
		ORDER BY AF8_FINISH
	EndSql

	Pergunte(cPerg,.F.)

	// Lista a quantidade de projetos de acordo com o que for inserido no parametro
	While (cAliasQRY)->(!EOF()) .And. Len(aRetPanel) < mv_par01
		dData:= Stod((cAliasQRY)->AF8_FINISH)
		AADD (aRetPanel,{ALLTRIM(AF8_PROJET) + " : " + ALLTRIM(AF8_DESCRI),STR0001 + Transform(dData,"99/99/99"),NIL,NIL}) //"Data limite:"
		(cAliasQRY)->(dbSkip())
	EndDo		

	(cAliasQRY)->(dbCloseArea())
	RestArea(aArea)

Return aRetPanel      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmsLOnl03 ³ Autor ³ Ana Paula N. Silva    ³ Data ³ 16/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Projetos com data de inicio próxima - painel tipo 1         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PmsLOnl03                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1] = Texto da coluna                           ³±±
±±³          ³ aRetPanel[n][2] = Valor a ser exibido                       ³±±
±±³			 | aRetPanel[n][3] = Cor do valor no formato RGB               ³±±
±±³          | aRetPanel[n][4] = Bloco de codigo p/ executar no click      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function PMSLOnl03()

	Local aArea     := GetArea()
	Local cAliasQRY := GetNextAlias()
	Local aRetPanel := {}    
	Local cPerg     := "PMSOL03"
	
	BeginSql Alias cAliasQRY
	SELECT AF8_PROJET, AF8_DESCRI, AF8_START
		FROM %Table:AF8% AF8
		WHERE AF8.AF8_FILIAL = %xFilial:AF8%   		
			AND AF8.%NotDel% 
		  	AND AF8_START >= %Exp:DtoS(dDataBase)%
			AND AF8_ENCPRJ = '2'
		ORDER BY AF8_START
	EndSql
          
	Pergunte(cPerg,.F.)

	// Lista a quantidade de projetos de acordo com o que for inserido no parametro
	While (cAliasQRY)->(!EOF()) .And. Len(aRetPanel) < mv_par01
		dData:= Stod((cAliasQRY)->AF8_START)
		AADD (aRetPanel,{ALLTRIM(AF8_PROJET) + " : " + ALLTRIM(AF8_DESCRI),STR0002 + Transform(dData,"99/99/99"),NIL,NIL}) //"Data Inicio:"
		(cAliasQRY)->(dbSkip())
	EndDo		

	(cAliasQRY)->(dbCloseArea())
	RestArea(aArea)

Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmsLOnl04 ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 08/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Maiores Consumos por Produto - painel tipo 2                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PmsLOnl04                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1] = Codigo do ProdutoTexto da coluna          ³±±
±±³          ³ aRetPanel[n][2][1] = Descricao do Projeto                   ³±±
±±³			 | aRetPanel[n][2][2] = Qtde do produto no projeto             ³±±
±±³          | aRetPanel[n][2][3] = Cor do valor no formato RGB            ³±±
±±³          | aRetPanel[n][2][4] = Bloco de codigo p/ executar no click   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function PMSLOnl04()
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local aAux      := {}
Local aRetPanel := {}
Local cPerg     := "PMSOL04"
Local cFiltro1  := ""
Local cFiltro2  := ""
Local cFiltro3  := ""
Local n         := 0
Local nX        := 0
Local nPos      := 0
Local cFilAF8   := xFilial("AF8")
Local cFilSB1   := xFilial("SB1")
Local cPictQtde := "@E 999,999,999.99" //x3Picture("AFN_QUANT") - coloquei fixo porque estah com problema a funcao x3Picture

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Produtos ?                                        ³
//³ mv_par02 - Projetos ?                                        ³
//³ mv_par03 - Quantos proj. por produtos ?                      ³
//³ mv_par04 - Status do projeto ? Em aberto/Encerrado/Todos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

MakeSqlExpr(cPerg)

If !Empty(Mv_Par01)
	cFiltro1 += " AND " + StrTran(Mv_Par01,"B1_COD","AFN_COD")
	cFiltro2 += " AND " + StrTran(Mv_Par01,"B1_COD","AFI_COD")
	cFiltro3 += " AND " + StrTran(Mv_Par01,"B1_COD","AJC_COD")
EndIf
If !Empty(Mv_Par02)
	cFiltro1 += " AND " + StrTran(Mv_Par02,"AF8_PROJET","AFN_PROJET")
	cFiltro2 += " AND " + StrTran(Mv_Par02,"AF8_PROJET","AFI_PROJET")
	cFiltro3 += " AND " + StrTran(Mv_Par02,"AF8_PROJET","AJC_PROJET")
EndIf
If mv_par04 = 1
	cFiltro1 += " AND AF8.AF8_ENCPRJ = '2' "
	cFiltro2 += " AND AF8.AF8_ENCPRJ = '2' "
	cFiltro3 += " AND AF8.AF8_ENCPRJ = '2' "
ElseIf mv_par04 = 2
	cFiltro1 += " AND AF8.AF8_ENCPRJ = '1' "
	cFiltro2 += " AND AF8.AF8_ENCPRJ = '1' "
	cFiltro3 += " AND AF8.AF8_ENCPRJ = '1' "
EndIf

cFiltro1 := "% " + cFiltro1 + " %"
cFiltro2 := "% " + cFiltro2 + " %"
cFiltro3 := "% " + cFiltro3 + " %"


//AFN - Projeto x Doc de Entrada
BeginSql Alias cAliasQry
	SELECT AFN_FILIAL, AFN_PROJET, AFN_COD, SUM(AFN_QUANT) AFN_QUANT
	FROM %Table:AFN% AFN
		JOIN %Table:AF8% AF8 ON AF8_FILIAL = %xFilial:AF8% AND AF8_PROJET=AFN_PROJET AND AF8.%NotDel%
	WHERE AFN.AFN_FILIAL = %xFilial:AFN%
			AND AFN.%NotDel%
			%Exp:cFiltro1%
	GROUP BY AFN_FILIAL, AFN_PROJET, AFN_COD
	ORDER BY AFN_FILIAL, AFN_PROJET
EndSql

While !(cAliasQry)->(EOF())
	Aadd( aAux , { (cAliasQry)->AFN_PROJET, (cAliasQry)->AFN_COD, (cAliasQry)->AFN_QUANT } )
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())


//AFI - Projeto x Mov Interno
BeginSql Alias cAliasQry
	SELECT AFI_FILIAL, AFI_PROJET, AFI_COD, SUM(AFI_QUANT) AFI_QUANT
	FROM %Table:AFI% AFI
		JOIN %Table:AF8% AF8 ON AF8_FILIAL = %xFilial:AF8% AND AF8_PROJET=AFI_PROJET AND AF8_REVISA=AFI_REVISA AND AF8.%NotDel%
	WHERE AFI.AFI_FILIAL = %xFilial:AFI%
			AND AFI.%NotDel%
			%Exp:cFiltro2%
	GROUP BY AFI_FILIAL, AFI_PROJET, AFI_COD
	ORDER BY AFI_FILIAL, AFI_PROJET
EndSql

While !(cAliasQry)->(EOF())
	nPos := Ascan(aAux, { |x|x[1]+x[2]==(cAliasQry)->(AFI_PROJET+AFI_COD) } )
	If nPos > 0
		aAux[nPos,3] += (cAliasQry)->AFI_QUANT
	Else
		Aadd( aAux , { (cAliasQry)->AFI_PROJET, (cAliasQry)->AFI_COD, (cAliasQry)->AFI_QUANT } )
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())


//AJC - Apontamento Direto
BeginSql Alias cAliasQry
	SELECT AJC_FILIAL, AJC_PROJET, AJC_COD, SUM(AJC_QUANT) AJC_QUANT
	FROM %Table:AJC% AJC
		JOIN %Table:AF8% AF8 ON AF8_FILIAL = %xFilial:AF8% AND AF8_PROJET=AJC_PROJET AND AF8_REVISA=AJC_REVISA AND AF8.%NotDel%
	WHERE AJC.AJC_FILIAL = %xFilial:AJC%
			AND AJC.AJC_TIPO = "1"
			AND AJC.%NotDel%
			%Exp:cFiltro3%
	GROUP BY AJC_FILIAL, AJC_PROJET, AJC_COD
	ORDER BY AJC_FILIAL, AJC_PROJET
EndSql

While !(cAliasQry)->(EOF())
	nPos := Ascan(aAux, { |x|x[1]+x[2]==(cAliasQry)->(AJC_PROJET+AJC_COD) } )
	If nPos > 0
		aAux[nPos,3] += (cAliasQry)->AJC_QUANT
	Else
		Aadd( aAux , { (cAliasQry)->AJC_PROJET, (cAliasQry)->AJC_COD, (cAliasQry)->AJC_QUANT } )
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())


AF8->(DbSetOrder(1))  //filial+projeto+descricao
For n:=1 to Len(aAux)
	AF8->(DbSeek(cFilAF8+aAux[n,1]))

	nPos := Ascan(aRetPanel, { |x|x[1]==aAux[n,2] } )
	If nPos > 0
		Aadd( aRetPanel[nPos,2] , {AF8->AF8_DESCRI , aAux[n,3] , CLR_BLACK , NIL} )
	Else
		Aadd( aRetPanel , { aAux[n,2],{ { AF8->AF8_DESCRI , aAux[n,3] , CLR_BLACK , NIL} } } )
	EndIf
Next n

aSort(aRetPanel,,,{|x,y| x[1]<y[1] })

SB1->(DbSetOrder(1))  //filial+cod

For n:=1 to Len(aRetPanel)
	aSort(aRetPanel[n,2],,,{|x,y| x[2]>y[2] })
	If Mv_Par03!=0 .And. Mv_Par03<Len(aRetPanel[n,2])
		aSize(aRetPanel[n,2], Mv_Par03)
	EndIf
	SB1->(DbSeek(cFilSB1+aRetPanel[n,1]))
	For nX:=1 to Len(aRetPanel[n,2])
		aRetPanel[n,2,nX,2] := AllTrim(Transform(aRetPanel[n,2,nX,2],cPictQtde)+" "+SB1->B1_UM)
	Next nX
Next n

Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmsLOnl05 ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 13/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recursos com mais Horas Previstas no Período - painel tipo 1³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PmsLOnl05                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1] = Texto da coluna                           ³±±
±±³          ³ aRetPanel[n][2] = Valor a ser exibido                       ³±±
±±³			 | aRetPanel[n][3] = Cor do valor no formato RGB               ³±±
±±³          | aRetPanel[n][4] = Bloco de codigo p/ executar no click      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function PmsLOnl05()
Local cAliasQry := GetNextAlias()
Local aRetPanel := {}
Local cPerg     := "PMSOL05"
Local cFiltro   := ""
Local cPictQtde := "@E 999999999.99"
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Data de alocacao de ?                             ³
//³ mv_par02 - Data de alocacao ate ?                            ³
//³ mv_par03 - Recurso ? (tipo range)                            ³
//³ mv_par04 - Quantos Recursos ?                                ³
//³ mv_par05 - Status do projeto ? Em aberto/Encerrado/Todos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

MakeSqlExpr(cPerg)

If !Empty(Mv_Par03)
  	cFiltro += " AND " + Mv_Par03
EndIf

cFiltro += " AND (AFA_START BETWEEN '"+DtoS(mv_par01)+"' And '"+DtoS(mv_par02)+"' OR AFA_FINISH BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"') "
If mv_par05 = 1
	cFiltro += " AND AF8.AF8_ENCPRJ = '2' "
ElseIf mv_par05 = 2
	cFiltro += " AND AF8.AF8_ENCPRJ = '1' "
EndIf
cFiltro := "% " + cFiltro + " %"

BeginSql Alias cAliasQry
	SELECT AFA_RECURS, AE8_DESCRI, SUM(AFA_QUANT) AFA_QUANT	
	FROM %Table:AFA% AFA 
		JOIN %Table:AE8% AE8 ON AE8_FILIAL = %xFilial:AE8% AND AE8_RECURS=AFA_RECURS AND AE8.%NotDel%
		JOIN %Table:AF8% AF8 ON AF8_FILIAL = %xFilial:AF8% AND AF8_PROJET=AFA_PROJET AND AF8_REVISA=AFA_REVISA AND AF8.%NotDel%
	WHERE AFA.AFA_FILIAL = %xFilial:AFA%
			AND AFA.%NotDel%
			%Exp:cFiltro%
	GROUP BY AFA_RECURS, AE8_DESCRI
	ORDER BY AFA_QUANT DESC
EndSql

While !(cAliasQry)->(EOF()) .And. Len(aRetPanel)<mv_par04
	aAdd (aRetPanel,{ IIF(Empty(cObfNRecur),(cAliasQry)->AE8_DESCRI,cObfNRecur),Transform((cAliasQry)->AFA_QUANT,cPictQtde)+" "+STR0003,NIL,NIL} ) //HR
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

FATPDLogUser("PMSLONL05")

Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmsLOnl06 ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 14/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Equipes com mais Horas Alocadas no Período - painel tipo 1  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PmsLOnl06                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1] = Texto da coluna                           ³±±
±±³          ³ aRetPanel[n][2] = Valor a ser exibido                       ³±±
±±³			 | aRetPanel[n][3] = Cor do valor no formato RGB               ³±±
±±³          | aRetPanel[n][4] = Bloco de codigo p/ executar no click      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function PmsLOnl06()
Local cAliasQry := GetNextAlias()
Local aRetPanel := {}
Local cPerg     := "PMSOL06"
Local cFiltro   := ""
Local cPictQtde := "@E 999999999.99"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Data de alocacao de ?                             ³
//³ mv_par02 - Data de alocacao ate ?                            ³
//³ mv_par03 - Equipe ? (tipo range)                             ³
//³ mv_par04 - Quantas equipes ?                                 ³
//³ mv_par05 - Status do projeto ? Em aberto/Encerrado/Todos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

MakeSqlExpr(cPerg)

If !Empty(Mv_Par03)
  	cFiltro += " AND " + Mv_Par03
EndIf

cFiltro += " AND (AFA_START BETWEEN '"+DtoS(mv_par01)+"' And '"+DtoS(mv_par02)+"' OR AFA_FINISH BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"') "
If mv_par05 = 1
	cFiltro += " AND AF8.AF8_ENCPRJ = '2' "
ElseIf mv_par05 = 2
	cFiltro += " AND AF8.AF8_ENCPRJ = '1' "
EndIf
cFiltro := "% " + cFiltro + " %"

BeginSql Alias cAliasQry
	SELECT AED_EQUIP, AED_DESCRI, SUM(AFA_QUANT) AFA_QUANT
	FROM %Table:AFA% AFA 
		JOIN %Table:AE8% AE8 ON AE8_FILIAL = %xFilial:AE8% AND AE8_RECURS=AFA_RECURS AND AE8.%NotDel%
		JOIN %Table:AED% AED ON AED_FILIAL = %xFilial:AED% AND AED_EQUIP=AE8_EQUIP AND AED.%NotDel%
		JOIN %Table:AF8% AF8 ON AF8_FILIAL = %xFilial:AF8% AND AF8_PROJET=AFA_PROJET AND AF8_REVISA=AFA_REVISA AND AF8.%NotDel%
	WHERE AFA.AFA_FILIAL = %xFilial:AFA%
		AND AFA.%NotDel%
		%Exp:cFiltro%
	GROUP BY AED_EQUIP, AED_DESCRI
	ORDER BY AFA_QUANT DESC
EndSql

While !(cAliasQry)->(EOF()) .And. Len(aRetPanel)<mv_par04
	aAdd (aRetPanel,{ (cAliasQry)->AED_DESCRI,Transform((cAliasQry)->AFA_QUANT,cPictQtde)+" "+STR0003,NIL,NIL} ) //HR
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

Return aRetPanel


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
