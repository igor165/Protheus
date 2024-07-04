#include "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#include "QIPP020.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIPP020  ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 26.03.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Número de Não-Conformidades x Produtos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPP020()

Local aRetPanel := {} //Array com os dados que serão exibidos no painel
Local aDados    := {} 
Local nCnt

Private aDados1   := {}
Private nTot 	  := 0
Private cAtu      := ''

dbSelectArea("QEE")  
dbSelectArea("SB1")

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aDados:         		³
³ aDados[1] - Fornecedor					³	
³ aDados[2] - Loja		          			³
³ aDados[3] - Produto          				³
³ aDados[4] - Data Entrada     				³
³ aDados[5] - Lote	          				³
³ aDados[6] - Classe da Não-Conformidade	³
³ aDados[7] - Numero de Não-Conformidades	³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aDados:         		³
³ aDados[1] - Produto		    			³	
³ aDados[2] - Data Producao       			³
³ aDados[3] - Lote	          				³
³ aDados[4] - Classe da Não-Conformidade	³
³ aDados[5] - Numero de Não-Conformidades	³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
aDados := aClone(QIPGerQry())

// Dimensão Classe de Não-Conformidade
aDados := aSort(aDados,,,{|x,y|x[4]<y[4]})
Aeval(aDados,;
	{|x| Iif(cAtu <> x[4],;
		     Iif(Empty(AllTrim(cAtu)),;
			     {nTot+=x[5],cAtu:=x[4]},;
			     {Aadd(aDados1,{cAtu,nTot}),nTot:=0,nTot+=x[5],cAtu:=x[4]}),;
			 {nTot+=x[5],cAtu:=x[4]})})
If Len(aDados) >= 1
	Aadd(aDados1,{cAtu,nTot})
EndIf

If Len(aDados1) > 0
	aAdd(aRetPanel,{STR0001,{}}) // "Classe Não-Conformidade"
	For nCnt := 1 To Len(aDados1)
		aAdd(aRetPanel[1][2],{Posicione("QEE",1,xFilial('QEE')+aDados1[nCnt][1],"QEE_DESCPO"),Transform(aDados1[nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
	Next nCnt           
Else	
	aAdd(aRetPanel,{STR0001,{}}) // "Classe Não-Conformidade"
	aAdd(aRetPanel[1][2],{STR0003,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao há dados na dimensão"  
EndIf

// Dimensão por Produto
aDados1   := {}
nTot 	  := 0
cAtu      := ''
aDados := aSort(aDados,,,{|x,y|x[1]<y[1]})
Aeval(aDados,;
	{|x| Iif(cAtu <> x[1],;
		     Iif(Empty(AllTrim(cAtu)),;
			     {nTot+=x[5],cAtu:=x[1]},;
			     {Aadd(aDados1,{cAtu,nTot}),nTot:=0,nTot+=x[5],cAtu:=x[1]}),;
			 {nTot+=x[5],cAtu:=x[1]})})
If Len(aDados) >= 1
	Aadd(aDados1,{cAtu,nTot})
EndIf

If Len(aDados1) > 0
	aAdd(aRetPanel,{STR0002,{}}) // "Produto"
	For nCnt := 1 To Len(aDados1)
		aAdd(aRetPanel[2][2],{Posicione("SB1",1,xFilial('SB1')+aDados1[nCnt][1],"B1_DESC"),Transform(aDados1[nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
	Next nCnt           
Else	
	aAdd(aRetPanel,{STR0002,{}}) // "Produto"
	aAdd(aRetPanel[2][2],{STR0003,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao há dados na dimensão"  
EndIf


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
±±³ Uso      ³ SIGAQIP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QIPGerQry()
Local cAliasQry := GetNextAlias()
Local cStatus   := ""
Local cPerg 	:= "QIP020"
Local cWhere    := ""
Local aDados 	:= {}
 
Pergunte(cPerg,.F.)   

cWhere    :='% '

If !Empty(AllTrim(MV_PAR01)) .AND. Iif(At(";",MV_PAR01)>0,.T.,Iif(At("-",MV_PAR01)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR01, "QPK_CLIENT", "QPK")
	cWhere    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR01)) //se comporta sem range
	cWhere    += " QPK_CLIENT = '"+ PadL(AllTrim(MV_PAR01),GetSx3Cache("QPK_CLIENT","X3_TAMANHO")) + "' AND "
EndIf   

If !Empty(AllTrim(MV_PAR02)) .AND. Iif(At(";",MV_PAR02)>0,.T.,Iif(At("-",MV_PAR02)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR02, "QPR_PRODUT", "QPR")
	cWhere    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR02)) //se comporta sem range
	cWhere    += " QPR_PRODUT = '"+ PadL(AllTrim(MV_PAR02),GetSx3Cache("QPR_PRODUT","X3_TAMANHO")) + "' AND "
EndIf   

cWhere    +=' %'

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QPU")
dbSelectArea("QPR")
dbSelectArea("QPK")

BeginSql Alias cAliasQry
 
	SELECT QPK.QPK_PRODUT, QPK.QPK_DTPROD, QPK.QPK_LOTE, QPU.QPU_CLASSE, SUM(QPU_NUMNC)	NONNC					
	FROM   %table:QPK% QPK, %table:QPR% QPR, %table:QPU% QPU
	WHERE  QPK.QPK_FILIAL = %xFilial:QPK%   AND 
		   QPR.QPR_FILIAL = %xFilial:QPR%   AND 
		   QPU.QPU_FILIAL = %xFilial:QPU%   AND 
		   QPU.QPU_CODMED = QPR.QPR_CHAVE   AND 
		   QPR.QPR_PRODUT = QPK.QPK_PRODUT	AND 
		   QPR.QPR_REVI   = QPK.QPK_REVI	AND 
		   QPR.QPR_LOTE   = QPK.QPK_LOTE	AND 
		   %Exp:cWhere%
		   QPK.QPK_DTPROD BETWEEN %exp:Dtos(mv_par03)% and %exp:Dtos(mv_par04)% AND
		   QPK.%notDel% AND
		   QPR.%notDel% AND
		   QPU.%notDel%
	GROUP BY QPK.QPK_PRODUT, QPK.QPK_DTPROD, QPK.QPK_LOTE, QPU.QPU_CLASSE	

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{&(cAliasQry+"->QPK_PRODUT"),&(cAliasQry+"->QPK_DTPROD"),&(cAliasQry+"->QPK_LOTE"),&(cAliasQry+"->QPU_CLASSE"),&(cAliasQry+"->NONNC")})
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

(cAliasQry)->(DbCloseArea())

Return aDados
