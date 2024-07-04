#INCLUDE "ESTPgOn02.ch"
#include "protheus.ch"
#include "msgraphi.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ESTPgOn02³ Autor ³ Nereu Humberto Junior ³ Data ³ 29/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo 2           ³±±
±±³          ³ Valor em estoque                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ESTPgOn02()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³{{cCombo1,{cText1, cValor, nColorValor, bClick},{...},},    ³±±
±±³          ³{cCombo2, {cText2, cValor, nColorValor, bClick},...}}       ³±±
±±³          ³                                                            ³±±
±±³          ³cCombo1 = Item da Selecao                                   ³±±
±±³          ³cText1 = Texto da Coluna                                    ³±±
±±³          ³cValor = Valor a ser exibido (string) ja com a picture aplic³±±
±±³          ³nColorValor = Cor do Valor no Formato RGB (Opcional)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  ESTPgOn02()

Local aRet      := {}
Local cPerg     := ""
Local cAliasSB2 := 'SB2'
Local nValor1   := 0,nValor2 := 0,nValor3 := 0,nValor4 := 0,nValor5 := 0
Local lQuery    := .F.
Local cSimB01   := SuperGetMv("MV_SIMB1")
Local cSimB02   := SuperGetMv("MV_SIMB2")
Local cSimB03   := SuperGetMv("MV_SIMB3")
Local cSimB04   := SuperGetMv("MV_SIMB4")
Local cSimB05   := SuperGetMv("MV_SIMB5")
Local cDescM1   := AllTrim(SuperGetMv("MV_MOEDA1"))
Local cDescM2   := AllTrim(SuperGetMv("MV_MOEDA2"))
Local cDescM3   := AllTrim(SuperGetMv("MV_MOEDA3"))
Local cDescM4   := AllTrim(SuperGetMv("MV_MOEDA4"))
Local cDescM5   := AllTrim(SuperGetMv("MV_MOEDA5"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Produto                     (Range)   ³
//³ mv_par02            // Armazem                     (Range)   ³
//³ mv_par03            // Tipo                        (Range)   ³
//³ mv_par04            // Grupo                       (Range)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg := 'ESTPGONL02'

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Converte os parametros do tipo range, para um range cheio,  ³
//³caso o conteudo do parametro esteja vazio                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FullRange(cPerg)

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)

	cAliasSB2 := GetNextAlias()	
	lQuery    := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(cPerg)
	mv_par01 := '%'+mv_par01+'%'
	mv_par02 := '%'+mv_par02+'%'
	mv_par03 := '%'+mv_par03+'%'
	mv_par04 := '%'+mv_par04+'%'
	
	BeginSql Alias cAliasSB2

		SELECT SUM(SB2.B2_VATU1) VATU1, SUM(SB2.B2_VATU2) VATU2, SUM(SB2.B2_VATU3) VATU3, SUM(SB2.B2_VATU4) VATU4, SUM(SB2.B2_VATU5) VATU5

		FROM %table:SB2% SB2
		
		JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SB2.B2_COD AND SB1.%NotDel%

		WHERE SB2.B2_FILIAL = %xFilial:SB2%
   		      AND %Exp:mv_par01%
   		      AND %Exp:mv_par02%
   		      AND %Exp:mv_par03%
   		      AND %Exp:mv_par04%   		      
   		      AND SB2.%NotDel%

	EndSql

While (cAliasSB2)->(!Eof())
	
	If lQuery .Or. ( !lQuery .And. SB1->(MsSeek(xFilial("SB1")+(cAliasSB2)->B2_COD) .And. &mv_par03 .And. &mv_par04) )

		nValor1 += IIF(lQuery,(cAliasSB2)->VATU1,(cAliasSB2)->B2_VATU1)
		nValor2 += IIF(lQuery,(cAliasSB2)->VATU2,(cAliasSB2)->B2_VATU2)
		nValor3 += IIF(lQuery,(cAliasSB2)->VATU3,(cAliasSB2)->B2_VATU3)
		nValor4 += IIF(lQuery,(cAliasSB2)->VATU4,(cAliasSB2)->B2_VATU4)
		nValor5 += IIF(lQuery,(cAliasSB2)->VATU5,(cAliasSB2)->B2_VATU5)

	Endif	
	(cAliasSB2)->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao tipo 2 - Padrao 1                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Aadd( aRet, { cDescM1 , { ;
		   	{ STR0001+cSimB01, AllTrim(Trans(nValor1,PesqPictQt("B2_VATU1"))),IIF(nValor1 > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  ) //"Valor em "

Aadd( aRet, { cDescM2 , { ;
		   	{ STR0001+cSimB02, AllTrim(Trans(nValor2,PesqPictQt("B2_VATU2"))),IIF(nValor2 > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  ) //"Valor em "
		   	
Aadd( aRet, { cDescM3 , { ;
		   	{ STR0001+cSimB03, AllTrim(Trans(nValor3,PesqPictQt("B2_VATU3"))),IIF(nValor3 > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  )		   	 //"Valor em "

Aadd( aRet, { cDescM4 , { ;
		   	{ STR0001+cSimB04, AllTrim(Trans(nValor4,PesqPictQt("B2_VATU4"))),IIF(nValor4 > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  )		   	 //"Valor em "
		   	
Aadd( aRet, { cDescM5 , { ;
		   	{ STR0001+cSimB05, AllTrim(Trans(nValor5,PesqPictQt("B2_VATU5"))),IIF(nValor5 > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  )		   	 //"Valor em "

dbSelectArea(cAliasSB2)
dbCloseArea()

dbSelectArea("SB2")
dbSetOrder(1)

Return aRet