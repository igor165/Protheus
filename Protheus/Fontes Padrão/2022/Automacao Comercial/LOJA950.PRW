#INCLUDE "LOJA950.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRDDEF.CH"
#INCLUDE "AUTODEF.CH" 

Static lMsgPafEcf := .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o	 |LJAnalisaLegºAutor  ³   Vendas Clientes  º Data ³  15/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Retorna se ha uma exigencia Legal da Secretaria da Fazenda   º±±
±±º          ³ do Estado                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nItem - Qual item da legistacao sera analizado                º±±
±±º			 ³cEstCob - qual o estado que devera ser analizado              º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³aRet - array com a analise da legistacaos sendo               º±±
±±º          ³ (descrito abaixo como estrutura)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function LJAnalisaLeg( nItem, cEstCob, nDiaVenRec )

Local aRet := {.F., ,{}, , }						// Array de retorno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura                                                                 ³
//³                                                                          ³
//³Posicao 1 = ExistExig                                                     ³
//³Se existe exigencia legal: TRUE ou FALSE                                  ³
//³                                                                          ³
//³Posicao 2 = cEstados                                                      ³
//³Qual os estados que estao afetos a essa legislacao                        ³
//³                                                                          ³
//³Posicao 3 = aRegra                                                        ³
//³Qual o artigo, inciso, qual e o embasamento legal.                        ³
//³                                                                          ³
//³Posicao 4 = cDescRegra                                                    ³
//³Linguagem para o usuario do sistema, traduzindo o que a lei diz           ³
//³                                                                          ³
//³Posicao 5 = cHelp                                                         ³
//³Mensagem de help para o usuario apontando o que o sistema esta controlando³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cHelp			:= ""							// Texto do help             	
Local lExistExig 	:= .F.    						// Flag de controle de exigencia legal ou nao
Local cAuxStr		:= ""							//variável auxiliar
Local cEstados      := ""							// Estados afetos a legislacao	     	
Local aRegra 		:= {}							// Array contendo a descricao das regras	
Local cDescRegra	:= ""							// Descricao das regras
Local cCidCob		:= AllTrim(Upper(SM0->M0_CIDCOB))// Cidade de cobranca do SIGAMAT.EMP
Local lMvLjPdvPa	:= LjxBGetPaf()[2] 				//Indica se é PDV
Local lFindEst		:= .F.
Local lMvSpedEnd	:= SuperGetMv("MV_SPEDEND",,.F.)
Local cNFCERTC		:= SuperGetMv("MV_NFCERTC",,"AL,AM,MS,PE,PR,SC,TO")
Local aFilCodMun 	:= {{"",""},{"",""}}

Default cEstCob 	:= SM0->M0_ESTCOB				// Estado de cobranca do SIGAMAT.EMP porque e o estado onde o cliente Microsiga sera tributado.	
Default nDiaVenRec	:= 0

If FindClass("FWSM0Util") //Proteção, para ambiente com RPO Ctree essa função não existe
	aFilCodMun	:= FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CODMUN","M0_CIDCOB" } )
EndIf

If cPaisLoc == "BRA"
	Do Case
		// 1 - trava cadastro de estacoes - Todos estados Estados não permitem que seja alterada a impressora fiscal
		Case nItem == 1
			If cEstCob $ "AL|AM|ES|MA|MG|SC|BA|RR|RJ|PR|PA|DF|CE" .OR. LjNfPafEcf(SM0->M0_CGC) 
				lExistExig:= .F. //alteração para permissão da troca do ECF
				cEstados  :="AL|AM|ES|MA|MG|SC|BA|RR|RJ|PR|PA|DF|CE"
				aRegra	  := {	STR0001, ; //'ES - Decreto 1.090-R/2002 - Art.657, Inciso XVI A e B'
								STR0002, ; //'MA - Decreto 19.140/2002 - Art.88, Inciso XVI A e B'
								STR0003, ; //'MG - Port.3492/2002 - Art.115, Inciso XVI A e B'
								STR0004, ; //'SC - Regulamento ICMS - Art.94, Inciso XVI A e B'
								STR0005, ; //'BA - Port.53/2005 - Anexo único, Item 2.11'
						    	STR0006, ; //'Convenio ICMS 85/01 - Clausula octogesima sexta,  Inciso XVI A e B'
								STR0196, ; //'RR - Decreto 5898 - Art.458, Inciso XVI A e B'
								STR0206, ; //'RJ - Decreto 27.427, Livro VIII, Art. 100, Inciso XVI Item 1 e 2'
								STR0210 }  //'PR - NPF 004/2002 Art. 93 Inciso XVI Item A e B'
				// Descricao conforme Convênio 85/01
				cDescRegra:= STR0007 +Chr(10)+; //'- Não possuir "menus" de configuração que possibilitem a desativação do ECF'
							 STR0008 //'- Não possuir tela de acesso ao usuário que possibilite configurar o ECF a ser utilizado, exceto quanto a porta de comunicação'
				cHelp     := STR0009 //'Uma vez configurada a Estação não é permitido alterar os dados de Impressora Fiscal.'
			Endif
			
			
		// 2 - nao aceita produto sem preco
		Case nItem == 2
			If cEstCob $ "AM|ES|MA|MG|SC|SP|RR|RJ|PR|PA|DF|CE"
				lExistExig:=.T.
				cEstados  :="AM|ES|MA|MG|SC|SP|RR|RJ|PR|PA|DF|CE"
				aRegra	  := {	STR0010, ; //'ES - Decreto 1.090-R/2002 - Art.657, Inciso V'
								STR0011, ; //'MA - Decreto 19.140/2002 - Art.88, Inciso V'
								STR0012, ; //'MG - Port.3492/2002 - Art.115, Inciso VI'
								STR0013, ; //'SC - Regulamento ICMS - Art.94, Inciso V'
								STR0014, ; //'Convenio ICMS 85/01 - Clausula octogesima sexta,  Inciso V'
								STR0199, ; //'RR - Decreto 5898 - Art.458, Inciso V item A'
								STR0204, ; //'RJ - Decreto 27.427, Livro VIII, Art. 100, Inciso V'
								STR0208 }  //'PR - NPF 004/2002, Art. 93 Inciso V Item A'
								 
				// Descricao conforme Convênio 85/01
				cDescRegra:= STR0015+Chr(10)+; //'- Não aceitar valor negativo ou nulo nos campos:'
			  	 			 STR0016 //'a) valor unitário da mercadoria ou do serviço;'
				cHelp     := STR0017 //'Cadastre um preco para o produto.'
			Endif
			
			// 3 - faz verificacao de data/hora
		Case nItem == 3
			If cEstCob $ "AM|ES|MA|MG|SC|SP|BA|AL|RR|RJ|PR|PA|DF|CE"
				lExistExig:=.T.
				cEstados  :="AM|ES|MA|MG|SC|SP|BA|AL|RR|RJ|PR|PA|DF|CE"
				aRegra	  := {	STR0018, ; //'ES - Decreto 1.090-R/2002 - Art.657, Inciso XI'
								STR0019, ; //'MA - Decreto 19.140/2002 - Art.88, Inciso XI'
								STR0020, ; //'MG - Port.3492/2002 - Art.115, Inciso XIII'
								STR0021, ; //'SC - Regulamento ICMS - Art.94, Inciso XI'
								STR0022, ; //'BA - Port.53/2005 - Anexo único, Item 2.7'
								STR0023, ; //'Convenio ICMS 85/01 - Clausula octogesima sexta,  Inciso XI'
								STR0197, ; //'RR - Decreto 5898 - Art.458, Inciso XI'
								STR0205, ; //'RJ - Decreto 27.427, Livro VIII, Art. 100, Inciso XI'
								STR0209 }  //'PR - NPF 004/2002, Art. 93 Inciso XI'
				// Descricao conforme Convênio 85/01
				cDescRegra:= STR0024 +; //'Manter a data e a hora do computador e do registro da movimentação sincronizada com a data e a hora '
 							 STR0025 +; //'do ECF, admitida tolerância de 15 minutos para a hora, devendo impossibilitar registro de operações '
							 STR0026 //'no ECF até o ajuste'
				If lMvLjPdvPa
					/* "Conforme previsto no Requisito XVII (Ato Cotepe/ICMS 9, de 13 de Março de 2013),
						para PAF-ECF admite-se somente uma tolerância em minutos entre a hora do Sistema e a hora do ECF,
						limitada a uma hora, desde que na mesma data." */
					cHelp     := STR0354
				Else
					cHelp     := STR0027 //'A diferenca entre a hora do computador e do ECF não pode ultrapassar 15 minutos.'
				EndIf
				
			Endif
			
			// 4 - o pagamento deve ser concomitante
		Case nItem == 4
			If cEstCob $ "RR"
				lExistExig:=.T.
				cEstados  :="RR"
				aRegra	  := {STR0198} //'RR - Decreto 5898 - Art.457.' 
				cDescRegra:= STR0028 //'o pagamento deve ser concomitante	'
				cHelp     := ''
			Endif
			
			// 5 - Bloqueia alteracao de preco do produto (tabela de precos)
		Case nItem == 5
			If cEstCob $ "AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SE|TO"
				lExistExig:=.T.
				cEstados  :="AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SE|TO"
				aRegra	  := {STR0292} 	// "Roteiro de Análise Funcional de Programa Aplicativo Fiscal Versão 1.4 - junho/2010"
				cDescRegra:= STR0293+; 	// "REQUISITO XI" 
							 STR0294+;	// "ITEM 1: O PAF-ECF deve utilizar Tabela de Mercadorias e Servicos que contenha os seguintes campos,"
							 STR0295	// "admitindo-se a utilizacao de mais de uma tabela, desde que haja recurso para selecionar a tabela ser utilizada."			 
				cHelp     := STR0034+Chr(10)+; //'Nao é permitido alterar o preco do produto sem enviar comando de acréscimo ou desconto para o ECF.'
			 				 STR0035 //'Para alterar o preco utilize desconto ou acrescimo.'
			Endif
		
			// 6 - Deve imprimir e cancelar orçamentos
			// Validação para exclusão de orçamento. Nesses Estados quando houver cancelamento de
			// orçamento, o sistema deverá obrigatoriamente emitir o Cupom Fiscal e cancelar.
			// Se for um orçamento, o sistema imprime o cupom fiscal e o cancelamento, também apaga o orçamento da base.
		Case nItem == 6
			If cEstCob $ "MA|MG"
				lExistExig:=.T.
				cEstados  :="MA|MG"
				aRegra	  := {	STR0036, ; //'MA - Decreto 19.140/2002 - Art.93, Parágrafo 1º'
								STR0037} //'MG - Port.3492/2002 - Art.115, Parágrafo 5º'
				// Descricao conforme Portaria de MG
				cDescRegra:= STR0038+; //'Na hipótese do inciso III do artigo 68, para o cancelamento de operação ou prestação já registrada'
							 STR0039+; //'pelo programa aplicativo e para a qual ainda não tenha sido emitido o documento fiscal, o programa'
							 STR0040 //'deverá obrigatoriamente comandar a sua emissão e, imediatamente, a emissão do cancelamento.'
				cHelp     := STR0041 //'No caso de cancelamento de orçamento, o sistema imprime o cupom fiscal, o cancelamento e apaga o orçamento da base.'
			Endif
			
			// 7 - Ao excluir a venda o orcamento deve ser eliminado.
			// Se for uma venda, cancela o cupom e apaga o orçamento da base, pra que não seja reutilizado.
		Case nItem == 7
			If cEstCob $ "AM"
				lExistExig:=.T.
				cEstados  :="AM"
				aRegra	  := {STR0042} //'AM - GSefaz 001/06. Capítulo V - Seção I'
				cDescRegra:= STR0043 //"Não poderá ser excluído da base nenhum orçamento."
				cHelp     := STR0044 //"Manter na base de dados todos os orçamentos."
			Endif
			
			// 8 - LIVRE PARA USO
		Case nItem == 8
			If cEstCob $ ""
				lExistExig:= .F.
				cEstados  := ""
				aRegra	  := ''
				cDescRegra:= ''
				cHelp     := ''
			Endif
			
			// 9 - Codigo do produto preenchido com zeros(0) a esquerda
		Case nItem == 9
			If cEstCob $ "AM"
				lExistExig:=.T.
				cEstados  :="AM"
				aRegra	  := ''   // nao temos essa documentacao
				cDescRegra:= STR0047 //'Codigo do produto preenchido com zeros(0) a esquerda'
				cHelp     := ''
			Endif
			
			// 10 - Na geração de NF para CF, zerar apenas os impostos
			/* Foi feita uma mudança no procedimento da geração da nota fiscal a
			partir de um cupom fiscal, pois o mesmo era replicado e logo em seguida,
			os valores da venda e dos impostos eram zerados, conforme retorno da
			consulta do IOB para o estado do Maranhão, o que deve ser apenas zerado
			é o valor dos impostos, sendo assim, foi feita a melhoria apenas para
			o estado do Maranhao, para o estado de São Paulo, estamos aguardando
			a posição dos consultores da IOB:*/
		Case nItem == 10
			If cEstCob $ "MA"
				lExistExig:=.T.
				cEstados  :="MA"
				aRegra	  := STR0048 //'Consulta IOB'
				cDescRegra:= STR0049 //'Na geração de NF para CF, zerar apenas os impostos'
				cHelp     := STR0050 //'Na geração de NF para CF, são zerados apenas os impostos'
			Endif
			
			// 11 - Utiliza outro formato de numeracao de orçamento - "L1_NSO"
		Case nItem == 11
			If cEstCob $ "AM"
				lExistExig:=.T.
				cEstados  :="AM"
				aRegra	  := '' // não sabemos a descrição da lei/decreto/regra
				cDescRegra:= STR0051+; //'1. Autorizada a impressão, em equipamento não fiscal, de documento auxiliar de venda - orçamento '
							 STR0052+Chr(10)+; //'desde que:'
							 STR0053+; //'a) Seja emitido em papel de tamanho não inferior a 240 X 180 mm, com numeracao sequencial única '
							 STR0054+; //'no formato nnn.nnn/xx, onde "n" será o número do orçamento e "x" o número do terminal que gerou a'
							 STR0055 //'informação, reiniciada a numeração quando atingir o limite.'
				cHelp     := STR0056 //'Alguns estados exigem um formato de numeração diferenciada para orçamento.'
			Endif
			
			// 12 - Efetuar o desconto no item somente após a impressão do mesmo.
			// não e permitido enviar comando de desconto junto com o registro de item
		Case nItem == 12
			If cEstCob $ "AM"
				lExistExig:=.T.
				cEstados  :="AM"
				aRegra	  := {STR0057}// nao temos essa documentacao
				cDescRegra:= STR0057 //'Não e permitido enviar comando de desconto junto com o registro de item'
				cHelp     := STR0057
			Endif
			
			// 13 - Tratamento nas formas de pagamento específicas - Concomitancia.
		Case nItem == 13
			If cEstCob $ "AM|MG"
				lExistExig:=.T.
				cEstados  :="AM|MG"
				aRegra	  := ''  // nao temos essa documentacao
				cDescRegra:= STR0058 //'Tratamento nas formas de pagamento específicas - Concomitancia.'
				cHelp     := ''
			Endif
			
			// 14 - Impressao concomitante do desconto no total.
		Case nItem == 14
			If cEstCob $ "AM|MG|RR"
				lExistExig:=.T.
				cEstados  :="AM|MG|RR"
				aRegra	  := '' // nao temos essa documentacao
				cDescRegra:= STR0059 //'Impressao concomitante do desconto no total.'
				cHelp     := ''
			Endif
			
			// 15 - nao aceita cadastrar produto sem preco
		Case nItem == 15
			If cEstCob $ "MG|RR"
				lExistExig:=.T.
				cEstados  :="MG|RR"
				aRegra	  := {STR0012,;  //'MG - Port.3492/2002 - Art.115, Inciso VI'
				              STR0199}   //'RR - Decreto 5898 - Art.458, Inciso V item A'
				// Descricao conforme Convênio 85/01
				cDescRegra:= STR0015+Chr(10)+; //'- Não aceitar valor negativo ou nulo nos campos:'
							 STR0016 //'a) valor unitário da mercadoria ou do serviço;'
				cHelp     := STR0060 //'Informe um preco para o produto.'
			Endif
			
			// 16 - Aliquota de 0,01% de ICMS na coluna de outros
		Case nItem == 16
			If cEstCob $ "MT"
				lExistExig:=.T.
				cEstados  :="MT"
				aRegra	  := {STR0061 } //'MT - Decreto 903 (15/07/2003)'
				cDescRegra:= STR0062 //'- ICMS com 0,01% será lançado na coluna outros'
				cHelp     := ''
			Endif
			
			// 17 - Imprime a mensagem: "Não Documento Fiscal" no final do orçamento.
		Case nItem == 17
			If cEstCob $ "MG|MA"
				lExistExig:=.T.
				cEstados  :="MG|MA"
				aRegra	  := {STR0063, ;   //'MG - Port.3492/2002 - Art.68, Inciso I'
				              STR0203}    //'MA - Decreto 19.886/03 - Art. 91, Inciso III'
				cDescRegra:= STR0064 //'- Não válido como documento fiscal'
				cHelp     := ''
			Endif
			
			// 18 - Grava CF no campos de especie da Nota Fiscal, somente para o Paiui
		Case nItem == 18
			If cEstCob $ "PI"
				lExistExig:=.T.
				cEstados  :="PI"
				aRegra	  := {STR0065 } //'PI - Decreto 9.513/96 - Art.38'
				cDescRegra:= STR0066 //'- Impressao de CF na colunas respectivas a especie'
				cHelp     := ''
			Endif
			
			// 19 - Valida se pode ser impresso Nota fiscal ou Nao
		Case nItem == 19
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Essa regra vale para todos os estados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lExistExig := .T.
			cEstados   := "SP|PR|MG"
			aRegra	   := {STR0067 			,; //' SP - Artigo 251 do RICMS'
						   STR0068 			,; //' PR - Artigo 309 do RICMS'
						   STR0069 }		   //' MG - Anexo XVI artigo 18 do regulamento de IMCS'
			cDescRegra := STR0070	+Chr(10)+; //'- Artigo 251 - obrigatório o uso de Equipamento Emissor de Cupom Fiscal'
						  STR0071	+Chr(10)+; //'- ECF por estabelecimento que efetue operação com mercadoria ou prestação'
						  STR0072	+Chr(10)+; //' de serviços em que o destinatário ou o tomador do serviço seja pessoa física'
						  STR0073 	+Chr(10)+; //' ou jurídica não-contribuinte do imposto'
						  STR0074	+Chr(10)+; //' (Lei 6.374/89, art. 67, § 1; Convênio de 15-12-70, art. 50, paragrafo 1 e paragrafo 3'
						  STR0075	+Chr(10)+; //', na redação do Ajuste SINIEF-10/99; Convênio ECF-1/98, cláusulas primeira e terceira,'
						  STR0076	+Chr(10)+; //' com alteração dos Convênios ECF-2/98, ECF-6/99 e ECF-1/00).'
						  STR0077	+Chr(10)+; //'§ 3 paragrafo - A obrigatoriedade prevista neste artigo não se aplica:'
						  STR0078	+Chr(10)+; //' 1 - a estabelecimento:'
						  STR0079	+Chr(10)+; //'	a) que realize venda de veículo sujeito a licenciamento por órgão oficial;'
						  STR0080 	+Chr(10)+; //'	b) de concessionária ou permissionária de serviço público relacionado com fornecimento de '
						  STR0081	+Chr(10)+; //'energia elétrica, fornecimento de gás canalizado ou distribuição de água;'
						  STR0082	+Chr(10)+; //'	c) prestador de serviço de comunicação e de transporte de carga e de valor;'
						  STR0083 	+Chr(10)+; //'	d) que se utilize de Nota Fiscal emitida por sistema eletrônico de processamento de dados;'
						  STR0084   +Chr(10)+; //'	e) usuário de sistema eletrônico de processamento de dados, para emissão de Bilhete de '
						  STR0085	+Chr(10)+; //' Passagem nas prestações de serviços de transporte'
						  STR0086	+Chr(10)+; //' intermunicipal, interestadual e internacional de passageiros (Convênio ECF-2/04). '
						  STR0087	+Chr(10)+; //' (Acrescentada a alínea "e" pelo inciso II do art. 2 paragrafo do Decreto 48.739 de '
						  STR0088	+Chr(10)+; //' 21-06-2004 DOE 22-06-2004; efeitos a partir de 1 paragrafo-05-2004)'
						  STR0089  	+Chr(10)+; //'	2 - ao contribuinte que tenha auferido receita bruta no exercício imediatamente anterior de até'
						  STR0090	+Chr(10)+; //' R$ 120.000,00 (cento e vinte mil reais), observado o disposto nos §§ 1º e 2º do artigo 252;'
						  STR0091	+Chr(10)+; //'	3 - às operações realizadas:'
						  STR0092	+Chr(10)+; //'	a) fora do estabelecimento;'
						  STR0093	//'	b) por farmácia de manipulação.'
			cHelp      := STR0094	+ Chr(10)+; //'A nota fiscal pelo SIGALOJA só pode ser emitida nos seguintes casos: Cliente pessoa Júridica,'
						  STR0095    //'fora do estado de cobrança da Loja e diferente de cliente padrão'
		// 20 - Valida a Venda Bruta Diaria a cada cupom fiscal
		Case nItem == 20
			If cEstCob $ "SC"
				lExistExig:=.T.
				cEstados  :="SC"
				aRegra	  := {STR0096 } //'Inciso XVI - Anexo 9 - Regime ICMS 01 - Santa Catarina '
				cDescRegra:= STR0097 //'- O valor da venda bruta deve ser validada a cada cupom fiscal'
				cHelp     := ''
			Endif 
		// 21 - Verifica se e' a primeira reducao do mes e faz a LMF
		Case nItem == 21
			If cEstCob $ "SC|MG"
				lExistExig:=.T.
				cEstados  :="SC|MG"
				aRegra	  := {STR0098 } //'Inciso XVIII - Anexo 9 - Regime ICMS 01 - Santa Catarina '
				cDescRegra:= STR0099+Chr(10)+; //'- Emitir automaticamente a Leitura da Memória Fiscal, imediatamente após a emissão da primeira'
							 STR0100 //' Redução Z do mês, referente ao período integral do mês imediatamente anterior.'
				cHelp     := ''
			Endif 					  								
		Case nItem == 22
			If cEstCob $ "AM"
				lExistExig:= .T.
				cEstados  := "AM"
				aRegra	  := {STR0101} //'AM - GSefaz 001/06. - Subseção X - Art. 102'
				cDescRegra:= STR0102 	+ CHR(10)	+ ;  //" I - comandar a impressão, no ECF, do registro referente à venda de mercadoria ou prestação de serviço, "
							 STR0103	+ CHR(10) 	+ ; //" concomitantemente ao comando enviado para registro  no dispositivo  utilizado para visualização pelo operador do "
							 STR0104 	+ CHR(10) 	+ ; //" ECF e pelo consumidor adquirente da mercadoria ou usuário do serviço, ressalvado o disposto no art. 51;"
							 STR0105 //" b) desconto sobre o valor total do cupom "

				cHelp     := ''
			Endif
		Case nItem == 23
			If cEstCob $ "AM|ES|RR|SC|MA|RJ|PR|PA|DF|CE"
				lExistExig:= .T.
				cEstados  := "AM|ES|RR|SC|MA|RJ|PR|PA|DF|CE"
				aRegra	  := {	STR0106 , ; //"AM - GSefaz 001/06. - Subseção X - Art. 102"
				                STR0107 , ; //"ES - Subsessão II - Art. 657"
				                STR0200 , ; //"RR - Decreto 5898 - Art. 458 Inciso XVI Item D"
				                STR0201 , ; //"SC - Seção III Art. 94 Inciso XVI Item C"
				                STR0202 , ; //"MA - Decreto 19.886/03, Inciso XVI Item C e D"
				                STR0207 , ; //"RJ - Decreto 27.427, Livro VIII, Art. 100, Inciso XVI Item 3 e 4"
				                STR0211 , ; //"PR - NPF 004/2002 Art. 93 Inciso XVI Item C e D"
				                STR0212 , ; //"PA - Convenio ICMS 85/01 - Clausula 86 Inciso XVI Item C e D"
				                STR0213 ,;  //"DF - Convenio ICMS 85/01 - Clausula 86 Inciso XVI Item C e D"
				                STR0214 }   //"CE - Convenio ICMS 85/01 - Clausula 86 Inciso XVI Item C e D"
				cDescRegra:= STR0108	+ CHR(10)	+ ;  //" AM - XVIII - Garantir que será utilizado com ECF, nos termos do disposto na Seção "
							 STR0109	+ CHR(10) 	+ ; //" I deste Capitulo, adotando as seguintes rotinas: "
							 STR0110 	+ CHR(10) 	+ ; //" d) o programa aplicativo fiscal deverá, ao liberar acesso à tela de registro "
							 STR0111 	+ CHR(10) 	+ ; //" de venda e ao enviar comando para abertura de documento no ECF, conferir o   "
							 STR0112 	+ CHR(10) 	+ ; //" número de fabricação do ECF conectado neste momento, com o número            "
							 STR0113 	+ CHR(10) 	+ ; //" criptografado no arquivo auxiliar mencionado na alínea “c” e impedir o       "
							 STR0114 	+ CHR(10) 	+ ; //" funcionamento do aplicativo caso não haja coincidência, exceto para as       "
							 STR0115 	+ CHR(10) 	+ ; //" funções de consulta "
							 STR0116	+ CHR(10) 	+ ; //"------------------------------------------------------------------------------"
							 STR0117    + CHR(10) 	+ ; //"ES - XVI - Grarantir que será utilizado com ECF, nos termos do disposto no    "
							 STR0118    + CHR(10) 	+ ; //" capítulo II, deste título, adotando as seguintes rotinas: (alterado pelo     "
							 STR0119	+ CHR(10) 	+ ; //" Decreto nº 1.555-R, de 17 de outubro de 2005. DOE: 18.10.2005                "
							 STR0120	+ CHR(10) 	+ ; //" d) iniciando-se o aplicativo, este deverá, ao liberar acesso à tela de 		"
							 STR0121	+ CHR(10) 	+ ; //" registro de venda e ao enviar comando para abertura de documento ao ECF,     "
							 STR0122	+ CHR(10) 	+ ; //" conferir o número de fabricação do equipamento, conectado neste momento, 	"
							 STR0123	+ CHR(10) 	+ ; //" com o número criptografado no arquivo auxiliar mencionado na alínea c e 		"
							 STR0124	+ CHR(10) 	+ ; //" impedir o funcionamento do aplicativo, caso não haja coincidência, exceto 	"
							 STR0125	+ CHR(10) 	+ ; //" para as funções de consulta; (alterado pelo decreto nº 1.555-R de 17 de 		"
							 STR0126 //" outubro de 2005. DOE: 18.10.2005 "

				cHelp     := STR0127 //'Número de série do ECF diferente'
			Endif
		Case nItem == 24
			If cEstCob $ "AM|MG"
				lExistExig 	:= .T.
				cEstados 	:= "AM|MG"
				aRegra 		:= {STR0128} //"GSEFAZ 0001/2006, capítulo V - Das Disposições relativas aos Contribuintes Usuários de ECF"
				cDescRegra  := 	STR0129 	+ CHR(10) 	+ ; //"§ 5º Aquelas pré-vendas geradas e não finalizadas com a respectiva 	"
								STR0130		+ CHR(10)	+ ; //"emissão do cupom fiscal deverão, ao final do dia, ser canceladas com   "
								STR0131 //"a emissão do cupom fiscal cancelamento no ECF."
		    	cHelp 		:= STR0132 //"Na emissão da Redução Z, é necessário cancelar todos os orçamentos pendentes."
		    EndIf
		// Exigencia da SEFAZ - AM. Nao existe legislcao para este tratamento.
		Case nItem == 25
			If cEstCob $ "AM"
				lExistExig 	:= .T.
				cEstados 	:= "AM"
				aRegra 		:= {}
				cDescRegra  := 	STR0133 //"Nao pode ser enviado o cupom nao-fisal vinculado para impressao de reserva"
				cHelp 		:= ""
		    EndIf
		// Exigencia da SEFAZ - AM. Nao existe legislcao para este tratamento. (Exigencia da fiscal no dia da homologação)
		Case nItem == 26
			If cEstCob $ "AM"
				lExistExig 	:= .T.
				cEstados 	:= "AM"
				aRegra 		:= {}
				cDescRegra  := 	STR0134 //"Realizar a abertura do caixa automaticamente."
				cHelp 		:= ""
		    EndIf
		// Liberacao para nao obrigatoriedade de ECF
		Case nItem == 27
				lExistExig 	:= .T.
				cEstados 	:= STR0135 //"Todos"
				aRegra	  := {	STR0136} //"Obrigatoriedade do uso de ECF por contribuinte que possua autorização para emissão de documentos fiscais por processamento eletrônico de dados - AIDF"
				cDescRegra:= STR0137 	+ CHR(10)	+ ;  //"Convênio ECF 01/98"
							 STR0138	+ CHR(10)	+ ;  //"Cláusula primeira Os estabelecimentos que exerçam a atividade de venda ou "
							 STR0139	+ CHR(10)	+ ;  //"revenda de mercadorias ou bens, ou de prestação de serviços em que o "
							 STR0140	+ CHR(10)	+ ;  //"adquirente ou tomador seja pessoa física ou jurídica não contribuinte do "
							 STR0141	+ CHR(10)	+ ;  //"imposto estadual, estão obrigados ao uso de equipamento emissor de Cupom "
							 STR0142	+ CHR(10)	+ ;  //"Fiscal - ECF."
							 STR0143	+ CHR(10)	+ ;  //"§ 2º Somente será permitida a emissão de documento fiscal por qualquer "
							 STR0144	+ CHR(10)	+ ;  //"outro meio, inclusive o manual, por razões de força maior ou caso fortuito, "
							 STR0145	+ CHR(10)	+ ;  //"tais como falta de energia elétrica, quebra ou furto do equipamento, e nas "
							 STR0146	+ CHR(10)	+ ;  //"condições previstas no Convênio SINIEF S/Nº de 15 de dezembro de 1970, "
							 STR0147	+ CHR(10)	+ ;  //"devendo o usuário anotar o motivo no livro Registro de Utilização de "
							 STR0148	+ CHR(10)	+ ;  //"Documentos Fiscais e Termos de Ocorrência (RUDFTO), modelo 6."
							 STR0149	+ CHR(10)	+ ;  //"De acordo com o parágrafo segundo, transcrito acima, somente será permitida "
							 STR0150	+ CHR(10)	+ ;  //"a emissão de documento fiscal por outro meio por razões de força maior ou "
							 STR0151	+ CHR(10)	+ ;  //"caso fortuito, tais como falta de energia, quebra ou furto do equipamento "
							 STR0152	+ CHR(10)	+ ;  //"e nas condições previstas no Convênio SINIEF sn/70, art. 50, transcritas "
							 STR0153	+ CHR(10)	+ ;  //"a seguir:"
							 STR0154	+ CHR(10)	+ ;  //"1- quando o adquirente esteja inscrito no cadastro e contribuintes, será "
							 STR0155	+ CHR(10)	+ ;  //"emitida nota fiscal modelo 1 ou 1A;"
							 STR0156	+ CHR(10)	+ ;  //"2 - operações realizadas por estabelecimento que realize venda de veículos "
							 STR0157	+ CHR(10)	+ ;  //"sujeitos a licenciamento por órgão oficial;"
							 STR0158	+ CHR(10)	+ ;  //"3 - operações realizadas fora do estabelecimento;"
							 STR0159	+ CHR(10)	+ ;  //"4 - operações realizadas por concessionárias ou permissionárias de "
							 STR0160	+ CHR(10)	+ ;  //"serviço público, relacionadas com o fornecimento de energia, fornecimento "
							 STR0161	+ CHR(10)	+ ;  //"de gás canalizado e distribuição de água;"
							 STR0162	+ CHR(10)	+ ;  //"5 - a critério das unidades federadas:"
							 STR0163	+ CHR(10)	+ ;  //"  a) às operações realizadas por contribuinte, pessoa natural ou jurídica, "
							 STR0164 	+ CHR(10)	+ ;  //"     com receita bruta anual de até R$ 120.000,00 (cento e vinte mil reais),"
							 STR0165	+ CHR(10)	+ ;  //"     sem estabelecimento fixo ou permanente, portando o seu estoque de "
							 STR0166	+ CHR(10)	+ ;  //"     mercadorias, com ou sem utilização de veículo, que exerça atividade "
							 STR0167	+ CHR(10)	+ ;  //"     comercial na condição de barraqueiro, ambulante, feirante, mascate, "
							 STR0168	+ CHR(10)	+ ;  //"     tenda e similares;"
							 STR0169	+ CHR(10)	+ ;  //"  b) contribuinte que utilize a Nota Fiscal, modelo 1 ou 1-A, emitida "
							 STR0170	+ CHR(10)	+ ;  //"     por sistema eletrônico de processamento de dados, nos termos de "
							 STR0171 //"    convênio específico sobre a matéria."
 
				cHelp     := STR0172 //'Liberacao para não obrigatoriedade de ECF proximo de expirar'

		Case nItem == 28
				lExistExig 	:= .T.
				cEstados 	:= STR0135 //"Todos"
				aRegra	  	:= {} 
				cDescRegra	:= STR0186 + " " +  Trim(STR(nDiaVenRec)) + " " + STR0187 + CHR(10) +;
							   STR0188	 	//"Para utilização de impressora não fscal no Recebimento de Títulos, o prazo expira em XX dias." 
											//. A exibição desta mensagem está configurada no parâmetro MV_LJDREC." 
				cHelp     	:= STR0186 + " " +  STR(nDiaVenRec) + " " + STR0187 + CHR(10) +;
							   STR0188	 	//"Para utilização de impressora não fscal no Recebimento de Títulos, o prazo expira em XX dias." 
											//. A exibição desta mensagem está configurada no parâmetro MV_LJDREC." 
		Case nItem == 29
			If cEstCob $ "CE"
				lExistExig:=.T.
				cEstados  :="CE"
				aRegra	  := {STR0189 } //"CE - cláusula 79 do Convênio 85/01"
				// "A empresa não obrigada à emissão do Mapa Resumo, a escrituraçao dos cupons fiscais emitidos"
				// " é feita diretamente no Livro Registro de Saída, devendo, na coluna Observações, ser lançado"
				// " o número do contador de redução Z."
				cDescRegra:= STR0190 + CHR(10) + STR0191 + CHR(10) + STR0192 
				cHelp     := ''
			Endif

		Case nItem == 30
			If (cEstCob $ "AL|SP|DF|MG|SE|PR|MA|RO|RJ|RS|GO|PA") .Or. (ExistFunc("LjInfDocCli") .And. LjInfDocCli() > 0)
						
				lExistExig:=.T.
				cEstados  :="AL|SP|DF|MG|SE|PR|MA|RO|RJ|RS|GO|PA"				
				aRegra	  := {STR0193 , ;	//"SP - Portaria CAT- 52, de 6-6-2007 e Portaria CAT-85, de 04 setembro de 2007"
							  STR0239 , ;	//"AL - Decreto Nº 4.074, de 13 novembro de 2008"
							  STR0252 ,	; 	// "DF - Lei Nº 4.159/08 (NOTA LEGAL)"							  
							  STR0312 , ;	// "SE - Portaria 365/2011 http://www.sefaz.se.gov.br/internet/index.jsp?arquivo=webcontrol/detalhesNoticia.jsp&cod=1394"
							  STR0313 , ;	// "MG - Itens 16 e 49 do manual ECF de MG - http://www.fazenda.mg.gov.br/empresas/ecf/manuais/cartilha_perg_resp.pdf"
							  STR0314 , ;	// "PR - Artigo 32, página 38 do documento NORMA DE PROCEDIMENTO FISCAL Nº 004/2002"
							  STR0315 , ;	// "MA - Lei 9.120/2010 - http://www.ma.gov.br/agencia/noticia.php?Id=18845"
							  STR0324 , ;	// "RO - Lei LEI N. 2.589, DE 28 DE OUTUBRO DE 2011. PUBLICADA NO DOE Nº 1848, DE 03.11.11"
							  STR0325 ,	;	// "RJ - DECRETO N.º 32250 DE 11 DE MAIO DE 2010. "
							  STR0328 , ; 	// "RS - INSTRUÇÃO NORMATIVA RE Nº 034/12 (DOE 07/05/2012) - http://www.legislacao.sefaz.rs.gov.br/Site/Document.aspx?inpKey=202380&inpCodDispositive=&inpDsKeywords="
							  STR0330 , ;	// "GO - ANEXO XI DO EQUIPAMENTO EMISSOR DE CUPOM FISCAL - http://www.sefaz.go.gov.br/lte/lte_ver_40_3_htm/rcte/anexos/ANEXO_11_ECF.htm"
							  STR0333 } 	// "PA - DECRETO Nº 490, DE 1º DE AGOSTO DE 2012 - http://www.sefa.pa.gov.br/LEGISLA/leg/estadual/ICMS/le07632_12.htm"

				// "Estabelece disciplina relativa ao Registro Eletrônico de Documento Fiscal - REDF e " - STR0194
				// " Dispõe sobre geração e guarda de arquivo digital por contribuinte usuário de equipamento Emissor de Cupom Fiscal - ECF" - STR0195
				cDescRegra:= STR0194 + CHR(10) + STR0195
				cHelp     := ''
			Endif

		Case nItem == 31
			If cEstCob $ "AL"
				lExistExig  :=.T.
				cEstados	:="AL"
				aRegra		:= {} 
				cDescRegra	:= STR0215             //"Verificacao da data/hora no registro do item."
				cHelp		:= ''
			EndIf
        //VERIFICA SE E NECESSARIO VALIDAR O CNPJ PARA VENDA NAO CONCOMITANTE
		Case nItem == 32
			If cEstCob $ "MG"
				lExistExig:=.T.
				cEstados  :="MG"
				aRegra	  := {STR0216 } //"MG - AUTORIZADO A VENDA NAO CONCOMITANTE
 				cDescRegra:= ""
				cHelp     := ''
			EndIf

		//Orcamento DAV
		Case nItem == 33
			If cEstCob $ "MG"
				lExistExig:=.T.
				cEstados  :="MG"
				aRegra	  := {STR0217 } //"MG - Anexo I da Portaria 18/05 - Emissao do DAV"
				// "Ao usuario de ECF-PDV ou ECF-IF interligado ao computador podera ser autorizado o uso de "
				// "equipamento impressor nao fiscal para impressao de DAV conforme modelo constante do Anexo I"
				// "da Portaria 18/05"
				cDescRegra:= STR0218 + CHR(10) + STR0219 + CHR(10) + STR0220
				cHelp     := ''
			EndIf
		
		//Impressao do Relatorio Gerencial recebimentos não fiscais
		Case nItem == 34
			If cEstCob $ "MG"
				lExistExig:=.T.
				cEstados  :="MG"
				aRegra	  := {}
				// "Após operação de recebimento nao fiscal, é necessário a impressão do Relatório Gerencial, "
				// "e não o CDC"
				cDescRegra:= STR0221 + CHR(10) + STR0222
				cHelp     := ''
			EndIf
		Case nItem == 35
			If cEstCob $ "AM|MG"
				lExistExig:=.T.
				cEstados  :="AM|MG"
				aRegra	  := {STR0223}	//MG - Portaria 18/2005 art 93 inciso XV
				
				// "Impedir o seu próprio uso sempre que o ECF estiver sem condições de emitir documento fiscal, ";
                // "exceto para funções de consultas, emissão de documento fiscal por sistema de  "
				// "Processamento Eletrônico de Dados (PED) e emissão de leituras fiscais"
				cDescRegra := STR0224 + CHR(10) + STR0225 + CHR(10) + STR0226
				cHelp      := STR0227 	//"Após a Redução Z não é possivel realizar operações com documento fiscal"
			EndIf
		
		    //Na pre venda nao e permitido impressao de orcamento
		Case nItem == 36
			If cEstCob $ "MG"
				lExistExig:=.T.
				cEstados  :="MG"
				aRegra	  := {STR0228}	//MG - Portaria 18/2005 art 1 inciso XIII
				cDescRegra := STR0229	// "Pré-venda a operação de registro, sem a impressão de documento que descreva os itens registrados"
				cHelp      := STR0230 	//"Na pré-venda não é permitido a impressão de orçamentos"
			EndIf
		Case nItem == 37
			If cEstCob $ "MG"
				lExistExig:=.T.
				cEstados  :="MG"
				aRegra	  := {}	//Não temos esta legislação 
				cDescRegra := ""	// /Não pode haver pulos no numero do orcamento
				cHelp      := ""
			EndIf
	    Case nItem == 38
			//
		Case nItem == 39
			//
	    Case nItem == 40
			//
	    Case nItem == 41
			//
		    
		    //Leitura X na primeira Abertura de Caixa no Dia
	    Case nItem == 42
			If cEstCob $ "AM/MG"
				lExistExig 	:= .T.
				cEstados 	:= cEstCob
				aRegra 		:= {STR0237}				//"É necessário a Emissão de uma Leitura X na primeira abertura do Caixa no dia."
				cDescRegra  := STR0237
		    	cHelp 		:= STR0238					//"Será emitida uma Leitura X."
		    EndIf

		Case nItem == 43
			If cEstCob $ "GO"
					lExistExig 	:= .T.
					cEstados 	:= "GO"
					aRegra 		:= {STR0240}				//"GO - Art. 183. Emitir nota fiscal abrangendo mais de um cupom fiscal"
					cDescRegra  := 	""
			    	cHelp 		:=  ""					
			    EndIf			    		    	
			    		    	
			    		    	
   		Case nItem == 44
			If cEstCob $ "SP"
				lExistExig:=.T.
				cEstados  :="SP"
				aRegra	  := {STR0241} //"SP - Mapa Resumo ANEXO 3 - Portaria CAT Nº 55/98"
				cDescRegra:= STR0241
				cHelp     := ''
			Endif


   		Case nItem == 45
			If cEstCob $ "GO"
				lExistExig:=.T.
				cEstados  :="GO"
				aRegra	  := {STR0242}	//"GO - DECRETO Nº 5.652, de 6 de Setembro de 2002, que aprova o Regulamento da Lei nº 13.998, de 13 de dezembro de 2001."
				cDescRegra:= STR0243	//"GO - Art. 126 para comercialização de vacinas para estabelecimento revendedor de produtos de uso veterinário fica obrigado a adotar subsérie distinta de nota fiscal para este produto." 
				cHelp     := ''
			Endif
						
		Case nItem == 46
			If (cEstCob $ "SC") .AND. (cCidCob $ "JOINVILLE")
				lExistExig:=.T.
				cEstados  :="SC"
				aRegra	  := {STR0244} //"SC(Joinville)- Decreto nº. 15.007, de 25 de novembro de 2008  "
				cDescRegra:= STR0244
				cHelp     := ''
			Endif
		Case nItem == 47
			If cEstCob $ "SP"
				lExistExig:=.T.
				cEstados  :="SP"
				aRegra	  := {STR0253} //"Lei Estadual nº 13.747, de 7 de outubro de 2009 do Governo do Estado de São Paulo"
				cDescRegra:= STR0253
				cHelp     := ''
			Endif			
		Case nItem == 48
			If cEStCob $ "RJ"
				lExistExig:=.T.  			
				cEstados  :="RJ"
				aRegra	  := {STR0254} // "DECRETO 42.084/2009 (DO-RJ DE 21-10-2009)"
									   //  "Art. 1.º O inciso XI do art. 50 do Livro VIII do Regulamento do ICMS (RICMS/00) aprovado pelo Decreto nº 27.427/00, de 17 de novembro de 2000 , passa a vigorar com a seguinte redação:" 
                                       //  "” Art. 50- ………………………………………………………………………………………."
                                       //  "XI - informações suplementares, se for o caso, impressas no máximo em 8 (oito) linhas, onde deverá constar:"
                                       //  "1 - o valor total do ICMS devido na operação ou prestação, isto é, o somatório dos valores do imposto incidente em cada item do Cupom Fiscal;"
                                       //  "2 - a expressão: ” VÁLIDO PARA O CUPOM MANIA “." 
                                       //  "Art. 2.º Fica acrescentado parágrafo único ao art. 50 do Livro VIII do RICMS/00 com a seguinte redação:"
                                       //  "” Art. 50 - ……………………………………………………………………………………" 
                                       //  "Parágrafo Único - A obrigatoriedade prevista no item 2 do inciso XI do caput deste artigo somente se aplica aos Cupons Fiscais emitidos por equipamento Emissor de Cupom Fiscal (ECF) com Memória de Fita-detalhe (MFD) ou pertencente a estabelecimento obrigado à transmissão do registro tipo 60 “I”: item do documento fiscal emitido pelo ECF, de acordo com legislação específica.”"
                                       //  "Art. 3.º Este Decreto entra em vigor na data da sua publicação, tendo seus efeitos plenos no prazo de 15 (quinze) dias, contado da data de sua publicação."
			    cDescRegra:= STR0255 + CHR(10) +  STR0256 + CHR(10) + STR0257 + CHR(10) + ;
			                 STR0258 + CHR(10) +  STR0259 + CHR(10) + STR0260 + CHR(10) + ;
			                 STR0261 + CHR(10) +  STR0262 + CHR(10) + STR0263
				cHelp     := '' 
			EndIf	
		Case nItem == 49
			If cEstCob $ "CE"
				lExistExig:=.T.
				cEstados  :="CE"
				aRegra	  := {STR0264} //"RICMS/CE -Decreto Estadual nº 24.569 de 31/07/1997 D.O.E.:04/08/1997"
				cDescRegra:= STR0265 + CHR(10) +; //"Art. 675. Nas operações com partes e peças substitiídas, em virtude de garantia, por frabricantes "
							 STR0266			// "ou por oficinas credenciadas ou autorizadas, observar-se as disposição desta subseção"
				cHelp     := ''
			Endif
		Case nItem == 50
			If cEstCob $ "BA"
				lExistExig:=.T.
				cEstados  :="BA"
				aRegra	  := {STR0267} 	//"RICMS/BA - Decreto Estadual nº 6.284 de 14/03/1997 D.O.E.: 16/06/1997"
				cDescRegra:= STR0268+;	//"Art 824-B. Os contribuites do ICMS que realizarem vendas de mercadorias ou prestação de "
							 STR0269+;	//"serviços a não contribuites desse imposto deverão utilizar equipamento Emissor de Cupom "
							 STR0270 	//"Fiscal (ECF) para documentar tais operações ou prestações."
				cHelp     := ''
			Endif			
		Case nItem == 51
			If IIF(!(SuperGetMv("MV_SPEDEND",,.F.)),cEstCob,SM0->M0_ESTENT) $ "SP" .And. !LjFTVD()
				lExistExig := 	.T.
				cEstados   := 	"SP"
				aRegra	   := 	{STR0271}  				//Decreto Nº 54.869, de 2 de outubro de 2009 do Estado de São Paulo
				cDescRegra := 	STR0272 + CHR(10) +;	//Introduz alterações no Regulamento do Imposto sobre Operações Relativas à Circulação de Mercadorias e sobre Prestações de Serviços de Transporte Interestadual e Intermunicipal e de Comunicação - RICMS
							  	STR0273 + CHR(10) +; 	//JOSÉ SERRA, GOVERNADOR DO ESTADO DE SÃO PAULO, no uso de suas atribuições legais, tendo em vista o disposto nos artigos 67, 68 e 69 da Lei 6.374, de 1º de março de 1989, Decreta:
								STR0274 + CHR(10) +; 	//Artigo 1º - Passam a vigorar com a redação que se segue os dispositivos adiante indicados do Regulamento do Imposto sobre Operações Relativas à Circulação de Mercadorias e sobre Prestações de Serviços de Transporte Interestadual e Intermunicipal e de Comunicação - RICMS, aprovado pelo Decreto 45.490, de 30 de novembro de 2000:
								STR0275 + CHR(10) +; 	//I - o § 3º do artigo 124:
								STR0276 + CHR(10) +; 	//"§ 3º - Os documentos referidos neste artigo, exceto os previstos nos incisos III, XXII, XXIII e XXV, obedecerão aos modelos contidos no Anexo/Modelos." (NR);
								STR0277 + CHR(10) +; 	//II - o "caput" do artigo 135, mantidos seus incisos:
								STR0278 + CHR(10) +; 	//"Artigo 135 - O Cupom Fiscal será emitido por meio de Equipamento Emissor de Cupom Fiscal - ECF, nas vendas à vista a pessoa natural ou jurídica não-contribuinte do imposto, em que a mercadoria for retirada ou consumida no próprio estabelecimento pelo comprador (Lei 6.374/89, art. 67, § 1º, Convenio SINIEF de 15-12-70, art. 50, na redação do Ajuste SINIEF-10/99):" (NR).
								STR0279 + CHR(10) +; 	//Artigo 2º - Ficam acrescentados os dispositivos adiante indicados ao Regulamento do Imposto sobre Operações Relativas à Circulação de Mercadorias e sobre Prestações de Serviços de Transporte Interestadual e Intermunicipal e de Comunicação - RICMS, aprovado pelo Decreto 45.490, de 30 de novembro de 2000, com a seguinte redação:
								STR0280 + CHR(10) +; 	//I - ao artigo 124, o inciso XXV:
								STR0281 + CHR(10) +; 	//XXV - Documento Auxiliar do Conhecimento de Transporte Eletrônico - DACTE (Ajuste SINIEF- 9/07)." (NR);
								STR0282 + CHR(10) +; 	//II - ao artigo 135, o § 7º:
								STR0283 + CHR(10) +; 	//"§ 7º - Fica vedada a emissão de Cupom Fiscal nas operações com valores superiores a R$ 10.000,00 (dez mil reais), hipótese em que deverá ser emitida Nota Fiscal, modelo 1 ou 1-A, ou Nota Fiscal Eletrônica - NF-e, modelo 55." (NR).
								STR0284 + CHR(10) +; 	//Artigo 3º - Este decreto entra em vigor na data de sua publicação, sendo que o inciso II do artigo 2º produz efeitos a partir de 1º dezembro de 2009.
								STR0285 + CHR(10) +; 	//Palácio dos Bandeirantes, 2 de outubro de 2009
								STR0286 			 	//JOSÉ SERRA
				cHelp     := 	STR0287 + CHR(10) +;	//Atingido o valor máximo do cupom fiscal: 10.000,00.
								STR0291 				//É necessário emitir uma Nota Fiscal modelo 1 ou 1-A, ou Nota Fiscal Eletrônica - NF-e, modelo 55.
			Endif		
		// Para o Estado de Santa Catarina no caso de NF sobre cupom deve se gravar os valores nas tabelas SD2 e SF2
		Case nItem == 52
			If cEstCob $ "SC"
				lExistExig:= .T.
				cEstados  := "SC"
				aRegra	  := {STR0296} 					//Decreto No 2.870, de 27 de Agosto de 2001 do Estado de Santa Catarina.
				cDescRegra:= STR0297 	+ CHR(10)	+ ; //Art. 123. As prerrogativas para uso de ECF não vedam a emissão de Nota Fiscal, modelo 1 ou 1-A, em função da natureza da operação.
				             STR0298 	+ CHR(10)	+ ; //§1  A operação de venda acobertada por nota fiscal deverá ser registrada no ECF, hipótese em que:  
							 STR0299	+ CHR(10) 	+ ; //I - serão anotados nas vias da nota fiscal emitida os números de ordem do Cupom Fiscal e do ECF;	
							 STR0300 	+ CHR(10) 	+ ; //II - serão indicados na coluna Observações do livro Registro de Saídas apenas o número e a série da nota fiscal;
							 STR0301 	+ CHR(10) 	+ ; //III - será o Cupom Fiscal anexado à via fixa da nota fiscal emitida.
							 STR0302                    //§2  O disposto no § 1º não se aplica às saídas de mercadorias em transferência, bem como às destinadas a contribuintes, mesmo em devolução.
				cHelp     := ''
			Endif		
	    // Para o Estado de Santa Catarina sera vedado o destaque do imposto ao emitir a Nota Fiscal Eletronica (NFe) ou o DANFE
		Case nItem == 53
			If cEstCob $ "SC"
				lExistExig:= .T.
				cEstados  := "SC"                                         	
				aRegra	  := {STR0303} 					//Decreto No 3.706/2010, produzindo efeitos desde 17/06/2010, fica regulamentada a utilização dos CFOPs 5.929 e 6.929 
				cDescRegra:= STR0304 	+ CHR(10)	+ ; //na emissao das notas fiscais pelo contribuinte obrigado ao uso do ECF, quando o adquirente da mercadoria for pessoa fisica ou juridica nao contribuinte do ICMS.
				             STR0305 	+ CHR(10)	+ ; //Art.67 do anexo 9 RICMS/SC  
							 STR0306	+ CHR(10) 	+ ; //I- a Nota Fiscal, a Nota Fiscal Eletronica (NF-e) ou o DANFE, quando for o caso, devera conter os numeros de ordem do Cupom Fiscal, do numero de fabricacao do ECF e o Codigo Fiscal de Operacoes e Prestacoes(CFOP) 5.929 ou 6.929, vedado o destaque do imposto;	
							 STR0307 	+ CHR(10) 	+ ; //II- o Cupom Fiscal devera ser anexado à via fixa da Nota Fiscal emitida ou a copia do DANFE quando for ocaso e, tratando-se de operacoes com combustiveis, lubrificantes e pecas de veiculos automotores, conterem a placa do veiculo;
							 STR0308					//Paragrafo unico -- A Nota Fiscal e a Nota Fiscal Eletronica(NF-e) emitidas nos termos deste artigo nao geram direito a credito do imposto.
				cHelp     := ''
			EndIf 
			
   		Case nItem == 54
			If cEstCob $ "GO"
				lExistExig:=.T.
				cEstados  :="GO"
				aRegra	  := {STR0309} //"GO - Mapa Resumo Art. 224 - Apêndice XVIII"
				cDescRegra:= STR0310 	+ CHR(10)	+ ; //"GO - DECRETO Nº 6.234, DE 31 DE AGOSTO DE 2005 (http://www.sefaz.go.gov.br/LTE/LTE_VER_40_3_htm/Decretos/D_06234.htm)."
							 STR0311					//"Art. 224. Com base na redução Z emitida pelo ECF, as operações ou prestações devem ser registradas, diariamente, em Mapa Resumo ECF, conforme modelo constante do Apêndice XVIII."
				cHelp     := ''
			Endif
			
		// Para o Estado de Santa Catarina quando configurado para emissao de DAV, somente deverá ser impresso em ECF via Relatorio Gerencial
		Case nItem == 55
			If cEstCob $ "SC"
				lExistExig:=.T.
				cEstados  :="SC"
				
				aRegra	  := {STR0316} //"De acordo com o parágrafo único do art. 29 do Anexo 9 do RICMS/SC, em Santa Catarina o DAV deve ser impresso no ECF."
				
				cDescRegra:= STR0316 //"De acordo com o parágrafo único do art. 29 do Anexo 9 do RICMS/SC, em Santa Catarina o DAV deve ser impresso no ECF."
				cHelp     := ''
			Endif			
			
		//Conforme o Anexo I, do Art. 1º do Ato COTEPE/ICMS 39/11, de 14 de setembro de 2011, Para o estado de Minas Gerais é obrigatório emitir no cupom fiscal dados referente ao programa MINAS LEGAL
		Case nItem == 56
			If cEstCob $ "MG"
				lExistExig :=.T.
				cEstados   :="MG"
				aRegra	   := {STR0317} //"Art. 1º O Anexo I do ATO COTEPE ICMS 6/08, de 14 de abril de 2008,fica acrescido do seguinte requisito:"
				cDescRegra := 	STR0318 + CHR(10) +; //"A critério da unidade federada, mediante parametrização, o PAF-ECF deve comandar a impressão no Cupom Fiscal de código composto por informações relativas ao respectivo Cupom Fiscal, observando-se que:"
							  	STR0319 + CHR(10) +; //"Para o PAF-ECF utilizado por estabelecimento situado no Estado de Minas Gerais o código deve ser precedido da expressão “MINAS LEGAL:” em caixa alta e deve obedecer ao formato 99999999999999espacoddmmaaaaespaco8888888, onde:"
								STR0320 + CHR(10) +; //"'99999999' representa o número do núcleo do CNPJ do contribuinte usuário do ECF, impresso no cabeçalho do Cupom Fiscal, considerando como núcleo do CNPJ os oito (8) primeiros dígitos que o compõe;"
								STR0321 + CHR(10) +; //"'ddmmaaaa' representa a data de emissão do Cupom Fiscal impressa em seu cabeçalho"
								STR0322 + CHR(10) +; //"'8888888' representa o valor total do respectivo Cupom Fiscal, sem as casas decimais (centavos) e sem zeros (0) à esquerda."
								STR0323  			 //"O código deve ser impresso na primeira linha disponível do campo 'mensagens promocionais', conforme o modelo de ECF, após a impressão das demais informações previstas nesta especificação."
				cHelp      := '' 
			EndIf
			
		//Decreto 43.437 de 25/01/2012 obriga todos os PAF-ECF dentro do estado do Rio de Janeiro estarem com a versão que atenda os requisitos da versão 01.09 do Ato Cotepe
		Case nItem == 57
			If cEstCob $ "RJ"
				lExistExig :=.T.
				cEstados   :="RJ"
				aRegra	   := {STR0326} //"Decreto 43.437 de 25/01/2012 obriga todos os PAF-ECF dentro do estado do Rio de Janeiro estarem com a versão que atenda os requisitos da versão 01.09 do Ato Cotepe"
				cDescRegra := STR0326	//"Decreto 43.437 de 25/01/2012 obriga todos os PAF-ECF dentro do estado do Rio de Janeiro estarem com a versão que atenda os requisitos da versão 01.09 do Ato Cotepe"
				cHelp      := '' 
			EndIf

		Case nItem == 58
			If cEstCob $ "RS|GO"
				lExistExig :=.T.
				cEstados   :="RS|GO" 
				aRegra	   := {	STR0238 ,	;	//"RS - ALTERAÇÃO INSTRUÇÃO NORMATIVA RE Nº 034/12 (DOE 07/05/2012) - http://www.legislacao.sefaz.rs.gov.br/Site/Document.aspx?inpKey=202380&inpCodDispositive=&inpDsKeywords="
								STR0330 	}   //"GO - ANEXO XI DO EQUIPAMENTO EMISSOR DE CUPOM FISCAL - http://www.sefaz.go.gov.br/lte/lte_ver_40_3_htm/rcte/anexos/ANEXO_11_ECF.htm"
				cDescRegra := 	STR0239 + CHR(10) +;	//"1. Define que o Cupom Fiscal que documentar operação de venda realizada por estabelecimento que promova operações de comércio atacadista e varejista deverá conter, também, o nome e o número de inscrição do destinatário no CNPJ ou no CPF. (Tít. I, Cap. XV, 4.3.1.1.2 e 4.3.1.6)"
								STR0331					//"Art. 179. O cupom fiscal a ser entregue ao consumidor final, qualquer que seja o seu valor deve conter, no mínimo, as seguintes indicações (Convênio ICMS 85/01, cláusula trigésima oitava): ...a) número do CNPJ ou do cadastro de pessoa física; b) nome ; c) endereço"
								
				cHelp      :=	STR0332		//"Impressão de CPF/CNPJ, Nome e Endereco do Cliente"
			EndIf

		Case nItem == 59
			If cEstCob $ "PB"
				lExistExig :=.T.
				cEstados   :="PB"
				aRegra	   := {STR0334} //"PB - Ato COTEPE/ICMS nº 51, de 17.10.2012 - DOU de 19.10.2012 - http://www.fazenda.gov.br/confaz/ "
				cDescRegra := STR0335	//"Para o PAF-ECF utilizado por estabelecimento situado no Estado da Paraíba, o código deve ser precedido da expressão 'PARAÍBA LEGAL - RECEITA CIDADÃ', em caixa alta, na primeira linha e, na segunda linha, 'TORPEDO PREMIADO:'"
				cHelp      := ''
			EndIf


   		Case nItem == 60
			If cEstCob $ "MG"
				lExistExig:=.T.
				cEstados  :="MG"
				aRegra	  := {STR0336} //"MG - Mapa Resumo Artigo 6º, Parte 1, Seção II, Anexo VI do RICMS/2002/MG"
				cDescRegra:= STR0336+STR0337 //#STR0336 -> "MG - Artigo 6º, Parte 1, Seção II, Anexo VI do RICMS/2002/MG" ##STR0337->", Dec. nº 46.101, de 11/12/2012. (http://www.fazenda.mg.gov.br/empresas/legislacao_tributaria/ricms_2002_seco/anexovi2002_3.htm#parte2)."
				cHelp     := ''
			Endif             

		Case nItem == 61
			If cEstCob $ "MA|AC|RS|MT|RN|SE|AM|PB|SP|RJ|RO|PR|DF|RR|PA|BA|PI|ES|CE|GO||AL|PE|MS|AP|TO|MG"
				lExistExig :=.T.

				If  SuperGetMv("MV_PAFNFCE",,.F.) //atenção, parametro utilizado somente internamente para poder simular ambiente PAF-NFCE com Sigamat AM (NFC-e)
					lExistExig :=.F.
				Endif  

				cEstados   := "MA|AC|RS|MT|RN|SE|AM|PB|SP|RJ|RO|PR|DF|RR|PA|BA|PI|ES|CE|AL|PE|MS|AP|TO|MG"
				aRegra	   := {	STR0355,; 	//"MA - Resolução Administrativa GABIN Nº 18 DE 02/05/2013"
								STR0339,;	//"AC - Decreto Estadual Nro. 5.257 de 18/02/2013"
								STR0356,; 	//"RS - INSTRUÇÃO NORMATIVA RE Nº 082/13"
								STR0338,;	//"MT - Decreto Estadual Nro. 1.657 de 11/03/2013"
								STR0342,;	//"RN - Portaria 036/2013 de 11/04/2013"
								STR0340,;	//"SE - Decreto Estadual Nro. 29.108 de 04/03/2013"
								STR0341,;	//"AM - Decreto Estadual 33.405 de 16/04/2013"
								STR0387,;	//"PB - Portaria 117/GSER publicada no DOE de 27.05.14"
								"SP - Previsto para a primeira quinzena de julho",;
								STR0388,;	//"RJ - Decreto N.º 44.785 de 12 de maio DE 2014"
								STR0391,;	//"RO - INSTRUÇÃO NORMATIVA Nº 003/2014/GAB/CRE"
								"PR - Em construção!",;
								STR0408,;	//"DF - Publicada no DODF nº 224, de 24/10/2014"}
								STR0417,;	//"RR - Portaria SEFAZ/GAB nº 768/2014"
								STR0418,;	//"PA - Instrução Normativa nº 28/2014"
								STR0445,;	//"PI - Decreto Nº15.581, Publicado no DOE Nº055 de 24/03/2014";
								STR0449,;	//"ES - PORTARIA N.º 01-R, DE 08 DE JANEIRO DE 2016" 
								STR0450,;	//"CE - DECRETO Nº31.922, de 11 de abril de 2016"
								STR0451,;	//"GO - DECRETO Nº 8.231, de 12 de Agosto de 2014"
								STR0452,;	//"AL - DECRETO Nº 43.606, DE 1º DE SETEMBRO DE 2015"
								STR0453,;	//"PE - PORTARIA SF Nº 180, DE 06.11.2014" 
								STR0454,; 	//"MS - DECRETO Nº 14.308, de 17 de novembro de 2015"
								STR0471,;	//"AP - DECRETO Nº 2970 DE 18.08.2016"
								STR0474,;	//"TO - Decreto Estadual 5.265, de 30.06.2015"
								STR0495 ;	//"MG - Decreto Nº 47.562, DE 14 DE DEZEMBRO DE 2018"
								}

				cDescRegra := "Aceita a Nota Fiscal Eletrônica para Consumidor Final – NFC-e - Modelo 65"	//"Aceita a Nota Fiscal Eletrônica para Consumidor Final – NFC-e"
				cHelp      := ''
			EndIf
			
		Case nItem == 62
			If cEstCob $ "DF"
				lExistExig	:=.T.
				cEstados	:=	"DF"
				aRegra		:= {STR0344} //"DF - Nota Legal: calculo do tributo a ser debitado por Cupom Fiscal"
				cDescRegra	:= STR0343 	//"DF - Nota Legal: calculo do tributo a ser debitado por Cupom Fiscal - http://www.fazenda.df.gov.br//aplicacoes/legislacao/legislacao/TelaSaidaDocumento.cfm?txtNumero=4159&txtAno=2008&txtTipo=5&txtParte=COMPILADO"}
				cHelp		:= ''
			EndIf
		
		Case nItem == 63
			If cEstCob $ "SC"
				lExistExig	:= .T.
				cEstados	:= "SC"
				aRegra		:= { STR0345  }	//"SC - Permitido Troco em Cartão - Ato Cotepe ICMS 28, de 30 de Maio de 2012 - http://www.fazenda.gov.br/confaz/confaz/atos/atos_cotepe/2012/AC028_12.htm"
				cDescRegra	:= 		STR0346 +;	//" a1) quando utilizado exclusivamente por estabelecimento enquadrado como minimercado, mercado, supermercado, "
									STR0347 +;	//" situado no Estado de Santa Catarina e cuja atividade seja o comércio varejista de mercadorias em geral, com "
									STR0348 +;	//" predominância de produtos alimentícios, admite-se, mediante parametrização, inacessível ao usuário, que o "
									STR0349 +;	//" valor a ser informado à empresa administradora de cartão de crédito ou débito seja superior em até R$ 10,00 (dez)"
									STR0350 +;	//" reais, hipótese em que o PAF-ECF deverá gerar as informações referentes ao totalizador de troco sempre "
									STR0351 +;	//" que o meio de pagamento for exclusivamente cartão de crédito ou débito e a administradora esteja informada "
									STR0352 +;	//" e identificada por seu CNPJ, no arquivo eletrônico a que se refere o item 17 do Requisito VII, "
									STR0353		//" conforme leiaute estabelecido no Anexo IV. "
				cHelp		:= "" 
			EndIf

		Case nItem == 64
			//Obrigatoriedade do PAF-ECF                    
			cAuxStr	:= "AL|AM|AP|CE|ES|MS|PB|PE|RN|RR|SC|"
						
			If (Date() >= Stod('20150101')) .And. (Date() < Stod('20150301')) //aaaammdd
				If cEstCob $ "RO|SE" .And. !lMsgPafEcf
					Alert(STR0413 +; //" De acordo com a Legislação deste estado, a partir de 1º de Janeiro de 2015 o Programa Aplicativo "
					STR0410 + CHR(13) + STR0411 +; //"Fiscal (PAF-ECF) se torna obrigatório. " #### "Efetue a adequação do sistema para continuar efetuando vendas." 
					CHR(13) + STR0412) //"Dúvidas entre em contato com o Suporte Protheus."
					
					lMsgPafEcf := .T.					
				EndIf
			EndIf
			
			If Date() >= Stod('20150301') //aaaammdd
				cAuxStr += "|RO|SE"
			EndIf                            
			   
			lFindEst := (cEstCob $ cAuxStr) 

			If lFindEst
				lExistExig	:= .T.
				cEstados	:= cAuxStr
				aRegra		:= {   STR0359 ,; //"Especificação dos requisitos que devem ser observados pelo Programa Aplicativo "
								   STR0360 }  //"Fiscal - Emissor de Cupom Fiscal (PAF-ECF) e pelo Sistema de Gestão (SG) - http://www1.fazenda.gov.br/confaz/confaz/atos/atos_cotepe/2008/AC006_08.htm"

				cDescRegra	:= 		STR0361 +;	//"ATO COTEPE/ICMS N° 6, DE 14 DE ABRIL DE 2008.  Publicado no DOU de 16.04.08."
								 	STR0362 +;	//"O Secretário Executivo do Conselho Nacional de Política Fazendária - CONFAZ, no uso de"
								 	STR0363 +;	//" suas atribuições que lhe confere o art. 12, XIII, do Regimento da Comissão Técnica Permanente do ICMS - COTEPE/ICMS, de 12 de dezembro de 1997, torna público que a Comissão, na sua 132ª reunião "
								 	STR0364 +;	//" ordinária, realizada nos dias 17 a 19 de março de 2008, em Brasília, DF, aprovou a especificação dos requisitos que devem ser observados pelo Programa Aplicativo Fiscal - Emissor de Cupom Fiscal (PAF-ECF)"
								 	STR0365 	//" e pelo Sistema de Gestão (SG), utilizados por estabelecimento usuário de equipamento Emissor de Cupom Fiscal (ECF)"
				cHelp		:= ""
			EndIf

		Case nItem == 65
			//Obrigatoriedade do envio do Relatório Gerencial de Identificação do PAF-ECF
			If cEstCob $ "MS|AL"
				lExistExig	:= .T.
				cEstados	:= "MS|AL"
				
				If cEstCob == "MS"

					aRegra		:= { STR0366  }	//"Mato Grosso do Sul - Entrega do Relatório Gerencial 'Identificação do PAF-ECF' - Diário Oficial n. 8.261 ,página 2, 24/agosto/2012 - http://ww1.imprensaoficial.ms.gov.br/pdf/DO8261_24_08_2012.pdf"
					cDescRegra	:=  STR0367 +;	//"Art. 7º Nas hipóteses de primeira instalação ou instalação de nova versão de PAF-ECF, a empresa desenvolvedora que tenha aplicativo regularmente registrado na UNICAC deve emitir,"
									STR0368 +;	//" relativamente a todos os ECFs de cada estabelecimento usuário, o Relatório Gerencial 'Identificação do PAF-ECF' do Menu Fiscal do PAF-ECF e apresentá-lo ao Fisco, via email,"
									STR0369		//" para o endereço eletrônico unicac@fazenda.ms.gov.br, em arquivo com a extensão 'pdf' contendo a imagem digitalizada."
				
				ElseIf cEstCob == "AL"
				
					aRegra		:= { STR0370 }	//"Alagoas - Entrega do Relatório Gerencial 'Identificação do PAF-ECF' - Instrução Normativa SEF nº 56/2011 - http://tol.sefaz.al.gov.br/tol/modules/documentos/retornaDocumentoLink.jsp?NUM_DOCUMENTO=56&NUM_ANO_DOCUMENTO=2011&COD_TIPDOC=IN&COD_SETOR=3"
					cDescRegra	:=  STR0371 +;	//" VII – o art. 9º-A, sob o título “Da Instalação e Desinstalação do PAF-ECF: Da Instalação e Desinstalação do PAF-ECF Art. 9º-A. A Empresa Desenvolvedora deverá emitir e apresentar à SEFAZ o Termo de Instalação ou Desinstalação "
									STR0372 +;	//"do PAF-ECF, conforme modelo constante no Anexo V, sempre que efetuar a primeira instalação, instalação de nova versão ou a desinstalação do PAF-ECF devidamente cadastrado na SEFAZ/AL."
									CHR(10)+CHR(13)+;
									STR0373	+;	//"§ 1º O termo de que trata o caput deste artigo deverá ser:"
									STR0374	+;	//"I - emitido em três vias, sendo uma destinada ao Fisco, outra ao contribuinte e outra ao arquivo da Empresa Desenvolvedora;"
									STR0375	+;	//"II - instruído com:"
									STR0376	+;	//"a) cópia da nota fiscal de aquisição do PAF-ECF, ou do contrato de licenciamento ou, ainda, do contrato de cessão de uso;"
									STR0377	+;	//"b) relatório gerencial denominado 'Identificação do PAF';"
									STR0378	+;	//"c) leitura X;"
									STR0379	+;	//"d) leitura da memória fiscal com as cinco últimas reduções, se for o caso;"
									STR0380	+;	//"e) cópia do livro Registro de Utilização de Documentos Fiscais e Termos de Ocorrências onde conste indicação, acompanhada de assinatura do usuário e da Empresa Desenvolvedora: da versão a ser utilizada, MD5 do principal arquivo executável e MD5 da relação dos arquivos executáveis, no caso de alteração da versão ou desinstalação;"
									STR0381		//"III – protocolado na repartição fiscal de seu domicílio em até 15 (quinze) dias da ocorrência, no caso de alteração da versão ou desinstalação."
				EndIf
				
				cHelp		:= STR0382	//"Efetue o envio do Relatório Gerencial de 'Identificação do PAF' e peça a liberação do CNPJ para Uso do PAF-ECF"
			EndIf			

		Case nItem == 66
			//Geração de documento fiscal no momento da venda para operações de entrega futura.
			If cEstCob $ "MG|RJ|CE|ES|RS|SC|SP"
				lExistExig	:= .T.
				cEstados	:= "MG|RJ|CE|ES|RS|SC|SP"
				aRegra		:= { STR0383 } //"Minas Gerais - Geração de documento fiscal no momento da venda para operações de entrega futura. - CAPÍTULO XL - Da Venda para Entrega Futura - http://www.fazenda.mg.gov.br/empresas/legislacao_tributaria/ricms/anexo_ix_12.htm"
				cDescRegra	:=  STR0384 +; //"Art. 322 - Nas vendas para entrega futura, poderá ser emitida nota fiscal sem destaque do ICMS, "
								STR0385 +; //"relativamente a todos os ECFs de cada estabelecimento usuário, o Relatório Gerencial 'Identificação do PAF-ECF' do Menu Fiscal do PAF-ECF e apresentá-lo ao Fisco, via email, "
								STR0386    //"com o imposto sendo debitado por ocasião da efetiva saída da mercadoria."
				cHelp		:= ""
			EndIf
		Case nItem == 67
			
			lExistExig := .F.
			
		Case nItem == 68
			If IIf(lMvSpedEnd, SM0->M0_ESTENT, cEstcob) $ "PB|"
				lExistExig	:= .T.
				cEstados := "PB"
				aRegra	 := { STR0396 }	//"PB - Obrigatoriedade do envio da tag <card> no arquivo da NFCe - Portaria 117/GSER publicada no DOE de 27.05.14" }
				cDescRegra := STR0397	//"Art. 1° § 7º Caso o pagamento seja efetuado com uso de cartão de crédito ou débito, "
				cDescRegra += STR0398	//"é obrigatório informar na Nota Fiscal de Consumidor Eletrônica (NFC-e) "
				cDescRegra += STR0399	//"o CNPJ da credenciadora e a bandeira da operadora do cartão e o número de autorização da operação, "
				cDescRegra += STR0400	//"por meio de Transferência Eletrônica de Fundos – TEF."
			Else
				lExistExig := .F.
			EndIf
		Case nItem == 69  
			//Geração de documento fiscal no momento da venda para operações de entrega futura.
			If cEstCob $ "MG|RJ"
				lExistExig	:= .T.
				cEstados	:= "MG|RJ"
				aRegra		:= { STR0401 } //"Minas Gerais - Dispoe que o estabelecimento que realiza operação de venda em virtude da exibição de mercadorias caracteriza-se como estabelecimento show-room (art. 350, §2º, Anexo IX do RICMS/MG). Neste sentido, as vendas decorrentes desses estabelecimentos deverão ser tratadas como venda para entrega futura."                                                                                                                                                                                                                                                                                                                                                                                                                    
				cDescRegra	:= STR0402 //" No ato da celebração do negócio (venda) realizada pela loja a mesma deverá emitir nota fiscal de simples faturamento, sem destaque do ICMS, para todas as operações de venda para entrega futura (artigo 305, §2º, Anexo IX do RICMS/MG)."                                                                                                                                              
				cDescRegra	+= STR0403	 //" Por ocasião da saída das mercadorias do CD, deverão ser emitidos os seguintes documentos fiscais (artigo 2º, §3º da IN DLT/SRE nº02/1998): "			 	
				cDescRegra	+= STR0404 //" 2) pelo “show-room” (loja), em nome do destinatário da mercadoria, com destaque do imposto."				 	
				cDescRegra	+= STR0405 //" 3) pelo estabelecimento CD, em nome do destinatário, para acompanhar o transporte da mercadoria, sem destaque do imposto como natureza da operação Remessa por conta de estabelecimento show-room"				 	
				cDescRegra	+= STR0406 //" 4) pelo estabelecimento CD, em nome do estabelecimento show-room, com destaque do imposto, se devido, indicando, como natureza da operação Transferência simbólica"					
																					
				cHelp		:= ""
			EndIf

	    //SAT CF-e
		Case nItem == 70      
            If cEstCob $ "SP|CE"
                lExistExig  := .T.
                cEstados    := "SP|CE"
                aRegra      := { "SP - Decreto nº 56.587, de 24/12/2010, Introduz alterações no Regulamento do Imposto sobre Operações Relativas à Circulação de Mercadorias e sobre Prestações de Serviços de Transporte Interestadual e Intermunicipal e de Comunicação - RICMS (CF-e-SAT)." }                                                                                                                                                                                                                                                                                                                                                                                                                     
                cDescRegra  := ""                                                                                                                                              
                cDescRegra  += ""                
                cDescRegra  += ""                 
                cDescRegra  += ""                   
                cDescRegra  += ""                  
                                                                                    
                cHelp       := ""
            EndIf

        Case nItem == 71
			If cEstCob $ "PE" .And. !LjFTVD()
				lExistExig	:= 	.T.
				cEstados  	:= 	"PE"
				aRegra	  	:= 	{STR0419}				//{"Decreto Nº 36.896, de 2 de Agosto de 2011 do Estado de Pernambuco"}
				cDescRegra	:= 	STR0420 + CHR(10) +; 	//"Introduz alterações na Consolidação da Legislação Tributária do Estado de Pernambuco, relativamente à saída de mercadoria para pessoa nãoinscrita no CACEPE." + CHR(10) +;
							  	STR0421 + CHR(10) +; 	//"O GOVERNADOR DO ESTADO, no uso das atribuições que lhe são conferidas pelo artigo 37, inciso IV, da Constituição Estadual, " + CHR(10) +;
								STR0422 + CHR(10) +; 	//"CONSIDERANDO a necessidade de promover ajustes nas condições e procedimentos relativos à saída demercadoria destinada à pessoa não-inscrita no CACEPE," + CHR(10) +;
								STR0423 + CHR(10) +; 	//"Art. 1º O Decreto nº 14.876, de 12 de março de 1991, passa a vigorar com as seguintes modificações: "  + CHR(10) +;
								STR0424 + CHR(10) +;	//"1. adquirir mercadoria em montante superior àqueles a seguir indicados, em cada período fiscal, "  + CHR(10) +;
								STR0425 + CHR(10) +;	//"relativamente à totalidade de remetentes, observando-se, quanto à dispensa de inscrição no CACEPE, "  + CHR(10) +;
								STR0426 + CHR(10) +;	//"o disposto em portaria da Secretaria da Fazenda: (REN/NR) "  + CHR(10) +;
								STR0427 				//"a partir de 1º de agosto de 2011, R$ 7.500,00 (sete mil e quinhentos reais)."		
				cHelp     := 	STR0428 + CHR(10) +;	//"Atingido o valor máximo do cupom fiscal: 7.500,00. "  + CHR(10) +;
								STR0429					//"necessário emitir uma Nota Fiscal modelo 1 ou 1-A, ou Nota Fiscal Eletrônica - NF-e, modelo 55. "											
			EndIf

		Case nItem == 72
			If cEstCob $ "SP"
				lExistExig	:= 	.T.
				cEstados  	:= 	"SP"
				aRegra	  	:= 	{STR0431}				//{"Lei 6.374/89, art. 67, § 1º, e Convênio 15-12-70 - SINIEF, art. 71, com alteração do Ajuste SINIEF-6/95, cláusula primeira, II, do estado de São Paulo"}
				cDescRegra	:= 	STR0432 + CHR(10) +; 	//"Artigo 215 - O livro Registro de Saídas, modelo 2 ou 2-A, destina-se à escrituração da saída de mercadoria, a qualquer título, ou da prestação de serviço ."
							  	STR0433 + CHR(10) +; 	//"5 - colunas sob os títulos "ICMS - Valores Fiscais" e "Operações ou Prestações sem Débito do Imposto."
								STR0434 + CHR(10) +; 	//"a) coluna "Isenta ou Não Tributada": o valor da operação ou prestação, deduzida a parcela do Imposto sobre Produtos Industrializados - IPI, se consignada no "
								STR0435 + CHR(10) +; 	//" documento fiscal, quando se tratar de mercadoria ou serviço cuja saída ou prestação tiver sido beneficiada com isenção ou amparada por não-incidência, bem como, ocorrendo a hipótese, o valor da parcela correspondente à redução da base de cálculo;" + CHR(10) +;
								STR0436 + CHR(10) +;	//"b) coluna "Outras": o valor da operação ou prestação, deduzida a parcela do IPI, se consignada no documento fiscal, quando se tratar de mercadoria ou serviço cuja saída ou prestação tiver sido efetivada sem lançamento do imposto, por ter sido atribuída a outra pessoa a responsabilidade pelo seu pagamento; "  + CHR(10) +;
								STR0437 + CHR(10) +;	//"7 - colunas sob os títulos "IPI - Valores Fiscais" e "Operações sem Débito do Imposto": "
								STR0438 + CHR(10) +;	//"a) coluna "Isenta ou Não Tributada": o valor da operação, quando se tratar de mercadoria cuja saída tiver sido beneficiada com isenção do IPI ou amparada por imunidade ou não-incidência, bem como, ocorrendo a hipótese, o valor da parcela correspondente à redução da base de cálculo "
								STR0439 				//"b) coluna 'Outras': o valor da operação, deduzida a parcela do IPI, se consignada no documento fiscal, quando se tratar de mercadoria cuja saída do estabelecimento tiver sido beneficiada com suspensão do recolhimento daquele imposto."																
			Endif

		Case nItem == 73
			If IIf(lMvSpedEnd, SM0->M0_ESTENT, cEstcob) $ "AM"
				lExistExig	:= 	.T.
				cEstados  	:= 	"AM"														
				aRegra	  	:= 	{STR0440}			//"RESOLUÇÃO Nº0006/2015 – GSEFAZ do AM"
				cDescRegra	:= 	STR0441	+ ;			//"Art. 3º Na hipótese de devolução de mercadoria em virtude de troca, inadimplemento do comprador ou desfazimento do negócio, o estabelecimento emissor de NFC-e que "  
								STR0442	+ CRLF + ; 	//"a receber de pessoa física ou jurídica considerada não contribuinte ou não obrigada à emissão de Nota Fiscal, deverá emitir NF-e modelo 55, para documentar a entrada."
								STR0443 + CRLF + ;	//"§ 1º A NF-e modelo 55 emitida para atender ao caput deste artigo deverá destacar:"			
								STR0444 			//"III - no campo Informações Adicionais de Interesse do Fisco - infAdFisco, informar o motivo da devolução, fazendo constar nome, endereço, número do CPF ou CNPJ do consumidor;"																
			EndIf

		Case nItem == 74
			If cEstCob $ "RS|RJ"
				lExistExig := .T.
				cEstados   := "RS|RJ"
				aRegra     := {STR0510,;		//"Lei nº 14.742/15 - Adicional de Alíquota do AMPARA/RS"
								STR0511 }		//"Lei nº 8.405/19 - Adicional de Alíquota do FECP/RJ"	
				If cEstCob = "RJ"
					cDescRegra := STR0512		//"FECP - Fundo Est. Combate a Pobreza - Lei Est. 8.405/19"
				Else		
					cDescRegra := STR0446		//"Adicional de alíquota do AMPARA/RS. Criado pela Lei nº 14.742/15"
				EndIf			
			EndIf

		Case nItem == 75
			If cEstCob $ "CE" .AND. AllTrim(SM0->M0_CNAE) == "4711301"
				lExistExig := .T.
				cEstados   := "CE"
				aRegra     :={"CE - Decreto nº 32.076 de 10 de Outubro de 2016."}
				cDescRegra := "Segundo Legislação, a obrigatoriedade do CPF/CNPJ é somente para o CNAE 4711-3/01 e também para contribuintes atacadistas usuários de ECF"
			EndIf
		
		/*
			Estados(UF) que não permitem emissão de NFC-e na modalidade Contingência Offline
		*/
		Case nItem == 76
			If IIf(lMvSpedEnd, SM0->M0_ESTENT, cEstcob) $ "SP"
				lExistExig	:= .T.
				cEstados	:= "SP"
				aRegra		:= {}
				cDescRegra	:= STR0465 	//"Contingência Offline não permitida. As contingências permitidas são: CF-e/SAT ou EPEC NFC-e."
				cHelp		:= STR0466	//"Utilize uma Estação configurada para emissão do CF-e SAT"
			EndIf
			
	    //MFE (SAT Ceará)
		Case nItem == 77      
            If cEstCob $ "CE"
                lExistExig  := .T.
                cEstados    := "CE"
                aRegra      := { "CE - DECRETO Nº 32.009 , de 05 de agosto de 2016, INSTITUI E DISCIPLINA O PROJETO PILOTO PARA UTILIZAÇÃO DO CUPOM FISCAL ELETRÔNICO (PP/CF-E), EMITIDO PELO MÓDULO FISCAL ELETRÔNICO (MFE)." }                                                                                                                                                                                                                                                                                                                                                                                                                     
                cDescRegra  := ""
                cHelp       := ""
            EndIf
		Case nItem == 78
            If IIf(lMvSpedEnd, SM0->M0_ESTENT, cEstcob) $ "PR"
                //De acordo com a Legislação deste estado, a partir de 3 de Abril de 2017                
                //A Receita Estadual solicita a imediata exclusão da expressão 
                //"Não permite aproveitamento de crédito de ICMS" do DANFE NFC-e, 
                //visto que já foi retirada a sua obrigatoriedade e, além disto, 
                //tem causado interpretação equivocada em relação ao Programa Nota Paraná.
                
                lExistExig  := .T.
                cEstados    := "PR"
                aRegra      := {}                                                                                                                                                                                                                                                                                                                                                                                                                     
                cDescRegra  := ""
                cHelp       := ""
            EndIf
            
        Case nItem == 79
            If IIf(lMvSpedEnd, SM0->M0_ESTENT, cEstcob) $ "RJ"
                cDescRegra := "	Nota Fiscal conjugada com Cupom Fiscal " + CHR(13) +;
                			  " A legislação de ECF prevê a possibilidade de emissão de NF-e, modelo 55, conjugada com Cupom " +;
                			  " Fiscal (CFOP 5.929) nas hipóteses em que legislação específica o exija ou por solicitação do " +;
                			  " adquirente (art. 52 do Livro VIII do RICMS/00)." + CHR(13) +;
                			  " Na NFC-e não há essa possibilidade. Nas operações com contribuintes, caso o adquirente solicite a" +; 
                			  " emissão de NF-e, modelo 55, imediatamente após a emissão da NFC-e, modelo 55, essa NFC-e" +;
                			  " deve ser cancelada. Caso a solicitação não ocorra imediatamente, não há previsão legal para emitir a NF-e, modelo 55, posteriormente." + CHR(13) + CHR(13)
               	cDescRegra	+= ' Legislação no link a seguir: ' + CHR(13)
               	cDescRegra	+= 'http://www.fazenda.rj.gov.br/sefaz/content/conn/UCMServer/path/Contribution%20Folders/site_fazenda/informacao/sistemaseletronicos/nfce/Preenchimento_NFC-e.pdf?lve'
                
                lExistExig  := .T.
                cEstados    := "RJ"
                aRegra      := {"RJ - Emissão de Nota Sobre Cupom para NFC-e - Não Permitido"}
                cHelp       := "Legislação não permite a geração de NOTA" 
            EndIf
        Case nItem == 80
			If cEstCob $ "RJ"
				lExistExig:=.T.
				cEstados  :="RJ"
				aRegra	  := {STR0475} //"RJ - Mapa Resumo Artigo 33º do Livro VIII do RICMS/00."
				cDescRegra:= STR0475+" (http://www.fazenda.rj.gov.br/sefaz/content/conn/UCMServer/uuid/dDocName%3A3448275)" //#STR0475 -> "RJ - Mapa Resumo Artigo 33º do Livro VIII do RICMS/00."
				cHelp     := ''
			Endif                   

		Case nItem == 81
			If cEstCob $ "DF"
				lExistExig:=.T.
				cEstados  :="DF"
				aRegra	  := {STR0476} //"DF - Mapa Resumo Art. 26."
				cDescRegra:= STR0476+" (http://www.fazenda.df.gov.br/aplicacoes/legislacao/legislacao/TelaSaidaDocumento.cfm?txtNumero=750&txtAno=1995&txtTipo=7&txtParte=.)" //#STR0476 -> "DF - Mapa Resumo Art. 26."
				cHelp     := ''
			Endif
		
		Case nItem == 82
			If cEstCob $ "MG|CE|SC|ES" .Or. !LJAnalisaLeg(64)[1]
				lExistExig	:= .T.
				cEstados	:= "MG|CE|SC|ES"
				aRegra		:= {STR0479} //"Não obrigatoriedade e/ou não existência do Envio de XML de Reduçao Z/Estoque pela SEFAZ deste Estado"
				cDescRegra	:= {;
								STR0477 + CRLF + ;	//"MG -Observar que em MG não existe transmissão de arquivos do PAF-ECF, consequentemente não existe a URL solicitada"
								STR0478 + CRLF + ; //"CE-O estado do Ceará não obriga o envio do XML da Redução Z das empresas que trabalham com ECF"
								STR0481 + CRLF + ;	//"SC - O Estado de Santa Catarina não obriga o envio do XML da Redução Z, essa desobrigação é avaliada pelo códigos da Classificação Nacional de Atividades Econômicas (CNAE)"
								STR0482} //"Estados aonde o PAF não é obrigatório, não considerar a obrigatoriedade do envio do XML, caso necessário ative o parâmetro MV_LJPENXM e as configuraçoes de WebService"
								
				cHelp		:= STR0480 //"Envio de XML desobrigado e/ou inexistência de URL de transmissão"
			EndIf

		Case nItem == 83
			If cEstCob $ "SP"
				lExistExig:=.T.
				cEstados  :="SP"
				aRegra	  := {STR0483} //"SP - COMUNICADO CAT Nº 52, de 15-10-2001"
				cDescRegra:= STR0484 + CRLF +;  //"1 - nos termos do artigo 135, § 2º do RICMS, aprovado pelo Decreto 45.490, de 30-11-00, além da regular emissão do cupom fiscal, é obrigatória a emissão da Nota Fiscal, modelo 1 ou 1-A, quando esse documento for solicitado pelo adquirente da mercadoria;"
				 			 STR0485 + CRLF +;  //"2 - essa Nota Fiscal deverá ser emitida com destaque de ICMS, se a operação for tributada, mas será escriturada no livro Registro de Saídas apenas na coluna 'Observações', conforme determinado no citado artigo;"
				 			 STR0486 + CRLF +;	//"3 - fica, portanto, sem efeito o Comunicado CAT-43, de 22-8-01."
				 			 STR0487			// " Fonte: http://www.normasbrasil.com.br/norma/comunicado-52-2001-sp_166524.html "
				
				cHelp     := STR0483 + CRLF + STR0487
			Endif				
          
        Case nItem == 84
          If cEstCob $ "PE|SP"
                lExistExig:=.T.
                cEstados  :="PE|SP"
                aRegra    := { STR0488 }        //"Manual da Nota Fiscal de Consumidor Eletrônica – NFC-e"
                cDescRegra:= STR0489 + CRLF +;  //"É vedada a emissão da NFC-e, nas operações com valor igual ou superior a R$ 200.000,00 (Duzentos mil reais), sendo obrigatória a emissão da NF-e."
                             STR0490            // "Fonte: https://www.sefaz.pe.gov.br/Servicos/Nota-Fiscal-de-Consumidor-Eletronica/PublishingImages/Paginas/Guias-e-Procedimentos/Manual%20da%20Nota%20Fiscal%20de%20Consumidor%20Eletr%C3%B4nica%20-%20vs%202.pdf"
                cHelp     := STR0488 + CRLF + cDescRegra
          EndIf

		Case nItem == 85      
            If cEstCob $ "PR"
                lExistExig  := .T.
                cEstados    := "PR"
                aRegra	  	:= {}		//Não temos esta legislação 
				cDescRegra 	:= ""
                cHelp       := ""
            EndIf
     	
		 Case nItem == 86 // Artigo 25 do Decreto 29.907/09 
		 	If cEstCob $ "CE"
                lExistExig  := .T.
                cEstados    := "CE"
                aRegra      := {STR0493}	//"Artigo 25 do Decreto 29.907/09 - Das devoluções de mercadorias"
                cDescRegra  := STR0494 		//"Art. 25. As devoluções de mercadorias cuja saída foi acobertada por documento fiscal emitido por ECF serão efetuadas por meio de nota fiscal de entrada, devendo ser emitida uma nota fiscal para cada documento fiscal a ser anulado durante o dia de funcionamento, exceto nos casos de cancelamento previsto no art.24;"
                cHelp       := ""
            EndIf
		

		Case nItem == 87  //Art. 5º O CF-e terá sua emissão vedada nas operações e prestações a seguir indicadas, hipóteses em que será emitida a Nota Fiscal Eletrônica (NF-e), modelo 55:
		 	If cEstCob $ "CE" // CE
				lExistExig  := .T. // CE
				aRegra      := {STR0501} 			// "Art. 5º O CF-e terá sua emissão vedada nas operações e prestações a seguir indicadas, hipóteses em que será emitida a Nota Fiscal Eletrônica (NF-e), modelo 55:"
				cDescRegra  := STR0502 + CRLF +;	// "I - operações com veículos sujeitos a licenciamento por órgão oficial;"
							   STR0503 + CRLF +;	// "II - operações com mercadorias e prestações de serviços em que o destinatário ou o tomador do serviço seja órgão da Administração Pública;"
							   STR0504				// "III - operações ou prestações com valor superior a R$ 10.000,00 (dez mil reais)."
                cHelp       := ""
            EndIf
		
		//Responsável Técnico
		Case nItem == 88
            If IIf(lMvSpedEnd, SM0->M0_ESTENT, cEstcob) $ cNFCERTC
				lExistExig  := .T.
				aRegra      := {STR0506} 			// "NT 2018.005 v1.20 conceito de responsabilização da emissão das notas fiscais. Trata-se do Responsável Técnico, a empresa responsável pela transmissão do documento para a Sefaz." 
				cDescRegra  := STR0507 + CRLF +;	// "Consideram-se responsável técnico empresas que são:"
							   STR0508 + CRLF +;	// "Desenvolvedora do sistema de emissão; ou"
							   STR0509				// "Empresa responsável tecnicamente pelo sistema de emissão."
                cHelp       := ""
            EndIf

		Case nItem == 89
				lExistExig 	:= .T.
				cEstados 	:= STR0135 //"Todos"
				aRegra	  	:= {} 

                cDescRegra := "	De acordo com a regra de validação da NF-e (794: NF-e com indicativo de NFC-e com Entrega a Domicílio)," +;
							  " não é permitida a emissão de NF-e referenciando uma operação de NFC-e com Entrega em Domicílio (tag:indPres=4)," +;
                			  " pois este tipo somente pode ser utilizado para NFC-e."

                cHelp       := "Legislação não permite NF-e com indicativo de NFC-e com Entrega a Domicílio"
		// Municipio Aquiraz - CE
		Case nItem == 90
			If (!Empty(aFilCodMun[1][2]) .AND. AllTrim(aFilCodMun[1][2]) == "2301000") .OR.;
				!Empty(aFilCodMun[2][2]) .AND. Upper(AllTrim(aFilCodMun[2][2])) == "AQUIRAZ"
				lExistExig  :=	.T.
				aRegra      :=	{STR0513}			// "Decreto Nº 88/2020, de 12 de dezembro de 2020 - Prefeitura de Aquiraz - CE" 
				cDescRegra  :=	STR0514 + CRLF +;	// "Seção VI - Das informações Necessárias ao RPS Parágrafo único." 
								STR0515 + CRLF +;	// "Caso o número do RPS seja impresso por meio de sistema informatizado do contribuinte, "
								STR0517 + CRLF +;	// "o formulário utilizado deverá conter número de controle impresso tipograficamente,"
								STR0514				// "em ordem crescente e sequencial, a partir do número 001 (um)."
                cHelp       := ""
			EndIf			
	EndCase

ElseIf cPaisLoc == "ARG"
	IF nItem == 27
			lExistExig 	:= .T.
			cEstados 	:= STR0135 //"Todos"
			aRegra	  := {	"Resolução Geral AFIP 1415/2003 – Artigo 12 – Inoperância da impressora fiscal na Venda Assistida" } //"Resolução Geral AFIP 1415/2003 – Artigo 12 – Inoperância da impressora fiscal na Venda Assistida"
			cDescRegra:= "Resol Gral AFIP 1415/2003 – Art. 12"													+ CHR(10)	+ ;  //"Resol Gral AFIP 1415/2003 – Art. 12"
						 "ARTUCULO 12.- La emisión de los comprobantes se efectuará."							+ CHR(10)	+ ;  //"ARTUCULO 12.- La emisión de los comprobantes se efectuará."
						 "a) Em forma manual (emisíon de comprobantes em forma manuscrita – talonario "			+ CHR(10)	+ ;  //"a) Em forma manual (emisíon de comprobantes em forma manuscrita – talonario "
						 "   de facturas o documentos equivalentes -, mediantes La utilización de "				+ CHR(10)	+ ;  //"   de facturas o documentos equivalentes -, mediantes La utilización de "
						 "   computadoras o Del equipamiento electrónico denominado “Controlador "				+ CHR(10)	+ ;  //"   computadoras o Del equipamiento electrónico denominado “Controlador "
						 "   Fiscal”, si se trata de documentos no fiscales homologados o documentos "			+ CHR(10)	+ ;  //"   Fiscal”, si se trata de documentos no fiscales homologados o documentos "
						 "   no fiscales)."																		+ CHR(10)	+ ;  //"   no fiscales)."
						 "b) Mediante La utilización de sistemas no manuales: "									+ CHR(10)	+ ;  //"b) Mediante La utilización de sistemas no manuales: "
						 "   1. Sistemas computarizados (autoimpresores), electromecánicos o mecánicos."		+ CHR(10)	+ ;  //"   1. Sistemas computarizados (autoimpresores), electromecánicos o mecánicos."
						 "   2. Equipamiento electrónico denominado “Controlador Fiscal”, si se trata "			+ CHR(10)	+ ;  //"   2. Equipamiento electrónico denominado “Controlador Fiscal”, si se trata "
						 "      de documentos fiscales."														+ CHR(10)	+ ;  //"      de documentos fiscales."
						 "El equipamiento electrónico denominado “Controlador Fiscal” a que se refieren "		+ CHR(10)	+ ;  //"El equipamiento electrónico denominado “Controlador Fiscal” a que se refieren "
						 "los incisos a) y b) precedentes, ES El que se encuentra regulado por La "				+ CHR(10)	+ ;  //"los incisos a) y b) precedentes, ES El que se encuentra regulado por La "
						 "Resolución General Nº 4.104 (DGI), texto substituído por La Resolución General "		+ CHR(10)	+ ;  //"Resolución General Nº 4.104 (DGI), texto substituído por La Resolución General "
						 "Nº 259, SUS modificatorias y complementarias. "										+ CHR(10)	+ ;  //"Nº 259, SUS modificatorias y complementarias. "
						 "Para La emisión Del comprobante podrá utilizarse, em forma complementaria o "			+ CHR(10)	+ ;  //"Para La emisión Del comprobante podrá utilizarse, em forma complementaria o "
						 "alternativa, sistemas manuales y computarizados."										+ CHR(10)	+ ;  //"alternativa, sistemas manuales y computarizados."
						 "Asimismo, se deberá tener comprobantes impresos por imprenta para su utilización "	+ CHR(10)	+ ;  //"Asimismo, se deberá tener comprobantes impresos por imprenta para su utilización "
						 "cuando se encuentre inoperante el sistema no manual de emisión."	                 					 //"cuando se encuentre inoperante el sistema no manual de emisión."
 
			cHelp     := STR0172 //'Liberacao para não obrigatoriedade de ECF proximo de expirar'
	EndIf
Endif	

aRet := {lExistExig, cEstados, aRegra, cDescRegra, cHelp}

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o	 |LJMsgLeg    ºAutor  ³  Vendas Clientes   º Data ³  29/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Tela da mensagem                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJMsgLeg( aLeg )

Local oDlgLeg							//Dialogo para mensagem de legistacao
Local oFntMsg							//varaivel que define o fonte a ser utilizado na mensagem 
Local oFntTit							//variavel que define o fonte do titulo da mensagem

// variaveis para o texto de detalhe
Local oMsgDet							//Objeto para mensagem detalhada
Local cMsgDet 	   := ''				//varaivel da mensagem detalhada
Local oBmp								//Imagem da tela de mensagem
Local lTelaDetalhe :=.F.				//Variavel que identifica se possui descricao detalhada
Local nX		   := 0	 				// controle de loop


If Type("lAutoExec") == "U"
	lAutoExec := .F.
EndIf

If !lAutoExec	// Para ExecAuto nao deve apresentar mensagem
	If Len(aLeg[3]) > 0
	
		cMsgDet:= STR0173+ aLeg[2] +Chr(10) //'Estados onde ocorre a exigência: '
		For nX :=1 to Len(aLeg[3])
			cMsgDet := cMsgDet + aLeg[3][nX] + Chr(10)
		Next nX
	
		cMsgDet := cMsgDet + Chr(10)
	Endif
	
	cMsgDet := cMsgDet + STR0174 + Chr(10) + '"' + aLeg[4] + '"' //'Regra:'
	
	DEFINE MSDIALOG oDlgLeg TITLE STR0175 FROM 0,0 TO 130,600 PIXEL //'Exigência Legal'
	
		DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
		DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15
		
		@ 0,0  BITMAP oBmp RESNAME STR0176 oF oDlgLeg SIZE 100,600 NOBORDER WHEN .F. PIXEL //"LOGIN"
		@05,50 TO 45,300 PROMPT STR0177 PIXEL //"AJUDA"
		@10,52 SAY aLeg[5] PIXEL SIZE 240,200 FONT oFntMsg
		
		
		@50,200 BUTTON STR0178 PIXEL ACTION oDlgLeg:End() //"Ok"
		@50,230 BUTTON STR0179 PIXEL ACTION If(	!lTelaDetalhe,; //"Detalhes"
													(oDlgLeg:ReadClientCoors(.T.),oDlgLeg:Move(oDlgLeg:nTop,oDlgLeg:nLeft,oDlgLeg:nWidth,oDlgLeg:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
													(oDlgLeg:ReadClientCoors(.T.),oDlgLeg:Move(oDlgLeg:nTop,oDlgLeg:nLeft,oDlgLeg:nWidth,oDlgLeg:nHeight-165,,.T.),lTelaDetalhe:=.F.))
														
		@ 67,50 TO 140,300 PROMPT STR0180 PIXEL //'Descrição da Regra'
		@ 73,52 GET oMsgDet VAR cMsgDet FONT oFntMsg MEMO size 245,65  PIXEL
		
	ACTIVATE MSDIALOG oDlgLeg CENTERED
EndIf

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ950RegraNF³ Autor ³ Mauricio Canalle    ³ Data ³ 19.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia as regras para permitir a impressao de NF na venda  ³±±
±±³          ³ assistida                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 = CNPJ da empresa                                    ³±±
±±³			 ³ lExp2 = Determina se esta liberado para emitir NF		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA701C                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K.³18/07/05³9.12  ³-Inclusao de um parametro na funcao         ³±±
±±³Marcelo K.³23/08/05³9.12  ³-Inclusao do nModulo do Gestao Hospitalar.  ³±±
±±³Marcelo K.³07/09/05³9.12  ³-Alteracao da funcao para o LOJA950.PRW     ³±±
±±³          ³        ³      ³uma funcao so pode ser alterada de um fonte ³±±
±±³          ³        ³      ³para outro se o nome da funcao tambem for   ³±±
±±³          ³        ³      ³alterado.                                   ³±±
±±³A.Veiga   ³17/11/05³9.12  ³Permite a emissao de NF sempre que o modulo ³±±
±±³          ³        ³      ³for o SIGAHSP (nmodulo = 51)                ³±±
±±³Henry F   ³27/11/05³9.12  ³Compatibilzacao fontes della via            ³±±
±±³Marcelo K.³08/08/06³9.12  ³-Inclusao do estado de RS para emissao de NF³±±
±±³          ³        ³      ³para pessoa Fisica e Juridica.              ³±±
±±³Machima   ³26/03/07³9.12  ³-Inclusao do parametro lLibEmiteNF          ³±±
±±³			 ³		  ³		 ³BOPS 122.210								  ³±±
±±³Conrado Q.³01/10/07³8.11  ³-Não apresenta aviso ao usuário quando for  ³±±
±±³          ³        ³      ³cliente padrão.                             ³±±
±±³			 ³		  ³		 ³BOPS 131.036								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj950RegraNF( cCnpj, lLibEmiteNF )

Local lRet    		:= .T.								// Retorno da funcao, determina se pode emitir NF
Local aArea   		:= GetArea()						// Salva a area atual
Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")  	// parametro que indica o CLIENTE PADRAO
Local cLojPad		:= SuperGetMV("MV_LOJAPAD",,"") 	// parametro que indica o LOJA PADRAO
Local cEstCob 		:= SM0->M0_ESTCOB					// Estado de cobranca do SIGAMAT.EMP porque e o estado onde o cliente Microsiga sera tributado.
Local lAutPFisica 	:= Lj950NfFis()						// Controla se pode alimentar array com os CNPJ que podem emitir Nota Fiscal para pessoa Fisica.
Local cNumCNPJ		:= Space(TamSX3("A1_CGC")[1]) 		//varivel para armazenar o retorno da funcao CGC

DEFAULT lLibEmiteNF  := .F.

If nModulo == 51
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando a rotina de Venda Assistida for executada do modulo SIGAHSP   ³
	//³ (Gestao Hospitalar) sempre permite a emissao de NF.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := .T.
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao Emite NF para cliente padrao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SA1->A1_COD == cCliPad) .AND. (SA1->A1_LOJA == cLojPad)
		lRet := .F.
		Msgstop(STR0470,STR0183) //#"Não é permitido emissão de NF para um Cliente Padrão" #"Atenção"
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Emite NF somente para Pessoa Juridica com CNPJ valido ³
		//³MG - RICMS Decreto n¦ 43.080/2002 Anexo VI - Parte 1  ³
		//³Art.15                                                ³
		//³A NF pode ser emitida somente pessoa juridica, dentro ³
		//³ou fora do estado.                                    ³
		//³                                                      ³
		//³SP - RICMS Art.251 Paragrafo 3 - A obrigatoriedade    ³
		//³prevista neste artigo nao se aplica a:                ³
		//³"que se utilize de Nota Fiscal por meio de processa-  ³
		//³mento eletronico de dados"                            ³
		//³                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A validacao tem que ser diferente de pessoa juridica sempre - nao pode ser = a "F" porque fragiliza o uso em campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (SA1->A1_PESSOA <> "J")
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o estado for diferente de Sao Paulo - bloqueia a impressao para pessoa Fisica.³
				//³Em SP e permitido porque temos uma consulta formalizada no SEFAZ-SP - 598/2005   ³
				//³desde que os cliente tenham AIDF para os formularios 1 e 1A.                     ³
				//³                                                                                 ³
				//³Para os demais estados as consultas foram feitas diretamente no site do SEFAZ    ³
				//³de cada estado.                                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  TRIM(cEstCob) == "SP" 																	.OR.;
					TRIM(cEstCob) == "BA" 																	.OR.;
					TRIM(cEstCob) == "RJ" 																	.OR.;
					TRIM(cEstCob) == "PR" 																	.OR.;
					TRIM(cEstCob) == "RS" 																	.OR.;
					TRIM(cEstCob) == "PE" 																	.OR.;
					lAutPFisica																				.OR.;
					Lj950CliEmis(cEstCob)
											
					lRet := .T.
				Else
					lRet := LjNfInterEst(SM0->M0_CGC , SA1->A1_EST , SA1->A1_PESSOA)
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for pessoa fisica valida se o CNPJ e valido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( SA1->A1_PESSOA == "J")
				If Empty( TRIM(SA1->A1_CGC) )
					Msgstop(STR0182,STR0183) //"Verifique o CNPJ do cadastro do cliente selecionado pois o mesmo está vazio"###"Atenção"
					lRet := .F.
				Else
					If !CGC(SA1->A1_CGC, @cNumCNPJ)
						Msgstop(STR0184,STR0183) //"Verifique o CNPJ do cadastro do cliente selecionado pois o mesmo não é válido"###"Atenção"
						lRet := .F.
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O modulo de Gestao Hospitalar nao esta no VAREJO por isso pode IMPRIMIR NF³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (nModulo == 51)
				lRet	:= .T.
		Endcase
	Endif
Endif

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj950Acres  ³ Autor ³ Andrea Farias       ³ Data ³ 23.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia os CNPJ's cadastrados para verificar se entra no    ³±±
±±³          ³ conceito de acrescimo financeiro separado do valor da venda³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 = CNPJ da empresa                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA701C                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³24/03/06³8.11  ³BOPS 93006- Adicionado CNPJ das filiais da  ³±±
±±³          ³        ³      ³empresa DADALTO.                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj950Acres( cCNPJ )

Local lRet	:= .F.         	//Retorno da funcao
Local aCNPJ	:= {}        	//Todos os CNPJ que utilizarao o recurso
Local nPos	:= 0          	//Posicao do CNPJ no array

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CNPJ's da empresa DADALTO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCNPJ,{'27179753001568'})
Aadd(aCNPJ,{'27179753000243'})
Aadd(aCNPJ,{'27179753000405'})
Aadd(aCNPJ,{'27179753001304'})
Aadd(aCNPJ,{'27179753001487'})
Aadd(aCNPJ,{'27179753001720'})
Aadd(aCNPJ,{'27179753001991'})
Aadd(aCNPJ,{'27179753002106'})
Aadd(aCNPJ,{'27179753003005'})
Aadd(aCNPJ,{'27179753003188'})
Aadd(aCNPJ,{'27179753003269'})
Aadd(aCNPJ,{'27179753000162'})
Aadd(aCNPJ,{'27179753000910'})
Aadd(aCNPJ,{'27179753002882'})
Aadd(aCNPJ,{'27179753002610'})
Aadd(aCNPJ,{'27463561000183'})
Aadd(aCNPJ,{'07080659000144'})
Aadd(aCNPJ,{'27334937000150'})
Aadd(aCNPJ,{'27179753001649'})
Aadd(aCNPJ,{'27179753001215'})
Aadd(aCNPJ,{'27179753000910'})
Aadd(aCNPJ,{'27179753002530'})
Aadd(aCNPJ,{'27179753003420'})
Aadd(aCNPJ,{'27179753003501'})
Aadd(aCNPJ,{'27179753000677'})
Aadd(aCNPJ,{'27179753000910'})
Aadd(aCNPJ,{'27334937000150'})
Aadd(aCNPJ,{'27334747000132'})
Aadd(aCNPJ,{'39810049000145'})
Aadd(aCNPJ,{'27406222000165'})
Aadd(aCNPJ,{'92775964000120'})
Aadd(aCNPJ,{'92775964000200'})
Aadd(aCNPJ,{'00387100163678'})
Aadd(aCNPJ,{'27334937000150'})
Aadd(aCNPJ,{'27179753003420'})
Aadd(aCNPJ,{'27179753001800'})
Aadd(aCNPJ,{'27179753003692'})
Aadd(aCNPJ,{'27179753000910'})
Aadd(aCNPJ,{'27179753003773'})
Aadd(aCNPJ,{'27179753003854'})
Aadd(aCNPJ,{'27179753004079'})
Aadd(aCNPJ,{'27179753004150'})
Aadd(aCNPJ,{'07080659000144'})
Aadd(aCNPJ,{'27179753000162'})
Aadd(aCNPJ,{'27179753000839'})
                                               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o CNPJ da filial corrente estiver em nossa lista, utiliza o recurso ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos:= Ascan(aCNPJ,{|x| x[1] == cCNPJ})
If nPos > 0
	lRet:= .T.
Endif
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950NfFis  ³ Autor ³ Vendas Clientes     ³ Data ³ 24.01.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao de emissao de NF para clientes Pessoa Fisica.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aExp1 = Array com os CNPJs autorizados.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA950                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj950NfFis()

Local aCNPJ		:= {}			// Array com os CNPJs
Local lRet		:= .F.      	//Define se libera emissao de NF
Local nPosCNPJ	:= 0        	//Posicao do CNPJ no array aCNPJ
Local cCNPJ    	:= SM0->M0_CGC  //CNPJ a ser validado
Local nMVLJLBNT := SuperGetMv("MV_LJLBNT",,0)//Habilita Finaliza Venda - Vide doc:http://tdn.totvs.com.br/display/PROT/TUXK67_DT_Disponibilizar_Emissao_Nota_Fiscal_Interestadual_Venda_Assistida

If nMVLJLBNT < 1

	AAdd( aCNPJ, {"00.778.553/0001-70" } ) 		//O Mestre Materiais de Construção Ltda. 
	AAdd( aCNPJ, {"00.778.553/0003-31" } ) 		//O Mestre Materiais de Construção Ltda. 
	AAdd( aCNPJ, {"05.557.910/0001-93" } ) 		//O Mestre Materiais de Construção Ltda. 
	AAdd( aCNPJ, {"22.351.415/0001-42" } ) 		//ORMIMAQ-ORG MINEIRA DE MAQUINAS LTDA   
	AAdd( aCNPJ, {"38.058.475/0001-01" } )     // KRISTA TECNOLOGIA LTDA
	               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA AGROPECUARIA UNAI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"25.834.847/0002-83"}  )
	AAdd( aCNPJ, {"25.834.847/0004-45"}  )
	AAdd( aCNPJ, {"25.834.847/0003-64"}  )
	AAdd( aCNPJ, {"25.834.847/0008-79"}  )
	AAdd( aCNPJ, {"25.834.847/0006-07"}  )
	AAdd( aCNPJ, {"25.834.847/0016-89"}  )
	AAdd( aCNPJ, {"25.834.847/0012-55"}  )
	AAdd( aCNPJ, {"25.834.847/0013-36"}  )
	AAdd( aCNPJ, {"25.834.847/0015-06"}  )
	AAdd( aCNPJ, {"25.834.847/0019-21"}  )
	AAdd( aCNPJ, {"38.058.475/0001-01"}  )	// KRISTA TECNOLOGIA LTDA 
	AAdd( aCNPJ, {"25.834.847/0021-46"}  )
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RUNNER ASSESSORIA EMPRESARIAL E PARTICIP	 		³					
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"04.145.844/0001-81" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.734.668/0001-86" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"04.631.468/0001-35" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.949.864/0001-78" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.702.490/0001-91" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.702.481/0001-09" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.938.853/0001-92" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.702.299/0001-40" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.924.206/0001-21" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.694.436/0001-41" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.590.343/0001-77" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.827.856/0001-59" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.924.206/0001-21" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.207.704/0001-89" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.050.047/0001-09" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.265.222/0001-85" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.671.892/0001-00" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.443.843/0001-01" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"08.661.940/0001-33" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.463.763/0001-92" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"08.319.582/0001-85" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"04.839.758/0001-15" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"00.074.927/0001-76" , CTOD("08/08/2010") }  )   
	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Razão Social: SAFRA - SAO FRANCISCO AF LTDA EPP	³					
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"70.313.051/0002-30"}  )
	AAdd( aCNPJ, {"70.313.051/0006-63"}  )
	AAdd( aCNPJ, {"70.313.051/0005-82"}  )
	AAdd( aCNPJ, {"70.313.051/0001-59"}  )
	AAdd( aCNPJ, {"70.313.051/0004-00"}  )  
	AAdd( aCNPJ, {"40.791.386/0001-11"}  ) //FUNERÁRIA SÃO FRANCISCO LTDA EPP                                        
	
	//Razão Social: FUNERARIA SAO FRANCISCO LTDA EPP
	AAdd( aCNPJ, {"40.791.386/0001.11"}  )
	AAdd( aCNPJ, {"40.791.386/0004-64"}  )
	
	
	//Razão Social: MORADA CEMITERIOS LTDA EPP  
	AAdd( aCNPJ, {"70.028.675/0001-24"}  )
	AAdd( aCNPJ, {"70.028.675/0003-96"}  )
	
	AAdd( aCNPJ, {"06.006.272/0001-85"}  ) //Razão Social: CENTRO FUNERARIO MORADA DA PAZ LTDA
	AAdd( aCNPJ, {"09.452.018/0001-07"}  ) //Razão Social: CAICO PLANO DE ASSISTENCIA FAMILIAR LTDA
	AAdd( aCNPJ, {"10.792.676/0001-19"}  ) //Razão Social: S. F. I. SERVICO FUNERARIO INTEGRAL LTDA
	AAdd( aCNPJ, {"04.689.302/0001-70"}  ) //Razão Social: ODONTOTAL CLINICA ODONTOLIGICA LTDA
	AAdd( aCNPJ, {"03.246.724/0001-08"}  ) //Razão Social: MULTIFAM CLINICA MEDICA LTDA EPP
	AAdd( aCNPJ, {"03.246.724/0002-99"}  ) //Razão Social: MULTIFAM CLINICA MEDICA LTDA EPP
	AAdd( aCNPJ, {"08.726.760/0001-92"}  ) //Razão Social: PARAIBA PLANO DE ASSIS. FAMILIAR LTDA
	AAdd( aCNPJ, {"08.726.760/0002-73"}  ) //Razão Social: PARAIBA PLANO DE ASS. FAMILIAR LTDA
	AAdd( aCNPJ, {"08.968.665/0001-03"}  ) //Razão Social: SAO FRANCISCO SERVICOS FUNERARIOS LTDA  
	AAdd( aCNPJ, {"07.139.718/0001-02"}  ) 	//Razão Social: FUNERARIA MORADA DA PAZ LTDA 
	AAdd( aCNPJ, {"70.028.675/0002-05"}  )	//Razão Social: MORADA CEMITERIOS LTDA EPP
	AAdd( aCNPJ, {"04.811.849/0001-04"}  )	//Razão Social: SERPOS SERVICOS POSTUMOS LTDA 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Locagyn máquinas e equipamentos Ltda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"01.570.529/0001-03"}  )			
	AAdd( aCNPJ, {"01.570.529/0003-75"}  )      
	AAdd( aCNPJ, {"01.570.529/0002-94"}  )			
	AAdd( aCNPJ, {"01.570.529/0004-56"}  )  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DALLAS RENT A CAR LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"00.470.111/0004-04" } )			
	AAdd( aCNPJ, {"00.470.111/0006-76" } )    
	AAdd( aCNPJ, {"00.470.111/0008-38" } )			
	AAdd( aCNPJ, {"00.470.111/0009-19" } )    
	AAdd( aCNPJ, {"00.470.111/0010-52" } )			
	AAdd( aCNPJ, {"00.470.111/0011-33" } )    
	AAdd( aCNPJ, {"00.470.111/0012-14" } )			
	AAdd( aCNPJ, {"00.470.111/0014-86" } )    
	AAdd( aCNPJ, {"00.470.111/0015-67" } )			
	AAdd( aCNPJ, {"00.470.111/0017-29" } )    
	AAdd( aCNPJ, {"00.470.111/0018-00" } )			
	AAdd( aCNPJ, {"00.470.111/0019-90" } )    
	AAdd( aCNPJ, {"00.470.111/0020-24" } )			
	AAdd( aCNPJ, {"00.470.111/0023-77" } )    
	AAdd( aCNPJ, {"00.470.111/0026-10" } )			
	AAdd( aCNPJ, {"00.470.111/0027-09" } )    
	AAdd( aCNPJ, {"00.470.111/0028-81" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BRC AUTOMÓVEIS DE ALUGUEL LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, {"07.185.183/0001-06" } )  
	AAdd( aCNPJ, {"07.185.183/0002-97" } )			
	AAdd( aCNPJ, {"07.185.183/0003-78" } )    
	AAdd( aCNPJ, {"07.185.183/0004-59" } )			
	AAdd( aCNPJ, {"07.185.183/0005-30" } )    
	AAdd( aCNPJ, {"07.185.183/0006-10" } )
	AAdd( aCNPJ, {"07.185.183/0007-00" } )
	AAdd( aCNPJ, {"07.185.183/0008-82" } )    
	AAdd( aCNPJ, {"07.185.183/0009-63" } )			
	AAdd( aCNPJ, {"07.185.183/0010-05" } )
	AAdd( aCNPJ, {"07.185.183/0011-88" } )     
	AAdd( aCNPJ, {"00.470.111/0011-88" } )
	AAdd( aCNPJ, {"00.470.111/0009-63" } )			
	    
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DISTRIBUIDORA DE PECAS AUTOMOTIVAS DB LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	
	AAdd( aCNPJ, {"04.315.899/0002-73" } )
	AAdd( aCNPJ, {"04.315.899/0003-54" } )			
	AAdd( aCNPJ, {"04.315.899/0001-92" } )    
	AAdd( aCNPJ, {"11.139.947/0001-02" } )			
	AAdd( aCNPJ, {"08.396.963/0001-68" } )      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA  AGROPECUARIA CENTRO SERRANA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"27.942.085/0006-98" } )    
	AAdd( aCNPJ, {"27.942.085/0014-06" } )    
	AAdd( aCNPJ, {"27.942.085/0020-46" } )    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GUAIAPO ELETRODOMESTICOS LTDA.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"00.963.257/0013-82", CTOD("02/05/2011") })			// GUAIAPÓ ELETRODOMESTICOS LTDA
	AAdd( aCNPJ, {"08.908.749/0001-43", CTOD("07/12/2011") })			// GUAPORÉ ELETROMÓVEIS LTDA
	AAdd( aCNPJ, {"08.908.749/0002-24", CTOD("22/05/2012") })			// GUAPORÉ ELETROMÓVEIS LTDA
	  
	// BARRELA RECAUCHUTAGEM DE PNEUS LTDA
	AAdd( aCNPJ, {"56.354.897/0003-78" } )
	
	//--------------------------------------+
	//|DELLA VIA PNEUS LTDA                 |
	//--------------------------------------+
	AAdd( aCNPJ, {"60.957.784/0056-46" } )
	AAdd( aCNPJ, {"60.957.784/0064-56" } )
	AAdd( aCNPJ, {"60.957.784/0066-18" } )
	AAdd( aCNPJ, {"60.957.784/0067-07" } )
	AAdd( aCNPJ, {"60.957.784/0051-31" } )  
	AAdd( aCNPJ, {"60.957.784/0070-02" } )                       
	AAdd( aCNPJ, {"60.957.784/0069-60" } )
	AAdd( aCNPJ, {"60.957.784/0071-85" } )  
	AAdd( aCNPJ, {"60.957.784/0072-66" } )                       
	AAdd( aCNPJ, {"60.957.784/0073-47" } )  
	AAdd( aCNPJ, {"60.957.784/0074-28" } )
	AAdd( aCNPJ, {"60.957.784/0075-09" } )
	AAdd( aCNPJ, {"60.957.784/0077-70" } )
	AAdd( aCNPJ, {"60.957.784/0080-76" } )
	AAdd( aCNPJ, {"60.957.784/0061-03" } )
	AAdd( aCNPJ, {"60.957.784/0092-00" } )
	AAdd( aCNPJ, {"60.957.784/0093-90" } )
	AAdd( aCNPJ, {"60.957.784/0093-90" } )
	AAdd( aCNPJ, {"60.957.784/0089-04" } )
	AAdd( aCNPJ, {"60.957.784/0094-71" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CURINGA DOS PNEUS LTDA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"00.041.327/0053-32" } )
	AAdd( aCNPJ, {"00.041.327/0043-60" } )
	AAdd( aCNPJ, {"00.041.327/0049-56" } ) 
	AAdd( aCNPJ, {"04.843.999/0002-72" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SEMPRE CENTRAL DE VELORIOS E FUNERARIAS LTDA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"12.773.805/0001-57" } )
	AAdd( aCNPJ, {"12.773.805/0002-38" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DISTRIBUIDORA DE PECAS KAMPEAO LTDA			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"38.060.430/0001-71" } )
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|2C COMERCIO E IMPORTACAO DE PRESENTES FINOS LTDA
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"50.588.409/0004-91"} )
	AAdd( aCNPJ, {"50.588.409/0005-72"} )
	AAdd( aCNPJ, {"50.588.409/0006-53"} )
	AAdd( aCNPJ, {"50.588.409/0007-34"} )
	AAdd( aCNPJ, {"50.588.409/0008-15"} )
	AAdd( aCNPJ, {"50.588.409/0009-04"} )
	AAdd( aCNPJ, {"50.588.409/0010-30"} )
	
	//BULGARI
	AAdd( aCNPJ, {"14.863.735/0001-53"} ) //UF: SP
	
	//CASA J NAKAO LTDA
	AAdd( aCNPJ, {"53.794.996/0004-63"} ) //UF: SP
	AAdd( aCNPJ, {"53.794.996/0001-10"} ) //UF: SP
	AAdd( aCNPJ, {"53.794.996/0003-82"} ) //UF: SP
	
	//AGUILERA AUTOPEÇAS LTDA - MT 
	AAdd( aCNPJ, { "37.525.771/0001-02" } )
	AAdd( aCNPJ, { "37.525.771/0002-93" } )
	AAdd( aCNPJ, { "37.525.771/0003-74" } )
	AAdd( aCNPJ, { "37.525.771/0004-55" } )
	AAdd( aCNPJ, { "37.525.771/0005-36" } )
	AAdd( aCNPJ, { "37.525.771/0006-17" } )
	AAdd( aCNPJ, { "37.525.771/0007-06" } )
	AAdd( aCNPJ, { "37.525.771/0008-89" } )
	AAdd( aCNPJ, { "37.525.771/0009-60" } )
	AAdd( aCNPJ, { "37.525.771/0010-01" } )
	AAdd( aCNPJ, { "37.525.771/0011-84" } )
	AAdd( aCNPJ, { "37.525.771/0012-65" } )
	AAdd( aCNPJ, { "37.525.771/0013-46" } )
	AAdd( aCNPJ, { "37.525.771/0014-27" } )
	AAdd( aCNPJ, { "37.525.771/0015-08" } )
	AAdd( aCNPJ, { "37.525.771/0016-99" } )
	AAdd( aCNPJ, { "37.525.771/0017-70" } )
	AAdd( aCNPJ, { "37.525.771/0018-50" } )
	AAdd( aCNPJ, { "37.525.771/0019-31" } )
	AAdd( aCNPJ, { "37.525.771/0020-75" } )
	AAdd( aCNPJ, { "37.525.771/0021-56" } )
	AAdd( aCNPJ, { "37.525.771/0022-37" } )
	AAdd( aCNPJ, { "37.525.771/0023-18" } )
	AAdd( aCNPJ, { "37.525.771/0024-07" } )
	
	AAdd( aCNPJ, { "07.270.160/0001-08" } ) //COMERCIO DE PEÇAS VERDE LUCAS LTDA - MT - FILIAL 
	AAdd( aCNPJ, { "11.615.634/0001-75" } ) //COMÉRCIO DE PEÇAS GLOBAL LTDA - MT - FILIAL
	AAdd( aCNPJ, { "13.448.434/0001-09" } ) //COMERCIO DE AUTOPEÇAS COLIDER LTDA - MT - FILIAL
	
	//SHOW DE TELHAS / LEMI IND. COM. DE COIFA
	AAdd( aCNPJ, { "06.056.395/0001-20" } )
	AAdd( aCNPJ, { "06.211.343/0001-81" } )
	AAdd( aCNPJ, { "13.312.706/0001-30" } )
	
	//FATTU DO BRASIL COMERCIO DE MATERIAIS DE COMUNICACAO VISUAL LTDA
	AAdd( aCNPJ, { "11.460.665/0001-02" } )
	AAdd( aCNPJ, { "11.460.665/0002-85" } )
	AAdd( aCNPJ, { "11.460.665/0003-66" } )
	AAdd( aCNPJ, { "11.460.665/0004-47" } )
	AAdd( aCNPJ, { "11.449.801/0001-55" } )
	                                   
	//CD-MAX
	AAdd( aCNPJ, { "00.777.674/0008-73" } )	
	AAdd( aCNPJ, { "00.777.674/0009-54" } )	
	AAdd( aCNPJ, { "00.777.674/0002-88" } )	
	AAdd( aCNPJ, { "01.396.282/0001-50" } )	
	
	//PLASTIREAL INDUSTRIA E COMERCIO DE PLASTICOS LTDA
	AAdd( aCNPJ, { "53.234.274/0001-01" } )	
	
	//MTI EXP E REP LTDA
	AAdd( aCNPJ, { "04.326.492/0001-60" } )
	AAdd( aCNPJ, { "04.326.492/0008-37" } )
	AAdd( aCNPJ, { "04.326.492/0024-57" } )
	AAdd( aCNPJ, { "04.326.492/0006-75" } )
	
	//Schirmann
	AAdd( aCNPJ, { "88.579.701/0001-78" } )
	
	//Comando Auto Peças Ltda.
	AAdd( aCNPJ, { "01.032.275/0001-70" } )
	AAdd( aCNPJ, { "01.032.275/0002-50" } )
	AAdd( aCNPJ, { "01.032.275/0004-12" } )
	AAdd( aCNPJ, { "01.032.275/0003-31" } )
	AAdd( aCNPJ, { "01.032.275/0005-01" } )
	AAdd( aCNPJ, { "01.032.275/0006-84" } )
	AAdd( aCNPJ, { "01.032.275/0007-65" } )
	AAdd( aCNPJ, { "01.032.275/0008-46" } )
	
	//Direção Produtos Automotivos Ltda.
	AAdd( aCNPJ, { "08.184.963/0001-02" } )
	AAdd( aCNPJ, { "08.184.963/0002-85" } )
	AAdd( aCNPJ, { "08.184.963/0003-66" } )
	
	//Distribuidora de Peças Kampeão Ltda.
	AAdd( aCNPJ, { "38.060.430/0001-71" } )
	AAdd( aCNPJ, { "38.060.430/0002-52" } )
	
	//Contagem Motor Peças
	AAdd( aCNPJ, { "02.633.281/0001-45" } )
	AAdd( aCNPJ, { "10.418.748/0001-62" } )
	AAdd( aCNPJ, { "19.446.980/0001-89" } )
	
	//Cooper Sucesso
	AAdd( aCNPJ, { "08.112.721/0003-67" } )
	
	//RICCIERI CONFECCOES LTDA
	AAdd( aCNPJ, { "75.456.764/0006-08" } )
	AAdd( aCNPJ, { "75.456.764/0007-80" } )

	//Moderna Auto Pecas
	AAdd( aCNPJ, { "00.679.038/0001-32" } )


	nPosCNPJ := Ascan( aCNPJ, { |x| x[1] == Transform( cCNPJ, PesqPict("SA1","A1_CGC") ) } )
	If nPosCNPJ > 0
	    If Len(aCNPJ[nPosCNPJ]) == 1
		   lRet := .T.						//O CNPJ pode imprimir NF no varejo
		Else
		   If DTOS(dDatabase) <= DTOS(aCNPJ[nPosCNPJ][2])			
		      If (aCNPJ[nPosCNPJ][2] - dDatabase) < SuperGetMV("MV_LJDMNF", ,60)
			  	LJMsgLeg(LJAnalisaLeg(27, ""))
			  EndIf
			  lRet := .T.				
		   Else
		      lRet := .F.	  
		   EndIf          	       
		EndIf
	Else
		lRet := .F.				//O CNPJ nao pode imprimir NF no varejo	
	Endif

Else
	lRet := .T.
EndIf	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950CliEmis³ Autor ³ Vendas Clientes     ³ Data ³ 31.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao de emissao de NF para clientes Pessoa Fisica.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet -> Emite ou Nao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA950                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950CliEmis(cEstCob , lFimVend)

Local lRet		:= .F.		// Retorno da funcao
Local nPosProd	:= 0		// Posicao no aHeader do campo Produto na interface de Venda Assistida 
Local nX		:= 0    	// Variavel utilizada no For
Local nMVLJLBNT	:= SuperGetMV("MV_LJLBNT",,0)	//Habilita Emissao de NF 0-mantem o legado, 1-Juridico e 2-Fisica e Juridica
Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")  	// parametro que indica o CLIENTE PADRAO
Local cLojPad		:= SuperGetMV("MV_LOJAPAD",,"") 	// parametro que indica o LOJA PADRAO


DEFAULT cEstCob := ""
DEFAULT lFimVend:= .F.

If (SA1->A1_COD == cCliPad) .AND. (SA1->A1_LOJA == cLojPad)
	lRet := .F.
	//Não permite emissão de nota Fiscal para cliente padrão
Else
	//Se for 2, libera para Pessoa FISICA e Juridica
	If nMVLJLBNT < 2
			If lFimVend
				nPosProd := aScan( aHeader,{|z| Alltrim(Upper(z[2]))=="LR_PRODUTO" }) // Posicao no aHeader do campo Produto na interface de Venda Assistida 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Checagem se o produto eh vacina e se              ³
				//³atende as condicoes do cliente ser pessoa fisica, ³
				//³produtor rural e pertencer ao Estado de Goias.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LjAnalisaLeg(45)[1] .AND. SB1->(ColumnPos("B1_VACINA")) > 0  .AND. !lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se o tipo de cliente é Produtor Rural e Pessoa Fisica.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SA1->A1_TIPO == "L"  .AND. SA1->A1_PESSOA == "F"
						lRet := .T.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Consiste se todos os produtos sao vacinas. Caso algum produto³
						//³nao seja, a escolha entre cupom e nota nao sera permitida.   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nX := 1 to Len(aCols)
							If !aCols[nX][len(aHeader)+1]
						   		DbSelectArea("SB1")
						   		DbSetOrder(1)
						   		If dbSeek(xFilial("SB1")+acols[nX][nPosProd])
						   			If SB1->B1_VACINA <> "1"
						   				lRet := .F.
						   				Exit
						   			Endif
						   		Endif
							Endif
						Next nX   
					Endif
				EndIf
			Else
				If !Empty(SA1->A1_INSCR) .AND. IE(SA1->A1_INSCR,SA1->A1_EST) .AND. ;
					SA1->A1_CONTRIB == "1" .AND. SA1->A1_PESSOA == "F" .AND. ;
					( SA1->A1_TIPO == "L" .OR. TRIM(cEstCob) == "ES" ) 
					
					lRet := .T.
				EndIf
			EndIf
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950CheckRPS³ Autor ³ Vendas Clientes    ³ Data ³ 31.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Cupom Fiscal "CF" equipara-se ao ao 		  ³±±
±±³ 		 ³	"Recibo Provisório de Serviços - RPS".  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet -> Emite ou Nao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJXFUNC                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950CheckRPS(cL1Num,cA1RecIss)

Local aArea	  	:= GetArea()		// Armazena area atual (alias, order e recno)
Local lRet 		:= .F.              // Retorno Logico
Local lTemISS	:= .F.				// Possui algum item de servico
Local lDescIss	:= SuperGetMV("MV_DESCISS",, .F.)

DEFAULT cL1Num  	:= ""
DEFAULT cA1RecIss   := ""

If LJAnalisaLeg(46)[1]		// Regra valida somente para o municipio de Joinville
	DbSelectArea("SL2")
	DbSetOrder(1)
	If DbSeek( xFilial( "SL2" ) + cL1Num ) 
		While !SL2->( Eof() ) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + cL1Num
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o SF4   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a situacao tributaria do item                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (SF4->F4_ISS == "S" .AND. ((( cA1RecIss == "1" .AND. lDescIss ) .OR. (cA1RecIss <> "1" ))))
				lTemISS :=	.T.       // Produto nao possui ISS
				Exit
			EndIf		
			SL2->(DbSkip())
		End
		lRet := lTemISS
	EndIf	
EndIf  

RestArea(aArea)		// Restaura area anterior
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950SP10OK  ³ Autor ³ Vendas Clientes    ³ Data ³ 06.07.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limitacao de 10.000,00 - Legislacao Paulista				  ³±±
±±³ 		 ³ Pergunta ao usuario / Informa bloqueio na venda / Bloqueia ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlrTotal = Total da venda								  ³±±
±±³			 ³ nFlag =  1 = Avisa sobre a legislacao					  ³±±
±±³			 ³			2 = Avisa e pergunta se deseja continuar, ignorand³±±
±±³			 ³			3 = Pergunta se deseja prosseguir imprimindo NF	  ³±±
±±³			 ³	     	# (Outro valor qualquer) = Nao exibe nada         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet -> .T. = Autorizada / .F. = Nao Autorizada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja e Venda Assistida                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950SP10OK(nVlrTotal, nFlag,cCliente, cLojaCli)
Local lRet 			:= .F. 		 	// Retorno da funcao.
Local lEnquadra		:= .F.		 	// Controla se as condicoes fazem com que o sistema se enquadre na regra.
Local lInforma		:= .F.		 	// Controla se a função apenas emitira o aviso.
Local lQuestiona	:= .F.		 	// Controla se a função fara a pergunta para prosseguir no Cupom Fiscal.
Local lQuestNF		:= .F.			// Controla se a função fara a pergunta para prosseguir na Nota Fiscal.
Local nValorMax 	:= 0 			// Valor maximo do cupom fiscal. LIMEMISCF > "CRDDEF.CH"
Local cNovaLinha	:= Chr(13)	 	// Caractere de quebra de linha.
Local cMsgRegra		:= ""
Local lFtvdVer12	:= LjFTVD()		// Verifica se é Release 11.8 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida                                                   	
Local lUseSAT		:= LjUseSat()
Local aAreaSA1		:= {}
Local lInforma51    := .F.
Local lInforma71    := .F.
Local lInforma84    := .F.
Local lInforma87    := .F.
Local lEmitNfce		:= LjEmitNFCe()	// Sinaliza se utiliza NFC-e

DEFAULT nVlrTotal	:= 0	     	// Valor total da venda.
DEFAULT nFlag		:= 0		 	// 1 = Avisa sobre a legislacao | 2 = Avisa e pergunta se deseja continuar mesmo assim | 3 = Pergunta se deseja prosseguir imprimindo Nota Fiscal | # (Outro valor qualquer) = Nao exibe nada
DEFAULT cCliente   	:= ""
DEFAULT cLojaCli 	:= ""

lInforma	:= (nFlag == 1)
lQuestiona	:= (nFlag == 2)
lQuestNF	:= (nFlag == 3)

If Type("lAutoExec") == "U"
	lAutoExec := .F. 
EndIf
 
If LjAnalisaLeg(51)[1] .And. !lEmitNfce
	
	nValorMax 	:= LIMEMISCF
	If lUseSAT
		nValorMax := 10000.00 	// Limite do Valor Total da venda Permitido com SAT (Independente do cliente ser identificado ou não)
	EndIf
	lEnquadra 	:= (nVlrTotal > nValorMax)
	cMsgRegra	:= LjAnalisaLeg(51)[3][1]
	
	If lEnquadra
        lInforma51 := .T.
   EndIf
	
ElseIf LjAnalisaLeg(71)[1] // Estado PE
	
	aAreaSA1 := SA1->(GetArea())
	dbSelectArea("SA1")	
	SA1->(dbSetOrder(1))
	If SA1->(DbSeek( xFilial( "SA1" ) + cCliente + cLojaCli ))

		lPessoa	:= SA1->A1_PESSOA == "J"
		lTpj	:= SA1->A1_TPJ == "3" // MEI
		cInscr	:= SA1->A1_INSCR
			
		// Cliente Pessoa Juridica que NAO TENHA Inscricao Estadual (CACEPE)
		If lPessoa .and. lTpj .and. Empty(cInscr)
			nValorMax 	:= 7500.00
			lEnquadra 	:= (nVlrTotal > nValorMax)  
			cMsgRegra	:= LjAnalisaLeg(71)[3][1]
			
			If lEnquadra
                lInforma71 := .T.
          EndIf
          
		// Cliente Pessoa Juridica que TENHA Inscricao Estadual (CACEPE)
		ElseIf lPessoa .and. !lTpj .and. !Empty(cInscr)
                nValorMax   := 199999.99
                lEnquadra   := (nVlrTotal > nValorMax)  
                cMsgRegra   := LjAnalisaLeg(84)[3][1]
                
                If lEnquadra
                    lInforma84 := .T.
                EndIf
	
		Endif
	Endif
	SA1->(RestArea(aAreaSA1)) 

ElseIf LjAnalisaLeg(87)[1] // CE
	
	nValorMax 	:= LIMEMISCF
	If lUseSAT
		nValorMax := 10000.00 	// Limite do Valor Total da venda Permitido com MF-e (Independente do cliente ser identificado ou não)
	EndIf
	lEnquadra 	:= (nVlrTotal > nValorMax)
	cMsgRegra	:= LjAnalisaLeg(87)[3][1]
	
	If lEnquadra
        lInforma87 := .T.
   EndIf	

ElseIf LjAnalisaLeg(84)[1] .And. lEmitNfce
	nValorMax 	:= 200000.00 	// Limite do Valor Total da venda Permitido com NFC-e
	lEnquadra 	:= (nVlrTotal > nValorMax)
	cMsgRegra	:= LjAnalisaLeg(84)[3][1]
	
	If lEnquadra
        lInforma84 := .T.
   	EndIf
EndIf	

If lEnquadra .AND. !lAutoExec .AND. !lFtvdVer12

		If lQuestiona .Or. lQuestNF
			If LjAnalisaLeg(51)[1] .And. !lEmitNfce
				If lUseSAT
					lRet := MsgYesNo(	STR0467 + " " + AllTrim(Transform(nValorMax, PesqPict( "SL1", "L1_VLRTOT",, 1 ))) +	cNovaLinha	;	// "Atingido o valor máximo permitido para venda com SAT:"
										+	cNovaLinha	;
										+	IIf(lQuestiona, STR0472 + AllTrim(Transform(nValorMax, PesqPict( "SL1", "L1_VLRTOT",, 1 ))) + STR0473, STR0290) + cNovaLinha ; // STR0472 / STR0473 "Se dado um desconto de modo que o valor não exceda R$ XXX, a venda poderá ser finalizada." / STR0290 O sistema finalizará esta venda em Nota Fiscal.
										+	cNovaLinha	;
										+	STR0289		) // Deseja continuar como NF-e ?
				Else	
					lRet := MsgYesNo( 	cMsgRegra +	cNovaLinha	; // Decreto Nº 54.869, de 2 de outubro de 2009 do Estado de São Paulo
										+ STR0287 +	cNovaLinha 	; // Atingido o valor máximo do cupom fiscal: 10.000,00.
										+			cNovaLinha 	;
										+ IIf(lQuestiona,STR0288,STR0290) + cNovaLinha	; // STR0288 Se dado um desconto de modo que o valor não exceda R$ 10.000,00, o Cupom Fiscal poderá ser finalizado.// STR0290 O sistema finalizará esta venda em Nota Fiscal.
										+			cNovaLinha 	;
										+ STR0289				) // Deseja continuar como NF-e ?
				EndIf

			ElseIf LjAnalisaLeg(71)[1] .AND. lEnquadra .AND. Empty(cInscr)
                lRet := MsgYesNo( cMsgRegra	+	cNovaLinha	; // Decreto Nº 36.896, de 2 de Agosto de 2011 do Estado de Pernambuco
                                + STR0428 +	cNovaLinha 	; // Atingido o valor máximo do cupom fiscal: 7.500,00.
                                +				cNovaLinha 	; 
                                + IIf(lQuestiona,STR0430,STR0290) + cNovaLinha	; // Se dado um desconto de modo que o valor não exceda R$ 7.500,00, o Cupom Fiscal poderá ser finalizado.// "O sistema finalizará esta venda em Nota Fiscal.
                                +          	cNovaLinha 	;
                                + STR0289					) // Deseja continuar como NF-e ?
 
            ElseIf LjAnalisaLeg(84)[1] .AND. lEnquadra
                lRet := MsgYesNo( cMsgRegra +   cNovaLinha  ; 
                                  + STR0488 +   cNovaLinha  ;   // "Manual da Nota Fiscal de Consumidor Eletrônica – NFC-e"
                                  + STR0489 +   cNovaLinha  ;   // "É vedada a emissão da NFC-e, nas operações com valor igual ou superior a R$ 200.000,00 (Duzentos mil reais), sendo obrigatória a emissão da NF-e."
                                  + IIf(lQuestiona,STR0491,STR0290) + cNovaLinha ; // "Se dado um desconto de modo que o valor não exceda R$ 199.999,99, o Cupom Fiscal poderá ser finalizado." // "O sistema finalizará esta venda em Nota Fiscal."
                                  +             cNovaLinha  ;
                                  + STR0289                 ) //Deseja continuar como NF-e ?)  
							  
			ElseIf LjAnalisaLeg(87)[1] .AND. lUseSAT
				lRet := MsgYesNo(	STR0499 + " " + AllTrim(Transform(nValorMax, PesqPict( "SL1", "L1_VLRTOT",, 1 ))) + cNovaLinha	;	// "Atingido o valor máximo permitido para venda com MFE:"
									+ STR0500 + cNovaLinha	; // "A venda não poderá ser finalizada."
									+ cNovaLinha	;
									+ IIf(lQuestiona, STR0472 + AllTrim(Transform(nValorMax, PesqPict( "SL1", "L1_VLRTOT",, 1 ))) + STR0473, STR0290) + cNovaLinha ;  // STR0472 / STR0473 "Se dado um desconto de modo que o valor não exceda R$ XXX, a venda poderá ser finalizada." // STR0290 O sistema finalizará esta venda em Nota Fiscal.
									+ STR0505 + cNovaLinha ; // STR0505 Caso contrário o sistema finalizará esta venda em Nota Fiscal.
									+ 			cNovaLinha ;
									+ STR0289		) // Deseja continuar como NF-e ?					

			EndIf					  	    	

	    Else	    	
	    	If lInforma

                Do Case
                    Case lInforma51
                        LjMsgLeg(LjAnalisaLeg(51))
                    Case lInforma71
                        LjMsgLeg(LjAnalisaLeg(71))                        
                    Case lInforma84
                        LjMsgLeg(LjAnalisaLeg(84)) 
					Case lInforma87
                        LjMsgLeg(LjAnalisaLeg(87))
                EndCase                    

	    	EndIf
	    	lRet := .F.
	    EndIf
Else
	lRet := .T.
EndIf	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950MinasL  ³ Autor ³ Vendas Clientes    ³ Data ³ 02.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta Texto para o estado de Minas Gerais para o		  ³±±
±±³ 		 ³ Minas Legal 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlrTotal = Total da venda								  ³±±
±±³			 ³ nDecimais = Número de casas decimais						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cMsgCupom -> Texto a ser impresso do Minas Legal			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja e Venda Assistida                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950MinasL(nVlrTotal, nDecimais)

Local cDtMGLegal	:= ""			// Armazena data no formato esperado para a legislação do "Minas Legal"
Local cVlMGLegal	:= ""			// Total do cupom fiscal ex.: 125,45 => 12545 1.230,86 => 123086 
Local cMsgCupom	:= ""   		// Valor de Retorno com a Mensagem de Retorno
Local lMinasLegal	:= LJAnalisaLeg(56)[1]

DEFAULT nVlrTotal := 0
DEFAULT nDecimais := 0

If  lMinasLegal
	//Converte data ddmmyyyy
	cDtMGLegal := StrZero(Val(AllTrim(Str(DAY(dDataBase)))),2)		//dd
	cDtMGLegal += StrZero(Val(AllTrim(Str(MONTH(dDataBase)))),2) 	//mm
	cDtMGLegal += AllTrim(Str(YEAR(dDataBase))) //yyyy
	        
	//Converte valor para o formato NNNNNNN
	cVlMGLegal := AllTrim(Str(nVlrTotal,7,2))
	cVlMGLegal := StrTran(cVlMGLegal,",")
	cVlMGLegal := StrTran(cVlMGLegal,".")        
	                                        
	        //Não pode conter zeros a esquerda
	While Substr(cVlMGLegal,1,1) == "0"
		cVlMGLegal := Substr(cVlMGLegal,2,Len(cVlMGLegal)-1)
	End

	cMsgCupom := UPPER(STR0327) + SM0->M0_CGC + " " + cDtMGLegal + " " + cVlMGLegal + Chr(10)+Chr(13)  //"MINAS LEGAL: "	
EndIf

Return cMsgCupom

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950CMania  ³ Autor ³ Vendas Clientes    ³ Data ³ 02.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta Texto para o estado do Rio de Janeiro para o		  ³±±
±±³ 		 ³ Cupom Mania 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlrTotal = Total da venda								  ³±±
±±³			 ³ nDecimais = Número de casas decimais						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cMsgCupom -> Texto a ser impresso do Minas Legal			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja e Venda Assistida                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950CMania(cNumCupom)
//RESOLUÇÃO Nº 873, DE 19 DE MARÇO DE 2015 - extinguiu o Cupom Mania
Local cRet := ""
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950PBLegal ³ Autor ³ Vendas Clientes    ³ Data ³ 06.11.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta Texto para o estado da Paraíba para o Paraiba Legal ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlrTotal = Total da venda								  ³±±
±±³			 ³ nDecimais = Número de casas decimais						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cMsgCupom -> Texto a ser impresso do Paraiba Legal		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja e Venda Assistida                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950PBLeg(nVlrTotal, nDecimais , cCooCupom)

Local cDtPBLegal:= ""			// Armazena data no formato esperado para a legislação do "Minas Legal"
Local cMsgCupom	:= ""   		// Valor de Retorno com a Mensagem de Retorno
Local cIE			:= ""			// Inscricao Estadual
Local cVlPBLegal	:= ""
Local lPOS			:= ExistFunc("STFIsPOS") .AND. STFIsPOS()
Local lPBLegal		:= .F.

DEFAULT nVlrTotal	:= 0
DEFAULT nDecimais	:= 0
DEFAULT cCooCupom	:= ""						//Numero do Cupom

If LJAnalisaLeg(59)[1]
	If lPOS
		lPBLegal := STBIsPAF()
	Else
		lPBLegal := LjNfPafEcf(SM0->M0_CGC)
	EndIf
EndIf

//Para o PAF-ECF utilizado por estabelecimento situado no Estado da Paraíba, o código deve ser precedido da
//expressão "PARAÍBA LEGAL - RECEITA CIDADÃ", em caixa alta, na primeira linha e, na segunda linha,
//"TORPEDO PREMIADO:", em caixa alta e deve
//obedecer ao formato 99999999999999espaçoddmmaaaaespaço8888888espaço99999999999, onde:
//"999999999" representa o número do IE do contribuinte usuário do ECF, impresso no cabeçalho do Cupom Fiscal;
//"ddmmaaaa" representa a data de emissão do Cupom Fiscal impressa em seu cabeçalho;
//"888888" representa o numero do COO do comprovante com zeros a esquerda
//"777777777" representa o valor total do respectivo Cupom Fiscal, sem zeros (0) à esquerda;
//Exemplo:
//Dados do Cupom Fiscal -> IE: 123456780 Data: 12/06/2012  Coo: 127563 Valor Total: R$ 125,45
//PARAÍBA LEGAL - RECEITA CIDADÃ
//TORPEDO PREMIADO: 123456780 12062012 127563 12545
If  lPBLegal

	//"999999999" representa o número da Inscrição Estadual do contribuinte usuário do ECF, impresso no cabeçalho do Cupom Fiscal, com 8 dígitos(iniciais);
	cIE	:= AllTrim(SM0->M0_INSC)
	
	//"ddmmaa" representa a data de emissão do Cupom Fiscal impressa em seu cabeçalho, no formato dia, mês e os dois últimos dígitos do ano;
	cDtPBLegal := StrZero(Val(AllTrim(Str(DAY(dDataBase)))),2)	//dd
	cDtPBLegal += StrZero(Val(AllTrim(Str(MONTH(dDataBase)))),2) //mm
	cDtPBLegal += AllTrim(Str(YEAR(dDataBase))) 		//yyyy

	//"888888" representa o número do COO
	If Empty(AllTrim(cCooCupom))
		cCooCupom	:= Space(TamSX3("L1_DOC")[1])
		
		If lPOS
			cCooCupom	:= STBRetCup()
		Else
			IFPegCupom( nHdlECF, @cCooCupom )
		EndIf
	EndIf
	
	//"777777777" converte valor para o formato NNNNNNN
	cVlPBLegal := AllTrim(Str(nVlrTotal,9,2))
	cVlPBLegal := StrTran(cVlPBLegal,",","")
	cVlPBLegal := StrTran(cVlPBLegal,".","")        
	                                        
	//Não pode conter zeros a esquerda
	While Substr(cVlPBLegal,1,1) == "0"
		cVlPBLegal := Substr(cVlPBLegal,2,Len(cVlPBLegal)-1)
	End
	                                                       
	cMsgCupom := "PARAÍBA LEGAL - RECEITA CIDADÃ" + Chr(10)+Chr(13)
	cMsgCupom += "TORPEDO PREMIADO: " + cIE + " " + cDtPBLegal + " " + cCooCupom + " " + cVlPBLegal + Chr(10)+Chr(13)
EndIf

Return cMsgCupom

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj950NotaL ³ Autor ³ Vendas Clientes    ³ Data ³ 15.01.13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta Texto para o Distrito Federal para a Nota Legal     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 							  								  ³±±
±±³			 ³  														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cMsgCupom -> Texto a ser impresso da Nota Legal		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja e Venda Assistida                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950NotaL(nValorIcms , nValorIss , nDecimais)
          
Local cTributos := ""           // String contendo os tributos do Cupom Fiscal 
Local cMsgCupom := ""			// Retorno da função 
Local lConcessaoCred	:= SuperGetMV("MV_LJCCRDF",,.F.) .AND. LJAnalisaLeg(62)[1]//Verifica se está no regime de concessão de créditos-Legislação do Distrito Federal 
Local lNotaLegal		:= lConcessaoCred .OR. LJAnalisaLeg(62)[1] //Verifica se imprime a nota legal 

DEFAULT nValorIcms := 0			// Valor de ICMS do Cupom
DEFAULT nValorIss  := 0         // Valor de ISS do Cupom 
DEFAULT nDecimais  := 0

//Para o PAF-ECF utilizado por estabelecimento situado no Distrito Federal, 
//incluído no programa de concessão de créditos, o código deve ser precedido, 
//na primeira linha,  da expressão ESTABELECIMENTO INCLUÍDO NO PROGRAMA DE, 
//na segunda linha, CONCESSÃO DE CRÉDITOS – LEI nº 4.159/08. e, na terceira linha, 
//que se torna a primeira se o estabelecimento não estiver incluído no programa 
//de concessão de crédito: NOTA LEGAL:  <TRIBUTO> = onde NOTA LEGAL vem destacado 
//em negrito e a variável <TRIBUTO> assume a expressão ICMS ou ISS, tudo em caixa alta, 
//seguido do valor do tributo obtido conforme item 5 do Requisito VIII-B.

//Exemplo:
//ESTABELECIMENTO INCLUÍDO NO PROGRAMA DE
//CONCESSÃO DE CRÉDITOS – LEI nº 4.159/08.
//NOTA LEGAL: ICMS = 3.000,00 ISS =1.500,00

If lConcessaoCred
	cMsgCupom := "ESTABELECIMENTO INCLUÍDO NO PROGRAMA DE" + Chr(10) + Chr(13)
	cMsgCupom += "CONCESSÃO DE CRÉDITOS – LEI nº 4.159/08." + Chr(10) + Chr(13)	
EndIf

If lNotaLegal
	cValorIcms:= AllTrim(Str(nValorIcms,7,2))
	cValorIss := AllTrim(Str(nValorIss,7,2))
	cTributos := "ICMS = " + cValorIcms + "  " + "ISS = " + cValorIss                           
	cMsgCupom += TAG_NEGRITO_INI + "NOTA LEGAL:" + TAG_NEGRITO_FIM + cTributos + Chr(10) + Chr(13)
EndIf

Return cMsgCupom

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj950ImpNC   ³ Autor ³ Vendas Clientes    ³ Data ³ 06.11.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta Texto para impressao da lei de olho no imposto      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                    		  ³±±
±±³			 ³                                                  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cMsgCupom -> Texto a ser impresso                		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja e Venda Assistida                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950ImpNC(nVlrTotal,nTotaImp,nDecimais, lNFCe,nTotImpFED,nTotImpEST,nTotImpMUN)

Local cMsgCupom	:= ""   		// Valor de Retorno com a Mensagem de Retorno
Local npercVenda:= 0
Local npercVdaFED	:= 0
Local npercVdaEST	:= 0
Local npercVdaMUN	:= 0
Local cTotaImp	:= 0
Local cTotImpFED		:= 0
Local cTotImpEST		:= 0
Local cTotImpMUN		:= 0
Local cMvFisCTrb	:= SuperGetMV("MV_FISCTRB",,"1")              // Define se é tipo GE
Local cFonte 		:= iif(cMvFisCTrb=='1',"Fonte:IBPT",SuperGetMv("MV_FNTCTRB",,'Fonte Cliente'))
Local lMvEnteTrb		:= SuperGetMv("MV_ENTETRB",.F.,.F.)
Local lDanfe		:= .F.

DEFAULT nVlrTotal	:= 0
DEFAULT nTotaImp	:= 0
DEFAULT nDecimais	:= MsDecimais(nMoedaCor)
DEFAULT lNFCe		:= .F.
DEFAULT nTotImpFED	:= 0
DEFAULT nTotImpEST	:= 0
DEFAULT nTotImpMUN	:= 0

If cPaisLoc == 'BRA'
	npercVenda	:= noRound((nTotaImp/nVlrTotal)*100,nDecimais) 
	cTotaImp 		:= AllTrim( Transform(  nTotaImp	, PesqPict( "SL1", "L1_VLRTOT",, 1 ) ) ) 

	If lMvEnteTrb
		npercVdaFED	:= noRound((nTotImpFED/nVlrTotal)*100,nDecimais) 
		npercVdaEST	:= noRound((nTotImpEST/nVlrTotal)*100,nDecimais) 
		npercVdaMUN 	:= noRound((nTotImpMUN/nVlrTotal)*100,nDecimais)
		cTotImpFED 	:= AllTrim( Transform(  nTotImpFED , PesqPict( "SL1", "L1_VLRTOT",, 1 ) ) ) 
		cTotImpEST		:= AllTrim( Transform(  nTotImpEST , PesqPict( "SL1", "L1_VLRTOT",, 1 ) ) ) 
		cTotImpMUN 	:= AllTrim( Transform(  nTotImpMUN , PesqPict( "SL1", "L1_VLRTOT",, 1 ) ) ) 
	EndIf
		
	If lNFCe  
		//Metodo novo de impressao da aliquota.	
		If lMvEnteTrb
			lDanfe := IsInCallStack("LjNFCeDANFE")
			
			If lDanfe
				cMsgCupom := "Informação dos Tributos Totais Incidentes" + CRLF + "(Lei Federal 12.741/2012) " + cTotaImp
				//nao habilitado os valores abaixo por estar aguardando 
				//regulamentacao da disposicao dos valores na Danfe, neste
				//caso as informações estarão em informações complementares - 22.04.2015
				/*
				cMsgCupom := "Trib.Aprox R$: " + cTotImpFED + " Fed;" 
				cMsgCupom += 			  " R$: " + cTotImpEST + " Est;" 
				cMsgCupom += 			  " R$: " + cTotImpMUN + " Mun." 
				cMsgCupom += cFonte
				*/
			Else	
				cMsgCupom := "Trib.Aprox R$: " + cTotImpFED + " Fed;" 
				cMsgCupom += 			  " R$: " + cTotImpEST + " Est;" 
				cMsgCupom += 			  " R$: " + cTotImpMUN + " Mun." 
				cMsgCupom += cFonte
			EndIf
						 
		Else 		//Metodo antigo de impressao da aliquota.	
			cMsgCupom := "Informacao dos Tributos Totais Incidentes" + CRLF + "(Lei Federal 12.741/2012) " + cTotaImp
		EndIf	

	Else
		
		//Metodo novo de impressao da aliquota.	
		If lMvEnteTrb
			cMsgCupom := "Trib.Aprox R$: " + cTotImpFED + " Fed;" 
			cMsgCupom += 			  " R$: " + cTotImpEST + " Est;" 
			cMsgCupom += 			  " R$: " + cTotImpMUN + " Mun." + Chr(10)+Chr(13)  
			cMsgCupom += cFonte  + Chr(10)+Chr(13)
		Else 		//Metodo antigo de impressao da aliquota.	
			cMsgCupom := "Valor aprox dos tributos R$ " + cTotaImp +" (" + Alltrim(Str(npercVenda)) +"%) ";
			+ Chr(10)+Chr(13) + cFonte  + Chr(10)+Chr(13)
		EndIf	

	EndIf
EndIf

Return cMsgCupom


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj950GrArrºAutor  ³Vendas Clientes     º Data ³  03/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera titulo provisorios no financeiro para os produtos      º±±
±±º          | com doação ao Instituto Arredondar.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void Lj950GrArr(cNumOrc,cCli,nArredondar)                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNumOrc     - número do orçamento (para histórico)          º±±
±±º          ³cCli        - código do cliente   (para histórico)          º±±
±±º          ³nArredondar - Valor a lançar para o título provisório       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj950GrArr(cNumOrc, cNumSerie, cNumDoc, cCli,;
							 cLojaCli, cCPFCli, cFormPg, nArredondar, nDescArredondar)


Local aAreaSE2:= SE2->(GetArea())              	// Salva alias da tabela
Local cPrefixo:= SuperGetMv("MV_LJPREIA",,"") 	// Prefixo do titulo a pagar provisorio 
Local cNum    := ''								    // Numero sequencial do titulo a pagar provisorio 
Local cParcela:= SuperGetMv("MV_1DUP",,"") 		// Parcela do titulo a pagar provisorio 
Local cTipo   := SuperGetMv("MV_LJTPFIN",,"PRE")	// Tipo do titulo a pagar provisorio 
Local cNaturez:= SuperGetMv("MV_LJNATIA",,"")		// Prefixo do titulo a pagar provisorio 
Local cFornece:= SuperGetMv("MV_LJFORIA",,"")	// Fornecedor para o titulo a pagar provisorio 
Local cLojaF  := SuperGetMv("MV_LJLOJIA",,"")	// Loja Fornecedor para o titulo a pagar provisorio  
Local aArray  := {} 									// Array para ExecAuto
Local nValTit := 0 									// Valor do titulo a pagar provisório
Local cAdmFin := ''									// administradora financeira
Local cNumMGK := ""									// Numero sequencial da tabela MGK
Local cTokenRet := ""									// Token para envio de dados ao Webservice Rest para o Instituto Arredondar
Local cUrl		:= ""									// Variável para URL
Local aHeaderStr 	:= {}								// Array para envio de headers do texto html
Local cHeaderOut 	:= ""								// Array para retorno do conteúdo html
Local dDataMGK := cTod("")							// Data do registro do MGK
Local cHoraMGK := ""									// Hora do registro do MGK
Local cCliMGK	:= ""									// Cliente da tabela MGK
Local cLojaMGK	:= ""								// Loja do Cliente da tabela MGK
Local cCnpjSA1 := ""									// CNPJ ou CPF do cliente
Local cNomeSA1 := ""									// Nome do cliente
Local cEmailSA1 := ""								// E-mail do cliente
Local aAreaSA1 := ""									// Área do SA1
Local cToken		 := SuperGetMV("MV_LJTOKIA",,"")  // Token para o Webservice Rest do Instituto Arredondar
Local lWebService := SuperGetMV("MV_LJRESIA",,.F.) // Ativar Webservice Rest para o Instituto Arredondar
Local cUrlIA      := SuperGetMV("MV_LJURLIA",,"" )  // Site de recebimento do Webservice Rest
Local cCnpjLojaIA := SuperGetMV("MV_LJCNPIA",,"" )  // CNPJ da loja de envio para o Instituto Arredondar
Local lImprimiuCupom	:= .F.								// Se imprimiu o cupom não-fiscal
Local lAutomato 	:= IIf(Type("lAutomatoX")<>"L",.F.,lAutomatoX)	//Teste Automatizado

Private lMsErroAuto := .F.                     		// Para Executar ExecAuto

Default cNumOrc		:= ""								// Número do Orçamento
Default cNumSerie		:= ""								// Número da Serie
Default cNumDoc		:= ""								// Número do Documento
Default cCli			:= ""								// Código do Cliente
Default cLojaCli		:= ""								// Loja do Cliente
Default cCPFCli		:= ""								// CPF/CNPJ do Cliente
Default cFormPg		:= ""								// Forma de Pagamento
Default nArredondar	:= 0								// Valor da Doação ao Instituto Arredondar
Default nDescArredondar := nArredondar						// Doação com taxa adm. deduzida se MV_LJTEFIA ativado

nValTit := nArredondar
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria um número sequencial para chave da SE2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("SE2")
DbSetOrder(1)
Dbseek( xFilial("SE2") + cPrefixo + Replicate("Z", TamSX3("E2_NUM")[1]), .T. )
DbSkip(-1) 
If SubStr(SE2->E2_NUM, 1, 1) == "0"                                    
	cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
Else
 	cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
EndIf
		 
		 
aArray := { { "E2_PREFIXO"  ,cPrefixo           , NIL },;
            { "E2_NUM"      , cNum              , NIL },;
            { "E2_PARCELA"  , cParcela          , NIL },;
            { "E2_TIPO"     , cTipo             , NIL },;
            { "E2_NATUREZ"  , cNaturez          , NIL },;
            { "E2_FORNECE"  , cFornece          , NIL },;
            { "E2_LOJA"     , cLojaF            , NIL },;
            { "E2_EMISSAO"  , dDataBase			, NIL },;
            { "E2_VENCTO"   , LastDay(dDataBase), NIL },;
            { "E2_VALOR"    , nDescArredondar	, NIL },;
            { "E2_HIST"     , 'DOC. ' + cNumSerie+"/"+cNumDoc, NIL },;
            { "E2_FLUXO"    , "S"   		    , NIL }}			 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a inclusao do contas a pagar via ExecAuto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
MSExecAuto({|x,y,z| Fina050(x,y,z)},aArray,,3)
			 	 
If lMsErroAuto
    MostraErro(Iif( lAutomato .or. IsBlind(), "\", ""))
Endif
			
cAdmFin := ''
aArray  := {}
cFornece:= ''

RestArea(aAreaSE2)

If !IsBlind()		//Somente imprime se não veio do job. Exemplo: Venda Assistida
	lImprimiuCupom := Lj950ImpIA(nValTit, cNumSerie, cNumDoc, cCli,;
										 cLojaCli, cCPFCli, cFormPg)
Else
	lImprimiuCupom := .T.	//O cupom foi impresso anteriormente via TOTVS PDV ou FrontLoja
EndIf

If !lMsErroAuto .AND. lImprimiuCupom
	//Veremos se há a tabela MGK.
	//Gravação do histórico da doação para o Instituto Arredondar.
	//Gravação para transmissão da doação via webservice Rest em MGK_TRANSM.

	DBSelectArea("MGK")
	DbSetOrder(1)		//MGK_FILIAL+MGK_NUM
	Dbseek( xFilial("MGK") + Replicate("Z", TamSX3("MGK_NUM")[1]), .T. )
	DbSkip(-1) 
 	cNumMGK := StrZero(Val(MGK->MGK_NUM) + 1 ,(TamSX3("MGK_NUM")[1]))

	// Gravação da tabela auxiliar
	RecLock("MGK",.T.)
	
	MGK->MGK_FILIAL	:= xFilial("MGK")
	MGK->MGK_NUM		:= cNumMGK
	MGK->MGK_DATA		:=	dDataBase
	MGK->MGK_HORA		:= Left(Time(),5)
	MGK->MGK_NUMORC	:=	cNumOrc
	MGK->MGK_SERIE	:=	cNumSerie
	MGK->MGK_DOC		:=	cNumDoc
	MGK->MGK_CODCLI 	:= cCli
	MGK->MGK_LOJA	 	:= cLojaCli
	MGK->MGK_CGCCLI	:= cCPFCli
	MGK->MGK_VALOR 	:= nDescArredondar
	MGK->MGK_FORMPG	:= cFormPg
	MGK->MGK_TRANSM := ""			 

	MGK->(MsUnlock())

	If lWebService
		// Envio via REST
		// Este + os anteriores que não foram enviados
		DBSelectArea("MGK")
		DbSetOrder(2)	//MGK_FILIAL+MGK_TRANSM
		While .T.

			MGK->(Dbseek(xFilial("MGK") + " "))
			If (MGK->(Eof()) .OR. (MGK->MGK_TRANSM != " "))
				Exit
			EndIf
			
			cNumMGK 	:= MGK->MGK_NUM
			dDataMGK 	:= MGK->MGK_DATA
			cHoraMGK	:= MGK->MGK_HORA
			cCliMGK	:= MGK->MGK_CODCLI
			cLojaMGK	:= MGK->MGK_LOJA
			nValTit	:= MGK->MGK_VALOR
			cCnpjSA1	:= MGK->MGK_CGCCLI
			cNomeSA1	:= ""
			cEmailSA1	:= ""

			aAreaSA1 := SA1->(GetArea())
			DbSelectArea("SA1")
			DbSetOrder(1)			
			If SA1->(DbSeek(xFilial("SA1")+cCliMGK+cLojaMGK))
				cCnpjSA1  := If(!Empty(cCnpjSA1),cCnpjSA1,Alltrim(SA1->A1_CGC))
				cNomeSA1  := Alltrim(SA1->A1_NOME)
				cEmailSA1 := Alltrim(SA1->A1_EMAIL)
			EndIf
			RestArea(aAreaSA1)
					
			cTokenRet    := Lj950TokIA( cToken )
			cUrl      := cUrlIA + '/webservice/transacao/'
			cUrlParms := 'token='+cTokenRet+'&transacoes='+ Escape('[{"id":'+Alltrim(Str(Val(cNumMGK)))+',"cnpj":"' ;
							+ cCnpjLojaIA + '","datatransacao":"'+DtoS(dDataMGK) + ' ' + cHoraMGK ;
							+'","meiopagamento":"debito","parcelas":1,"valorarredondado":' ;
							+Alltrim(Transform(nValTit,"999999.99")) ;
							+ iif(Len(cCnpjSA1)>0,',"cpf":"'+cCnpjSA1+'"', '') ;
							+ iif(Len(cNomeSA1)>0,',"nome":"'+cNomeSA1+'"', '') ;
							+ iif(Len(cEmailSA1)>0,',"email":"'+cEmailSA1+'"', '') ;
							+'}]')

			aHeaderStr := {} 
			aadd(aHeaderStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
			aadd(aHeaderStr,'Content-Type: application/json')
			cHeaderOut := ""

			Conout( "Endereço: " ,cUrl + '?' + cUrlParms )
			cHtmlPage := Httpget(cUrl, cUrlParms, 120000, aHeaderStr, @cHeaderOut)

			Conout("Resposta", cHtmlPage)
			VarInfo("cHeaderOut", cHeaderOut)
			
			If HTTPGetStatus() <> 200 //200 = OK, diferente de 200 = erro
				MsgStop(STR0395+Alltrim(Str(HTTPGetStatus())),STR0183) //"Erro na Requisição HTTP: ","Atenção !"
				RecLock("MGK",.F.)
				MGK->MGK_TRANSM := "E"  // Transmitido = "Erro"			 
				MGK->(MsUnlock())
			Else
				RecLock("MGK",.F.)
				MGK->MGK_TRANSM := "S"	// Transmitido = "Sim"		 
				MGK->(MsUnlock())
			EndIf

		Enddo

		// Em seguida, todos os "E"s voltarão para a posição inicial (em branco).
		DBSelectArea("MGK")
		DbSetOrder(2)	//MGK_FILIAL+MGK_TRANSM
		While .T.

			MGK->(Dbseek(xFilial("MGK") + "E"))
			If (MGK->(Eof()) .OR. (MGK->MGK_TRANSM != "E"))
				Exit
			EndIf
		
			RecLock("MGK",.F.)
			MGK->MGK_TRANSM := " "			 
			MGK->(MsUnlock())
			
		EndDo

	EndIf
	
EndIf
	
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | Lj950TokIA ³ Autor ³ Vendas Clientes     ³ Data ³31/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o token a ser enviado para o Webservice Rest		³±±
±±³          ³ do Instituto Arredondar						 				  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.:	 ³ 																	   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA / FRONTLOJA                     			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj950TokIA(cChave)
// Exemplo: 70-KEML5JLR. cIdentificador = "70" e cSegredo = "KEML5JLR".
Local cPos									// Posição de onde está o hifen 
Local cIdentificador						// Primeiro grupo
Local cSegredo							// Segundo grupo
Local cHoje								// Data de hoje em formato dTos()
Local cHash								// Cálculo final do Hash

cPos := At( '-', cChave )
If cPos <= 1
	Return Left( cChave, 2 )
Else	
	cIdentificador := Left( cChave, cPos-1 )
	cSegredo := Alltrim( Substr( cChave, cPos+1, 100 ) )   
	cHoje := DtoS( Date() )
	cHash=md5(cSegredo+cHoje)
Endif	

Return cIdentificador+"-"+cHash



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | Lj950ImpIA ³ Autor ³ Vendas Clientes     ³ Data ³01/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressão do Cupom não-fiscal em uma impress. ECF/NFC-e/SAT³±±
±±³          ³     				               			 				  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.:	 ³ 																	   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA / FRONTLOJA												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj950ImpIA(nArredondar, cSerie, cDoc, cCliente,;
							 cLojaCli, cCpfCli, cFormPg)
Local cTickForm	:= ""								//Texto para cupom não-fiscal para Instituto Arredondar
Local cFormaPgto 	 := GetPvProfString("Instituto Arredondar", "FormaPgto", " ", GetClientDir() + "SIGALOJA.INI" )	// Ler qual cond. pagto. no Sigaloja.ini
Local cTotalizNFis := GetPvProfString("Instituto Arredondar", "Totalizador", "01", GetClientDir() + "SIGALOJA.INI" )  // Ler qual totalizador no Sigaloja.ini
Local lRetorno := .T.								// Se função executada com sucesso
Local cMsgComprovante 	:= ""						//Mensagem do Comprovante

Local lINFCutPpr		:= ExistFunc('INFCutPpr')
Local lRecNaoFis := (nModulo == 5 .OR. nModulo == 6) .OR.;	//Recebimento pelo Venda Direta
			 		((nModulo == 12 .OR. nModulo == 23) .AND. ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe())	//Recebimento pelo Loja/Front com NFC-e
			 															//Sinaliza recebimento por modulo não fiscal(sem ECF) *NFC-e, Venda Direta


Default nArredondar 	:= 0			//Valor da doação
Default cSerie		:= ""			//Serie do Documento vinculado
Default cDoc			:= ""			//Documento vinculado
Default cCliente	 	:= ""			//Cliente
Default cLojaCli		:= ""			//Loja do Cliente
Default cCpfCli		:= ""			//CPF do Cliente
Default cFormPg		:= ""			//Forma de Pagamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressão de Cupom Não-Fiscal                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
	A impressora deverá estar cadastrada como:
	Forma de Pagamento: A VISTA ou RECEBER, ou o código cadastrado de um deles
	Totalizador não-fiscal: DOACAO
*/

If lRecNaoFis				//NFC-e e SAT

	cMsgComprovante := Lj950TxtIA(nArredondar, cSerie, cDoc, cCliente, cLojaCli, cCpfCli, cFormPg)

	nRet := INFTexto(cMsgComprovante)  //Envia comando para a Impressora

	If lINFCutPpr
		INFCutPpr()
	EndIf

Else

	// cTickform é a descrição do texto.
	cTickForm := STR0455 + chr(10) + chr(13);	//"DOAÇÃO - INSTITUTO ARREDONDAR"
					+ STR0456 + chr(10) + chr(13);		//"CNPJ 14.416.996/0001-25"
					+ STR0457  								//"www.arredondar.org.br"

	nRet := -1
	nRet := IFAbrCNFis( nHdlECF, cFormaPgto , Str(nArredondar,14,2) , cTotalizNFis )
		
	If nRet <> 0
		MsgStop(STR0392, STR0183) //"Erro ao efetuar a Abertura Não-Fiscal.", "Atenção!"
		lRetorno := .F.
	EndIf	

	nRet := IFTxtNFis( nHdlECF, cTickForm , 1 )
	If nRet <> 0
		MsgStop(STR0393, STR0183) //"Erro ao efetuar o Texto Não-Fiscal.", "Atenção!"
		lRetorno := .F.
	EndIf	

	nRet := IFFchCNFis( nHdlECF )
	If nRet <> 0
		MsgStop(STR0394, STR0183) //"Erro ao efetuar o Encerramento Não-Fiscal.", "Atenção!"
		lRetorno := .F.
	EndIf

EndIf

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj950FECP    ³ Autor ³ Vendas Clientes    ³ Data ³ 09.03.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui texto da Lei de Fundo de Combate a Probreza         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cMsgCupom -> Texto a ser impresso                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja e Venda Assistida                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj950FECP(nValFECP)

Local cMsgCupom	:= ""

cMsgCupom := LJAnalisaLeg(74)[4]

If !Empty( cMsgCupom )
	cMsgCupom += Space(1) + "R$ " + AllTrim(Transform(nValFECP, "@E 999,999.99"))
	
	If Len(cMsgCupom)>40    //Quebra em duas linhas
		cMsgCupom := MemoLine(cMsgCupom,40,1)+Chr(10)+MemoLine(cMsgCupom,40,2)
    EndIf
EndIf

Return cMsgCupom


/*/{Protheus.doc} Lj950UFVal
Retorna array com os valores limites para emissao e obrigacao de identificação para NFC-e
@type		function
@param		cUF, retorna os valores de determinada UF, se for nao for informado, retorna todas
@author  	Varejo
@version 	P11.80
@since   	20/11/2016
@return  	aRet, valores limite de determinada UF ou todas
/*/
Function Lj950UFVal(cUF)

Local aUF	:= {}	//vetor com os valores limites de cada UF, mais detalhes logo abaixo
Local aRet	:= {}
Local nPos	:= 0	//indica a posicao do array que contem a info desejada

Default cUF := "*"	//se nao for informado nenhuma UF, retorna todas

/*
aUF[1] UF
aUF[2] valor limite para emissao de NFC-e
aUF[3] valor para emissao de NFC-e obrigando identificação completa <idDest>
aUF[4] valor para emissao de NFC-e obrigando identificação por CPF/CNPJ/Id.Estrangeiro
*/

Aadd( aUF, {"SP", 200000, 0		, 0		} )
Aadd( aUF, {"PB", 200000, 10000	, IIf(DDATABASE >= CtoD('01/01/18'), 500, 0)} )	//PORTARIA N° 00100/2017/GSER PUBLICADA NO DOe-SER DE 26.04.17

If cUF == "*"
	aRet := aClone( aUF )
Else
	//obtem os valores limites da UF que obrigam algum tipo de identificacao do destinatario para emissao da NFC-e
	nPos := aScan( aUF, {|x| x[1] == cUF} )
	If nPos > 0
		aRet := aClone( aUF[nPos] )
	EndIf
EndIf

//destruimos o array para melhor gerenciamento de memoria
aSize( aUF, 0 )
aUF := Nil

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj950ImpCPF
Verifica se obriga a identificacao do cliente por CPF/CNPJ
@param nVlrVenda Valor total da venda
@author Varejo
@version P12.1.14
@since 20/04/2016
@return lObrigaID - Se obriga identificacao do cliente
/*/
//-------------------------------------------------------------------
Function Lj950ImpCPF(nVlrVenda,nObrigaCPF)
Local cUF			:= ""
Local nVlrLimite	:= 0								// Valor limite para vendas sem identificacao do cliente
Local nMV_LJVLCID	:= SuperGetMV("MV_LJVLCID",,0)
Local lObrigaID		:= .F.								// Indica se obriga identificacao do cliente
Local lUseSAT		:= LjUseSAT()
Local lMvSpedEnd	:= SuperGetMV("MV_SPEDEND",,.F.)	// .F. Endereço de Cobrança / .T. Endereço de Entrega
Local aValIdUF		:= {}								// Array com a UF e seus respectivos valores para identificacao do cliente
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - 
//alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável 
// lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois 
//o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lEmitNfce		:= LjEmitNFCe()						// Sinaliza se utiliza NFC-e
Local aGetMvTSS		:= {}
Local cMvModNFCe	:= ""
Local nNFCECON		:= SuperGetMV("MV_NFCECON",,0)		// Habilita a obrigatoriedade do CPF caso a NFC-e for emitida em contigência

Default nVlrVenda	:= 0
Default nObrigaCPF	:= 0
//essa Legislacao é válido para todos as solucoes fiscais do CE: ECF, CF-e, NF-e e NFC-e
If LJAnalisaLeg(75)[1]
	lObrigaID 	:= .T.
	nObrigaCPF 	:= 1
// somente se for NFC-e
ElseIf lEmitNFCe .AND. !lUseSAT

	// obtemos a UF que sera utilizado para emissao	da NFC-e
	cUF := AllTrim( IIF(!lMvSpedEnd, SM0->M0_ESTCOB, SM0->M0_ESTENT) )

	// carrega os valores que obrigam algum tipo de identificacao do destinatario
	aValIdUF := Lj950UFVal(cUF)
	If Len(aValIdUF) > 0
		// o valor da venda deve ser menor que o valor max para emissao de NFC-e
		If aValIdUF[2] = 0 .OR. ( aValIdUF[2] > 0 .AND. nVlrVenda < aValIdUF[2] )
			// e tambem menor que o valor que obriga <enderDest>
			If aValIdUF[3] = 0 .OR. ( aValIdUF[3] > 0 .AND. nVlrVenda < aValIdUF[3] )
				//obtem o valor que obriga a identificacao do cliente por CPF/CNPJ/
				nVlrLimite := aValIdUF[4]
			EndIf
		EndIf
	EndIf	
	
	//Obtemos a e MODALIDADE do TSS
	aGetMvTSS := LjGetMVTSS("MV_MODNFCE","1")
	If aGetMvTSS[1]
		cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
	EndIf

	If cMvModNFCe == "2" .And. nNFCECON == 1
		lObrigaID 	:= .T.
		nObrigaCPF 	:= 2
	EndIf
EndIf

//se nao ha nenhuma legislacao, entao utiliza o valor do parametro
If !lObrigaID
	If nVlrLimite = 0
		nVlrLimite := nMV_LJVLCID
	EndIf

	// verifica se obriga a identificacao do cliente
	If nVlrLimite > 0 .AND. nVlrVenda >= nVlrLimite
		lObrigaID 	:= .T.
		nObrigaCPF 	:= 3
	EndIf
EndIf

Return lObrigaID


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | Lj950TxtIA ³ Autor ³ Vendas Clientes     ³ Data ³14/09/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LayOut para impressão de texto para doação			 		³±±
±±³          ³ ao Instituto Arredondar          			 				  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.:	 ³ 																	   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA / FRONTLOJA												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj950TxtIA(nArredondar, cSerie, cDoc, cCliente,;
									 cLojaCli, cCpfCli, cFormPg)

Local aArea			:= GetArea()				// Armazena o posicionamento atual
Local cMvSimb1		:= SuperGetMV("MV_SIMB1")						// Simbolo da moeda
Local cTickForm 		:= STR0455 + chr(10) + chr(13);	//"DOAÇÃO - INSTITUTO ARREDONDAR"
							+ STR0456 + chr(10) + chr(13);		//"CNPJ 14.416.996/0001-25"
							+ STR0457  								//"www.arredondar.org.br"
Local cDescFormPg	:= ""														//Descrição da Forma de Pagamento

Default nArredondar 	:= 0			//Valor da doação
Default cSerie		:= ""			//Serie do Documento vinculado
Default cDoc			:= ""			//Documento vinculado
Default cCliente	 	:= ""			//Cliente
Default cLojaCli		:= ""			//Loja do Cliente
Default cCpfCli		:= ""			//CPF do Cliente
Default cFormPg		:= ""			//Forma de Pagamento

DbSelectArea("SX5")
SX5->(DbSetOrder(1))	//X5_FILIAL+X5_TABELA+X5_DESCRI
SX5->(DbSeek(xFilial("SX5")+"24"+cFormPg))
cDescFormPg	:= "("+PadR(SX5->X5_DESCRI,12)+")"
RestArea(aArea)
	

	//       "C O M P R O V A N T E"
	// 		    "D E   D O A C A O"
	//""
	//"Cliente : "
	//"CNPJ/CPF: "
	//"Doc     : "                 Data : "
	//""
	//"======================================="
	//""
	//"Valor : "
	//""
	//"DOAÇÃO - INSTITUTO ARREDONDAR"
	//"CNPJ 14.416.996/0001-25"
	//"www.arredondar.org.br"
	
	cCliente := PadR( cCliente, TamSX3("A1_COD")[1] )
	cMsgComprovante := 	Space((40-Len(STR0458)) / 2) + STR0458 + Chr(10) +;		//"C O M P R O V A N T E"
							Space((40-Len(STR0459)) / 2) + STR0459 + Chr(10) +;		//"D E   D O A C A O"
							Chr(10) + Chr(10) +;
							STR0460 + PadR(Posicione( "SA1",1,xFilial("SA1")+cCliente+cLojaCli,"SA1->A1_NOME"),30) +;	//"Cliente : "
							Chr(10) +;
							If(!Empty(cCpfCli),;
								STR0461 + PadR(cCpfCli, 25) +;			//"CNPJ/CPF: "
								Chr(10),"") +;
							STR0462 + PadR(cSerie+"/"+cDoc, 25) +;					//"Doc     : "
							Chr(10) +;
							STR0463 + DtoC(Date()) + " " + Time() +;	//"Data    : "
							Chr(10) + Chr(10) +;
							Replicate("=",40) + Chr(10) +;
							Chr(10) +;
							STR0464 + cDescFormPg + " :  " + cMvSimb1 + Trans(nArredondar,"@E 999,999,999.99") + Chr(10)+;	//"Valor "
							Chr(10) + Chr(10) +;
							StrTran(cTickForm,Chr(13),"")

							
Return cMsgComprovante

