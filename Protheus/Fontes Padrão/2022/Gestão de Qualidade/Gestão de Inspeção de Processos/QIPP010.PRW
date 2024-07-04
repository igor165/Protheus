#include "protheus.ch"
#include "msGraphi.ch"
#include "QIPP010.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIPP010  ³ Autor ³ Rafael S. Bernardi    ³ Data ³17/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Ordens de produção inspecionadas / a    ³±±
±±³          ³ inspecionar                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQIP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QIPP010()

Local aRetPanel := {} //Array com os dados que serao exibidos no painel
Local nX
Local aDesCpo   := SX3Desc({"QKP_FILIAL","QPK_OP","QPK_SITOP"})
Private aDados  := {}

Pergunte("QIPP10",.F.)

//Geracao dos Dados para o Browse
QIPGerOP()

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{aDesCpo[1],aDesCpo[2],aDesCpo[3]})//Filial###Ordem de Producao###Situacao da OP
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"CENTER","LEFT","CENTER"})

Return aRetPanel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QIPGerOP  ³ Autor ³ Rafael S. Bernardi    ³ Data ³17/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados do painel de gestao Ordens de produção        ³±±
±±³          ³inspecionadas / a  inspecionar                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQIP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QIPGerOP()
Local cAliasQry := GetNextAlias()
Local cSit1 := Space(TamSX3("QPK_SITOP")[1])
Local cSit2 := '2'
Local cSit3 := '3'
Local cSit4 := '4'
Local cSit5 := '5'
Local cSit7 := '7'
Local nX

mv_par02 := DtoS(mv_par02)
mv_par03 := DtoS(mv_par03)

MakeSqlExpr("QIPP10")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QPK")

IF mv_par01 == 1
	BeginSql Alias cAliasQry
		
		SELECT QPK.QPK_FILIAL, QPK.QPK_OP, QPK.QPK_SITOP FROM %table:QPK% QPK
		WHERE QPK.QPK_FILIAL = %xFilial:QPK% AND
		      QPK.QPK_DTPROD BETWEEN %Exp:mv_par02% AND %Exp:mv_par03% AND
			 (QPK.QPK_SITOP = %Exp:cSit2% OR
			  QPK.QPK_SITOP = %Exp:cSit3% OR
			  QPK.QPK_SITOP = %Exp:cSit4% OR
			  QPK.QPK_SITOP = %Exp:cSit5%) AND
			  QPK.%NotDel%
			
	EndSql
ElseIf mv_par01 == 2
	BeginSql Alias cAliasQry
		
		SELECT QPK.QPK_FILIAL, QPK.QPK_OP, QPK.QPK_SITOP FROM %table:QPK% QPK
		WHERE QPK.QPK_FILIAL = %xFilial:QPK% AND
		      QPK.QPK_DTPROD BETWEEN %Exp:mv_par02% AND %Exp:mv_par03% AND
			 (QPK.QPK_SITOP = %Exp:cSit1% OR
			  QPK.QPK_SITOP = %Exp:cSit7%) AND
			  QPK.%NotDel%
			
	EndSql
ElseIf mv_par01 == 3
	BeginSql Alias cAliasQry

		SELECT QPK.QPK_FILIAL, QPK.QPK_OP, QPK.QPK_SITOP FROM %table:QPK% QPK
			WHERE QPK_FILIAL = %xfilial:QPK% AND
		     QPK.QPK_DTPROD BETWEEN %Exp:mv_par02% AND %Exp:mv_par03% AND
			(QPK.QPK_SITOP = %Exp:cSit1% OR
			 QPK.QPK_SITOP = %Exp:cSit2% OR
			 QPK.QPK_SITOP = %Exp:cSit3% OR
			 QPK.QPK_SITOP = %Exp:cSit4% OR
			 QPK.QPK_SITOP = %Exp:cSit5% OR
			 QPK.QPK_SITOP = %Exp:cSit7%) AND
			QPK.%NotDel%

	EndSql	
EndIf

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{&(cAliasQry+"->QPK_FILIAL"),&(cAliasQry+"->QPK_OP"),&(cAliasQry+"->QPK_SITOP")})
		(cAliasQry)->(DbSkip())
	EndDo
	For nX := 1 To Len(aDados)
		cStatus := IIF(aDados[nX][3] $ " 7",STR0001,STR0002)//"A Inspecionar"###"Inspecionada"
		aDados[nX][3] := cStatus
	Next nX
Else
	aAdd(aDados,{"","",""})
EndIf

(cAliasQry)->(DbCloseArea())

Return Nil