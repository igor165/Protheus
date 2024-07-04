#INCLUDE "PMSR010.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMSR010 ³ Autor ³Paulo Carnelossi       ³ Data ³29/05/2006³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSR010()
Local oReport := Nil 

Private lAE2_Produt
Private nValTot
Private cItem

If !PMSBLKINT()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PARAMETROS                                                             ³
	//³ MV_PAR01 : Composicao de ?                                             ³
	//³ MV_PAR02 : Composicao Ate ?                                            ³
	//³ MV_PAR03 : Data Ult.Atualizacao De                                     ³
	//³ MV_PAR04 : Data Ult.Atualizacao Ate?                                   ³
	//³ MV_PAR05 : Imprimir SubComposicao ?                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("PMR010",.F.)  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                       
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Paulo Carnelossi       ³ Data ³29/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef() 
Local oReport	:= Nil
Local oComp		:= Nil
Local oRecComp	:= Nil
Local oDespComp	:= Nil
Local oSub_Comp	:= Nil
Local oTotal	:= Nil
Local cAliasAE1 := "AE1"
Local cAliasAE2 := "AE2"
Local cAliasAE3 := "AE3"
Local cAliasAE4 := "AE4"
Local cAliasSB1 := "SB1"
Local cAliasAE8 := "AE8"

Private nCustD := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("PMSR010",STR0001,"PMR010", ;
			{|oReport| ReportPrint(oReport, @cAliasAE1, @cAliasAE2, @cAliasAE3, @cAliasAE4, @cAliasSB1, @cAliasAE8 )},;
			STR0002+STR0003+STR0004)
//"Este relatorio ira imprimir a relacao das composicoes"
//"e seus detalhes(Itens,Despesas,Sub-Composicoes) conforme "
//"os parametros solicitados"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oComp := TRSection():New(oReport,STR0001,{cAliasAE1}, {}, .F., .F.) //"Cadastro das Composicoes "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//{"Referencia","Descricao","Un.","Ult.Atual.","Utiliza"},;
TRCell():New(oComp,	"AE1_COMPOS"	,cAliasAE1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE1)->AE1_COMPOS})
TRCell():New(oComp,	"AE1_DESCRI"	,cAliasAE1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE1)->AE1_DESCRI})
TRCell():New(oComp,	"AE1_UM"		,cAliasAE1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE1)->AE1_UM})
TRCell():New(oComp,	"AE1_ULTATU"	,cAliasAE1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE1)->AE1_ULTATU})
TRCell():New(oComp,	"AE1_USO"		,cAliasAE1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{||(cAliasAE1)->(If( AE1_USO="1","OP",If(AE1_USO="2","O","I" ))) })

oRecComp := TRSection():New(oReport,STR0016,{cAliasAE2,cAliasSB1,cAliasAE8},/*aOrdem*/,.F.,.F.) //"Itens"
TRCell():New(oRecComp	,"AE2_ITEM"		,cAliasAE2,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cItem })
TRCell():New(oRecComp	,"AE2_PRODUT"   ,cAliasAE2,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lAE2_Produt, (cAliasAE2)->AE2_PRODUT, (cAliasAE2)->AE2_RECURS)})
TRCell():New(oRecComp	,"B1_DESC"		,cAliasSB1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lAE2_Produt, (cAliasSB1)->B1_DESC, FATPDObfuscate((cAliasAE8)->AE8_DESCRI,"AE8_DESCRI",Nil,.T.))})
TRCell():New(oRecComp	,"B1_TIPO"		,cAliasSB1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lAE2_Produt, (cAliasSB1)->B1_TIPO, "HR")})
TRCell():New(oRecComp	,"AE2_QUANT"	,cAliasAE2,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE2)->AE2_QUANT})
TRCell():New(oRecComp	,"B1_UM"		,cAliasSB1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasSB1)->B1_UM})
TRCell():New(oRecComp	,"B1_CUSTD"		,cAliasSB1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lAE2_Produt, (cAliasSB1)->(RetFldProd(B1_COD,"B1_CUSTD")),nCustD)})
TRCell():New(oRecComp	,"B1_CUSTD"		,cAliasSB1,STR0019/*Titulo*/,PESQPICT(cAliasSB1,"B1_CUSTD")/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lAE2_Produt, (cAliasSB1)->(RetFldProd(B1_COD,"B1_CUSTD")*(cAliasAE2)->AE2_QUANT),nCustD * (cAliasAE2)->AE2_QUANT)})

oDespComp := TRSection():New(oReport,STR0017,{cAliasAE3},/*aOrdem*/,.F.,.F.) //"Despesas"
TRCell():New(oDespComp	,"AE3_ITEM"		,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_ITEM})
TRCell():New(oDespComp	,"AE3_DESCRI"   ,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_DESCRI})
TRCell():New(oDespComp	,"AE3_TIPOD"	,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_TIPOD})
TRCell():New(oDespComp	,"AE3_VALOR"	,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_VALOR})

oSub_Comp := TRSection():New(oReport,STR0018,{cAliasAE4},/*aOrdem*/,.F.,.F.) //"Sub-Composição"
TRCell():New(oSub_Comp	,"AE4_ITEM"		,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE4_ITEM})
TRCell():New(oSub_Comp	,"AE4_SUBCOM"   ,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE4_SUBCOM})
TRCell():New(oSub_Comp	,"AE1_DESCRI"   ,cAliasAE4,/*Titulo*/,/*Picture*/,41/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE1_DESCRI})
TRCell():New(oSub_Comp	,"AE4_QUANT"	,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE4_QUANT})
TRCell():New(oSub_Comp	,"AE1_UM"   	,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE1_UM})
TRCell():New(oSub_Comp	,"B1_CUSTD"		,cAliasSB1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->(Pmr010CMP(AE4_SUBCOM))})
TRCell():New(oSub_Comp	,"B1_CUSTD"		,cAliasSB1,STR0019/*Titulo*/,PESQPICT(cAliasSB1,"B1_CUSTD")/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->(Pmr010CMP(AE4_SUBCOM))*(cAliasAE4)->AE4_QUANT}) //"Valor"

oTotal := TRSection():New(oReport,STR0020,{},/*aOrdem*/,.F.,.F.) //"Totalizador"
TRCell():New(oTotal	,"B1_CUSTD"		,,STR0021/*Titulo*/,PESQPICT(cAliasSB1,"B1_CUSTD")/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValTot}) //"** TOTAL DA COMPOSICAO **"

oRecComp:SetLinesBefore(0)
oDespComp:SetLinesBefore(0)
oSub_Comp:SetLinesBefore(0)

Return( oReport )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Paulo Carnelossi      ³ Data ³29/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³que faz a chamada desta funcao ReportPrint()                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³ExpC1: Alias da tabela de composicoes (AE1)                 ³±±
±±³          ³ExpC2: Alias da tabela de Recursos das Composicoes (AE2)    ³±±
±±³          ³ExpC3: Alias da tabela de Despesas das Composicoes (AE3)    ³±±
±±³          ³ExpC4: Alias da tabela de Sub-Composicoes (AE4)             ³±±
±±³          ³ExpC5: Alias da tabela de Produtos (SB1)                    ³±±
±±³          ³ExpC5: Alias da tabela de Produtos (AE8)                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport, cAliasAE1, cAliasAE2, cAliasAE3, cAliasAE4, cAliasSB1, cAliasAE8 )
Local oComp		:= oReport:Section(1)
Local oRecComp	:= oReport:Section(2)
Local oDespComp	:= oReport:Section(3)
Local oSub_Comp	:= oReport:Section(4)
Local oTotal	:= oReport:Section(5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam/*Nome da Pergunte*/)

#IFDEF TOP

TRPosition():New(oComp,"AE1",1,{|| xFilial("AE1")+(cAliasAE1)->AE1_COMPOS})

TRPosition():New(oRecComp,"SB1",1,{|| xFilial("SB1")+ If(lAE2_Produt,(cAliasAE2)->AE2_PRODUT,Space(Len((cAliasAE2)->AE2_PRODUT))) })
TRPosition():New(oRecComp,"AE8",1,{|| xFilial("AE8")+(cAliasAE2)->AE2_RECURS})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oComp:BeginQuery()	

cAliasAE1 := GetNextAlias()

	BeginSql Alias cAliasAE1
	SELECT  AE1_FILIAL, AE1_COMPOS, AE1_DESCRI, AE1_UM, AE1_ULTATU, AE1_USO
	FROM %table:AE1% AE1
	WHERE AE1.AE1_FILIAL = %xFilial:AE1% AND 
			AE1.AE1_COMPOS >= %Exp:mv_par01% AND
			AE1.AE1_COMPOS <= %Exp:mv_par02% AND
			AE1.AE1_ULTATU >= %Exp:Mv_Par03% AND
			AE1.AE1_ULTATU <= %Exp:Mv_Par04% AND
			AE1.%NotDel% 
	ORDER BY AE1.AE1_FILIAL, AE1.AE1_COMPOS//%Exp:AE1%
	EndSql 	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³                                                                        ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³                                                                        ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oComp:EndQuery(/*ExpA1*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasAE2 := GetNextAlias()

Begin REPORT QUERY oRecComp

	BeginSql Alias cAliasAE2
	SELECT  AE2_FILIAL, AE2_COMPOS, AE2_ITEM, AE2_PRODUT, AE2_QUANT, AE2_RECURS
	FROM %table:AE2% AE2
	WHERE AE2.AE2_FILIAL = %xFilial:AE2% AND 
			AE2_COMPOS = %report_param:(cAliasAE1)->AE1_COMPOS% AND
			AE2.%NotDel%
	ORDER BY AE2.AE2_FILIAL, AE2.AE2_COMPOS// %Exp:AE2%
	EndSql 
    
End REPORT QUERY oRecComp

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasAE3 := GetNextAlias()

Begin REPORT QUERY oDespComp

	BeginSql Alias cAliasAE3
	SELECT AE3_FILIAL, AE3_COMPOS, AE3_ITEM, AE3_DESCRI, AE3_TIPOD, AE3_VALOR
	FROM %table:AE3% AE3
	WHERE AE3.AE3_FILIAL = %xFilial:AE3% AND 
			AE3.AE3_COMPOS = %report_param:(cAliasAE1)->AE1_COMPOS% AND
			AE3.%NotDel%
	ORDER BY  AE3.AE3_FILIAL, AE3.AE3_COMPOS//%Exp:AE3%
	EndSql 	

End REPORT QUERY oDespComp

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 4                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasAE4 := GetNextAlias()

Begin REPORT QUERY oSub_Comp

	BeginSql Alias cAliasAE4
	SELECT AE4_FILIAL, AE4_COMPOS, AE4_ITEM, AE4_SUBCOM, AE1_DESCRI, AE4_QUANT, AE1_UM
	FROM %table:AE1% AE1, %table:AE4% AE4
	WHERE AE4.AE4_FILIAL = %xFilial:AE4% AND 
			AE4.AE4_COMPOS = %report_param:(cAliasAE1)->AE1_COMPOS% AND
			AE4.%NotDel% AND
			AE1.AE1_FILIAL = %xFilial:AE1% AND 
			AE1.AE1_COMPOS = AE4.AE4_SUBCOM AND
			AE1.%NotDel%                        
	ORDER BY  AE4.AE4_FILIAL, AE4.AE4_COMPOS//%Exp:AE4%
	EndSql
    	    
End REPORT QUERY oSub_Comp

oReport:SetMeter((cAliasAE1)->(LastRec()))
	
dbSelectArea(cAliasAE1)
While (cAliasAE1)->(!Eof()) .And. !oReport:Cancel()	
	oComp:Init()
	oComp:PrintLine()
	
	nValTot := 0
	cItem   := "01"
	
	//-- Imprime Itens (recursos da composicao)
	oRecComp:ExecSQL()
	If (cAliasAE2)->(! Eof())

		oRecComp:Init()
		oReport:SkipLine()
		oReport:PrintText(STR0013) //"ITENS"
		
		While (cAliasAE2)->(! Eof()) .And. !oReport:Cancel()

			lAE2_Produt := (Empty((cAliasAE2)->AE2_RECURS)) 
			If lAE2_Produt
				// produto alocado
				DbSelectArea("SB1")
				DbSetOrder(1)
				If MsSeek( xFilial("SB1")+(cAliasAE2)->AE2_PRODUT )
					nCustd	:=	RetFldProd(SB1->B1_COD,"B1_CUSTD")
					nValTot += (RetFldProd(SB1->B1_COD,"B1_CUSTD")*(cAliasAE2)->AE2_QUANT)
				EndIf
			Else
				nCustD   := 0
				// recurso alocado
				DbSelectArea("AE8")
				DbSetOrder(1)
				If AE8->(MsSeek( xFilial("AE8") + (cAliasAE2)->AE2_RECURS))
					If ! Empty( (cAliasAE2)->AE2_PRODUT )
						// produto alocado
						DbSelectArea("SB1")
						DbSetOrder(1)
						If MsSeek( xFilial("SB1")+(cAliasAE2)->AE2_PRODUT )
							nCustD   := RetFldProd(SB1->B1_COD,"B1_CUSTD")
						EndIf
						DbSelectArea("AE8")
				    Else
					    nCustD   := AE8->AE8_VALOR
				    EndIf
					nValTot += (nCustD * (cAliasAE2)->AE2_QUANT)
				EndIf				
			EndIf				

			oRecComp:PrintLine()
			
			(cAliasAE2)->(DbSkip())
			cItem:= Soma1(cItem)

		EndDo
		oRecComp:Finish()
	EndIf

	//-- Imprime Despesas da composicao
	oDespComp:ExecSQL()
	If (cAliasAE3)->(! Eof())

		oDespComp:Init()
		oReport:SkipLine()
		oReport:PrintText(STR0014) //"DESPESAS"

		While (cAliasAE3)->(! Eof()) .And. !oReport:Cancel()
			nValTot := nValTot + (cAliasAE3)->AE3_VALOR
			oDespComp:PrintLine()
			(cAliasAE3)->(DbSkip())
		EndDo
		oDespComp:Finish()
	EndIf

	//-- Imprime Sub-Composicoes
	oSub_Comp:ExecSQL()
	If (cAliasAE4)->(! Eof())

		oSub_Comp:Init()
		oReport:SkipLine()
		oReport:PrintText(STR0015) //"SUB-COMPOSICAO"

		While (cAliasAE4)->(! Eof()) .And. !oReport:Cancel()

			oSub_Comp:PrintLine()
			If mv_par05 = 1 //Imprimir SubComposicao ?
				oSub_Comp:Finish()
				SUBCOMP( oReport, oSub_Comp, (cAliasAE4)->AE4_SUBCOM, 1 )
				oSub_Comp:Init()
			EndIf
			
			nValTot += ( Pmr010CMP((cAliasAE4)->AE4_SUBCOM) * (cAliasAE4)->AE4_QUANT )
			(cAliasAE4)->(DbSkip())
		EndDo
		oSub_Comp:Finish()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o total da composicao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTotal:Init()
	oTotal:PrintLine()
	oTotal:Finish()

  	(cAliasAE1)->(DbSkip())
	oComp:Finish()
	oReport:IncMeter()
		
EndDo

//=================================================================================//
//VERSÃO SEM TOPCONNECT DO RELATORIO PARA RELEASE 4 DO PROTHEUS 8.11
//=================================================================================//
#ELSE

oSub_Comp:Cell("AE1_DESCRI"):SetBlock({|| AE1->AE1_DESCRI })
oSub_Comp:Cell("AE1_UM")    :SetBlock({|| AE1->AE1_UM })

DbSelectArea("AE8")
DbSetOrder(1)

DbSelectArea("AE2")
DbSetOrder(1)

DbSelectArea("AE3")
DbSetOrder(1)

DbSelectArea("AE4")
DbSetOrder(1)

DbSelectArea("SB1")
DbSetOrder(1)

dbSelectArea("AE1")
dbSetOrder(1)
oReport:SetMeter(AE1->(LastRec()))

dbSeek(xFilial("AE1")+mv_par01,.T.)
While !Eof() .And. (AE1->AE1_FILIAL == xFilial("AE1")) .And. ;
					(AE1->AE1_COMPOS >= mv_par01) .And. ;
					(AE1->AE1_COMPOS <= mv_par02) .And.;
					((AE1->AE1_ULTATU >= Mv_Par03) .And. (AE1->AE1_ULTATU <= Mv_Par04) .Or. ;
							 Empty(DTOS(AE1->AE1_ULTATU))) .And. !oReport:Cancel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os dados da composicao.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oComp:Init()
	oComp:PrintLine()
	nValTot  := 0
	cItem	 := "01"

	DbSelectArea("AE2")
	DbSetOrder(1)
	If MsSeek(xFilial("AE2")+AE1->AE1_COMPOS)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os dados Recursos da composicao.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oRecComp:Init()
		oReport:SkipLine()
		oReport:PrintText(STR0013) //"ITENS"

		While !Eof()  .And. (xFilial("AE2")  == AE2->AE2_FILIAL) .And.;
						 (AE1->AE1_COMPOS == AE2->AE2_COMPOS ) .And. !oReport:Cancel()
						 
			lAE2_Produt := (Empty(AE2->AE2_RECURS))
		
			If lAE2_Produt
				// produto alocado
				DbSelectArea("SB1")
				DbSetOrder(1)
				If MsSeek( xFilial("SB1")+AE2->AE2_PRODUT )
					nValTot += (RetFldProd(SB1->B1_COD,"B1_CUSTD")*AE2->AE2_QUANT)
				EndIf
			Else
				nCustD   := 0
				// recurso alocado
				DbSelectArea("AE8")
				DbSetOrder(1)
				If AE8->(MsSeek( xFilial("AE8") + AE2->AE2_RECURS))
					If ! Empty( AE2->AE2_PRODUT )
						// produto alocado
						DbSelectArea("SB1")
						DbSetOrder(1)
						If MsSeek( xFilial("SB1")+AE2->AE2_PRODUT )
							nCustD   := RetFldProd(SB1->B1_COD,"B1_CUSTD")
						EndIf
						DbSelectArea("AE8")
					Else
						nCustD   := AE8->AE8_VALOR
					EndIf
					nValTot += (nCustD * AE2->AE2_QUANT)
				EndIf				
			EndIf				
			oRecComp:PrintLine()

			DbSelectArea("AE2")
			DbSkip()
			cItem := Soma1(cItem)
		EndDo

		oRecComp:Finish()
	EndIf
	
	DbSelectArea("AE3")
	DbSetOrder(1)
	If MSSeek( xFilial("AE3")+AE1->AE1_COMPOS )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os dados Despesas da composicao.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDespComp:Init()
		oReport:SkipLine()
		oReport:PrintText(STR0014) //"DESPESAS"

		While !Eof() .And. (xFilial("AE3")  == AE1->AE1_FILIAL) .And. (AE1->AE1_COMPOS == AE3->AE3_COMPOS) .And. !oReport:Cancel()
			nValTot := nValTot + AE3->AE3_VALOR
			oDespComp:PrintLine()
			dbSkip()
		End
		oDespComp:Finish()
	EndIf
	
	DbSelectArea("AE4")
	DbSetOrder(1)
	If MSSeek(xFilial("AE4")+AE1->AE1_COMPOS )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os dados Despesas da composicao.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSub_Comp:Init()
		oReport:SkipLine()
		oReport:PrintText(STR0015) //"SUB-COMPOSICAO"

		While AE4->(!Eof()) .And. (xFilial("AE4")  == AE1->AE1_FILIAL) .And. ;
					 (AE4->AE4_COMPOS == AE1->AE1_COMPOS) .And. !oReport:Cancel()

			aAreaAe1 := AE1->(GetArea())
			If AE1->(MsSeek(xFilial("AE1")+AE4->AE4_SUBCOM))
				oSub_Comp:PrintLine()

				If mv_par05 = 1 //Imprimir SubComposicao ?
					oSub_Comp:Finish()
					SUBCOMP( oReport, oSub_Comp, AE4->AE4_SUBCOM, 1 )
					oSub_Comp:Init()
				EndIf

				nValAux  := Pmr010CMP(AE4->AE4_SUBCOM)
				AE1->(RestArea(aAreaAe1))
				nValTot += ( nValAux * AE4->AE4_QUANT )
			EndIf
			AE4->(DbSkip())
		End
		oSub_Comp:Finish()
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o total da composicao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTotal:Init()
	oTotal:PrintLine()
	oTotal:Finish()
	
	dbSelectArea("AE1")
	dbSkip()

	oComp:Finish()
	oReport:IncMeter()

End

#ENDIF

If oReport:Cancel()
	oReport:Say( oReport:Row()+1 ,10 ,STR0007 )
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SUBCOMP    ³ Autor ³Daniel Tadashi Batori ³ Data ³18/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao eh utilizada para a impressão das subcomposicoes   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nulo                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oReport     : objeto TReport                                ³±±
±±³          ³oSectionX   : objeto TRSection                              ³±±
±±³          ³cComposicao : codigo da subcomposicao a ser aberta          ³±±
±±³          ³nNivel      : nivel da subcomposicao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SUBCOMP( oReport, oSectionX, cComposicao, nNivel )
Local oRecComp
Local oDespComp
Local oSub_Comp
Local cAliasAE2 := GetNextAlias()
Local cAliasAE3 := GetNextAlias()
Local cAliasAE4 := GetNextAlias()
Local lProduto 	:= .F.
Local cCodItem 	:= "01"
Local nMargem 	:= 5 * nNivel
Local aAreaAE1

Private nCustD

//Criacao das secoes da subcomposicao
oRecComp := TRSection():New(oSectionX,STR0016,,/*aOrdem*/,.F.,.F.) //"Itens"
TRCell():New(oRecComp ,"AE2_ITEM"  ,cAliasAE2,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cCodItem })
TRCell():New(oRecComp ,"AE2_PRODUT",cAliasAE2,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lProduto, (cAliasAE2)->AE2_PRODUT, (cAliasAE2)->AE2_RECURS)})
TRCell():New(oRecComp ,"B1_DESC"   ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lProduto, SB1->B1_DESC, FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",NiL,.T.))})
TRCell():New(oRecComp ,"B1_TIPO"   ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lProduto, SB1->B1_TIPO, "HR")})
TRCell():New(oRecComp ,"AE2_QUANT" ,cAliasAE2,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE2)->AE2_QUANT})
TRCell():New(oRecComp ,"B1_UM"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| SB1->B1_UM })
TRCell():New(oRecComp ,"B1_CUSTD"  ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lProduto, SB1->(RetFldProd(B1_COD,"B1_CUSTD")),nCustD)})
TRCell():New(oRecComp ,"B1_CUSTD"  ,"SB1",STR0019/*Titulo*/,PESQPICT("SB1","B1_CUSTD")/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(lProduto, SB1->(RetFldProd(B1_COD,"B1_CUSTD")*(cAliasAE2)->AE2_QUANT),nCustD * (cAliasAE2)->AE2_QUANT)})
oRecComp:SetLinesBefore(0)
oRecComp:SetLeftMargin(nMargem)
 
oDespComp := TRSection():New(oSectionX,STR0017,{cAliasAE3},/*aOrdem*/,.F.,.F.) //"Despesas"
TRCell():New(oDespComp ,"AE3_ITEM"   ,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_ITEM})
TRCell():New(oDespComp ,"AE3_DESCRI" ,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_DESCRI})
TRCell():New(oDespComp ,"AE3_TIPOD"  ,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_TIPOD})
TRCell():New(oDespComp ,"AE3_VALOR"  ,cAliasAE3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE3)->AE3_VALOR})
oDespComp:SetLinesBefore(0)
oDespComp:SetLeftMargin(nMargem)

oSub_Comp := TRSection():New(oSectionX,STR0018,{cAliasAE4},/*aOrdem*/,.F.,.F.) //"Sub-Composição"
TRCell():New(oSub_Comp ,"AE4_ITEM"   ,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE4_ITEM})
TRCell():New(oSub_Comp ,"AE4_SUBCOM" ,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE4_SUBCOM})
TRCell():New(oSub_Comp ,"AE1_DESCRI" ,cAliasAE4,/*Titulo*/,/*Picture*/,41/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE1_DESCRI})
TRCell():New(oSub_Comp ,"AE4_QUANT"  ,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE4_QUANT})
TRCell():New(oSub_Comp ,"AE1_UM"     ,cAliasAE4,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->AE1_UM})
TRCell():New(oSub_Comp ,"B1_CUSTD"   ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->(Pmr010CMP(AE4_SUBCOM))})
TRCell():New(oSub_Comp ,"B1_CUSTD"   ,"SB1",STR0019/*Titulo*/,PESQPICT("SB1","B1_CUSTD")/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAE4)->(Pmr010CMP(AE4_SUBCOM))*(cAliasAE4)->AE4_QUANT}) //"Valor"
oSub_Comp:SetLinesBefore(0)
oSub_Comp:SetLeftMargin(nMargem)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin REPORT QUERY oRecComp
	BeginSql Alias cAliasAE2

	SELECT  AE2_FILIAL, AE2_COMPOS, AE2_ITEM, AE2_PRODUT, AE2_QUANT, AE2_RECURS
	FROM %table:AE2% AE2
	WHERE AE2.AE2_FILIAL = %xFilial:AE2% AND 
			AE2_COMPOS = %Exp:cComposicao% AND
			AE2.%NotDel%
	ORDER BY AE2.AE2_FILIAL, AE2.AE2_COMPOS
	EndSql 
	
End REPORT QUERY oRecComp

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin REPORT QUERY oDespComp
	BeginSql Alias cAliasAE3

	SELECT AE3_FILIAL, AE3_COMPOS, AE3_ITEM, AE3_DESCRI, AE3_TIPOD, AE3_VALOR
	FROM %table:AE3% AE3
	WHERE AE3.AE3_FILIAL = %xFilial:AE3% AND 
			AE3.AE3_COMPOS = %Exp:cComposicao% AND
			AE3.%NotDel%
	ORDER BY AE3.AE3_FILIAL, AE3.AE3_COMPOS//%Exp:AE3%
	EndSql 	
End REPORT QUERY oDespComp

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 4                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin REPORT QUERY oSub_Comp
	BeginSql Alias cAliasAE4

	SELECT AE4_FILIAL, AE4_COMPOS, AE4_ITEM, AE4_SUBCOM, AE1_DESCRI, AE4_QUANT, AE1_UM
	FROM %table:AE1% AE1, %table:AE4% AE4
	WHERE AE4.AE4_FILIAL = %xFilial:AE4% AND 
			AE4.AE4_COMPOS = %Exp:cComposicao% AND
			AE4.%NotDel% AND
			AE1.AE1_FILIAL = %xFilial:AE1% AND 
			AE1.AE1_COMPOS = AE4.AE4_SUBCOM AND
			AE1.%NotDel%                        
	ORDER BY  AE4.AE4_FILIAL, AE4.AE4_COMPOS//%Exp:AE4%
			
	EndSql
End REPORT QUERY oSub_Comp

oReport:SkipLine()
	
//-- Imprime Itens (recursos da composicao)
If (cAliasAE2)->(! Eof())
	oRecComp:Init()
			
	oReport:SkipLine()
	oReport:PrintText(Space(nMargem)+STR0013) //"ITENS"

	While (cAliasAE2)->(! Eof())
		lProduto := (Empty((cAliasAE2)->AE2_RECURS)) 	
		If lProduto
			// produto alocado
			DbSelectArea("SB1")
			DbSetOrder(1)
			MsSeek(xFilial("SB1")+(cAliasAE2)->AE2_PRODUT)
		Else
			nCustD   := 0
			// recurso alocado
			DbSelectArea("AE8")
			DbSetOrder(1)
			If AE8->(MsSeek( xFilial("AE8") + (cAliasAE2)->AE2_RECURS))
				If ! Empty( (cAliasAE2)->AE2_PRODUT )
					// produto alocado
					DbSelectArea("SB1")
					DbSetOrder(1)
					If MsSeek( xFilial("SB1")+(cAliasAE2)->AE2_PRODUT )
						nCustD   := RetFldProd(SB1->B1_COD,"B1_CUSTD")
					EndIf
					DbSelectArea("AE8")
				Else
					nCustD   := AE8->AE8_VALOR
				EndIf
			EndIf				
		EndIf				

		oRecComp:PrintLine()
			
		(cAliasAE2)->(DbSkip())
		cCodItem:= Soma1(cCodItem)

	EndDo
	oRecComp:Finish()
EndIf

//-- Imprime Despesas da composicao
oDespComp:ExecSQL() 
If (cAliasAE3)->(! Eof())
	oDespComp:Init()
	oReport:SkipLine()
	oReport:PrintText(Space(nMargem)+STR0014) //"DESPESAS"
	While (cAliasAE3)->(! Eof())
		oDespComp:PrintLine()
		(cAliasAE3)->(DbSkip())
	EndDo
	oDespComp:Finish()
EndIf
	
//-- Imprime Sub-Composicoes
If (cAliasAE4)->(! Eof())
	oReport:SkipLine()
	oReport:PrintText(Space(nMargem)+STR0015) //"SUB-COMPOSICAO"
	While (cAliasAE4)->(! Eof())
		oSub_Comp:Init()

		aAreaAE1 := AE1->(GetArea())
		AE1->(MsSeek(xFilial("AE1")+(cAliasAE4)->AE4_SUBCOM))
		oSub_Comp:PrintLine()
		RestArea(aAreaAE1)
		
		SUBCOMP( oReport, oSub_Comp, (cAliasAE4)->AE4_SUBCOM, nNivel+1 )
		oSub_Comp:Finish()
		(cAliasAE4)->(DbSkip())
	EndDo
EndIf
		
oReport:SkipLine(1)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMR010CMP ³ Autor ³Fabio Rogerio Pereira  ³ Data ³ 18-09-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o o custo da Composicao.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo de Referencia da Composicao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMR010CMP(cReferencia)
Local aArea    := GetArea()
Local aAreaAE4 := AE4->(GetArea())
Local nCusto   := 0

SB1->(dbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o custo dos Recursos utilizados no AE2         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AE2")
dbSetOrder(1)
MsSeek(xFilial()+cReferencia)
While !Eof() .And. AE2->AE2_FILIAL+AE2->AE2_COMPOS==xFilial("AE2")+cReferencia
	If ! Empty(AE2->AE2_PRODUT)
		SB1->(MsSeek(xFilial()+AE2->AE2_PRODUT))
		nCusto += xMoeda(RetFldProd(SB1->B1_COD,"B1_CUSTD")*AE2->AE2_QUANT,Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD")),1,dDataBase)
	Else
			dbSelectArea("AE8")
			If AE8->(MsSeek(xFilial("AE8")+AE2->AE2_RECURS))
				nCusto += xMoeda(AE8_VALOR*AE2->AE2_QUANT,1 ,1,dDataBase)
			EndIf
	EndIf   
	dbSelectArea("AE2")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o custo dos Recursos utilizados no AE3         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AE3")
dbSetOrder(1)
MsSeek(xFilial()+cReferencia)
While !Eof() .And. AE3->AE3_FILIAL+AE3->AE3_COMPOS==xFilial("AE3")+cReferencia
	nCusto += xMoeda(AE3->AE3_VALOR,AE3->AE3_MOEDA,1,dDataBase)
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o custo da sub composicao relacionada          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AE4")
dbSetOrder(1)
MsSeek(xFilial()+cReferencia)
While !Eof() .And. AE4->AE4_FILIAL+AE4->AE4_COMPOS==xFilial("AE4")+cReferencia
	nCusto+= AE4->AE4_QUANT*Pmr010CMP(AE4->AE4_SUBCOM)
	dbSkip()
End

RestArea(aArea)
RestArea(aAreaAE4)

Return(nCusto)

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
