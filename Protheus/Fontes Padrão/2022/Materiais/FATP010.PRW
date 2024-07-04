#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATP010.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FATP010   ³ Autor ³ Marco Bianchi         ³ Data ³ 18/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 4: Meta de Venda       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FATP010()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {cText1,nPosIni,nPosFim,{cValor,cLegenda,nColorValor,³±±
±±³          ³ cClick,nPos},{cValor,cLegenda,nColorValor,cClick,nPos}}      ³±±
±±³          ³ cText1      = Texto da Barra                         		³±±
±±³          ³ nPosIni     = Valor Inicial                      		    ³±±
±±³          ³ nPosFim     = Valor Final                                    ³±±
±±³          ³ cValor      = Valor a ser exibido                            ³±±
±±³          ³ cLegenda    = Nome da Legenda                                ³±±
±±³          ³ nColorValor = Cor do Valor no formato RGB (opcional)         ³±±
±±³          ³ cClick      = Funcao executada no click do valor (opcional)  ³±±
±±³          ³ nPos        = Valor da Barra                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMDI                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function FATP010()

Local aRet       := {} 
Local nMeta      := 0							// Meta ate final do mes
Local nMetaHj    := 0							// Meta ate Data Base
Local nVendas    := 0			 				// Vendas realizadas no mes
Local nDevol     := 0   						// Devolucoes realizadas no mes
Local nTpMeta    := 1							// 1 = por Valor, 2 = por Quantidade
Local cMes       := StrZero(Month(dDataBase),2)
Local cAno       := Substr(DTOC(dDataBase),7,2)
Local dDataIni   := CTOD("01/"+cMes+"/"+cAno)
Local dDataFim   := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nPercMt	 := 0
Local nPercReal  := 0
Local cMensagem1 := ""
Local cMensagem2 := ""
          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("FATP010",.F.)
nTpMeta  := mv_par01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a funcao de calculo das Metas                           ³
//³Parametros³ExpN1: Tipo de Meta  :( 1-Valor    )               ³
//³          ³                      ( 2-Quantidade )             ³
//³          ³ExpC2: cCodigo do Vendedor/Supervisor/Gerente      ³
//³          ³ExpD3: Data de Inicio                              ³
//³          ³ExpD4: Data de Termino                             ³
//³          ³ExpC5: Regiao de Vendas                            ³
//³          ³ExpC6: Tipo de Produto                             ³
//³          ³ExpC7: Grupo de Produto                            ³
//³          ³ExpC8: Codigo do Produto                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMetaHj := FtMetaVenda(nTpMeta,,dDataIni,dDataBase)		// Meta ate DataBase
nMeta   := FtMetaVenda(nTpMeta,,dDataIni,dDataFim)		// Meta do Mes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a funcao de calculo das vendas                          ³
//³Parametros:                                                   ³
//³    ExpN1: Tipo Meta :(1-Numerico-Valor liquido - desconto )  ³
//³                      (2-Numerico-Quantidade )                ³
//³                      (3-Numerico-Valor bruto + desconto )    ³
//³                      (4-Array-contendo todos os valores acima³
//³                      (5-Array-contendo todos os valores acima³
//³                       por produto                            ³
//³    ExpC2: cCodigo                                            ³
//³    ExpD3: Data de Inicio                                     ³
//³    ExpD4: Data de Termino                                    ³
//³    ExpC5: Regiao de Vendas.                                  ³
//³    ExpC6: Tipo de Produto                                    ³
//³    ExpC7: Grupo de Produto                                   ³
//³    ExpC8: Codigo do Produto                                  ³
//³    ExpN9: Moeda para conversao                               ³
//³    ExpCA: Cliente                                            ³
//³    ExpCB: Loja                                               ³
//³    ExpCC: Expressao a ser adicionada na Query ou Filtro para ³
//³           SGBD ISAM                                          ³
//³    ExpCD: Determina se devem ser consideradas N.fiscais (1)  ³
//³           REMITOS (2) ou ambos tipos de documento (3)        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVendas := FtNfVendas(1,,dDataIni,dDataFim,,,,,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a funcao de calculo das devolucoes de venda             ³
//³Parametros:                                                   ³
//³ ExpN1: Tipo de Meta :(1-Numerico-Valor liquido - desconto )  ³
//³                      (2-Numerico-Quantidade )                ³
//³                      (3-Numerico-Valor bruto + desconto )    ³
//³                      (4-Array-contendo todos os valores acima³
//³                      (5-Array-contendo todos os valores acima³
//³                       por produto                            ³
//³ ExpC2: cCodigo                                               ³
//³ ExpD3: Data de Inicio                                        ³
//³ ExpD4: Data de Termino                                       ³
//³ ExpC5: Regiao de Vendas.                                     ³
//³ ExpC6: Tipo de Produto                                       ³
//³ ExpC7: Grupo de Produto                                      ³
//³ ExpC8: Codigo do Produto                                     ³
//³ ExpN9: Moeda para conversao                                  ³
//³ ExpCA: Cliente                                               ³
//³ ExpCB: Loja                                                  ³
//³ ExpCC: Determina se devem ser consideradas Notas fiscais (1) ³
//³        REMITOS (2) ou ambos tipos de documento (3)           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDevol   := FtNfDevol(1,,dDataIni,dDataFim,,,,,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula percentuais                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPercMt	  := Round( ((nMetaHj * 100) / nMeta),0)
nPercReal := Round( (((nVendas-nDevol) * 100) / nMeta),0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta mensagens apresentadas ao clicar no percentual                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTpMeta == 1
	cMensagem1 := "'"+STR0004 + "'+chr(13)+chr(10)+" 										 	        // "Calculos por Valor"
	cMensagem1 += "'"+"-----------------------" + "'+chr(13)+chr(10)+" 
	cMensagem1 += "'"+PadR(STR0005,35) + Transform(nMeta,"@E 999,999,999.99") + "'+chr(13)+chr(10)+"   // "Meta do Mes"
	cMensagem1 += "'"+PadR(STR0006,35) + Transform(nMetaHj,"@E 999,999,999.99")+"'"					// "Meta alcancada ate hoje"
	cMensagem2 := "'"+PadR(STR0007,35) + Transform(nVendas-nDevol,"@E 999,999,999.99")+"'" 		    // "Valor realizado ate hoje"
Else
	cMensagem1 := "'"+STR0008 + "'+chr(13)+chr(10)+"										            // "Calculos por Quantidade"
	cMensagem1 += "'"+"------------------------------" + "'+chr(13)+chr(10)+" 	
	cMensagem1 += "'"+PadR(STR0009,35) + Transform(nMeta,"@E 999,999,999.99") + "'+chr(13)+chr(10)+"  // "Meta do Mes"
	cMensagem1 += "'"+PadR(STR0010,35) + Transform(nMetaHj,"@E 999,999,999.99")+"'"					// "Meta alcancada ate hoje"
	cMensagem2 := "'"+PadR(STR0011,35) + Transform(nVendas-nDevol,"@E 999,999,999.99")+"'"			    // "Quantidade realizada ate hoje"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet :=	{ STR0001,0,100,;	// "Meta x Realizado"
			{{AllTrim(Str(nPercMt))+" %" ,STR0002 ,CLR_RED ,"{ || MsgInfo("+cMensagem1+") }",nPercMt},;	// "% Meta ate Hoje"
			{AllTrim(Str(nPercReal))+" %",STR0003 ,CLR_BLUE,"{ || MsgInfo("+cMensagem2+") }",nPercReal}}}	// "% Realizado"

Return aRet
                   