#include "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#include "QIEP030.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIEP030  ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 12.03.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Entradas Inspecionadas/à Inspecionar     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEP030()

Local aRetPanel := {} //Array com os dados que serão exibidos no painel
Local aDados    := {}
Local nX

//Geracao dos Dados para o Browse
aDados    := aClone(QIEGerQry())

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{STR0001,STR0002,STR0003,STR0004,STR0005,STR0006})  // "Fornecedor"###"Produto"###"Data Entrada"###"Lote"###"Validade"###"Status"
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"LEFT","LEFT","CENTER","LEFT","CENTER","LEFT"})

Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QIEGerQry ³ Autor ³ Cicero Odilio Cruz    ³ Data ³06.03.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera a Query que sera exibida pelo Painel de Gestao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEGerQry()
Local cAliasQry1 := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local cStatus
Local nX   
Local cPerg 	:= "QEP030"
Local cWhere1   := ""
Local cWhere2   := "" 
Local aDados 	:= {}
 
Pergunte(cPerg,.F.)   

cWhere1    :='% '
If mv_par06 == 1
	cWhere1 += "(QEK.QEK_TIPONF = ' ' OR QEK.QEK_TIPONF = 'N') AND"
ElseIf mv_par03 == 2                                   
	cWhere1 += "QEK.QEK_TIPONF = 'B' AND"
ElseIf mv_par03 == 3
	cWhere1 += "QEK.QEK_TIPONF = 'D' AND"
EndIf

If !Empty(AllTrim(MV_PAR01)) .AND. Iif(At(";",MV_PAR01)>0,.T.,Iif(At("-",MV_PAR01)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR01, "QEK_PRODUT", "QEK")
	cWhere1    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR01)) //se comporta sem range
	cWhere1    += " QEK_PRODUT = '"+ PadL(AllTrim(MV_PAR01),GetSx3Cache("QEK_PRODUT","X3_TAMANHO")) + "' AND "
EndIf

If !Empty(AllTrim(MV_PAR02)) .AND. Iif(At(";",MV_PAR02)>0,.T.,Iif(At("-",MV_PAR02)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR02, "QEK_FORNEC", "QEK")
	cWhere1    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR02)) //se comporta sem range
	cWhere1    += " QEK_FORNEC = '"+ PadL(AllTrim(MV_PAR02),GetSx3Cache("QEK_FORNEC","X3_TAMANHO")) + "' AND "
EndIf    

If !Empty(AllTrim(MV_PAR03)) .AND. Iif(At(";",MV_PAR03)>0,.T.,Iif(At("-",MV_PAR03)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR03, "QEK_LOJFOR", "QEK")
	cWhere1    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR03)) //se comporta sem range
	cWhere1    += " QEK_LOJFOR = '"+ PadL(AllTrim(MV_PAR02),GetSx3Cache("QEK_LOJFOR","X3_TAMANHO")) + "' AND "
EndIf  

cWhere1    +=' %'

cWhere2    :='% '
If mv_par07 == 1
	cWhere2 += "QEL.QEL_DTVAL <= '"+Dtos(dDataBase+mv_par08)+"' AND"
EndIf
cWhere2    +=' %'

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QEK")
dbSelectArea("QEL")

BeginSql Alias cAliasQry1
	
	SELECT QEK.QEK_SITENT, QEK.QEK_FILIAL, QEK.QEK_FORNEC, QEK.QEK_LOJFOR, 
	       QEK.QEK_PRODUT, QEK.QEK_DTENTR, QEK.QEK_LOTE  , QEK.QEK_TAMLOT, 
	       QEL.QEL_DTVAL
	FROM  %table:QEK% QEK, %table:QEL% QEL
	WHERE QEK.QEK_FILIAL = %xFilial:QEK% AND
		  QEL.QEL_FILIAL = QEK.QEK_FILIAL AND
	      QEK.QEK_DTENTR BETWEEN %Exp:mv_par04% AND %Exp:mv_par05% AND        
		  QEK.QEK_VERIFI = 1 AND 
	      (QEK.QEK_SITENT <> '1' AND QEK.QEK_SITENT <> '4' AND QEK.QEK_SITENT <> '7' AND QEK.QEK_SITENT <> '8') AND
	      QEL.QEL_FORNEC = QEK.QEK_FORNEC AND
	      QEL.QEL_LOJFOR = QEK.QEK_LOJFOR AND
 	      QEL.QEL_PRODUT = QEK.QEK_PRODUT AND
	      QEL.QEL_DTENTR = QEK.QEK_DTENTR AND
		  %Exp:cWhere1%
	      QEL.QEL_LOTE   = QEK.QEK_LOTE AND
		  %Exp:cWhere2%
	 	  QEK.%notDel% AND
	 	  QEL.%notDel% 
	GROUP BY QEK.QEK_SITENT, QEK.QEK_FILIAL, QEK.QEK_FORNEC, QEK.QEK_LOJFOR, 
		     QEK.QEK_PRODUT, QEK.QEK_DTENTR, QEK.QEK_LOTE  , QEK.QEK_TAMLOT, 
		     QEL.QEL_DTVAL

EndSql

dbSelectArea(cAliasQry1)
If !(cAliasQry1)->(Eof())
	While !(cAliasQry1)->(Eof())
		aAdd(aDados,{&(cAliasQry1+"->QEK_FORNEC"),&(cAliasQry1+"->QEK_PRODUT"),&(cAliasQry1+"->QEK_DTENTR"),&(cAliasQry1+"->QEK_LOTE"),StoD(&(cAliasQry1+"->QEL_DTVAL")),STR0007}) //"Inspecionada"
		(cAliasQry1)->(DbSkip())
	EndDo
EndIf

BeginSql Alias cAliasQry2
	
	SELECT QEK.QEK_SITENT, QEK.QEK_FILIAL, QEK.QEK_FORNEC, QEK.QEK_LOJFOR, 
	       QEK.QEK_PRODUT, QEK.QEK_DTENTR, QEK.QEK_LOTE  , QEK.QEK_TAMLOT,
	       QEL.QEL_DTVAL
	FROM   %table:QEK% QEK 
	LEFT JOIN  %table:QEL% QEL ON QEL.QEL_FILIAL = QEK.QEK_FILIAL AND 
	      	   QEL.QEL_FORNEC = QEK.QEK_FORNEC AND
	      	   QEL.QEL_LOJFOR = QEK.QEK_LOJFOR AND
    	       QEL.QEL_PRODUT = QEK.QEK_PRODUT AND
	           QEL.QEL_DTENTR = QEK.QEK_DTENTR AND
	           QEL.%notDel%
	WHERE      QEK.QEK_FILIAL = %xFilial:QEK% AND
	           QEK.QEK_DTENTR BETWEEN %Exp:mv_par04% AND %Exp:mv_par05% AND       
	           QEK.QEK_VERIFI = 1 AND 
		       (QEK.QEK_SITENT = '1' OR QEK.QEK_SITENT = '7' OR QEK.QEK_SITENT = '8' ) AND
		       %Exp:cWhere1%
		       QEK.%notDel%
	GROUP BY   QEK.QEK_SITENT, QEK.QEK_FILIAL, QEK.QEK_FORNEC, QEK.QEK_LOJFOR, 
		       QEK.QEK_PRODUT, QEK.QEK_DTENTR, QEK.QEK_LOTE  , QEK.QEK_TAMLOT,
		       QEL.QEL_DTVAL
EndSql

dbSelectArea(cAliasQry2)
If !(cAliasQry2)->(Eof())
	While !(cAliasQry2)->(Eof())
		aAdd(aDados,{&(cAliasQry2+"->QEK_FORNEC"),&(cAliasQry2+"->QEK_PRODUT"),&(cAliasQry2+"->QEK_DTENTR"),&(cAliasQry2+"->QEK_LOTE"),StoD(&(cAliasQry2+"->QEL_DTVAL")),STR0008})//"Á Inspecionar"
		(cAliasQry2)->(DbSkip())
	EndDo
EndIf

aDados := aSort(aDados,,,{|x,y|x[1]+x[2]+x[4]<y[1]+y[2]+y[4]})

(cAliasQry1)->(DbCloseArea())
(cAliasQry2)->(DbCloseArea())

Return aDados