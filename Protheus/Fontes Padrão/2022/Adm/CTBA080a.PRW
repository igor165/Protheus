#INCLUDE "ctba080a.ch"
#INCLUDE "Protheus.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ChkCVA   ³ Autor ³ Edson Maricate        ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia dos registros no CVA                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkCVA()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ChkCVA()
Local nx
Local aCVA 	:= {}
Local lCpoModulo := .F.
Local lCpoCFG	  := .F.
Local lCpoProc   := .F.
Local aArea		  := GetArea()

if ( FwRetIdiom()=="es" )                                            
	aChave    := NIL
	nOrdemSXB := NIL
	nCont     := NIL
endif
// Sexto parâmetro do vetor aCVA (1=Online;2=Offline;3=Ambos)
aAdd(aCVA,{'500',STR0001,'2',"06","200","3"})//"Contas a Receber - Inclusao de Titulos"
aAdd(aCVA,{'501',STR0002,'2',"06","200","3"})//"Contas a Receber - Inclusao de Titulos Recebimento Antecipado (RA)"
aAdd(aCVA,{'502',STR0003,'2',"06","200","1"})//"Contas a Receber - Exclusao de Titulos Recebimento Antecipado"
aAdd(aCVA,{'503',STR0004,'2',"06","200","1"})//"Contas a Receber - Substituicao de Titulos Provisorios"
aAdd(aCVA,{'504',STR0005,'2',"06","200","3"})//"Contas a Receber - Geracao de Titulos por Desdobramento"
aAdd(aCVA,{'505',STR0006,'2',"06","200","1"})//"Contas a Receber - Exclusao de Titulos"
aAdd(aCVA,{'506',STR0007,'2',"06","200","1"})//"Contas a Receber - Inclusão Rateio Centro de Custo Multipla Natureza"
aAdd(aCVA,{'507',STR0008,'2',"06","200","1"})//"Contas a Receber - Cancelamento Rateio Centro de Custo Multipla Natureza"
aAdd(aCVA,{'508',STR0009,'2',"06","300","3"})//"Contas a Pagar - Rateio Centro de Custo Multipla Natureza"
aAdd(aCVA,{'509',STR0010,'2',"06","300","1"})//"Contas a Pagar - Cancelamento Rateio Centro de Custo Multipla Natureza"
aAdd(aCVA,{'51A',STR0206,'2',"06","300","1"})//"Contas a Receber - Provisao para cobrancas duvidosas"
aAdd(aCVA,{'510',STR0011,'2',"06","300","3"})//"Contas a Pagar - Inclusao de Titulos"
aAdd(aCVA,{'511',STR0012,'2',"06","300","3"})//"Contas a Pagar - Inclusao de Titulos com Rateio Simples"
aAdd(aCVA,{'512',STR0013,'2',"06","300","1"})//"Contas a Pagar - Exclusao de Titulos com Rateio Simples"
aAdd(aCVA,{'513',STR0014,'2',"06","300","3"})//"Contas a Pagar - Inclusao de Titulos Pagamento Antecipado (PA)"
aAdd(aCVA,{'514',STR0015,'2',"06","300","1"})//"Contas a Pagar - Exclusao Titulos Pagamento Antecipado (PA)"
aAdd(aCVA,{'515',STR0016,'2',"06","300","1"})//"Contas a Pagar - Exclusao de Titulos"
aAdd(aCVA,{'516',STR0017,'2',"06","350","3"})//"Movimento Bancario - Inclusao Movimento a Pagar com Rateio"
aAdd(aCVA,{'517',STR0018,'2',"06","350","1"})//"Movimento Bancario - Inclusao Movimento a Receber com Rateio"
aAdd(aCVA,{'518',STR0019,'2',"06","300","1"})//"Contas a Pagar - Baixa de Titulos por Vendor"
aAdd(aCVA,{'519',STR0020,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Baixa de Titulos por Vendor"
aAdd(aCVA,{'520',STR0021,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos em Carteira"
aAdd(aCVA,{'521',STR0022,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos Cobranca Simples"
aAdd(aCVA,{'522',STR0023,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos Cobranca Descontada"
aAdd(aCVA,{'523',STR0024,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos Cobranca Caucionada"
aAdd(aCVA,{'524',STR0025,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos Cobranca Vinculada"
aAdd(aCVA,{'525',STR0026,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos Cobranca Advogado"
aAdd(aCVA,{'526',STR0027,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos Cobranca Judicial"
aAdd(aCVA,{'527',STR0028,'2',"06","200","3"})//"Contas a Receber - Cancelamento de Baixas de Titulos"
aAdd(aCVA,{'528',STR0029,'2',"06","200","1"})//"Contas a Receber - Baixas de Titulos Cobranca Caucionada Descontada"
aAdd(aCVA,{'529',STR0030,'2',"06","200","1"})//"Contas a Receber - Exclusao de Titulos gerado via Desdobramento"
aAdd(aCVA,{'530',STR0031,'2',"06","300","3"})//"Contas a Pagar - Baixa de Titulos"
aAdd(aCVA,{'531',STR0032,'2',"06","300","3"})//"Contas a Pagar - Cancelamento de Baixas de Titulos"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'532',STR0033,'2',"06","300","3"})//"Contas a Pagar - Baixas de Titulos por Bordero de Pagamento"
Endif
aAdd(aCVA,{'533',STR0034,'2',"06","300","1"})//"Contas a Pagar - Substituicao de Titulos Provisorios"       
aAdd(aCVA,{'535',STR0322,'2',"06","200","1"})//Cancelamento da Compensação de titulos a Pagar / a Receber
aAdd(aCVA,{'536',STR0323,'2',"06","200","3"})//Baixas de titulos a Receber c/Distrib.em Multiplas Naturezas p/CC
aAdd(aCVA,{'537',STR0324,'2',"06","300","3"})//Baixas de titulos a Pagar c/Distr.em Mult.Naturezas p/CC
aAdd(aCVA,{'538',STR0325,'2',"06","200","3"})//Cancel.Baixas de titulos a Receber c/Distr.em Mult.Naturezas p/CC
aAdd(aCVA,{'539',STR0326,'2',"06","300","3"})//Cancel.Baixas de titulos a Pagar c/Distr.em Mult.Naturezas p/CC
aAdd(aCVA,{'540',STR0035,'2',"06","200","3"})//"Contas a Receber - Transferencia de Titulos para Carteira"
aAdd(aCVA,{'541',STR0036,'2',"06","200","1"})//"Contas a Receber - Transferencia de Titulos para Cobranca Simples"
aAdd(aCVA,{'542',STR0037,'2',"06","200","1"})//"Contas a Receber - Transferencia de Titulos para Cobranca Descontada"
aAdd(aCVA,{'543',STR0038,'2',"06","200","1"})//"Contas a Receber - Transferencia de Titulos para Cobranca Caucionada"
aAdd(aCVA,{'544',STR0039,'2',"06","200","1"})//"Contas a Receber - Transferencia de Titulos Cobranca Vinculada"
aAdd(aCVA,{'545',STR0040,'2',"06","200","1"})//"Contas a Receber - Transferencia de Titulos para Cobranca Advogado"
aAdd(aCVA,{'546',STR0041,'2',"06","200","1"})//"Contas a Receber - Transferencia de Titulos para Cobranca Judicial"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'547',STR0042,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Carteira"
	aAdd(aCVA,{'548',STR0043,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Cobranca Simples"
	aAdd(aCVA,{'549',STR0044,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Cobranca Descontada"
	aAdd(aCVA,{'550',STR0045,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Cobranca Caucionada"
	aAdd(aCVA,{'551',STR0046,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Cobranca Vinculada"
	aAdd(aCVA,{'552',STR0047,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Cobranca Advogado"
	aAdd(aCVA,{'553',STR0048,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Cobranca Judicial"
	aAdd(aCVA,{'554',STR0049,'2',"06","200","1"})//"Contas a Receber - Cancelamento de Bordero Contas a Receber"
Endif
aAdd(aCVA,{'555',STR0050,'2',"06","200","1"})//"Contas a Receber - Transferencia de Titulos para Cobranca Caucionada Descontada"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'556',STR0051,'2',"06","200","1"})//"Contas a Receber - Geração de Bordero Contas a Receber para Cobranca Caucionada Descontada"
Endif
aAdd(aCVA,{'54A',STR0438,'2',"06","200","1"})//"Contas a Receber - Contabilização Constituição PDD"
aAdd(aCVA,{'54B',STR0439,'2',"06","200","1"})//"Contas a Receber - Contabilização Reversão PDD" 
aAdd(aCVA,{'54C',STR0440,'2',"06","200","1"})//"Contas a Receber - Contabilização da Constituição PDD com Rateio por Item da Nota"
aAdd(aCVA,{'54D',STR0441,'2',"06","200","1"})//"Contas a Receber - Contabilização Reversão da Constituição PDD com Rateio por Item da Nota" 
aAdd(aCVA,{'54E',STR0554,'2',"06","200","1"})//"Contas a Receber - Contabilização Constituição PDD - PLS "
aAdd(aCVA,{'54F',STR0555,'2',"06","200","1"})//"Contas a Receber - Contabilização Reversão PDD - PLS "

aAdd(aCVA,{'54G',STR0574,'2',"06","200","3"})//"Contas a Receber - Transferência de carteira para Pix"
aAdd(aCVA,{'54H',STR0575,'2',"06","200","3"})//"Contas a Receber - Traneferência de Pix para carteira"

aAdd(aCVA,{'557',STR0052,'2',"06","350","1"})//"Movimento Bancario - Cancelamento de Movimento a Pagar com Rateio"
aAdd(aCVA,{'558',STR0053,'2',"06","350","1"})//"Movimento Bancario - Cancelamento de Movimento a Receber com Rateio"
aAdd(aCVA,{'559',STR0327,'2',"06","200","3"})//Compensação de Cheques Recebidos
aAdd(aCVA,{'560',STR0054,'2',"06","350","1"})//"Movimento Bancario - Transferencia Saida Banco Origem"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{"56A",STR0256,"2","06","300","3"})//"Movimento Bancário - Lançamento de ITF"
	aAdd(aCVA,{"56B",STR0257,"2","06","300","3"})//"Movimento Bancário - Lançamento de ITF (estorno)"
Endif
aAdd(aCVA,{'561',STR0055,'2',"06","350","1"})//"Movimento Bancario - Transferencia Entra Banco Destino"
aAdd(aCVA,{'562',STR0056,'2',"06","350","3"})//"Movimento Bancario - Inclusao de Movimento a Pagar"
aAdd(aCVA,{'563',STR0057,'2',"06","350","1"})//"Movimento Bancario - Inclusao de Movimento a Receber/Cancelamento  da Ordem de Pago "
aAdd(aCVA,{'564',STR0058,'2',"06","350","1"})//"Movimento Bancario - Cancelamento Movimento a Pagar"
aAdd(aCVA,{'565',STR0059,'2',"06","350","1"})//"Movimento Bancario - Cancelamento Movimento a Receber/Estorno  da Ordem de Pago"
aAdd(aCVA,{'566',STR0060,'2',"06","300","3"})//"Contas a Pagar - Geracao de Cheques sobre Titulos em aberto"
aAdd(aCVA,{'567',STR0061,'2',"06","300","3"})//"Contas a Pagar - Geracao de Cheques Avulsos"
aAdd(aCVA,{'568',STR0062,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Cheque Avulso"
aAdd(aCVA,{'569',STR0063,'2',"06","300","1"})//"Contas a Pagar - Redeposito de Cheque sobre Titulos em aberto"
aAdd(aCVA,{'570',STR0064,'2',"06","300","3"})//"Ordem de Pago - Inclusao de uma Ordem de Pago"
aAdd(aCVA,{'571',STR0065,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Cheques sobre Titulos em aberto / Exclusao da Ordem de Pago"
aAdd(aCVA,{'572',STR0066,'2',"06","370","3"})//"Movimento Caixa Interno - Movimentos do Caixa Interno"
aAdd(aCVA,{'573',STR0067,'2',"06","370","3"})//"Movimento Caixa Interno - Movimentos de Reposicao"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'574',STR0328,'2',"06","300","3"})//Rechazar Cheques - Chile
Endif
aAdd(aCVA,{'575',STR0068,'2',"06","200","3"})//"Recibo Diversos - Inclusao de um Recibo "
aAdd(aCVA,{'576',STR0068,'2',"06","200","1"})//"Recibo Diversos - Inclusao de um Recibo "
aAdd(aCVA,{'577',STR0069,'2',"06","300","3"})//"Contas a Pagar - Geracao de Titulo via desdobramento"
aAdd(aCVA,{'578',STR0070,'2',"06","300","1"})//"Contas a Pagar - Exclusao de Titulo gerado via desdobramento"
aAdd(aCVA,{'579',STR0179,'2',"06","370","3"})//"Mov. do Caixinha - Exclusao de um movimento de Adiantamento / Despesa"
aAdd(aCVA,{'57A',STR0213,'2',"06","380","3"})//"Contas a Receber - Diferenca de Cambio a Receber"
aAdd(aCVA,{'57B',STR0214,'2',"06","380","3"})//"Contas a Receber - Estorno de Diferenca de Cambio a Receber"
aAdd(aCVA,{'57C',STR0215,'2',"06","390","3"})//"Contas a Pagar - Diferenca de Cambio a Pagar"
aAdd(aCVA,{'57D',STR0216,'2',"06","390","3"})//"Contas a Pagar - Estorno de Diferenca de Cambio a Pagar"
aAdd(aCVA,{'57E',STR0409,'2',"06","370","3"})//"Movimento Caixa Interno - Estorno de Reposicao"
aAdd(aCVA,{'580',STR0071,'2',"06","250","3"})//"Aplicacões - Inclusão de Aplicacao Financeira"
aAdd(aCVA,{'581',STR0072,'2',"06","250","3"})//"Aplicacões - Exclusao Aplicacao Financeira"
aAdd(aCVA,{'582',STR0073,'2',"06","250","3"})//"Aplicacões - Apropriacao / Resgate de Emprestimo"
aAdd(aCVA,{'583',STR0329,'2',"06","300","1"})//Estorno de Compensação de Cheques Recebidos	
aAdd(aCVA,{'584',STR0074,'2',"06","250","1"})//"Aplicacões - Estorno Apropriacao Aplicacao Financeira"
aAdd(aCVA,{'585',STR0075,'2',"06","250","3"})//"Aplicacões - Resgate Aplicacao Financeira"
aAdd(aCVA,{'586',STR0076,'2',"06","250","3"})//"Aplicacões - Estorno Emprestimo / Estorno do Resgate"
aAdd(aCVA,{'587',STR0077,'2',"06","300","1"})//"Contas a Pagar - Geração de Faturas a Pagar"
aAdd(aCVA,{'588',STR0078,'2',"06","200","3"})//"Contas a Receber - Cancelamento Compensacao de Titulos"
aAdd(aCVA,{'589',STR0079,'2',"06","300","3"})//"Contas a Pagar - Cancelamento Compensacao de Titulos"
aAdd(aCVA,{'590',STR0080,'2',"06","300","3"})//"Contas a Pagar - Geracao de Cheques sobre Titulos baixados"
aAdd(aCVA,{'591',STR0081,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Cheques sobre Titulos baixados"
aAdd(aCVA,{'592',STR0082,'2',"06","200","1"})//"Contas a Receber - Cancelamento Faturas a Receber"
aAdd(aCVA,{'593',STR0083,'2',"06","300","1"})//"Contas a Pagar - Cancelamento Faturas a Pagar"
aAdd(aCVA,{'594',STR0084,'2',"06","330","1"})//"Contas a Pagar/Receber - Compensacao entre Carteiras"
aAdd(aCVA,{'595',STR0085,'2',"06","200","1"})//"Contas a Receber - Geração de Faturas a Receber"
aAdd(aCVA,{'596',STR0086,'2',"06","200","3"})//"Contas a Receber - Compensacao Contas a Receber"
aAdd(aCVA,{'597',STR0087,'2',"06","300","3"})//"Contas a Pagar - Compensacao Contas a Pagar"
aAdd(aCVA,{'598',STR0088,'2',"06","390","1"})//"Variacao Monetaria - Contas a Receber"
aAdd(aCVA,{'599',STR0089,'2',"06","380","1"})//"Variacao Monetaria - Contas a Pagar"
aAdd(aCVA,{'59A',STR0345,'2',"06","390","1"})//"Estorno da Variacao Monetaria - Contas a Receber"
aAdd(aCVA,{'59B',STR0346,'2',"06","380","1"})//"Estorno da Variacao Monetaria - Contas a Pagar"
aAdd(aCVA,{'5B1',STR0229,'2',"06","200","1"})//"Ajuste a Valor Presente - Contas a Receber"
aAdd(aCVA,{'5B2',STR0230,'2',"06","200","1"})//"Estorno do Ajuste a Valor Presente - Contas a Receber"
aAdd(aCVA,{'5B3',STR0231,'2',"06","300","1"})//"Ajuste a Valor Presente - Contas a Pagar"
aAdd(aCVA,{'5B4',STR0232,'2',"06","300","1"})//"Estorno do Ajuste a Valor Presente - Contas a Pagar"
aAdd(aCVA,{'5B5',STR0233,'2',"06","300","1"})//"Estorno de AVP no Cancelamento da Inclusao - Contas a Receber"
aAdd(aCVA,{'5B6',STR0234,'2',"06","300","1"})//"Estorno de AVP no Cancelamento da Inclusao - Contas a Pagar"
aAdd(aCVA,{'5B7',STR0235,'2',"06","300","1"})//"Estorno de AVP no Cancelamento da Baixa - Contas a Receber"
aAdd(aCVA,{'5B8',STR0236,'2',"06","300","1"})//"Estorno de AVP no Cancelamento da Baixa - Contas a Pagar"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'5C4',STR0414,'2',"06","300","2"})//"Apuração IRPJ/CSLL Lucro Real - Cabeçalho"
	aAdd(aCVA,{'5C5',STR0415,'2',"06","300","2"})//"Apuração IRPJ/CSLL Lucro Real - Item"
	aAdd(aCVA,{'5C6',STR0416,'2',"06","300","2"})//"Estorno Apuração IRPJ/CSLL Lucro Real - Cabeçalho"
	aAdd(aCVA,{'5C7',STR0417,'2',"06","300","2"})//"Estorno Apuração IRPJ/CSLL Lucro Real - Item"
Endif
//Pagar	
aAdd(aCVA,{'5B9',STR0363,'2',"06","300","1"})//"Contas a Pagar - Baixa de Título de Crédito"
aAdd(aCVA,{'5BA',STR0364,'2',"06","300","1"})//"Contas a Pagar - Baixa de Título de Débito"
aAdd(aCVA,{'5BB',STR0365,'2',"06","300","1"})//"Contas a Pagar - Geração de adiantamento (PA)"
aAdd(aCVA,{'5BC',STR0366,'2',"06","300","1"})//"Contas a Pagar - Documento Próprio Mediato"	
aAdd(aCVA,{'5BD',STR0367,'2',"06","300","1"})//"Contas a Pagar - Valores e transferências Imediato"	
aAdd(aCVA,{'5BE',STR0368,'2',"06","300","1"})//"Contas a Pagar - Documentos de Terceiro"		
aAdd(aCVA,{'5BF',STR0369,'2',"06","300","1"})//"Contas a Pagar - Documentos de Retenção"	
aAdd(aCVA,{'5BG',STR0370,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Baixa de Título de Crédito" 
aAdd(aCVA,{'5BH',STR0371,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Baixa de Título de Débito" 	
aAdd(aCVA,{'5BI',STR0372,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Geração de Adiantamento (PA)"
aAdd(aCVA,{'5BJ',STR0373,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Documentos Próprios Mediato"	
aAdd(aCVA,{'5BK',STR0374,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Valores e transferências Imediato"
aAdd(aCVA,{'5BL',STR0375,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Documentos de Terceiro"
aAdd(aCVA,{'5BM',STR0376,'2',"06","300","1"})//"Contas a Pagar - Cancelamento de Documentos de Retenção"

//Receber	
aAdd(aCVA,{'5BN',STR0377,'2',"06","200","1"})//"Contas a Receber - Baixa de Título Rec Crédito"
aAdd(aCVA,{'5BO',STR0378,'2',"06","200","1"})//"Contas a Receber - Baixa de Título Rec Débito"	
aAdd(aCVA,{'5BP',STR0379,'2',"06","200","1"})//"Contas a Receber - Recibo Antecipado Gerado (RA)"
aAdd(aCVA,{'5BQ',STR0380,'2',"06","200","1"})//"Contas a Receber - Cheque"
aAdd(aCVA,{'5BR',STR0381,'2',"06","200","1"})//"Contas a Receber - Nota Promissória"
aAdd(aCVA,{'5BS',STR0382,'2',"06","200","1"})//"Contas a Receber - Efetivo"
aAdd(aCVA,{'5BT',STR0383,'2',"06","200","1"})//"Contas a Receber - Transferências"		
aAdd(aCVA,{'5BU',STR0384,'2',"06","200","1"})//"Contas a Receber - Retenção"			
aAdd(aCVA,{'5BV',STR0385,'2',"06","200","1"})//"Contas a Receber - Cancel. de Baixa de Título Crédito"			
aAdd(aCVA,{'5BX',STR0386,'2',"06","200","1"})//"Contas a Receber - Cancel. de Baixa de Título Débito"		
aAdd(aCVA,{'5BW',STR0387,'2',"06","200","1"})//"Contas a Receber - Cancelamento de Recibo Antecipado Gerado (RA)"
aAdd(aCVA,{'5BY',STR0388,'2',"06","200","1"})//"Contas a Receber - Cancelamento de Cheque"
aAdd(aCVA,{'5BZ',STR0389,'2',"06","200","1"})//"Contas a Receber - Cancelamento de Nota Promissória"
aAdd(aCVA,{'5C1',STR0390,'2',"06","200","1"})//"Contas a Receber - Cancelamento de Transferência"
aAdd(aCVA,{'5C2',STR0391,'2',"06","200","1"})//"Contas a Receber - Cancelamento de Efetivo"	
aAdd(aCVA,{'5C3',STR0392,'2',"06","200","1"})//"Contas a Receber - Cancelamento de Retenção"

aAdd(aCVA,{'5C8',STR0571,'2',"06","350","2"}) //"Movimento Bancário - Movimento de Troco"
aAdd(aCVA,{'5C9',STR0572,'2',"06","350","2"}) //"Movimento Bancário - Estorno de Movimento de Troco"

//Financeiro
//Viagens  
aAdd(aCVA,{'8B3',STR0429,'2',"02","200","3"})//"Viagens - Prestação de Contas"
aAdd(aCVA,{'8B4',STR0430,'2',"02","200","1"})//"Viagens - Estorno da Prestação de Contas"
aAdd(aCVA,{'8B5',STR0442,'2',"02","200","3"})//"Viagens - Cabeçalho Prestação de Contas"
aAdd(aCVA,{'8B6',STR0443,'2',"02","200","1"})//"Viagens - Estorno do Cabeçalho da Prestação de Contas"
//Compras	
//Cabeçalho
aAdd(aCVA,{'683',STR0393,'2',"02","410","1"})//"Compras - Inclusão de Notas Fiscais MAN/AUT."
aAdd(aCVA,{'684',STR0394,'2',"02","410","1"})//"Compras - Inclusão de Nota de Crédito"
aAdd(aCVA,{'685',STR0395,'2',"02","410","1"})//"Compras - Inclusão de Nota de Débito"	
aAdd(aCVA,{'686',STR0396,'2',"02","410","1"})//"Compras - Inclusão de Remito de Entrada"
aAdd(aCVA,{'687',STR0397,'2',"02","410","1"})//"Compras - Exclusão de Notas Fiscais MAN/AUT."
aAdd(aCVA,{'688',STR0398,'2',"02","410","1"})//"Compras - Exclusão de Nota de Crédito"	
aAdd(aCVA,{'689',STR0399,'2',"02","410","1"})//"Compras - Exclusão de Nota de Débito"
aAdd(aCVA,{'690',STR0400,'2',"02","410","1"})//"Compras - Exclusão de Remito de Entrada"

//Faturamento	
//Cabeçalho
aAdd(aCVA,{'68A',STR0401,'2',"05","440","1"})//"Faturamento - Inclusão de Notas Fiscais MAN/AUT."
aAdd(aCVA,{'68B',STR0402,'2',"05","440","1"})//"Faturamento - Inclusão de Nota de Crédito"	
aAdd(aCVA,{'68C',STR0403,'2',"05","440","1"})//"Faturamento - Inclusão de Nota de Débito"	
aAdd(aCVA,{'68D',STR0404,'2',"05","440","1"})//"Faturamento - Inclusão de Remito de Saida"
aAdd(aCVA,{'68E',STR0405,'2',"05","440","1"})//"Faturamento - Exclusão de Nota Man/Aut."	
aAdd(aCVA,{'68F',STR0406,'2',"05","440","1"})//"Faturamento - Exclusão de Nota de Crédito"
aAdd(aCVA,{'68G',STR0407,'2',"05","440","1"})//"Faturamento - Exclusão de Nota de Débito"
aAdd(aCVA,{'68H',STR0408,'2',"05","440","1"})//"Faturamento - Exclusão de Remito de Saida"
//Itens
aAdd(aCVA,{'68I',STR0401,'2',"05","440","1"})//"Faturamento - Inclusão de Notas Fiscais MAN/AUT."
aAdd(aCVA,{'68J',STR0402,'2',"05","440","1"})//"Faturamento - Inclusão de Nota de Crédito"	
aAdd(aCVA,{'68K',STR0403,'2',"05","440","1"})//"Faturamento - Inclusão de Nota de Débito"	
aAdd(aCVA,{'68L',STR0404,'2',"05","440","1"})//"Faturamento - Inclusão de Remito de Saida"
aAdd(aCVA,{'68M',STR0405,'2',"05","440","1"})//"Faturamento - Exclusão de Nota Man/Aut."	
aAdd(aCVA,{'68N',STR0406,'2',"05","440","1"})//"Faturamento - Exclusão de Nota de Crédito"
aAdd(aCVA,{'68O',STR0407,'2',"05","440","1"})//"Faturamento - Exclusão de Nota de Débito"
aAdd(aCVA,{'68P',STR0408,'2',"05","440","1"})//"Faturamento - Exclusão de Remito de Saida"

//	
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'605',STR0090,'2',"09","700","1"})//"Apuracao de PIS - Inclusão"
	aAdd(aCVA,{'606',STR0091,'2',"09","700","1"})//"Apuracao de COFINS - Inclusão"
	aAdd(aCVA,{'607',STR0535,'2',"09","700","1"})//"NF Manual Entr./Saída"
	aAdd(aCVA,{'608',STR0093,'2',"09","700","1"})//"Apuracao de COFINS - Estorno"
	aAdd(aCVA,{'609',STR0426,'2',"09","700","1"})//"Outros Documentos - F100 - EFD Contribuições - Inclusão"
	aAdd(aCVA,{'611',STR0092,'2',"09","700","1"})//"Apuracao de PIS - Estorno"
	aAdd(aCVA,{'6A7',STR0422,'2',"09","700","1"})//"Documento de Entrada Manual - Inclusão de Documento Itens"
	aAdd(aCVA,{'6B7',STR0423,'2',"09","700","1"})//"Documento de Saída Manual - Inclusão de Documento Itens"
	aAdd(aCVA,{'6A8',STR0539,'2',"09","700","1"})//"Documento de Entrada Manual - Exclusão de Documento Itens"
	aAdd(aCVA,{'6B8',STR0540,'2',"09","700","1"})//"Documento de Saída Manual - Exclusão de Documento Itens"
	
	
Endif
aAdd(aCVA,{'6AA',STR0512,'2',"09","700","3"})//"VAT Sales Invoice - Header"
aAdd(aCVA,{'6AB',STR0513,'2',"09","700","3"})//"VAT Sales Invoice - Items"
aAdd(aCVA,{'6AC',STR0514,'2',"09","700","3"})//"Deletion of VAT Sales Invoice - Header"
aAdd(aCVA,{'6AD',STR0515,'2',"09","700","3"})//"Deletion of VAT Sales Invoice - Header"
If cPaisLoc == "RUS"
	aAdd(aCVA,{'6AE',STR0563,'2',"09","700","1"})//"Tax Record - Purchase Book - Post"
	aAdd(aCVA,{'6AF',STR0564,'2',"09","700","1"})//"Tax Record - Purchase Book - Storno"
	aAdd(aCVA,{'6AG',STR0565  ,'2',"09","700","1"})//Tax Record – VAT Write-off - Post
	aAdd(aCVA,{'6AH',STR0566,'2',"09","700","1"})//Tax Record – VAT Write-off - Storno
	aAdd(aCVA,{'6AI',STR0567,'2',"09","700","1"})//Tax Record – VAT Restoration - Post/Edit
	aAdd(aCVA,{'6AJ',STR0568,'2',"09","700","1"})//Tax Record – VAT Restoration - Storno
EndIf
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'6A9',STR0427,'2',"09","700","1"})//"Outros Documentos - F100 - EFD Contribuições - Estorno"
Endif
aAdd(aCVA,{'610',STR0094,'2',"05","440","3"})//"Documento de Saida - Inclusão de Documento Itens"
aAdd(aCVA,{'613',STR0444,'2',"05","440","3"})//"Documento de Saida - Inclusão de Documento Rateio Itens"
aAdd(aCVA,{'620',STR0095,'2',"05","440","3"})//"Documento de Saida - Inclusão de Documento Total"
aAdd(aCVA,{'630',STR0096,'2',"05","440","1"})//"Documento de Saida - Exclusão de Documento Itens"
aAdd(aCVA,{'633',STR0445,'2',"05","440","1"})//"Documento de Saida - Exclusão de Documento Rateio Itens"
aAdd(aCVA,{'635',STR0097,'2',"05","440","1"})//"Documento de Saida - Exclusão de Documento Total"
aAdd(aCVA,{'640',STR0098,'2',"02","410","3"})//"Documento de Entrada - Inclusão de Documento Devolução/Beneficiamento Itens"
aAdd(aCVA,{'641',STR0099,'2',"02","410","3"})//"Documento de Entrada - Inclusão de Documento Devolução/Beneficiamento Itens Rateio"
aAdd(aCVA,{'642',STR0100,'2',"02","410","3"})//"Documento de Entrada - Inclusão de Documento Devolução/Beneficiamento Total"
aAdd(aCVA,{'650',STR0101,'2',"02","410","3"})//"Documento de Entrada - Inclusão de Documento Entrada Itens"
aAdd(aCVA,{'651',STR0102,'2',"02","410","3"})//"Documento de Entrada - Inclusão de Documento Entrada Itens Rateio"
aAdd(aCVA,{'652',STR0103,'2',"02","400","3"})//"Pedido de Compras - Inclusão de Pedidos Itens"
aAdd(aCVA,{'655',STR0104,'2',"02","410","1"})//"Documento de Entrada - Exclusão de Documento Entrada Itens"
aAdd(aCVA,{'656',STR0105,'2',"02","410","1"})//"Documento de Entrada - Exclusão de Documento Entrada Itens Rateio"
aAdd(aCVA,{'657',STR0106,'2',"02","400","1"})//"Pedido de Compras - Exclusão de Pedidos Itens"
aAdd(aCVA,{'658',STR0208,'2',"02","400","1"})//"Pedido de Compras - Eliminação de Resíduos - Itens"
aAdd(aCVA,{'659',STR0244,'2',"02","400","3"})//"Pedido de Compras - Rateio do Pedido de Compra"
aAdd(aCVA,{'65A',STR0245,'2',"02","400","1"})//"Pedido de Compras - Exclusao/Estorno do Rateio do Pedido de Compra"
aAdd(aCVA,{'65B',STR0246,'2',"02","400","1"})//"Pedido de Compras - Pedido de Compra por Edital"
aAdd(aCVA,{'660',STR0107,'2',"02","410","3"})//"Documento de Entrada - Inclusão de Documento Entrada Total"
aAdd(aCVA,{'661',STR0108,'2',"02","410","1"})//"Documento de Entrada - Inclusão de Titulos a Pagar"
aAdd(aCVA,{'665',STR0109,'2',"02","410","1"})//"Documento de Entrada - Exclusão de Documento Entrada Total "
aAdd(aCVA,{'666',STR0110,'2',"04","110","3"})//"Movimento de Estoques - Saida de Produtos"
aAdd(aCVA,{'667',STR0111,'2',"04","110","1"})//"Movimento de Estoques - Saida de Produtos ( Antes de Atualizar o Custo )"
aAdd(aCVA,{'668',STR0112,'2',"04","100","3"})//"Movimento de Estoques - Entrada de Produtos"
aAdd(aCVA,{'669',STR0113,'2',"04","100","1"})//"Movimento de Estoques - Entrada de Produtos ( Antes de Atualizar o Custo)"
aAdd(aCVA,{'67A',STR0569,'2',"04","110","3"})//"Movimento de Estoques - Rateio da Solicitacao ao Armazem"
aAdd(aCVA,{'67B',STR0570,'2',"04","100","3"})//"Movimento de Estoques - Rateio da Solicitacao ao Armazem - Estorno"
aAdd(aCVA,{'670',STR0114,'2',"04","120","3"})//"Movimento de Estoques - Transferencia Origem"
aAdd(aCVA,{'672',STR0115,'2',"04","120","3"})//"Movimento de Estoques - Transferencia Destino"
aAdd(aCVA,{'674',STR0116,'2',"04","110","1"})//"Movimento de Estoques - Inventário Saida"
aAdd(aCVA,{'676',STR0117,'2',"04","100","1"})//"Movimento de Estoques - Inventário Entrada"
aAdd(aCVA,{'678',STR0118,'2',"04","130","3"})//"Documento de Saida - Custo de Mercadoria Vendida"
aAdd(aCVA,{'679',STR0119,'2',"04","100","3"})//"Movimento de Estoques - Entrada de Produtos ( Apropriação Indireta )"
aAdd(aCVA,{'680',STR0120,'2',"04","110","3"})//"Movimento de Estoques - Saida de Produtos ( Apropriação Indireta )"
aAdd(aCVA,{'681',STR0121,'2',"02","410","3"})//"Documento de Entrada - Compra / Remessa de Terceiros Itens"
aAdd(aCVA,{'682',STR0122,'2',"02","410","3"})//"Documento de Entrada - Retorno de Poder Terceiros Itens"

aAdd(aCVA,{'690',STR0182,'2',"69","500","1"})//"Caucionamento - Inclusão de cauções"
aAdd(aCVA,{'691',STR0183,'2',"69","500","1"})//"Caucionamento - Exclusão de de cauções"
aAdd(aCVA,{'692',STR0184,'2',"69","500","1"})//"Caucionamento - Baixa de cauções"
aAdd(aCVA,{'693',STR0203,'2',"69","520","1"})//"Gestão de Contratos - Cronograma Contábil - Apropriação das Parcelas"
aAdd(aCVA,{'694',STR0204,'2',"69","510","1"})//"Gestão de Contratos - Inclusão do Contrato"                          
aAdd(aCVA,{'69G',STR0349,'2',"69","500","1"})//"Gestão de Contratos - Aprovação da Revisão do Contrato"
aAdd(aCVA,{'69H',STR0523,'2',"69","510","1"})//"Gestão de Contratos - Encerramento da medição por item norma IFRS 15 (bens e serviços) – 69H"	
aAdd(aCVA,{'69I',STR0524,'2',"69","510","1"})//"Gestão de Contratos - Estorno da medição por item norma IFRS 15 (bens e serviços) – 69I		
aAdd(aCVA,{'695',STR0205,'2',"69","510","1"})//"Gestão de Contratos - Retenção do Contrato"
aAdd(aCVA,{'696',STR0207,'2',"69","510","1"})//"Gestão de Contratos - Exclusão do Contrato"
aAdd(aCVA,{'697',STR0247,'2',"69","510","1"})//"Gestão de Contratos - Encerramento da Medição"
aAdd(aCVA,{'698',STR0248,'2',"69","510","1"})//"Gestão de Contratos - Encerramento da Medição/Automatico"
aAdd(aCVA,{'699',STR0249,'2',"69","510","1"})//"Gestão de Contratos - Estorno da Medição"
aAdd(aCVA,{'69A',STR0250,'2',"69","510","1"})//"Gestão de Contratos - Encerramento da Medicao: Itens do Contrato"
aAdd(aCVA,{'69B',STR0251,'2',"69","510","1"})//"Gestão de Contratos - Estorno da Medicao: Itens do Contrato"
aAdd(aCVA,{'69C',STR0252,'2',"69","510","1"})//"Gestão de Contratos - Rateio Itens Contrato s/ Planilha no Encerramento da Medicao"
aAdd(aCVA,{'69D',STR0253,'2',"69","510","1"})//"Gestão de Contratos - Rateio Itens Contrato s/ Planilha no Estorno da Medicao"
aAdd(aCVA,{'69E',STR0254,'2',"69","510","1"})//"Gestão de Contratos - Rateio Itens Contrato c/ Planilha no Encerramento da Medicao"	
aAdd(aCVA,{'69F',STR0255,'2',"69","510","1"})//"Gestão de Contratos - Rateio Itens Contrato c/ Planilha no Estorno da Medicao"
aAdd(aCVA,{'69J',STR0501,'2',"69","520","1"})//"Cronograma Contábil - Estorno de Apropriação das Parcelas"	
aAdd(aCVA,{'69K',STR0538,'2',"69","520","1"})// Desfazer Revisão
aAdd(aCVA,{'69L',STR0548,'2',"69","510","1"})//"Gestão de Contratos - Inclusão de Contrato Vigente (Por Item de Planilha)"
aAdd(aCVA,{'69M',STR0549,'2',"69","510","1"})//"Gestão de Contratos - Estorno de Contrato Vigente (Por Item de Planilha)"
aAdd(aCVA,{'69N',STR0550,'2',"69","510","1"})//"Gestão de Contratos - Aprovação de Revisão (Por Item de Planilha)"
aAdd(aCVA,{'69O',STR0551,'2',"69","510","1"})//"Gestão de Contratos - Desfazer Revisão (Por Item de Planilha)"
aAdd(aCVA,{'69P',STR0578,'2',"69","520","1"})//"Gestão de Contratos - Cronograma Contábil - Rateio das Planilhas"
aAdd(aCVA,{'69Q',STR0579,'2',"69","520","1"})//"Gestão de Contratos - Cronograma Contábil - Estorno Rateio das Planilhas"
aAdd(aCVA,{'69R',STR0580,'2',"69","520","1"})//"Gestão de Contratos - Cronograma Contábil - Múltiplas Naturezas"
aAdd(aCVA,{'69S',STR0581,'2',"69","520","1"})//"Gestão de Contratos - Cronograma Contábil - Estorno Múltiplas Naturezas"

If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'710',STR0123,'2',"09","700","1"})//"Apuracao de ICMS - Inclusão"
	aAdd(aCVA,{'711',STR0124,'2',"09","700","1"})//"Apuracao de ICMS - Estorno"
	aAdd(aCVA,{'712',STR0241,'2',"09","700","1"})//"Apuracao de ICMS - Saldo Credor - Inclusão"
	aAdd(aCVA,{'713',STR0242,'2',"09","700","1"})//"Apuracao de ICMS - Saldo Credor - Estorno"
	aAdd(aCVA,{'720',STR0125,'2',"09","700","1"})//"Apuracao de IPI - Inclusão"
	aAdd(aCVA,{'721',STR0126,'2',"09","700","1"})//"Apuracao de IPI - Estorno "
	aAdd(aCVA,{'750',STR0127,'2',"09","700","1"})//"Apuracao de ISS - Inclusão"
	aAdd(aCVA,{'751',STR0128,'2',"09","700","1"})//"Apuracao de ISS - Estorno"
	aAdd(aCVA,{'752',STR0431,'2',"09","700","3"})//"SPED PIS/COFINS - Inclusão"
	aAdd(aCVA,{'753',STR0432,'2',"09","700","1"})//"SPED PIS/COFINS - Exclusão"
	aAdd(aCVA,{'755',STR0258,'2',"09","700","1"})//"Apropriação CIAP"
	aAdd(aCVA,{'756',STR0259,'2',"09","700","1"})//"Estorno CIAP"
	aAdd(aCVA,{'757',STR0525,'2',"09","700","1"})//"Diferimento de PIS mesmo período - Inclusão"
	aAdd(aCVA,{'758',STR0526,'2',"09","700","1"})//"Diferimento de COFINS mesmo período - Inclusão"
	aAdd(aCVA,{'759',STR0527,'2',"09","700","1"})//"Diferimento de PIS período anterior - Inclusão"
	aAdd(aCVA,{'760',STR0528,'2',"09","700","1"})//"Diferimento de COFINS mesmo período anterior - Inclusão"
	aAdd(aCVA,{'761',STR0529,'2',"09","700","1"})//"Diferimento de PIS mesmo período - Estorno"
	aAdd(aCVA,{'762',STR0530,'2',"09","700","1"})//"Diferimento de COFINS mesmo período - Estorno"
	aAdd(aCVA,{'763',STR0531,'2',"09","700","1"})//"Diferimento de PIS período anterior - Estorno"
	aAdd(aCVA,{'764',STR0532,'2',"09","700","1"})//"Diferimento de COFINS mesmo período anterior - Estorno"
	aAdd(aCVA,{'765',STR0533,'2',"09","700","1"})//"CPRB - Inclusão"
	aAdd(aCVA,{'766',STR0534,'2',"09","700","1"})//"CPRB - Estorno"
	aAdd(aCVA,{'767',STR0552,'2',"09","700","1"})//"Apuração Tributos Genéricos - Inclusão"
	aAdd(aCVA,{'768',STR0553,'2',"09","700","1"})//"Apuração Tributos Genéricos - Estorno"	
	aAdd(aCVA,{'770',STR0556,'2',"09","700","1"})//"FISCAL - Inclusão manual do Bem no CIAP"	
	aAdd(aCVA,{'771',STR0557,'2',"09","700","1"})//"FISCAL - Exclusão manual do Bem no CIAP"
	
Endif
aAdd(aCVA,{'801',STR0129,'2',"01","010","1"})//"Ativo Fixo - Aquisicao de Bem"
aAdd(aCVA,{'802',STR0130,'2',"01","010","1"})//"Ativo Fixo - Aquisicao - Reavaliacao"
aAdd(aCVA,{'803',STR0131,'2',"01","010","1"})//"Ativo Fixo - Aquisicao - Adiantamento"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'804',STR0132,'2',"01","010","1"})//"Ativo Fixo - Aquisicao - Lei 8.200"
Endif
aAdd(aCVA,{'805',STR0133,'2',"01","010","1"})//"Ativo Fixo - Exclusao Aquisicao do Bem"
aAdd(aCVA,{'806',STR0134,'2',"01","010","1"})//"Ativo Fixo - Exclusao - Reavaliacao"
aAdd(aCVA,{'807',STR0135,'2',"01","010","1"})//"Ativo Fixo - Exclusao - Adiantamento"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'808',STR0136,'2',"01","010","1"})//"Ativo Fixo - Exclusao - Lei 8.200"
Endif
aAdd(aCVA,{'810',STR0137,'2',"01","030","3"})//"Ativo Fixo - Baixa Aquisicao"
aAdd(aCVA,{'811',STR0138,'2',"01","030","3"})//"Ativo Fixo - Baixa Reavaliacao"
aAdd(aCVA,{'812',STR0139,'2',"01","030","3"})//"Ativo Fixo - Baixa - Adiantamentos"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'813',STR0140,'2',"01","030","3"})//"Ativo Fixo - Baixa Lei 8.200"
Endif
aAdd(aCVA,{'814',STR0141,'2',"01","030","3"})//"Ativo Fixo - Cancelamento Baixa Aquisicao"
aAdd(aCVA,{'815',STR0142,'2',"01","030","3"})//"Ativo Fixo - Cancelamento Baixa Reavaliacao"
aAdd(aCVA,{'816',STR0143,'2',"01","030","3"})//"Ativo Fixo - Cancelamento Baixa Adiantamento"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'817',STR0144,'2',"01","030","3"})//"Ativo Fixo - Cancelamento Baixa Lei 8.200"
Endif
aAdd(aCVA,{'820',STR0145,'2',"01","040","3"})//"Ativo Fixo - Calculo da Depreciacao"
aAdd(aCVA,{'821',STR0146,'2',"01","020","1"})//"Ativo Fixo - Ampliacao"
aAdd(aCVA,{'822',STR0147,'2',"01","020","1"})//"Ativo Fixo - Cancelamento de Ampliacao"
aAdd(aCVA,{'823',STR0274,'2',"01","040","3"})//"Cadastrar STR: Calculo de depreciacao: Rateio de despesas
aAdd(aCVA,{'825',STR0148,'2',"01","040","1"})//"Ativo Fixo - Descalculo"
aAdd(aCVA,{'827',STR0149,'2',"01","050","3"})//"Ativo Fixo - Ajuste Inventario"
aAdd(aCVA,{'828',STR0275,'2',"01","040","3"})//"Cadastrar STR: Estorno do calculo da depreciacao: Rateio de Despesas	
aAdd(aCVA,{'840',STR0573,'2',"01","170","3"})//"Ativo Fixo - Depreciação Acelerada"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'850',STR0150,'2',"01","090","1"})//"Ajuste por inflação - Calculo do Ajuste (Argentina)"
	aAdd(aCVA,{'851',STR0151,'2',"01","090","1"})//"Ajuste por inflação - Cancelamento do calculo do Ajuste (Argentina)"
Endif
aAdd(aCVA,{'860',STR0332,'2',"01","450","3"})//"Ativo Fixo - Ajuste a Valor Presente - Constituição"
aAdd(aCVA,{'861',STR0333,'2',"01","450","3"})//"Ativo Fixo - Ajuste a Valor Presente - Apropriação"
aAdd(aCVA,{'862',STR0334,'2',"01","450","3"})//"Ativo Fixo - Ajuste a Valor Presente - Baixa de apropriação"
aAdd(aCVA,{'863',STR0335,'2',"01","450","3"})//"Ativo Fixo - Ajuste a Valor Presente - Baixa"
aAdd(aCVA,{'864',STR0336,'2',"01","450","3"})//"Ativo Fixo - Ajuste a Valor Presente - Realização"
aAdd(aCVA,{'865',STR0337,'2',"01","450","3"})//"Ativo Fixo - Ajuste a Valor Presente - Baixa de realização"
aAdd(aCVA,{'866',STR0338,'2',"01","440","3"})//"Ativo Fixo - Ajuste a Valor Presente - Baixa por revisão"
aAdd(aCVA,{'867',STR0339,'2',"01","450","1"})//"Ativo Fixo - Ajuste a Valor Presente - Cancelamento de constituição"
aAdd(aCVA,{'868',STR0340,'2',"01","450","3"})//"Ativo Fixo - Ajuste a Valor Presente - Cancelamento de AVP - Baixa"
aAdd(aCVA,{'870',STR0264,'2',"01","110","1"})//"Ativo Fixo - Apontamento de estimativa de produção"
aAdd(aCVA,{'871',STR0265,'2',"01","110","1"})//"Ativo Fixo - Apontamento de revisão da estimativa de produção"
aAdd(aCVA,{'872',STR0266,'2',"01","110","3"})//"Ativo Fixo - Apontamento de produção"
aAdd(aCVA,{'873',STR0267,'2',"01","110","3"})//"Ativo Fixo - Apontamento de encerramento de produção"
aAdd(aCVA,{'874',STR0268,'2',"01","110","3"})//"Ativo Fixo - Apontamento de complemento de produção"
aAdd(aCVA,{'875',STR0269,'2',"01","110","1"})//"Ativo Fixo - Estorno de apontamento de estimativa de produção"
aAdd(aCVA,{'876',STR0270,'2',"01","110","1"})//"Ativo Fixo - Estorno de apontamento de revisão de estimativa de produção"
aAdd(aCVA,{'877',STR0271,'2',"01","110","1"})//"Ativo Fixo - Estorno de apontamento de produção"
aAdd(aCVA,{'878',STR0272,'2',"01","110","1"})//"Ativo Fixo - Estorno de apontamento de encerramento de produção"
aAdd(aCVA,{'879',STR0273,'2',"01","110","1"})//"Ativo Fixo - Estorno de apontamento de complemento de produção"
aAdd(aCVA,{'87A',STR0278,'2',"01","110","3"})//"Ativo Fixo - Apontamento de produção com rateio"
aAdd(aCVA,{'87B',STR0279,'2',"01","110","3"})//"Ativo Fixo - Estorno de apontamento de produção com rateio"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'845',STR0152,'2',"01","010","1"})//"Ativo Fixo - Aquisicao - Lei 8.200 (Tipo do Ativo - 0"
	aAdd(aCVA,{'846',STR0153,'2',"01","010","1"})//"Ativo Fixo - Exclusao - Lei 8.200 (Tipo do Ativo - 06"
	aAdd(aCVA,{'847',STR0154,'2',"01","030","1"})//"Ativo Fixo - Baixa Lei 8.200 (Tipo do Ativo -  06)"
Endif
aAdd(aCVA,{'848',STR0155,'2',"01","030","1"})//"Ativo Fixo - Cancelamento da Baixa (Tipo do Ativo - 0"
aAdd(aCVA,{'80A',STR0209,'2',"01","010","1"})//"Ativo Fixo - Inclusão de outros tipos de Ativo"
aAdd(aCVA,{'80B',STR0210,'2',"01","010","1"})//"Ativo Fixo - Exclusão de outros tipos de Ativo"
aAdd(aCVA,{'80C',STR0260,'2',"01","010","1"})//"Ativo Fixo - Aquisição de Bem por conversão"
aAdd(aCVA,{'80D',STR0261,'2',"01","010","1"})//"Ativo Fixo - Exclusão Aquisição do Bem por conversão"
aAdd(aCVA,{'80E',STR0519,'2',"01","060","1"})//"Fixed Asset - Revaluation"
aAdd(aCVA,{'80F',STR0520,'2',"01","060","1"})//"Fixed Asset - Storno of Revaluation"

If cPaisLoc == "RUS"
	aAdd(aCVA,{'80G',STR0521	,'2',"01","040","1"}) //"Modernization"
	aAdd(aCVA,{'80H',STR0522	,'2',"01","040","1"}) //"Storno of Modernization"
EndIf
aAdd(aCVA,{'81A',STR0211,'2',"01","030","3"})//"Ativo Fixo - Baixa de outros tipos de Ativo"
aAdd(aCVA,{'81B',STR0212,'2',"01","030","3"})//"Ativo Fixo - Cancelamento da baixa de outros tipos de Ativo"
aAdd(aCVA,{'81C',STR0262,'2',"01","030","3"})//"Ativo Fixo - Baixa por conversão"
aAdd(aCVA,{'81D',STR0263,'2',"01","030","3"})//"Ativo Fixo - Cancelamento Baixa Aquisição por conversão"
aAdd(aCVA,{'81E',STR0276,'2',"01","030","3"})//Baixa de ativo: Rateio de despesas
aAdd(aCVA,{'81F',STR0277,'2',"01","030","1"})//Cancelamento da baixa de ativo: Rateio de despesas
aAdd(aCVA,{'830',STR0217,'2',"01","070","1"})//"Ativo Fixo - Transferencia contabil"
aAdd(aCVA,{'833',STR0419,'2',"01","070","1"})//"Ativo Fixo - Transferencia contabil - Movimento"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'83A',STR0418,'2',"01","070","1"})//"Ativo Fixo - Cancelamento de Transferência Contábil Orig."
Endif
aAdd(aCVA,{'83B',STR0433,'2',"01","070","1"})//"Ativo Fixo - Cancelamento de Transferência Contábil Dest."
aAdd(aCVA,{'831',STR0218,'2',"01","070","1"})//"Ativo Fixo - Transferencia contabil entre filiais (origem)"
aAdd(aCVA,{'832',STR0219,'2',"01","070","1"})//"Ativo Fixo - Transferencia contabil entre filiais (destino)"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'835',STR0220,'2',"01","080","3"})//"Ativo Fixo - Aquisicao por transferencia"
	aAdd(aCVA,{'836',STR0221,'2',"01","080","1"})//"Ativo Fixo - Cancelamento da Aquisicao por transferencia"
Endif
aAdd(aCVA,{'890',STR0280,'2',"01","010","1"})//"Ativo Fixo - Simulação Depreciação - Bens Reais"

aAdd(aCVA,{'892',STR0281,'2',"01","010","1"})//"Ativo Fixo - Estorno Simulação Depreciação - Bens Reais"
aAdd(aCVA,{'891',STR0282,'2',"01","010","1"})//"Ativo Fixo - Simulação Depreciação - Bens Modificadores"
aAdd(aCVA,{'893',STR0283,'2',"01","010","1"})//"Ativo Fixo - Estorno Simulação Depreciação - Bens Modificadores"
aAdd(aCVA,{'880',STR0354,'2',"01","030","1"})//"Ativo Fixo - Baixa de provisão"
aAdd(aCVA,{'881',STR0355,'2',"01","490","1"})//"Ativo Fixo - Movimentos de provisão"
aAdd(aCVA,{'882',STR0356,'2',"01","490","1"})//"Ativo Fixo - Estormo de movimentos de provisão"
aAdd(aCVA,{'883',STR0357,'2',"01","490","1"})//"Ativo Fixo - Revisão de movimentos de provisão"	
aAdd(aCVA,{'884',STR0358,'2',"01","490","1"})//"Ativo Fixo - Estorno de efetivação de realização"		
Aadd(aCVA,{'8A0',STR0412,'2',"01","070","1"})//"Ativo Fixo - Cancelamento de transferência de filial (destino)"
Aadd(aCVA,{'8A1',STR0413,'2',"01","070","1"})//"Ativo Fixo - Cancelamento de transferência de filial (origem)"
aAdd(aCVA,{'8B1',STR0420,'2',"01","490","1"})//		
aAdd(aCVA,{'8B2',STR0421,'2',"01","490","1"})//
aAdd(aCVA,{'8A2',STR0510,'2',"01","010","1"})//"Fixed Asset - Putting Into Operation"		
aAdd(aCVA,{'8A3',STR0511,'2',"01","010","1"})//"Fixed Asset - Reversal Putting Into Operation"
aAdd(aCVA,{'8A6',STR0516,'2',"01","060","1"})//"Fixed Asset - Conservation"		
aAdd(aCVA,{'8A7',STR0517,'2',"01","060","1"})//"Fixed Asset - Desconservation"
aAdd(aCVA,{'8A8',STR0536,'2',"01","060","1"})//"Fixed Asset - Storno of Conservation"
aAdd(aCVA,{'8A9',STR0537,'2',"01","060","1"})//"Fixed Asset - Storno of Desconservation"
aAdd(aCVA,{'901',STR0189,'2',"43","490","3"})//"TMS - Inclusão de movimento de custo de transporte por data de baixa"
aAdd(aCVA,{'902',STR0190,'2',"43","490","1"})//"TMS - Estorno de movimento de custo de transporte por data de baixa"
aAdd(aCVA,{'903',STR0191,'2',"43","490","3"})//"TMS - Inclusão de movimento de custo de transporte por data de emissão"
aAdd(aCVA,{'904',STR0192,'2',"43","490","1"})//"TMS - Estorno de movimento de custo de transporte por data de emissão"
aAdd(aCVA,{'950',STR0156,'2',"17","910","3"})//"Documento de Entrada EIC - Inclusão de Itens"
aAdd(aCVA,{'955',STR0157,'2',"17","910","1"})//"Documento de Entrada EIC - Exclusao de Itens"
aAdd(aCVA,{'965',STR0181,'2',"45","980","1"})//"Calculo dos Direitos Autorais - CDA"
aAdd(aCVA,{'970',STR0185,'2',"65","800","1"})//"Gestao Advocatícia - Geração de Honorários - Cabeçalho da Fatura"
aAdd(aCVA,{'971',STR0186,'2',"65","800","1"})//"Gestao Advocatícia - Geração de Honorarios - Itens da Fatura"
aAdd(aCVA,{'972',STR0187,'2',"65","800","1"})//"Gestao Advocatícia - Geração de Despesas - Itens da Fatura"
aAdd(aCVA,{'973',STR0188,'2',"65","800","1"})//"Gestao Advocatícia - Geração de Eventoss - Itens da Fatura"
aAdd(aCVA,{'974',STR0195,'2',"65","800","1"})//"Gestao Advocatícia - Estorno de Honorários - Cabeçalho da Fatura"
aAdd(aCVA,{'975',STR0196,'2',"65","800","1"})//"Gestao Advocatícia - Estorno de Honorarios - Itens da Fatura"
aAdd(aCVA,{'976',STR0197,'2',"65","800","1"})//"Gestao Advocatícia - Estorno de Despesas - Itens da Fatura"
aAdd(aCVA,{'977',STR0198,'2',"65","800","1"})//"Gestao Advocatícia - Estorno de Eventoss - Itens da Fatura"
aAdd(aCVA,{'980',STR0199,'2',"65","810","1"})//"Gestao Advocatícia - Geração de Despesas Contas a Pagar - Cabeçalho da Fatura"
aAdd(aCVA,{'981',STR0200,'2',"65","810","1"})//"Gestao Advocatícia - Geração de Despesas Contas a Pagar - Itens da Fatura"
aAdd(aCVA,{'984',STR0201,'2',"65","810","1"})//"Gestao Advocatícia - Estorno de Despesas Contas a Pagar - Cabeçalho da Fatura"
aAdd(aCVA,{'985',STR0202,'2',"65","810","1"})//"Gestao Advocatícia - Estorno de Despesas Contas a Pagar - Itens da Fatura"
aAdd(aCVA,{'A01',STR0158,'2',"07","700","2"})//"Folha de Pagamento - Salarios a Pagar"
aAdd(aCVA,{'A02',STR0159,'2',"07","700","2"})//"Folha de Pagamento - Ferias"
aAdd(aCVA,{'A03',STR0160,'2',"07","700","2"})//"Folha de Pagamento - Salario Familia"
aAdd(aCVA,{'A04',STR0161,'2',"07","700","2"})//"Folha de Pagamento - Salario Maternidade"
aAdd(aCVA,{'A05',STR0162,'2',"07","700","2"})//"Folha de Pagamento - Pro-Labore"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'B01',STR0163,'2',"07","700","2"})//"Folha de Pagamento - INSS Empregados"
	aAdd(aCVA,{'B02',STR0164,'2',"07","700","2"})//"Folha de Pagamento - IRRF"
Endif
aAdd(aCVA,{'B03',STR0165,'2',"07","700","2"})//"Folha de Pagamento - Assistencia Medica"
aAdd(aCVA,{'B04',STR0166,'2',"07","700","2"})//"Folha de Pagamento - Contribuicao Sindical"
aAdd(aCVA,{'B05',STR0167,'2',"07","700","2"})//"Folha de Pagamento - Faltas"
aAdd(aCVA,{'B06',STR0168,'2',"07","700","2"})//"Folha de Pagamento - Aviso Previo (Desconto)"
aAdd(aCVA,{'B07',STR0169,'2',"07","700","2"})//"Folha de Pagamento - Outros Descontos"
aAdd(aCVA,{'B08',STR0170,'2',"07","700","2"})//"Folha de Pagamento - Pensao Alimenticia"
aAdd(aCVA,{'B09',STR0171,'2',"07","700","2"})//"Folha de Pagamento - Vale-Transporte"
aAdd(aCVA,{'B10',STR0172,'2',"07","700","2"})//"Folha de Pagamento - Desc. Insuficiencia de Saldo"
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'C01',STR0173,'2',"07","700","2"})//"Folha de Pagamento - INSS Empresa"
	aAdd(aCVA,{'C02',STR0174,'2',"07","700","2"})//"Folha de Pagamento - FGTS"
Endif
aAdd(aCVA,{'C03',STR0175,'2',"07","700","2"})//"Folha de Pagamento - Provisao de Ferias"
aAdd(aCVA,{'C04',STR0176,'2',"07","700","2"})//"Folha de Pagamento - Encargos Provisao de Ferias"
aAdd(aCVA,{'C05',STR0177,'2',"07","700","2"})//"Folha de Pagamento - Provisao de 13o Salario"
aAdd(aCVA,{'C06',STR0178,'2',"07","700","2"})//"Folha de Pagamento - Encargos de Provisao de 13o Salario"

aAdd(aCVA,{'700',STR0222,'2',"12","900","1"})//"Loja - Venda"
aAdd(aCVA,{'701',STR0223,'2',"12","900","1"})//"Loja - Cancelamento de Venda"	
aAdd(aCVA,{'702',STR0224,'2',"12","900","1"})//"Loja - Factura Global"
aAdd(aCVA,{'703',STR0225,'2',"12","900","1"})//"Loja - NF sobre Cupom"
aAdd(aCVA,{'704',STR0226,'2',"12","900","1"})//"Loja - Troca e Devolução"
aAdd(aCVA,{'612',STR0237,'2',"05","430","3"})//"Itens do Pedido de Venda - Inclusao"
aAdd(aCVA,{'614',STR0518,'2',"05","430","3"})//"Pedido de Vendas - Eliminação de Resíduos - Itens"
aAdd(aCVA,{'621',STR0238,'2',"05","430","3"})//"Cabeçalho do Pedido de Venda - Inclusao"
aAdd(aCVA,{'632',STR0239,'2',"05","430","1"})//"Itens do Pedido de Venda - Exclusão"
aAdd(aCVA,{'636',STR0240,'2',"05","430","1"})//"Cabeçalho do Pedido de Venda - Exclusão"	
If (cPaisLoc <> "RUS")
	aAdd(aCVA,{'9A0',STR0284,'2',"33","9A0","3"})//"PLS - Inclusao Contas a Receber-Antes BM1"
	aAdd(aCVA,{'9A1',STR0285,'2',"33","9A0","3"})//"PLS - Inclusao Conas a Receber-a Cada BM1"
	aAdd(aCVA,{'9A8',STR0286,'2',"33","9A0","3"})//"PLS - Inclusao Contas a Receber-Apos BM1"
	aAdd(aCVA,{'9AB',STR0287,'2',"33","9A0","3"})//"PLS - EXCLUSÃO CTAS RECEBER-A CADA BMN "
	aAdd(aCVA,{'9AG',STR0288,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-ANTES BMS        "
	aAdd(aCVA,{'9AH',STR0289,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-A CADA BMS DO BD7"
	aAdd(aCVA,{'9AI',STR0290,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-A CADA BMS DO BBC"
	aAdd(aCVA,{'9AJ',STR0291,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-A CADA BMS DO BGQ"
	aAdd(aCVA,{'9AK',STR0292,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-A CADA BMS DO BCE"
	aAdd(aCVA,{'9AL',STR0293,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-A CADA BMR       "
	aAdd(aCVA,{'9AM',STR0294,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-A CADA BMS OUTROS"
	aAdd(aCVA,{'9AN',STR0295,'2',"33","9A0","3"})//"PLS - INCL.CTAS PAGAR-APÓS BMS         "
	aAdd(aCVA,{'9AW',STR0296,'2',"33","9A0","3"})//"PLS - BAIXA CTAS RECEBER-ANTES BM1     "
	aAdd(aCVA,{'9AX',STR0297,'2',"33","9A0","3"})//"PLS - BAIXA CTAS RECEBER-A CADA BM1    "
	aAdd(aCVA,{'9B4',STR0298,'2',"33","9A0","3"})//"PLS - BAIXA CTAS RECEBER-APÓS BM1      "
	aAdd(aCVA,{'9B5',STR0299,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS RECEBER-ANTES BM1 "
	aAdd(aCVA,{'9B6',STR0300,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS RECEBER-A CADA BM1"
	aAdd(aCVA,{'9BC',STR0301,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS RECEBER-APÓS BM1  "
	aAdd(aCVA,{'9BD',STR0302,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-ANTES DO BMS       "
	aAdd(aCVA,{'9BE',STR0303,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-A CADA BMS DO BD7  "
	aAdd(aCVA,{'9BF',STR0304,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-A CADA BMS DO BBC  "
	aAdd(aCVA,{'9BG',STR0305,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-A CADA BMS DO BGQ  "
	aAdd(aCVA,{'9BH',STR0306,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-A CADA BMS DO BCE  "
	aAdd(aCVA,{'9BI',STR0307,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-A CADA BMR         "
	aAdd(aCVA,{'9BJ',STR0308,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-A CADA BMS OUTROS  "
	aAdd(aCVA,{'9BK',STR0309,'2',"33","9A0","3"})//"PLS - BX CTAS PAGAR-APÓS BMS           "
	aAdd(aCVA,{'9BL',STR0310,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-ANTES BMS   "
	aAdd(aCVA,{'9BM',STR0311,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-CADA BMS/BD7"
	aAdd(aCVA,{'9BN',STR0312,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-CADA BMS/BBC"
	aAdd(aCVA,{'9BO',STR0313,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-CADA BMS/BGQ"
	aAdd(aCVA,{'9BP',STR0314,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-CADA BMS/BCE"
	aAdd(aCVA,{'9BQ',STR0315,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-A CADA BMR  "
	aAdd(aCVA,{'9BR',STR0316,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-CADA BMS/OUT"
	aAdd(aCVA,{'9BS',STR0317,'2',"33","9A0","3"})//"PLS - CANCEL BX CTAS PAGAR-APÓS BMS    "
	aAdd(aCVA,{'9BZ',STR0318,'2',"33","9A0","3"})//"PLS - CONTABILIZAÇÃO DE GUIAS - BD5/BE4"
	aAdd(aCVA,{'9C0',STR0319,'2',"33","9A0","3"})//"PLS - CONTABILIZAÇÃO DE GUIAS - BD6    "
	aAdd(aCVA,{'9C1',STR0320,'2',"33","9A0","3"})//"PLS - CONTABILIZAÇÃO DE GUIAS - BD7    "
	aAdd(aCVA,{'9CU',STR0448,'2',"33","9A0","3"})//"PLS - HISTÓRICO DE REVERSÃO   - B3N    "
	aAdd(aCVA,{'9CX',STR0449,'2',"33","9A0","3"})//"PLS - PROVISÃO DE REEMBOLSO			   "
	aAdd(aCVA,{'9CY',STR0450,'2',"33","9A0","3"})//"PLS - REVERSÃO DE REEMBOLSO       	   "
	aAdd(aCVA,{'9CW',STR0451,'2',"33","9A0","3"})//"PLS - Provisão dos Recursos de Glosa   "
	aAdd(aCVA,{'9CZ',STR0452,'2',"33","9A0","3"})//"PLS - Reversão dos Recursos de Glosa   "
	aAdd(aCVA,{'9CL',STR0318,'2',"33","9A0","3"})//"PLS - CONTABILIZAÇÃO DE GUIAS - BD5/BE4"
	aAdd(aCVA,{'9CM',STR0319,'2',"33","9A0","3"})//"PLS - CONTABILIZAÇÃO DE GUIAS - BD6    "
	aAdd(aCVA,{'9CN',STR0477,'2',"33","9A0","3"})////"PLS - CONTABILIZAÇÃO DE GUIAS - BD7 - Provisão "
	aAdd(aCVA,{'9CQ',STR0478,'2',"33","9A0","3"})////"PLS - CONTABILIZAÇÃO DE GUIAS - BD7 - Reversão "
	aAdd(aCVA,{'9CT',STR0479,'2',"33","9A0","3"})////"PLS - CONTABILIZAÇÃO DE GUIAS - BD7 - Custos "
	aAdd(aCVA,{'9CV',STR0478,'2',"33","9A0","3"})////"PLS - CONTABILIZAÇÃO DE GUIAS - BD7 - Reversão "
Endif

//Modulo SIGAJURI
aAdd(aCVA,{'9D0',STR0360	,'2',"76","9D0","3"}) //"JURI - Inclusão de valores de provisão"
aAdd(aCVA,{'9D1',STR0361	,'2',"76","9D0","3"}) //"JURI - Cancelamento de valores de provisão"
aAdd(aCVA,{'9D2',STR0362	,'2',"76","9D0","3"}) //"JURI - Redução de valores de provisão"

//Modulo SIGAPFS 
//LP's reservados para PFS - 940 Até 949 e 956 Até 964
aAdd(aCVA,{'940',STR0541,'2',"77","940","3"}) //"PFS - Emissão de WO de Despesa"
aAdd(aCVA,{'941',STR0542,'2',"77","940","3"}) //"PFS - Cancelamento de WO de Despesa"
aAdd(aCVA,{'942',STR0543,'2',"77","940","3"}) //"PFS - Lançamento"
aAdd(aCVA,{'943',STR0544,'2',"77","940","3"}) //"PFS - Desdobramento Baixa"
aAdd(aCVA,{'944',STR0545,'2',"77","940","3"}) //"PFS - Desdobramento pós pagamento"
aAdd(aCVA,{'945',STR0546,'2',"77","940","3"}) //"PFS - Emissão de Fatura"
aAdd(aCVA,{'946',STR0547,'2',"77","940","3"}) //"PFS - Cancelamento de Fatura"
aAdd(aCVA,{'947',STR0558,'2',"77","940","3"}) //"PFS - Inclusão Desdobramento"
aAdd(aCVA,{'948',STR0559,'2',"77","940","3"}) //"PFS - Estorno de Inclusão de Desdobramento"
aAdd(aCVA,{'949',STR0560,'2',"77","940","3"}) //"PFS - Estorno de Desdobramento Pós Pagamento"
aAdd(aCVA,{'956',STR0561,'2',"77","940","3"}) //"PFS - Estorno Lançamento"
aAdd(aCVA,{'957',STR0562,'2',"77","940","3"}) //"PFS - Estorno Desdobramento Baixa"

//Modulo SIGATUR

//(pares) Gravação do Registro de Venda
//(impares) Cancelamento do Registro de Venda
aAdd(aCVA,{'T00',STR0455	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Venda Cliente (IV)"
aAdd(aCVA,{'T01',STR0456	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Venda Cliente (IV)"
aAdd(aCVA,{'T02',STR0457	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Venda Fornecedor (DR)"
aAdd(aCVA,{'T03',STR0458	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Venda Fornecedor (DR)"
aAdd(aCVA,{'T04',STR0459	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Receita Cliente (IV)"
aAdd(aCVA,{'T05',STR0460	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Receita Cliente (IV)"
aAdd(aCVA,{'T06',STR0461	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Receita Fornecedor (DR)"
aAdd(aCVA,{'T07',STR0462	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Receita Fornecedor (DR)"
aAdd(aCVA,{'T08',STR0463	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Reembolso Cliente(IV)"
aAdd(aCVA,{'T09',STR0464	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Reembolso Cliente(IV)"
aAdd(aCVA,{'T10',STR0465	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Reembolso Fornecedor (DR)"
aAdd(aCVA,{'T11',STR0466	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Reembolso Fornecedor (DR)"
aAdd(aCVA,{'T12',STR0467	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Abat.Receita Cliente (Acordos)"
aAdd(aCVA,{'T13',STR0468	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Abat.Receita Cliente (Acordos)"
aAdd(aCVA,{'T14',STR0469	,'2',"89","T00","3"}) //"Turismo - Geração de IF - Abat.Receita Fornecedor (Acordos)"
aAdd(aCVA,{'T15',STR0470	,'2',"89","T00","3"}) //"Turismo - Exclusão de IF - Abat.Receita Fornecedor (Acordos)"

//(pares) Faturamento de Receita / Venda
//(impares) Cancelamento de Faturas de Receita / Venda
aAdd(aCVA,{'T20',STR0491	,'2',"89","T20","3"}) //"Turismo - Finalização de IF - Faturamento de Venda"
aAdd(aCVA,{'T21',STR0492	,'2',"89","T20","3"}) //"Turismo - Estorno de IF - Faturamento de Venda"
aAdd(aCVA,{'T22',STR0493	,'2',"89","T20","3"}) //"Turismo - Finalização de IF - Faturamento de Reembolso de Venda"
aAdd(aCVA,{'T23',STR0494	,'2',"89","T20","3"}) //"Turismo - Estorno de IF - Faturamento de Reembolso de Venda"
aAdd(aCVA,{'T24',STR0495	,'2',"89","T20","3"}) //"Turismo - Finalização de IF - Faturamento de Receita"
aAdd(aCVA,{'T25',STR0496	,'2',"89","T20","3"}) //"Turismo - Estorno de IF - Faturamento de Receita"
aAdd(aCVA,{'T26',STR0497	,'2',"89","T20","3"}) //"Turismo - Finalização de IF - Faturamento de Abat. Receita"
aAdd(aCVA,{'T27',STR0498	,'2',"89","T20","3"}) //"Turismo - Estorno de IF - Faturamento de Abat. Receita"
aAdd(aCVA,{'T28',STR0499	,'2',"89","T20","3"})//"Turismo - Finalização de IF - Faturamento Breakage" 
aAdd(aCVA,{'T29',STR0500	,'2',"89","T20","3"})//"Turismo - Estorno de IF - Faturamento Breakage" 

//(pares) Conciliação de Fatura Fornecedor
//(impares) Cancelamento da Conciliação de Fatura Fornecedor
aAdd(aCVA,{'T30',STR0480	,'2',"89","T30","3"}) //"Turismo - Finalização de IF – Confirmação da Venda"
aAdd(aCVA,{'T31',STR0481	,'2',"89","T30","3"}) //"Turismo - Estorno de IF – Confirmação da Venda"
aAdd(aCVA,{'T32',STR0482	,'2',"89","T30","3"}) //"Turismo - Finalização de IF – Confirmação do Reembolso da Venda"
aAdd(aCVA,{'T33',STR0483	,'2',"89","T30","3"}) //"Turismo - Estorno de IF – Confirmação do Reembolso da Venda"
aAdd(aCVA,{'T34',STR0484	,'2',"89","T30","3"}) //"Turismo - Finalização de IF – Confirmação da Receita"
aAdd(aCVA,{'T35',STR0485	,'2',"89","T30","3"}) //"Turismo - Estorno de IF – Confirmação da Receita"
aAdd(aCVA,{'T36',STR0486	,'2',"89","T30","3"}) //"Turismo - Finalização de IF – Confirmação do Abat.Receita"
aAdd(aCVA,{'T37',STR0487	,'2',"89","T30","3"}) //"Turismo - Estorno de IF – Confirmação do Abat.Receita"

//(pares) Apuração de Receita Cliente (FEE)
//(impares) Cancelamento de Apuração de Receita Cliente (FEE)

aAdd(aCVA,{'T40',STR0471	,'2',"89","T40","3"}) //"Turismo - Geração de IF – Receita (Apuração)"
aAdd(aCVA,{'T41',STR0472	,'2',"89","T40","3"}) //"Turismo - Exclusão de IF – Receita (Apuração)"
aAdd(aCVA,{'T42',STR0473	,'2',"89","T40","3"}) //"Turismo - Geração de IF – Abat.Receita (Apuração)"
aAdd(aCVA,{'T43',STR0474	,'2',"89","T40","3"}) //"Turismo - Exclusão de IF – Abat.Receita (Apuração)"
aAdd(aCVA,{'T44',STR0475	,'2',"89","T40","3"}) //"Turismo - Geração de IF – Apuração - Total"
aAdd(aCVA,{'T45',STR0476	,'2',"89","T40","3"}) //"Turismo - Exclusão de IF – Apuração - Total"

//(par) Apuração de Metas (Fornecedor)
//(impar) Cancelamento de Apuração de Metas (Fornecedor)
aAdd(aCVA,{'T50',STR0488	,'2',"89","T40","3"}) //"Turismo - Efetivação da Conciliação"
aAdd(aCVA,{'T51',STR0489	,'2',"89","T40","3"}) //"Turismo - Estorno da Efetivação da Conciliação"

dbSelectArea("CVA")
dbSetOrder(1)
cFilCVA 	:= xFilial("CVA")
lCpoModulo	:= .T.	
lCpoCFG	:= .T.

If cPaisLoc $ "ANG/ARG/AUS/BOL/BRA/CHI/COL/COS/DOM/EUA/EQU/HAI/MEX/PAD/PAN/PAR/PER/POR/PTG/SAL/URU/VEN"
	lCpoProc  	:= .T.
Else
	lCpoProc  := .F.
EndIf

For nx := 1 to Len(aCVA)
	If  CVA->(MsSeek(cFilCVA+aCVA[nx,1]))
		If ( ALLTRIM(CVA->CVA_DESCRI) != alltrim(aCVA[nx,2]) .And. cPaisLoc <> 'RUS' ) .Or. ( lCpoModulo .And. ALLTRIM(CVA->CVA_MODULO) != alltrim(aCVA[nx,4]) ) .Or. ( lCpoProc .And. ALLTRIM(CVA->CVA_PROCES) != alltrim(aCVA[nx,5]) );
			.OR. ( ALLTRIM(CVA->CVA_TPINT) != alltrim(aCVA[nx,6]) )
			RecLock("CVA",.F.)
				CVA_DESCRI := aCVA[nx,2]

				If lCpoCFG
					CVA_CFGLAN := aCVA[nx,3]
				EndIf

				If lCpoModulo
					CVA_MODULO := aCVA[nx,4]
				EndIf

				If lCpoProc
					CVA_PROCES := aCVA[nx,5]
				EndIf		
				
				CVA_TPINT     := aCVA[nx,6]
				
			CVA->(MsUnlock())
		EndIf
	Else
		RecLock("CVA",.T.)
		CVA_FILIAL := cFilCVA
		CVA_CODIGO := aCVA[nx,1]
		CVA_DESCRI := aCVA[nx,2]
		If lCpoCFG
			CVA_CFGLAN := aCVA[nx,3]
		EndIf
		If lCpoModulo
			CVA_MODULO := aCVA[nx,4]
		EndIf
		If lCpoProc
			CVA_PROCES := aCVA[nx,5]
		EndIf
		
		CVA_TPINT     := aCVA[nx,6]

		CVA->(MsUnlock())
	EndIf
Next

dbSelectArea("CT5")
CT5->(dbSetOrder(1))
If CT5->(MsSeek(xFilial("CT5") + '905')) .Or. CT5->(MsSeek(xFilial("CT5") + '906'))
   Aviso( STR0228, STR0227,{'Ok'})
Else
	If  CVA->(MsSeek(cFilCVA+'905'))
		RecLock("CVA",.F.)
		dbDelete()
		MsUnLock()		
	EndIf
	If  CVA->(MsSeek(cFilCVA+'906'))
		RecLock("CVA",.F.)
		dbDelete()
		MsUnLock()		
	EndIf
EndIf

RestArea(aArea)

Return
