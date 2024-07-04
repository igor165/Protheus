#INCLUDE "ESTPgOn04.ch"
#include "protheus.ch"
#include "msgraphi.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ESTPgOn04³ Autor ³ Nereu Humberto Junior ³ Data ³ 24/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo 5           ³±±
±±³          ³ Lotes Vencidos                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ESTPgOn04()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {bClick,aCabec,aValores)                           ³±±
±±³          ³ bClick = Bloco de codigo para execucao do duplo-click no   ³±±
±±³          ³          browse.                                           ³±±
±±³          ³ aCabec = Array contendo o cabecalho             		      ³±±
±±³          ³ aValores = Array contendo os valores da lista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  ESTPgOn04(oPGOnline,nFuncao)

Local aRet      := {}
Local nTipoData := SuperGetMV("MV_TDATALO",.F.,1)
Local dDataConf := If(nTipoData==1,dDataBase,Date())
Local aTitle    := {STR0001,STR0002,STR0003,STR0004,STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011} //"Dt.Validade"###"Lote"###"Sub-Lote"###"Produto"###"Descrição"###"Armazém"###"Saldo"###"Clie/Forn."###"Loja"###"Documento"###"Série"
Local aLotes    := {}
Local cPerg     := ""
Local dDataVenc := CTOD("")
Local cOrder    := ""
Local cAliasSB8 := 'SB8'
Local lQuery    := .F.
Local cWhere    := ''

DEFAULT nFuncao := 1
//ÚÄESTPGON04ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Produto                     (Range)   ³
//³ mv_par02            // Armazem                     (Range)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄESTPGON05ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Produto                     (Range)   ³
//³ mv_par02            // Armazem                     (Range)   ³
//³ mv_par03            // Numero de dias a vencer               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFuncao == 1 //Vencidos
	cPerg := 'ESTPGONL04'
Else // A vencer
	cPerg := 'ESTPGONL05'
Endif	

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Converte os parametros do tipo range, para um range cheio,  ³
//³caso o conteudo do parametro esteja vazio                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FullRange(cPerg)

If nFuncao == 2 //A vencer
	dDataVenc := dDatabase+IIF(Empty(mv_par03),30,mv_par03)
	If Valtype(oPGOnline) == "O"
		oPGOnline:SetDescr(STR0012+Alltrim(Str(mv_par03))+STR0013) //"Lotes a vencer em "##" dias"
	Endif	
Endif

dbSelectArea("SB8")
dbSetOrder(1)

	cAliasSB8 := GetNextAlias()	
	lQuery    := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(cPerg)
	mv_par01 := '%'+mv_par01+'%'
	mv_par02 := '%'+mv_par02+'%'
	
	cWhere := "%"
    If nFuncao == 1
    	cWhere+=" AND SB8.B8_DTVALID < '" + %Exp:Dtos(dDataConf)%+ "'"
	Else
		cWhere+=" AND SB8.B8_DTVALID >= '" + %Exp:Dtos(dDataConf)%+ "'"
		cWhere+=" AND SB8.B8_DTVALID <= '" + %Exp:Dtos(dDataVenc)%+ "'"
	Endif    
	cWhere += "%"
	
	cOrder := "% B8_FILIAL,B8_DTVALID,B8_PRODUTO,B8_LOTECTL,B8_NUMLOTE,B8_LOCAL  %"

	BeginSql Alias cAliasSB8

		SELECT SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_DTVALID, SB8.B8_SALDO, 
		SB8.B8_CLIFOR, SB8.B8_LOJA, SB8.B8_DOC, SB8.B8_SERIE

		FROM %Table:SB8% SB8
	
		WHERE SB8.B8_FILIAL = %xFilial:SB8%
   		      AND %Exp:mv_par01%
   		      AND %Exp:mv_par02%
   		      AND SB8.B8_SALDO > 0
   		      %Exp:cWhere%
   		      AND SB8.%NotDel%

		ORDER BY %Exp:cOrder%
			
	EndSql


While (cAliasSB8)->(!Eof())
	
	SB1->(MsSeek(xFilial("SB1")+(cAliasSB8)->B8_PRODUTO))
	
	(cAliasSB8)->(Aadd(aLotes, {IIF(lQuery,STOD(B8_DTVALID),B8_DTVALID),B8_LOTECTL, B8_NUMLOTE, B8_PRODUTO,;
	              SB1->B1_DESC,B8_LOCAL,AllTrim(Trans(B8_SALDO,PesqPictQt("B8_SALDO"))),B8_CLIFOR,;
	              B8_LOJA,B8_DOC,AllTrim(SubStr(B8_SERIE,1,3))}))
	
	(cAliasSB8)->(dbSkip())
EndDo

If Len(aLotes) == 0
	aLotes := {{"","","","","","","","","","",""}}
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao tipo 5 - Browse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aRet := {/*{|x| bClick}*/,aTitle,aLotes}

dbSelectArea(cAliasSB8)
DbCloseArea()

dbSelectArea("SB8")
dbSetOrder(1)

Return aRet