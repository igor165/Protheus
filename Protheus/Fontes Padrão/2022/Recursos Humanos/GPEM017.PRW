#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM017.CH"

Static aLogrNum
Static aTLogr
Static aTLogr1
Static lOkFs2
Static lEFDMsg		:= SuperGetMv("MV_EFDMSG",,.F.)
Static lMiddleware  := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lIntTAF		:= SuperGetMv("MV_RHTAF",, .F.) == .T. //Integracao com TAF
Static lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).
Static aTabS130	 	:= {}
Static aTabS134	 	:= {}
Static __oSt1		 	//Query para verificar as verbas da SRC/SRD para o TAF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEM017    ³ Autor ³ Glaucia M./Mauricio M.  	                ³ Data ³ 12/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Funcoes especificas para eSocial                          			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEM017()                                                    	  		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Glaucia M.   ³12/06/2013³0000012010/2013 ³THFBY4   ³ Adicionar nova funcao, (fEFDsocial)que sera ³±±
±±³Mauricio M.	³          ³                ³         ³ responsavel por liberar para uso e validacao³±±
±±³         	³          ³                ³         ³ das implementacoes realizadas.              ³±±
±±³Glaucia M.   ³06/09/2013³00000012029/2013³THFBYI   ³ Inclusao de perguntas no compatibilizador   ³±±
±±³             ³          ³                ³         ³ 218 - eSocial fase 1.                       ³±±
±±³Glaucia M.   ³26/09/2013³00000023992/2013³THURS4   ³ Liberacao do pacote ao Cliente Final        ³±±
±±³             ³          ³                ³         ³ 218 - eSocial fase 1.                       ³±±
±±³Glaucia M.   ³26/09/2013³00000012000/2013³THFBXU   ³ Criacao Fase 2 eSocial.                     ³±±
±±³Glaucia M.   ³18/10/2013³00000012000/2013³THFBXU   ³ Fase 2 eSocial- Ajuste na dica compatibiliza³±±
±±³             ³          ³                ³         ³ dor .                                       ³±±
±±³Glaucia M.   ³21/10/2013³00000026891/2013³THXSWP   ³ Fase 1 - Quando pressionado o botao fechar, ³±±
±±³             ³          ³                ³         ³ nao executara compatibilizador.             ³±±
±±³Glaucia M.   ³06/11/2013³00000013941/2013³THFBYU   ³ Fase 2 - Tomadores e liberacao fase 2       ³±±
±±³             ³          ³                ³         ³ somente com implantacao do TAF.             ³±±
±±³Emerson Camp.³13/12/2013³00000030986/2013³TIBOYU   ³ Fase 2 - Executado os De/Para para rubrica  ³±±
±±³             ³          ³                ³         ³ Mot. Afastamento e Mot de Desligamento      ³±±
±±³Emerson Camp.³16/12/2013³00000030986/2013³TIBOYU   ³ Removido todas validacoes relativas ao TAF. ³±±
±±³Emerson Camp.³20/12/2013³00000032666/2013³TICSRH   ³ Implementado tratamento para uso do TOP     ³±±
±±³             ³          ³                ³         ³ na tabela SR8.                              ³±±
±±³Emerson Camp.³02/01/2014³00000031829/2013³TIC261   ³ Ajuste na tabela S053 para atender a fase 2 ³±±
±±³             ³          ³                ³         ³ do eSocial.                                 ³±±
±±³Alessandro S.³03/01/2014³00000013941/2013³THFBYU   ³ Adicionados tratamentos para nao utlizar ta-³±±
±±³             ³          ³                ³         ³ belas do TAF nas validacoes e sim tabelas   ³±±
±±³             ³          ³                ³         ³ do GPE S054 e S057.                         ³±±
±±³Emerson Camp.³07/01/2014³00000030986/2013³TIBOYU   ³ Ajustado tabela S047 par fase 2 do esocial. ³±±
±±³Alessandro S.³10/01/2014³00000031053/2013³TIBPSG   ³ Fase 2 - Rotina de conversao do campos      ³±±
±±³             ³          ³                ³         ³ RA_TPLOGR, RA_TPCTSAL e RA_PORTDEF.         ³±±
±±³Emerson Camp.³13/01/2014³00000000803/2014³TIFBL9   ³-BRA-Criano nova categoriA S049 - Catego-    ³±±
±±³             ³          ³                ³         ³ria de trabalhadores na fase 2-eSocial       ³±±
±±³Alessandro S.³23/01/2014³00000031053/2013³TIBPSG   ³Ajuste para correto tratamento na tabela S054³±±
±±³             ³          ³                ³         ³alterando informacoes conforme fase 2 eSocial³±±
±±³Glaucia M.   ³25/01/2014³00000002384/2014³TIGMLR   ³ Adicao funcao fGM17Nivel, para verificar se ³±±
±±³             ³          ³                ³         ³ usuario logado tem o nivel de acesso        ³±±
±±³             ³          ³                ³         ³ adequado para uso da rotina.                ³±±
±±³Glaucia M.   ³27/01/2014³00000002384/2014³TIGMLR   ³ Ajustes Adicao funcao fGM17Nivel.           ³±±
±±³Alessandro S.³29/01/2014³00000030986/2013³TIBOYU   ³ Ajustes na tabela S047 - Rubricas.          ³±±
±±³Glaucia M.   ³29/01/2014³00000002384/2014³TIGMLR   ³ Ajustes no campo RA_PORTDEF                 ³±±
±±³Glaucia M.   ³29/01/2014³00000002384/2014³TIGMLR   ³ Inclusao de campos fGM17Nivel.              ³±±
±±³Alessandro S.³31/01/2014³00000031821/2013³TIBZZ9   ³ eSocial - Retirada de Multiplos Vinculos ate³±±
±±³             ³          ³                ³         ³ autorizacao de funcionamento.               ³±±
±±³Glaucia M.   ³03/02/2014³00000034847/2013³TIEFTY   ³ Alterar a tela com nova estrategia aplicacao³±±
±±³             ³          ³                ³         ³ de pacote esocial.                          ³±±
±±³Glaucia M.   ³03/02/2014³00000034847/2013³TIEFTY   ³ Inclusao de validacao das tabelas de manuten³±±
±±³             ³          ³                ³         ³ cao.                                        ³±±
±±³Marcia MOura ³05/02/2014³                ³TIHO69   ³ Para geracao do CH                          ³±±
±±³Glaucia M.   ³17/02/2014³00000004735/2014³TIISS0   ³ Alteracao fGM17Nivel, para ser executado    ³±±
±±³             ³          ³                ³         ³ TRMA100 e somente qdo eSocial executado.    ³±±
±±³Glaucia M.   ³18/02/2014³00000004960/2014³TIIL14   ³ Modificacao estrategia de aplicacao compati-³±±
±±³             ³          ³                ³         ³ bilizador eSocial. E ajuste fCargaLogr      ³±±
±±³             ³          ³                ³         ³ o qual e usado no ATUESOC.                  ³±±
±±³Glaucia M.   ³25/02/2014³00000004960/2014³TIIL14   ³ Modificacao estrategia de aplicacao compati-³±±
±±³             ³          ³                ³         ³ bilizador eSocial..                         ³±±
±±³Gustavo M.   ³11/03/2014³00000006438/2014³TIKNBC   ³Ajuste para verificar em todas empresas se   ³±±
±±³             ³          ³                ³         ³as fases forem aplicadas.                    ³±±
±±³Alessandro S.³26/03/2014³00000000808/2014³TIFBLF   ³Adicionada funcao fGP17VrTaf para validacao  ³±±
±±³             ³          ³                ³         ³de campos Taf.                               ³±±
±±³Alessandro S.³26/03/2014³00000008946/2014³TPCA16   ³Ajuste na funcao fEFDsocial para validacao da³±±
±±³             ³          ³                ³         ³fase 1.2 eSocial.. 	                    ³±±
±±³Alessandro S.³02/04/2014³00000009431/2014³TPDBFN   ³Adicionada funcao fGp17VlLotpara validar     ³±±
±±³             ³          ³                ³         ³campo CTT_TIPO2    	                    ³±±
±±³Alessandro S.³02/04/2014³00000000808/2014³TIFBLF   ³Ajuste para na funcao fGP17VrTaf para conside³±±
±±³             ³          ³                ³         ³rar o campo C9R..   	                    ³±±
±±³Glaucia M.   ³03/04/2014³00000009062/2014³TIJDY8   ³Inclusao de GetArea e RestArea nas funcoes   ³±±
±±³             ³          ³                ³         ³que nao tinham este controle, e acerto string³±±
±±³Alessandro S.³04/04/2014³00000000805/2014³TIFBLK   ³Ajuste para verificacao da fase 1.2 eSocial. ³±±
±±³Glaucia M.   ³07/04/2014³00000010642/2014³TPFRL6   ³Ajuste na funcao fEFDSocial.                 ³±±
±±³Glaucia M.   ³07/04/2014³00000009920/2014³TPEEA4   ³Ajuste Fase 3 e validacao pre-requisitos TAF.³±±
±±³Glaucia M.   ³14/04/2014³00000000820/2014³TIFBQ5   ³Ajuste Fase 3 e validacao pre-requisitos TAF.³±±
±±³Alessandro S.³06/05/2014³00000013460/2014³TPLEQK   ³Ajuste na validacao de fase eSocial 1.2, pas-³±±
±±³             ³          ³                ³         ³sou a ser utilizada a tabela RFN.            ³±±
±±³Claudinei S. ³09/09/2014³00000021067/2014³TQAHGM   ³Removidas as checagens de aEfd[1] e aEfd[2]. ³±±
±±³Wagner Mobile³22/01/2015³00000021067/2014³TQAHGM   ³Compatibilização com a versão 11 validada    ³±±
±±³Christiane V.³30/07/2015³PCDEF-52364     ³         ³Adaptação nas funções de validação para CTT. ³±±
±±³Raquel Hager ³17/05/2016³                ³TVFFHH   ³Realizado ajuste na condição do Trigger do   ³±±
±±³             ³          ³		        ³          ³RA_LOGRDSC.									³±±
±±³Raquel Hager³24/08/2016³00000029392/2016³TVTOQD    ³Remoção do uso do parâmetro MV_INTTAF para   ³±±
±±³            ³          ³                 ³          ³release 12.1.7.							    ³±±
±±³Marcia Moura³01/09/2016³                 ³TUWITW    ³Correcoes referentes aos campos Tp Processo  ³±±
±±³            ³          ³                 ³          ³alem disso foi retirado a consitencia de horario³±±
±±³Marcos Cout ³13/04/2016³DRHESOCP-78      ³          ³Compatibilização do E-Social (2.2)          ³±±
±±³Marcos Cout ³17/04/2016³DRHESOCP-93      ³          ³Compatibilização do E-Social (2.2.01)       ³±±
±±³Marcia Moura³27/04/2017³DRHESOCP-38      ³Integracao do TAF - registro s2200                     ³±±
±±³Marcos Cout ³09/05/2017³DRHESOCP-225     ³          ³Realizar a geração do evento S-2300         ³±±
±±³            ³          ³                 ³          ³Compatibilização do eSocial p layout 2.2.01 ³±±
±±³Marcos Cout ³11/05/2017³DRHESOCP-237     ³          ³Ajuste da variavel nIdade para evitar gera- ³±±
±±³            ³          ³                 ³          ³cao de error.log                            ³±±
±±³Marcos Cout ³19/05/2017³DRHESOCP-278     ³          ³Merge de trechos importantes da P11 e P12.16³±±
±±³            ³          ³                 ³          ³Foi criado a função de auxilio do parametro ³±±
±±³            ³          ³                 ³          ³MV_EFDMSG - Exibe a mensagem de XML enviado ³±±
±±³            ³          ³                 ³          ³com sucesso para o TAF.                     ³±±
±±³Marcos Cout ³12/06/2017³DRHESOCP-384     ³          ³War Room (1a Semana) + Merge                ³±±
±±³            ³          ³                 ³          ³Ajustes para retornar os valores de memoria.³±±
±±³Marcos Cout.³13/06/2017³DRHESOCP-363     ³          ³Realizado ajuste necessário para que todos  ³±±
±±³            ³          ³                 ³          ³os campos obrigatórios para o eSocial apa-  ³±±
±±³            ³          ³                 ³          ³reçam na mensagem de confirmação. Realiza-  ³±±
±±³            ³          ³                 ³          ³do ajuste para tratar STATUS "4"            ³±±
±±³Marcos Cout.³14/06/2017³DRHESOCP-419     ³          ³Realizado ajustes para validar status da    ³±±
±±³            ³          ³                 ³          ³rescisão                                    ³±±
±±³Oswaldo L   ³19/06/2017³DRHESOCP-444     ³          ³Ajuste regra do relatorio p/ Deficientes    ³±±
±±³Oswaldo L   ³04/07/17  ³DRHESOCP-552     ³          ³Remover tratativas de campos que passaram   ³±±
±±³            ³          ³                 ³          ³a ser "nao utilizados" no SX3               ³±±
±±³Eduardo Vic ³18/07/17  ³DRHESOCP-617	    ³          ³Ajustes de array aTpAlt e melhoria da rotina³±±
±±³			   ³		  ³				    ³          ³responsavel pelo DE-PARA de erros.			³±±
±±³Marcos Cout ³18/07/17  ³            	    ³          ³Realizado ajustes na função que verifica o  ³±±
±±³			   ³		  ³				    ³          ³STATUS do evento. Adicionado no return lRet ³±±
±±³Marcos Cout ³28/07/2017 ³DRHESOCP-703    ³          ³Realizar ajustes estéticos e padronizados   ³±±
±±³            ³           ³                ³          ³no relatório de Carga Inicial dos Eventos   ³±±
±±|Claudinei S.|07/08/2017|DRHESOCP-774\DRHESOCP-626   |Removida a alteração, subiu indevidamente.  |±±
±±³Eduardo Vic ³15/08/17  ³DRHESOCP-592	    ³          ³Retir da var default lAltEst na FStatusTAF	³±±
±±³Eduardo Vic ³15/08/17  ³DRHESOCP-592	    ³          ³Retir da var default lAltEst na FStatusTAF	³±±
±±³Eduardo V   ³21/08/2017 ³DRHESOCP-902 ³         ³Trat. no campo RA_TPCONTR, onde em caso  do³±±
±±³Eduardo V   ³		   ³			 ³         ³mesmo esteja vazio,preencher com "1" o xml.³±±
±±|Claudinei S.|24/08/2017|DRHESOCP-917\DRHESOCP-882   |Ajuste em fG17VSRA() p/ tratar corretamente |±±
±±|			   |          |                            |a variável de retorno lRet.                 |±±
±±³Marcos Cout |30/08/2017|DRHESOCP-708    |           |Realizar a tratativa da TAG <estCiv> para   ³±±
±±³            |          |                |           |tratar a estado "União Estavel"             ³±±
±±³Marcos Cout |06/09/2017|DRHESOCP-887    |           |Realizando tratativa para que o EstCivi não ³±±
±±³            |          |                |           |bloqueie a integração com o TAF             ³±±
±±³Marcos Cout |14/09/2017|DRHESOCP-1018   |           |Realizando o ajuste necessário para que o   ³±±
±±³            |          |                |           |sistema realize a validação do layout dispo_³±±
±±³            |          |                |           |nível no ambiente para fazer a integração   ³±±
±±³            |          |                |           |entre o SIGAGPE e o SIGATAF                 ³±±
±±³Marcos Cout |20/09/2017|DRHESOCP-1117   |           |Corrigido possível cenário de comparação en_³±±
±±³            |          |                |           |tre 'string x string' que acarreta em error ³±±
±±³Cecília C.  |06/10/2017|DRHESOCP-1381   |           |Ajuste na função fG17Vsrv.                  ³±±
±±³Marcos Cout |12/10/2017|DRHESOCP-1388   |           |Realizado ajustes diversos necessários      ³±±
±±³Eduardo V   |18/10/2017|DRHESOCP-1628   |		   |Inclusao de S1005 no SigaMat				³±±
±±³Eduardo V   |23/10/2017|DRHESOCP-1628   |		   |Inclusão de Validação de Integração S1005	³±±
±±³Cecília C.  |03/11/2017|DRHESOCP-1766   |           |Ajuste na função fG17VSRA.                  ³±±
±±³Eduardo Vic |09/11/2017|DRHESOCP-1895   |		   |Verificação pra checagem de versão 2.4		³±±
±±³Marcos Cout |10/11/2017|DRHESOCP-1950   |           |Realizando ajustes para que a versão seja ve³±±
±±³            |          |                |           |_rificada também na Carga Inicial. Correção ³±±
±±³            |          |                |           |de ErrorLog na Carga Inicial quando não pos_³±±
±±³            |          |                |           |sui versão de envio do evento S-2100/S-2200 ³±±
±±³Marcos Cout |06/12/2017| DRHESOCP-2227  |           |Realizado ajustes na validação do estagiário³±±
±±³            |          |                |           |e do turno de trabalhado. Realizado ajustes ³±±
±±³            |          |                |           |para a consistência e carga inicials  S-1050³±±
±±³Marcos Cout |12/12/2017| DRHESOCP-2201              |Realiza ajustes necessários para trazer cam_³±±
±±³            |          |                            |pos voltados ao Agente Publico no relatório |±±
±±³            |          |                            |de carga e de inconsistencias               |±±
±±³Marcos Cout |18/12/2017| DRHESOCP-2491              |Ajustada a função que retorna o tipo de cate³±±
±±³            |          |                            |goria disponível para TCV e TSV             |±±
±±³Marcos Cout |20/12/2017| DRHESOCP-2449/DRHESOCP-2450|Realizado ajustes para liberar os campos CTT³±±
±±³            |          | DRHESOCP-2452              |TIPO2 e CEI2 quando CTT_TPLOT == "01"       |±±
±±³Marcos Cout |20/12/2017| DRHESOCP-2458  |           |Ajustado a validação do campo RA_PIS e RA_  |±±
±±³            |          |                |           |CARGO para os trabalhadores TSV e TCV       |±±
±±³            |          |                |           |Bloquear os campos quando TPLOT esta vazio  |±±
±±³Cecília C.  |21/12/2017|DRHESOCP-2463   |           |Ajuste no campo RS9_PROES para leiaute 2.4. |±±
±±³Eduardo Vic  |27/12/2017|DRHESOCP-2456  |           |Criação de nova função e tratativa para envio|±±
±±³             |          |               |           |das verbas no evento S-1010.				|±±
±±³João Balbino|28/12/2017|MPRIMESP-13029  |           |Realizado ajustes para que valide as infor- |±±
±±³            |          |                |           |mações corretamente para os trabladores.    |±±
±±³Eduardo V.  |02/01/2018|  DRHESOCP-2646 |		   |Inclusão de consistência de tabelas entre   |±±
±±³            |          |                |		   |TAF e GPE									|±±
±±³Cecília Car.|05/01/2018|  DRHESOCP-2704 |           |Ajuste para não impedir um trabalhador com  |±±
±±³            |          |                |           |estado civil preenchido como união estável  |±±
±±³            |          |                |           |de ser levado para o TAF.                   |±±
±±³Marcos Cout.|05/01/2018|  DRHESOCP-2679 |           |Ajuste para que o LOG da carga inicial do   |±±
±±³            |          |                |           |evento S-1010 Rubricas não ultrapasse o li_ |±±
±±³            |          |                |           |mite da pagina. Realizado ajustes no tamanho|±±
±±³            |          |                |           |do relatório                                |±±
±±³Cecília Carv|08/01/2018|DRHESOCP-2682   |           |Ajuste para geração de contrato intermitente|±±
±±³            |          |                |           | - evento S-2200.                           |±±
±±³João Balbino|12/01/2018|  MPRIMESP-13244|           |Ajuste para validar verba de IR conforme fa-|±±
±±³            |          |                |           |cilitador do cadastro.                      |±±
±±³Marcos Cout |16/01/2018| DRHESOCP-2490  |           |Criando os eventos extemporâneos do even    |±±
±±³            |          |                |           | _to S-1035 - Carreiras Públicas            |±±
±±³Cecília C.  |22/01/2018|DRHESOCP-2859   |           |Ajuste para realizar consistência quando no |±±
±±³            |          |                |           |intervalo está cadastrado meia-noite.       |±±
±±³Marcos Cout |16/02/2018|DRHESOCP-126    |           |Realizando ajustes para geração da integra- |±±
±±³            |          |                |           |ção com evento S-1005 a partir da manuten-  |±±
±±³            |          |                |           |ção de tabelas.                             |±±
±±³Marcos Cout |23/02/2018|DRHESOCP-3059   |           |Realizando ajustes para exclusao em lote    |±±
±±|Claudinei S.|27/02/2018|DRHESOCP-3308   |Ajuste em fGp17SRVEs() para não bloquear as verbas com  |±±
±±|			   |          |				   |Código do IR do eSocial entre 41 e 47.                  |±±
±±|Marcos Cout.|28/02/2018|DRHESOCP-3307   |           |Realizado ajustes para geração do evento de |±±
±±|            |          |                |           |exclusão dentro da carga inicial            |±±
±±|Eduardo vic |02/03/2018|DRHESOCP-3167			   | inclusão de validação de tab compartilhada |±±
±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fEFDsocial³ Autor ³ Emerson Campos        ³ Data ³ 12/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por liberar o uso e validacao das       ³±±
±±³          ³ implementacoes e-Social - Fase 1 - Cadastros               ³±±
±±³          ³ Fase 2 eSocial so sera liberada apos implantação da fase 1 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ Em diversas rotinas do modulo SIGAGPE/SIGATRM/SIGAAPT      ³±±
±±³          ³ Valid do campo CTT_TPLOT                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao se aplica.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com 3 posicoes, de conteudo logico (.T./.F.), para   ³±±
±±³          ³ indicar em qual fase da eSocial, encontra-se o ambiente em ³±±
±±³          ³ uso.                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fEFDSocial()
Local aArea		:= GetArea()
Local aRetorno := {.F.,.F.,.F.,.F.}
Local cEfdAvis := ""
LOCAL lMVEFD := SUPERGETMV("MV_EFD",.F.,.F.)

STATIC aEfd
STATIC lFase1
STATIC lFase2
STATIC lFase3
STATIC lFase4

DEFAULT lFase1	:= (.F.)
DEFAULT lFase2	:= (.F.)
DEFAULT lFase3	:= (.F.)
DEFAULT lFase4	:= (.F.)

If aEfd <> Nil
	lFase1	:= aEfd[1]
	lFase2	:= aEfd[2]
	lFase3	:= aEfd[3]
	lFase4	:= aEfd[4]
Else
	cEfdAvis:= SuperGetMV("MV_EFDAVIS",.F.,"9")

	dbSelectArea("SX3")
	SX3->(DbSetorder(2))

	If SX3->(dbSeek("RA_NSOCIAL"))
		lFase1:= lFase2:= lFase3:= lFase4:= .T.
	ElseIf SX3->(dbSeek("RA_CLASEST"))
		lFase1:= lFase2:= lFase3:= .T.
	ElseIf SX3->(dbSeek("CTT_TPLOT"))
		lFase1:= lFase2:= .T.
	ElseIf cEfdAvis <> "9"
		lFase1 := .T.
	Endif

Endif

aRetorno := {lFase1,lFase2,lFase3,lFase4}

RestArea(aArea)
Return (aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fEFDAviso ³ Autor ³ Mauricio MR/Glaucia M ³ Data ³ 06/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função que define o comportamento do sistema conforme a de ³±±
±±³          ³ teccao de inconsistencia para atendimento da eSocial.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Obtem conteudo do parametro MV_EFDAVIS.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ "0" - Exibe aviso, sem impedimento de prosseguimento.      ³±±
±±³          ³ "1" - Exibe aviso e impedide o prosseguimento, se as condi-³±±
±±³          ³       coes noa forem atendidas.                            ³±±
±±³          ³ "2" - Nao emite aviso e sem impedimento de prosseguimento. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fEFDAviso()
Local aArea		:= GetArea()
Local cRetorno := "0"

cRetorno := SuperGetMv( "MV_EFDAVIS" ,NIL, "0" ) //Exibe aviso sem impedimento do prosseguimento

RestArea(aArea)
Return (cRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fCargaLogr³ Autor ³ Glaucia M.		    ³ Data ³ 14/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas Logradouros (S54 e S55) e obtem   ³±±
±±³          ³o cod tipo logradouro, descricao tipo logradouro, logradouro³±±
±±³          ³e numero logradouro, usando o conteudo dos campos RA_ENDEREC³±±
±±³          ³e RA_NUMENDE.  eSocial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fCargaLogr(nOpc) 									 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Numero da acao Aitva (inc- alt- vis - apagar)	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ P11                                  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fCargaLogr(cRA_ENDERE,cRA_NUMENDE)
Local aArea		:= GetArea()
Local x			:= 0
Local y			:= 0
Local nPos1		:= 0
Local nPos2		:= 0
Local cTipoLogr	:=""
Local cDescLogr	:=""
Local cNumLogr	:=""
Local aLogr		:={}
Local cEnd, cNum
Local aRet:= {"","",""}

If Valtype(aTLogr) != "A"
	aTLogr		:={}

	dbSelectArea("RCC")
	dbSetOrder(1)
	MsSeek(xFilial("RCC")+"S054")
	While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+"S054"
		aLogr:= {}
		Aadd(aLogr, {Alltrim(Substr(RCC->RCC_CONTEU,4,20))})
		nPriPos := At("|", Alltrim(Substr(RCC->RCC_CONTEU,0,len(RCC->RCC_CONTEU))) )
		cEnd	:= Substr(RCC->RCC_CONTEU,nPriPos,len(RCC->RCC_CONTEU))
		While len(cEnd)> 0
			nPos1	:=	At("|", Substr(cEnd,1,len(cEnd)) )
			nPos2	:=  At("|", Substr(cEnd,nPos1+1,len(cEnd)) )
			If nPos2 == 0
				cEnd:= ""
			Else
				Aadd(aLogr, {Substr(cEnd,nPos1+1,nPos2-1)})
				cEnd	:= Substr(cEnd,nPos1+nPos2,len(cEnd))
			Endif
		End
		Aadd (aTLogr,aLogr)
		dBSkip()
	End
EndIf

If Valtype(aLogrNum) != "A"
	aLogrNum:={}
	cNum := fDescRCC("S055","01",1,2,38,67)
	While len(cNum)> 0
		nPos1	:=	At("|", Substr(cNum,1,len(cNum)) )
		nPos2	:=  At("|", Substr(cNum,nPos1+1,len(cNum)) )
		If nPos2 == 0
			cNum:= ""
		Else
			Aadd(aLogrNum, {Substr(cNum,nPos1+1,nPos2-1)})
			cNum	:= Substr(cNum,nPos1+nPos2,len(cNum))
		Endif
	End
EndIf

If !empty(cRA_ENDERE)
	For x:=1 to len(aTLogr)
		For y:=1 to len(aTLogr[x])
			If at(UPPER(aTLogr[x,y,1]),cRA_ENDERE) == 1
				cTipoLogr:= aTLogr[x,1,1]
				cDescLogr:=ALLTRIM(SUBSTR(cRA_ENDERE,LEN(aTLogr[x,y,1])+1,LEN(cRA_ENDERE)))
				exit
			Endif
		Next y
	Next x
EndIf

If !empty(cRA_NUMENDE)
	cNumLogr :=cRA_NUMENDE
Else
	If !empty(cDescLogr)
		For x:=1 to len(aLogrNum)
			nPos1:= Rat(UPPER(aLogrNum[x,1]),cDescLogr)
			If (nPos1 > 1)
				cNumLogr:= ALLTRIM(SUBSTR(cDescLogr,nPos1+len(aLogrNum[x,1]),len(cDescLogr)))
				cDescLogr:= SUBSTR(cDescLogr,0,nPos1-1)
				Exit
			EndIf
		Next x
	Endif
EndIf

If cDescLogr == ""
	cDescLogr:= cRA_ENDERE
EndIf

aRet:={fDescRCC("S054",cTipoLogr,4,20,1,3),cDescLogr,cNumLogr}

RestArea(aArea)
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17Opt ³ Autor ³ Glaucia M 			³ Data ³ 06/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela que apresenta opcoes de gravacao da tabela  SRA com   ³±±
±±³          ³ reordenacao de campos ou os campos novos na pasta eSocial. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ So estara disponivel enquanto a Fase 2 nao for liberada aos³±±
±±³          ³ Clientes.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 			                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fGPM17Opt()

Local oSay1, oSay2, oSay3, oSay4
Local aArea		:= GetArea()
Local nRadio 	:= 1
local lOpt 		:= .F.
Local oRadio, oGroup1,oDlgPerg

Local aAdv1Size			:= {}
Local aInfo1AdvSize		:= {}
Local aObj1Size			:= {}
Local aObj1Coords		:= {}

Local aAdv12Size		:= {}
Local aInfo12AdvSize	:= {}
Local aObj12Size 		:= {}
Local aObj12Coords		:= {}

Local lOk				:= .F.
Local bFecha			:= {||lOk:=.F., oDlgPerg:End()}
Local bOK				:= {||lOk:=.T., oDlgPerg:End()}

aAdv1Size	:= MsAdvSize(,.T.,380)
aInfo1AdvSize	:= { aAdv1Size[1] , aAdv1Size[2] , aAdv1Size[3] , aAdv1Size[4] , 15 , 15}
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. })
aAdd(aObj1Coords , { 000 , 020 , .T. , .F. })
aAdd(aObj1Coords , { 000 , 000 , .T. , .T. })
aAdd(aObj1Coords , { 000 , 020 , .T. , .F. })
aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )

aAdv12Size		:= aClone(aObj1Size[3])
aInfo12AdvSize	:= { aAdv12Size[2] , aAdv12Size[1] , aAdv12Size[4] , aAdv12Size[3] , 1 , 1 }
aAdd( aObj12Coords , { 005 , 000 , .F. , .T. } )			//1-Coluna 1
aAdd( aObj12Coords , { 000 , 000 , .T. , .T. } )			//2-Coluna 2
aObj12Size		:= MsObjSize( aInfo12AdvSize , aObj12Coords,,.T. )


DEFINE MSDIALOG oDlgPerg FROM aAdv1Size[7],0 TO aAdv1Size[6],aAdv1Size[5] TITLE OemToAnsi(STR0082) OF oMainWnd PIXEL //"Implantação eSocial:"

	oSay1:= tSay():New(aObj1Size[2,1],aObj1Size[2,2]+5,{||OemToAnsi(STR0089)},oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,270,10) //"Sua dicionário em uso foi analisado, concluiu-se que não foram efetuadas adaptações para o eSocial,"
	oSay2:= tSay():New(aObj1Size[2,1]+10,aObj1Size[2,2]+5,{||OemToAnsi(STR0090)},oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,270,10) //"sendo assim iniciaremos a compatibilização do dicionário, para atender ao leiaute 1.1 do eSocial"
	oSay3:= tSay():New(aObj1Size[2,1]+20,aObj1Size[2,2]+5,{||OemToAnsi(STR0091)},oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,270,10) //"(Publicada através da  CIRCULAR Nº 642, de 6 de janeiro de 2014, da Caixa Econômica Federal,"
	oSay4:= tSay():New(aObj1Size[2,1]+30,aObj1Size[2,2]+5,{||OemToAnsi(STR0092)},oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,270,10) //"publicada em 7 de janeiro de 2014 no Diário Oficial da União)"

	oRadio := TRadMenu():New (aObj12Size[2,1]+20,aObj12Size[2,2],;
		{	OemToAnsi(STR0007),; 												//'Os campos ja existentes serão reordenados em conjunto com os novos, inclusive com criação de novas abas.'
			OemToAnsi(STR0008)},,oDlgPerg,,,,,,,,300,200,,,,.T.)				//'Os novos campos serão alocados em nova aba eSocial, a ordem dos campos ja existentes nao sera alterada.'

	oRadio:SetOption(1)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

	@ aObj1Size[1,1] , aObj1Size[1,2] GROUP oGroup TO aObj1Size[4,3], aObj1Size[4,4]   OF oDlgPerg PIXEL

ACTIVATE MSDIALOG oDlgPerg CENTERED ON INIT EnchoiceBar( oDlgPerg , bOK , bFecha ,NIL, NIL,NIL )

lOpt:= IIf (nRadio==1,.F.,.T.)

If lOK
	aOpt := {1,lOpt}
Else
	aOpt := {9,.F.}
EndIf

RestArea(aArea)
Return aOpt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17Fas ³ Autor ³ Glaucia M 			³ Data ³ 10/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela que apresenta opcoes de gravacao da tabela  SRA com   ³±±
±±³          ³ reordenacao de campos ou os campos novos na pasta eSocial. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ So estara disponivel enquanto a Fase 2 nao for liberada aos³±±
±±³          ³ Clientes.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 			                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17Fas()

Local oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7
Local aArea		:= GetArea()
local lOpt 		:= .F.
Local oGroup1,oDlgPerg
Local aAdv1Size			:= {}
Local aInfo1AdvSize		:= {}
Local aObj1Size			:= {}
Local aObj1Coords		:= {}
Local lOk				:= .F.
Local bFecha			:= {||lOk:=.F., oDlgPerg:End()}
Local bOK				:= {||lOk:=.T., oDlgPerg:End()}

aAdv1Size	:= MsAdvSize(,.T.,380)
aInfo1AdvSize	:= { aAdv1Size[1] , aAdv1Size[2] , aAdv1Size[3] , aAdv1Size[4] , 1 , 1}
aAdd(aObj1Coords , { 000 , 000 , .T. , .T. }) //1-
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //2-Say 1
aAdd(aObj1Coords , { 000 , 020 , .T. , .F. }) //3-Say 2
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //4-Say 3
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //5-Say 4
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //6-Say 5
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //7-Say 6
aAdd(aObj1Coords , { 000 , 000 , .T. , .T. }) //8-
aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )

DEFINE MSDIALOG oDlgPerg FROM aAdv1Size[7],0 TO aAdv1Size[6],aAdv1Size[5] TITLE OemToAnsi(STR0082) OF oMainWnd PIXEL //"Implantação eSocial:"

	oSay1:= tSay():New(aObj1Size[2,1],aObj1Size[2,2]+10,{||OemToAnsi(STR0083)}			,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10) //"Sua Base de Dados em uso foi analisada, concluiu-se que as adaptações para o eSocial já foram realizadas, desta forma"
	oSay2:= tSay():New(aObj1Size[3,1],aObj1Size[3,2]+10,{||OemToAnsi(STR0084)}			,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10) //"iniciaremos agora a compatibilização do dicionário que tem os seguintes objetivos:"
	oSay3:= tSay():New(aObj1Size[4,1],aObj1Size[4,2]+10,{||OemToAnsi(STR0085)}			,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10) //"1-Adaptação para atender ao leiaute eSocial versão 1.1 (Publicada através da  CIRCULAR Nº 642, de 6 de janeiro"
	oSay4:= tSay():New(aObj1Size[5,1],aObj1Size[5,2]+10,{||"  "+OemToAnsi(STR0086)+"."}	,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10) //"de 2014, da Caixa Econômica Federal, DOU 7 de janeiro de 2014.)"
	oSay5:= tSay():New(aObj1Size[6,1],aObj1Size[6,2]+10,{||OemToAnsi(STR0087)+"."}		,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10) //"2-Inclusão de campos a serem utilizados no eSocial  na Tabela de Centro de Custo"
	oSay6:= tSay():New(aObj1Size[7,1],aObj1Size[7,2]+10,{||OemToAnsi(STR0088)}			,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,15) //"3-Conversão dos dados nas tabelas SRV, SRA e SR8, caso os mesmos já tenham sido inseridos. Maiores informações"
	oSay7:= tSay():New(aObj1Size[8,1],aObj1Size[8,2]+10,{||"  "+OemToAnsi(STR0093)+"."}	,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,15) //"consulte o boletim"

	@ aObj1Size[1,1] , aObj1Size[1,2] GROUP oGroup TO aObj1Size[8,3], aObj1Size[8,4]  OF oDlgPerg PIXEL

ACTIVATE MSDIALOG oDlgPerg CENTERED ON INIT EnchoiceBar( oDlgPerg , bOK , bFecha ,NIL, NIL,NIL )

If lOK
	aOpt := {1,lOpt}
Else
	aOpt := {9,.F.}
EndIf

RestArea(aArea)

Return aOpt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17Cor ³ Autor ³ Glaucia M 			³ Data ³ 17/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela  informa que a fase 1 e 1.1 eSocial foram aplicadas   ³±±
±±³          ³ e ha disponiveis correcoes.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 			                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17Cor()

Local oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oSay8
Local oCheck1
Local oCheck2
Local lCheck2	:= .F.
Local lCheck1	:= .T.
Local aArea		:= GetArea()
local lOpt 		:= .F.
Local oGroup1,oDlgPerg
Local aAdv1Size			:= {}
Local aInfo1AdvSize		:= {}
Local aObj1Size			:= {}
Local aObj1Coords		:= {}
Local lOk				:= .F.
Local bFecha			:= {||lOk:=.F., oDlgPerg:End()}
Local bOK				:= {||lOk:=.T., oDlgPerg:End()}
Local aAjustes			:= {}


aAdv1Size	:= MsAdvSize(,.T.,380)
aInfo1AdvSize	:= { aAdv1Size[1] , aAdv1Size[2] , aAdv1Size[3] , aAdv1Size[4] , 1 , 1}
aAdd(aObj1Coords , { 000 , 000 , .T. , .T. }) //1-
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //2-Say 1
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //3-Say 2
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //4-Say 3
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //5-Say 4
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //6-espaco
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //7-check
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //8-Say 5
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //9-Say 6
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //10-Say 7
aAdd(aObj1Coords , { 000 , 010 , .T. , .F. }) //11-Say 8
aAdd(aObj1Coords , { 000 , 000 , .T. , .T. }) //12-
aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )

DEFINE MSDIALOG oDlgPerg FROM aAdv1Size[7],0 TO aAdv1Size[6],aAdv1Size[5] TITLE OemToAnsi(STR0082) OF oMainWnd PIXEL //"Implantação eSocial:"

	oSay1:= tSay():New(aObj1Size[2,1],aObj1Size[2,2]+10,{||OemToAnsi(STR0096)}	,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10) //"Sua Base de Dados em uso foi analisada, concluiu-se que as adaptações para o eSocial Fase 1.1 foram aplicadas,"
	oSay2:= tSay():New(aObj1Size[3,1],aObj1Size[3,2]+10,{||OemToAnsi(STR0097)}	,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10) //"desta forma, realizaremos: "

	oCheck1 := TcheckBox():New(aObj1Size[4,1],aObj1Size[4,2]+10,OemToAnsi(STR0098),{|| lCheck1 },oDlgPerg, 300,10,,{|| lCheck1 },,,,,,.T.,,,{||.F.})	//"Ajustes no dicionário de dados das seguintes tabelas: SRA, CTT, RCE e SR8."
	oSay4:= tSay():New(aObj1Size[5,1],aObj1Size[5,2]+25,{||OemToAnsi(STR0099)}	,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10)	//"Este ajuste será executado independentemente da opção abaixo, ao pressionar o botão 'CONFIRMAR'."

	oCheck2 := TcheckBox():New(aObj1Size[7,1],aObj1Size[7,2]+10,OemToAnsi(STR0100),{|| lCheck2  },oDlgPerg, 300,10,,{|| lCheck2:=!lCheck2 },,,,,,.T.,,,)	//"OPCIONALMENTE: Ajustes na conversão do tipo de logradouros, realizados no eSocial Fase 1.1."

	oSay5:= tSay():New(aObj1Size[8,1],aObj1Size[8,2]+25,{||OemToAnsi(STR0101)}	,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10)	//"IMPORTANTE: Só MARQUE este item se o campo Tipo de Logradouro (RA_LOGRTP) 'NÃO FOI ALTERADO' "
	oSay6:= tSay():New(aObj1Size[9,1],aObj1Size[9,2]+25,{||OemToAnsi(STR0102)}	,oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10)	//"no cadastro de Funcionários, após a execução do compatibilizador eSocial Fase 1.1., pois "
	oSay7:= tSay():New(aObj1Size[10,1],aObj1Size[10,2]+25,{||OemToAnsi(STR0103)},oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10)	//"o campo será regravado com o Tipo de Logradouro extraído do campo de Endereço (RA_ENDEREC)."
	oSay8:= tSay():New(aObj1Size[11,1],aObj1Size[11,2]+25,{||OemToAnsi(STR0104)},oDlgPerg,,,,,,.T.,CLR_BLACK,CLR_WHITE,300,10)	//"Esta extração de Tipo de Logradouro, utilizaremos as abreviação da tabela S054."

	@ aObj1Size[1,1] , aObj1Size[1,2] GROUP oGroup TO aObj1Size[12,3], aObj1Size[12,4]  OF oDlgPerg PIXEL

ACTIVATE MSDIALOG oDlgPerg CENTERED ON INIT EnchoiceBar( oDlgPerg , bOK , bFecha ,NIL, NIL,NIL )

If lOK
	aOpt := {1,lOpt, lCheck2 }
Else
	aOpt := {9,.F.}
EndIf

RestArea(aArea)

Return aOpt


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17FPAS³ Autor ³ Glaucia M 			³ Data ³ 28/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador do campo CTT_SIT                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Cadastro Centro Custo - Tomador                  ³±±
±±³          ³ Rotina CTBA030 - Tabela 4 eSocial                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cFPAS - Codigo FPAS e cCODTER-Codigo terceiros	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17FPAS(cFPAS,cCODTER)

Local aArea			:= GetArea()
Local cSituacao		:= ""

If !EMPTY(cFPAS) .AND. !EMPTY(cCODTER)
	dbSelectArea("C8A")
	C8A->(dbSetOrder(2))
	C8A->(DbGotop())
	While !(C8A->( EOF() ))
		If (ALLTRIM(cFPAS) == ALLTRIM(C8A->C8A_CDFPAS) .AND. ALLTRIM(cCODTER) ==  ALLTRIM(C8A->C8A_CODTER) .AND. (C8A->C8A_VALIDA>=Ddatabase .OR. EMPTY(C8A->C8A_VALIDA)))
			cSituacao:= SUBSTR(C8A->C8A_SITCTB,1,70)
			Exit
		Endif
		C8A->(DbSkip())
	End
EndIf

RestArea(aArea)
Return cSituacao


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17LOT ³ Autor ³ Glaucia M 			³ Data ³ 28/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador do campo CTT_SIT                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Cadastro Centro Custo - Tomador                  ³±±
±±³          ³ Rotina CTBA030 - Tabela 10 eSocial                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cTpLotacao - Codigo Tipo de Lotacao         	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17LOT(cTpLotacao)

Local aArea			:= GetArea()
Local cLotDescr		:= ""

If !EMPTY(cTpLotacao)
	dbSelectArea("RCC")
	dbSetOrder(1)
	MsSeek(xFilial("RCC")+"S057")
	While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+"S057"
		If ALLTRIM(cTpLotacao) == SUBS(RCC->RCC_CONTEU, 1, 2)
			cLotDescr	:= SUBSTR(RCC->RCC_CONTEU,3,70)
			Exit
		Endif
		RCC->(DbSkip())
	End
EndIf

RestArea(aArea)
Return cLotDescr


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17vLT ³ Autor ³ Glaucia M 			³ Data ³ 28/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do campo CTT_TPLOT                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Cadastro Centro Custo - Tomador                  ³±±
±±³          ³ Rotina CTBA030 - Tabela 10 eSocial                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cTpLotacao - Codigo Tipo de Lotacao         	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17vLT(cTpLotacao)

Local aArea			:= GetArea()
Local lRet			:= .F.

If !EMPTY(cTpLotacao)
	dbSelectArea("RCC")
	dbSetOrder(1)
	MsSeek(xFilial("RCC")+"S057")
	While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+"S057"
		If ALLTRIM(cTpLotacao) == SUBS(RCC->RCC_CONTEU, 1, 2)
			lRet:= .T.
			Exit
		Endif
		RCC->(DbSkip())
	End
EndIf

If !lRet
	Help( ,, 'HELP',,OemToAnsi(STR0026) , 1, 0 )	//"Tipo de Lotação Inválida"
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17INSC³ Autor ³ Glaucia M 			³ Data ³ 28/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validador de Tipo de Incricao x Inscricao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial -  Tabela 5                                        ³±±
±±³          ³ Rotina CTBA030 -                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cTpIns - Tipo de Inscricao 1/2/3/4                        ³±±
±±³          ³ 	cInsc -  A inscricao correspondente ao Tipo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fGPM17INSC(cTpIns,cInsc)
Local aArea		:= GetArea()
Local lRet		:=	.T.

If cTpIns =="1"
	If (cInsc =='00000000000000') .OR. (EMPTY(cInsc)) .OR. (LEN(cInsc) < 14) .OR. !(CNPJ(cInsc))
		Help( ,, 'HELP',,OemToAnsi(STR0025) , 1, 0 )		//"Inscrição inválida ou incompatível com o Tipo."
		lRet	:=  .F.
	EndIf
ElseIf cTpIns =="2"
	If empty(cInsc) .OR. !(ChkCPF(cInsc))
		lRet 	:= 	.F.
	EndIf
EndIf

RestArea(aArea)
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGPM17TAF ³ Autor ³ Glaucia Messina       ³ Data ³ 29/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por verificar se o TAF esta em uso      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao se aplica.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Boolean                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17TAF()
Local aArea		:= GetArea()
Local lRetorno := .F.

dbSelectArea("SX3")
DbSetorder(2)

lRetorno := SX3->(dbSeek("C8A_CDFPAS"))

RestArea(aArea)
Return (lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGP17vFPAS³ Autor ³ Glaucia M 			³ Data ³ 30/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valid do campo CTT_FPAS                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Cadastro Centro Custo - Tomador                  ³±±
±±³          ³ Rotina CTBA030 - Tabela 4 eSocial                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cFPAS - Codigo FPAS e cCODTER-Codigo terceiros	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGP17vFPAS(cFPAS,cCODTER)

Local aArea			:= GetArea()
Local lRet			:= .F.

If !EMPTY(cFPAS) .AND. !EMPTY(cCODTER)
	dbSelectArea("C8A")
	C8A->(dbSetOrder(2))
	C8A->(DbGotop())
	While !(C8A->( EOF() ))
		If (ALLTRIM(cFPAS) == ALLTRIM(C8A->C8A_CDFPAS) .AND. ALLTRIM(cCODTER) ==  ALLTRIM(C8A->C8A_CODTER) .AND. (C8A->C8A_VALIDA>=Ddatabase .OR. EMPTY(C8A->C8A_VALIDA)))
			lRet			:= .T.
			Exit
		Endif
		C8A->(DbSkip())
	End
EndIf
RestArea(aArea)

If !lRet
	Help( ,, 'HELP',,OemToAnsi(STR0024) , 1, 0 ) //"Código FPAS inválido.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGPM17LGR ³ Autor ³ Glaucia M.		    ³ Data ³ 05/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Regra gatilho logradouros.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGPM17LGR()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao se aplica.				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010/ CTBA030  - Regra Gatilhos                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGPM17LGR(cLOGRTP,cLogrDSC,cLOGRTPD)

Local aArea		:= GetArea()
Local cLOGRabrv	:= ""
Local cReturn	:=''
DEFAULT cLOGRTP		:= ALLTRIM(M->RA_LOGRTP)
DEFAULT cLogrDSC 	:= ALLTRIM(M->RA_LOGRDSC)
DEFAULT cLOGRTPD	:= ALLTRIM(M->RA_LOGRTPD)

cLOGRabrv	:=	ALLTRIM(fDescRCC('S054',cLOGRTP,1,3,24,10))

nPosIni:= AT("|",cLOGRabrv)
nPosFim:= AT("|",SUBSTR(cLOGRabrv,nPosIni+1,(len(cLOGRabrv)-1)))
cLOGRabrv:= SUBSTR(cLOGRabrv,nPosIni+1,nPosFim-1)

If !EMPTY(cLOGRTP)
	If !EMPTY(cLOGRabrv)
		cReturn := SUBSTR(cLOGRabrv + " "+cLogrDSC,1,30)
	Else
		cReturn := SUBSTR(cLOGRTPD + " "+cLogrDSC,1,30)
	EndIf
EndIf

If EMPTY(cReturn)
	cReturn := SUBSTR(cLogrDSC,1,30)
EndIf

RestArea(aArea)

Return( cReturn )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGPM17LGC ³ Autor ³ Glaucia M.		    ³ Data ³ 05/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Condicao para executar gatilhos de logradouro.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGPM17LGC()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010/ CTBA030  - Condicao Gatilhos                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGPM17LGC(cLogrDSC,cEnderec)

Local aArea		:=GetArea()
Local lRet 		:= .F.
Local lIsEquals := .F.

DEFAULT cLogrDSC := ALLTRIM(M->RA_LOGRDSC)
DEFAULT cEnderec := ALLTRIM(M->RA_ENDEREC)

// - Variável para ativar o gatilho caso o conteúdo dos campos RA_LOGRDSC e RA_ENDEREC sejam iguais
// - e houver alteração no RA_LOGRDSC, fazendo assim o trigger para o campo RA_ENDEREC.
lIsEquals := !( Alltrim(cLogrDSC) == Alltrim(cEnderec) )

If !EMPTY(cLogrDSC) .AND. (EMPTY(cEnderec) .OR. (AT(SUBSTR(cLogrDSC,1,15),cEnderec )) > 0 .Or. lIsEquals)
	lRet := .T.
EndIf

RestArea(aArea)

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³updRubrSRV ³ Autor ³ Emerson Campos        ³ Data ³04/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza campo RV_NATUREZ com a novas rubricas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., se a gravação foi bem sucedida                         ³±±
±±³          ³ .F., caso contrário                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function updRubrSRV()
Local aArea       	:= GetArea()
Local lRet        	:= .F.
Local lAlter		:= .F.
Local aRubr			:= {}
Local aDePara		:= {}
Local nPos			:= 0
Local nTam 			:= 0
lOkFs2				:= .F.

DbSelectArea("RCC")
DbSetOrder(1)
dbSeek(xFilial("RCC") + "S047")
While RCC->(!EOF()) .AND. xFilial('RCC') + "S047" == RCC->RCC_FILIAL+RCC->RCC_CODIGO
	If AllTrim(Substr(RCC->RCC_CONTEU,1,50)) == '1001Vencimento, soldo, subsidio'
		lOkFs2	:= .T.
		Exit
	EndIf
	RCC->(DbSkip())
EndDo


If lOkFs2
	aAdd( aDePara, {'1213','1225'})

	//aAdd(aRubr,{DE,      PARA, "Em branco Exclui/com texto altera",      [.T.-Inclui][.F.-Altera/Exclui]})
	aAdd( aRubr, {'001', '1000', 'Salário, vencimento, soldo ou subsídio'})
	aAdd( aRubr, {'002', '1002', 'Descanso semanal remunerado - DSR'})
	aAdd( aRubr, {'003', '1003', 'Horas extraordinárias'})
	aAdd( aRubr, {'004', '1004', 'Horas extraordinárias - Indenização de banco de horas'})
	aAdd( aRubr, {'005', '1005', 'Direito de arena'})
	aAdd( aRubr, {'006', '1006', 'Intervalos intra e inter jornadas não concedidos'})
	aAdd( aRubr, {'007', '1007', 'Luvas e premiações'})
	aAdd( aRubr, {'008', '1009', 'Salário-família - complemento'})
	aAdd( aRubr, {'009', '1010', 'Salário in natura - pagos em bens ou serviços'})
	aAdd( aRubr, {'010', '1011', 'Sobreaviso e prontidão'})
	aAdd( aRubr, {'011', '1020', 'Férias - gozadas'})
	aAdd( aRubr, {'012', '1021', 'Férias - abono ou gratificação de férias superior a 20 dias'})
	aAdd( aRubr, {'013', '1022', 'Férias - abono ou gratificação de férias não excedente a 20 dias'})
	aAdd( aRubr, {'014', '1023', 'Férias - abono pecuniário'})
	aAdd( aRubr, {'015', '1024', 'Férias - o dobro na vigência do contrato'})
	aAdd( aRubr, {'016', '1040', 'Licença-prêmio'})
	aAdd( aRubr, {'017', '1041', 'Licença-prêmio indenizada'})
	aAdd( aRubr, {'018', '1050', 'Remuneração de dias de afastamento'})
	aAdd( aRubr, {'019', '1080', 'Stock Option'})
	aAdd( aRubr, {'020', '1099', 'Outras verbas salariais'})
	aAdd( aRubr, {'021', '1201', 'Adicional de função / cargo confiança'})
	aAdd( aRubr, {'022', '1202', 'Adicional de insalubridade'})
	aAdd( aRubr, {'023', '1203', 'Adicional de periculosidade'})
	aAdd( aRubr, {'024', '1204', 'Adicional de transferência'})
	aAdd( aRubr, {'025', '1205', 'Adicional noturno'})
	aAdd( aRubr, {'026', '1206', 'Adicional por tempo de serviço'})
	aAdd( aRubr, {'027', '1207', 'Comissões, porcentagens, produção'})
	aAdd( aRubr, {'028', '1208', 'Gueltas ou gorjetas - repassadas por fornecedores ou clientes'})
	aAdd( aRubr, {'029', '1209', 'Gueltas ou gorjetas - repassadas pelo empregador'})
	aAdd( aRubr, {'030', '1210', 'Gratificação por acordo ou convenção coletiva'})
	aAdd( aRubr, {'031', '1211', 'Gratificações'})
	aAdd( aRubr, {'032', '1212', 'Gratificações ou outras verbas de natureza permanente'})
	aAdd( aRubr, {'033', '1213', 'Gratificações ou outras verbas de natureza transitória'})
	aAdd( aRubr, {'034', '1214', 'Adicional de penosidade'})
	aAdd( aRubr, {'035', '1215', 'Adicional de unidocência'})
	aAdd( aRubr, {'036', '1225', 'Quebra de caixa'})
	aAdd( aRubr, {'037', '1230', 'Remuneração do dirigente sindical'})
	aAdd( aRubr, {'038', '1299', 'Outros adicionais'})
	aAdd( aRubr, {'039', '1300', 'PLR - Participação em Lucros ou Resultados'})
	aAdd( aRubr, {'040', '1350', 'Bolsa de estudo - estagiário'})
	aAdd( aRubr, {'041', '1351', 'Bolsa de estudo - médico residente'})
	aAdd( aRubr, {'042', '1352', 'Bolsa de estudo ou pesquisa'})
	aAdd( aRubr, {'043', '1401', 'Abono'})
	aAdd( aRubr, {'044', '1402', 'Abono PIS / PASEP'})
	aAdd( aRubr, {'045', '1403', 'Abono legal'})
	aAdd( aRubr, {'046', '1404', 'Auxílio babá'})
	aAdd( aRubr, {'047', '1405', 'Assistência médica'})
	aAdd( aRubr, {'048', '1406', 'Auxílio-creche'})
	aAdd( aRubr, {'049', '1407', 'Auxílio-educação'})
	aAdd( aRubr, {'050', '1409', 'Salário-família'})
	aAdd( aRubr, {'051', '1410', 'Auxílio - Locais de difícil acesso'})
	aAdd( aRubr, {'052', '1601', 'Ajuda de custo - aeronauta'})
	aAdd( aRubr, {'053', '1602', 'Ajuda de custo de transferência'})
	aAdd( aRubr, {'054', '1620', 'Ressarcimento de despesas pelo uso de veículo próprio'})
	aAdd( aRubr, {'055', '1621', 'Ressarcimento de despesas de viagem, exceto despesas com veículos'})
	aAdd( aRubr, {'056', '1623', 'Ressarcimento de provisão'})
	aAdd( aRubr, {'057', '1629', 'Ressarcimento de outras despesas'})
	aAdd( aRubr, {'058', '1651', 'Diárias de viagem - até 50% do salário'})
	aAdd( aRubr, {'059', '1652', 'Diárias de viagem - acima de 50% do salário'})
	aAdd( aRubr, {'060', '1801', 'Alimentação'})
	aAdd( aRubr, {'061', '1802', 'Etapas (marítimos)'})
	aAdd( aRubr, {'062', '1805', 'Moradia'})
	aAdd( aRubr, {'063', '1810', 'Transporte'})
	aAdd( aRubr, {'064', '2501', 'Prêmios'})
	aAdd( aRubr, {'065', '2510', 'Direitos autorais e intelectuais'})
	aAdd( aRubr, {'066', '2801', 'Quarentena remunerada'})
	aAdd( aRubr, {'067', '2901', 'Empréstimos'})
	aAdd( aRubr, {'068', '2902', 'Vestuário e equipamentos'})
	aAdd( aRubr, {'069', '2920', 'Reembolsos diversos'})
	aAdd( aRubr, {'070', '2930', 'Insuficiência de saldo'})
	aAdd( aRubr, {'071', '2999', 'Arredondamentos'})
	aAdd( aRubr, {'072', '3501', 'Remuneração por prestação de serviços'})
	aAdd( aRubr, {'073', '3505', 'Retiradas (pró-labore) de diretores empregados'})
	aAdd( aRubr, {'074', '3506', 'Retiradas (pró-labore) de diretores não empregados'})
	aAdd( aRubr, {'075', '3508', 'Retiradas (pró-labore) de proprietários ou sócios'})
	aAdd( aRubr, {'076', '3509', 'Honorários a conselheiros'})
	aAdd( aRubr, {'077', '3520', 'Remuneração de cooperado'})
	aAdd( aRubr, {'078', '4010', 'Complementação salarial de auxílio-doença'})
	aAdd( aRubr, {'079', '4050', 'Salário maternidade'})
	aAdd( aRubr, {'080', '4051', 'Salário maternidade - 13° salário'})
	aAdd( aRubr, {'081', '5001', '13º salário'})
	aAdd( aRubr, {'082', '5005', '13° salário complementar'})
	aAdd( aRubr, {'083', '5501', 'Adiantamento de salário'})
	aAdd( aRubr, {'084', '5504', '13º salário - Adiantamento'})
	aAdd( aRubr, {'085', '5510', 'Adiantamento de benefícios previdenciários'})
	aAdd( aRubr, {'086', '6000', 'Saldo de salários na rescisão contratual'})
	aAdd( aRubr, {'087', '6001', '13º salário relativo ao aviso-prévio indenizado'})
	aAdd( aRubr, {'088', '6002', '13° salário proporcional na rescisão'})
	aAdd( aRubr, {'089', '6003', 'Indenização compensatória do aviso-prévio'})
	aAdd( aRubr, {'090', '6004', 'Férias - o dobro na rescisão'})
	aAdd( aRubr, {'091', '6006', 'Férias proporcionais'})
	aAdd( aRubr, {'092', '6007', 'Férias vencidas na rescisão'})
	aAdd( aRubr, {'093', '6101', 'Indenização compensatória - multa rescisória 20 ou 40% (CF/88)'})
	aAdd( aRubr, {'094', '6102', 'Indenização do art. 9º lei nº 7.238/84'})
	aAdd( aRubr, {'095', '6103', 'Indenização do art. 14 da lei nº 5.889, de 8 de junho de 1973'})
	aAdd( aRubr, {'096', '6104', 'Indenização do art. 479 da CLT'})
	aAdd( aRubr, {'097', '6105', 'Indenização recebida a título de incentivo a demissão'})
	aAdd( aRubr, {'098', '6106', 'Multa do art. 477 da CLT'})
	aAdd( aRubr, {'099', '6107', 'Indenização por quebra de estabilidade'})
	aAdd( aRubr, {'100', '6129', 'Outras Indenizações'})
	aAdd( aRubr, {'101', '6901', 'Desconto do aviso-prévio'})
	aAdd( aRubr, {'102', '6904', 'Multa prevista no art. 480 da CLT'})
	aAdd( aRubr, {'103', '7001', 'Proventos'})
	aAdd( aRubr, {'104', '7002', 'Proventos - Pensão por morte Civil'})
	aAdd( aRubr, {'105', '7003', 'Proventos - Reserva'})
	aAdd( aRubr, {'106', '7004', 'Proventos - Reforma'})
	aAdd( aRubr, {'107', '7005', 'Pensão Militar'})
	aAdd( aRubr, {'108', '9200', 'Desconto de Adiantamentos'})
	aAdd( aRubr, {'109', '9201', 'Contribuição Previdenciária'})
	aAdd( aRubr, {'110', '9203', 'Imposto de renda retido na fonte'})
	aAdd( aRubr, {'111', '9205', 'Provisão de contribuição previdenciária e IRRF'})
	aAdd( aRubr, {'112', '9208', 'Atrasos ( Descontinuado a partir do Layout 2.2 )'})
	aAdd( aRubr, {'113', '9209', 'Faltas ou atrasos'})
	aAdd( aRubr, {'114', '9210', 'DSR s/faltas e atrasos'})
	aAdd( aRubr, {'115', '9211', 'Faltas e atrasos - estagiários ( Descontinuado a partir do Layout 2.2 )'})
	aAdd( aRubr, {'116', '9213', 'Pensão alimentícia'})
	aAdd( aRubr, {'117', '9214', '13° salário - desconto de adiantamento'})
	aAdd( aRubr, {'118', '9216', 'Desconto de vale-transporte'})
	aAdd( aRubr, {'119', '9217', 'Contribuição a Outras Entidades e Fundos'})
	aAdd( aRubr, {'120', '9218', 'Retenções judiciais'})
	aAdd( aRubr, {'121', '9219', 'Desconto de assistência médica ou odontológica'})
	aAdd( aRubr, {'122', '9220', 'Alimentação - desconto'})
	aAdd( aRubr, {'123', '9221', 'Desconto de férias'})
	aAdd( aRubr, {'124', '9222', 'Desconto de outros impostos e contribuições'})
	aAdd( aRubr, {'125', '9223', 'Previdência complementar - parte do empregado'})
	aAdd( aRubr, {'126', '9224', 'FAPI - parte do empregado'})
	aAdd( aRubr, {'127', '9225', 'Previdência complementar - parte do servidor'})
	aAdd( aRubr, {'128', '9226', 'Desconto de férias - abono'})
	aAdd( aRubr, {'129', '9230', 'Contribuição Sindical - Compulsória'})
	aAdd( aRubr, {'130', '9231', 'Contribuição Sindical - Associativa'})
	aAdd( aRubr, {'131', '9232', 'Contribuição Sindical - Assistencial'})
	aAdd( aRubr, {'132', '9233', 'Contribuição sindical - Confederativa'})
	aAdd( aRubr, {'133', '9250', 'Seguro de vida - desconto'})
	aAdd( aRubr, {'134', '9254', 'Empréstimos consignados - desconto'})
	aAdd( aRubr, {'135', '9255', 'Empréstimos do empregador - desconto'})
	aAdd( aRubr, {'136', '9258', 'Convênios'})
	aAdd( aRubr, {'137', '9270', 'Danos e prejuízos causados pelo trabalhador'})
	aAdd( aRubr, {'138', '9290', 'Desconto de pagamento indevido em meses anteriores'})
	aAdd( aRubr, {'139', '9299', 'Outros descontos'})
	aAdd( aRubr, {'140', '9901', 'Base de cálculo da contribuição previdenciária'})
	aAdd( aRubr, {'141', '9902', 'Total da base de cálculo do FGTS'})
	aAdd( aRubr, {'142', '9903', 'Total da base de cálculo do IRRF'})
	aAdd( aRubr, {'143', '9904', 'Total da base de cálculo do FGTS rescisório'})
	aAdd( aRubr, {'144', '9905', 'Serviço militar'})
	aAdd( aRubr, {'145', '9906', 'Remuneração no exterior'})
	aAdd( aRubr, {'146', '9908', 'FGTS - depósito'})
	aAdd( aRubr, {'147', '9910', 'Seguros'})
	aAdd( aRubr, {'148', '9911', 'Assistência Médica'})
	aAdd( aRubr, {'149', '9930', 'Salário maternidade pago pela Previdência Social'})
	aAdd( aRubr, {'150', '9931', '13° salário maternidade pago pela Previdência Social'})
	aAdd( aRubr, {'151', '9932', 'Auxílio-doença acidentário'})
	aAdd( aRubr, {'152', '9933', 'Auxílio-doença'})
	aAdd( aRubr, {'153', '9938', 'Isenção IRRF - 65 anos'})
	aAdd( aRubr, {'154', '9939', 'Outros valores tributáveis'})
	aAdd( aRubr, {'155', '9950', 'Horas extraordinárias - Banco de horas'})
	aAdd( aRubr, {'156', '9951', 'Horas compensadas - Banco de horas'})
	aAdd( aRubr, {'157', '9989', 'Outros valores informativos'})

	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	cTexto += STR0044 + Chr(13) + Chr(10)	//"Iniciando a analise das rubricas salvas na tabela SRV..."

	DbSelectArea( "SRV" )
	DbGoTop()
	While SRV->(!Eof())
		nPos	:= 0
		nPos 	:= aScan(aDePara,{|x| AllTrim(x[1]) == SRV->RV_NATUREZ})
		If nPos > 0
				lAlter	:= .T.
				If SRV->RV_NATUREZ	$ "3502*6013"
					cTexto +=	"***************"+STR0045+"***************" +Chr(13) + Chr(10) + STR0046 +SRV->RV_FILIAL+SRV->RV_COD+ "."+Chr(13) + Chr(10) //"As naturezas 3502 e 6013 deixaram de existir na tabela de Rubricas do eSocial e não tem outra equivalente, então avalie no registro da tabela SRV (Filil+Cod.Verba): "
					RecLock("SRV",.F.)
						SRV->RV_NATUREZ := "    "
					MsUnlock()
				Else
					cTexto +=	STR0047+SRV->RV_FILIAL+SRV->RV_COD+ STR0048 +SRV->RV_NATUREZ+STR0049+aDePara[nPos,2]+Chr(13) + Chr(10)//"O registro da tabela SRV (Filil+Cod.Verba): "### ", foi alterada a natureza de: " ###" para:"
					RecLock("SRV",.F.)
						SRV->RV_NATUREZ := aDePara[nPos,2]
					MsUnlock()
				EndIf
		EndIf
		SRV->(DbSkip())
	EndDo

	If lAlter
		cTexto += STR0050 + Chr(13) + Chr(10) + Chr(13) + Chr(10) //"Fim das alterações na tabela SRV..."
	Else
		cTexto += STR0051+ Chr(13) + Chr(10) + Chr(13) + Chr(10) //"Não ocorreu alteração na tabela SRV..."
	EndIf

	lAlter	:= .F.

	DbSelectArea("RCC")
	DbSetOrder(1)
	dbSeek(xFilial("RCC") + "S047")
	While RCC->(!EOF()) .AND. xFilial('RCC') + "S047" == RCC->RCC_FILIAL+RCC->RCC_CODIGO
		//Deleta todas as rubricas relativas a fase 1
		If AllTrim(RCC->RCC_CODIGO) == "S047"
			RCC->(RecLock("RCC",.F.))
			RCC->( dbDelete() )
			RCC->( MsUnlock() )
		EndIf
		RCC->(dbSkip())
	Enddo

	//Recrio a novas rubricas relativas a fase 2
	nTam := Len(aRubr)
	For nPos := 1 To nTam
		lAlter	:= .T.
	   	RecLock('RCC',.T.)
		RCC->RCC_FILIAL := xFilial("RCC")
		RCC->RCC_CODIGO := 'S047'
		RCC->RCC_FIL    := Replicate( " ", Len( xFilial("RCC") ) )
		RCC->RCC_CHAVE  := '      '
		RCC->RCC_SEQUEN := aRubr[nPos,1]
		RCC->RCC_CONTEU := aRubr[nPos,2]+aRubr[nPos,3]
		MsUnLock()
	Next nI

	If lAlter
		cTexto += STR0052 + Chr(13) + Chr(10) //"A tabela auxiliar S047 - Natureza das rubricas foi atualizado com sucesso na tabela RCC."
	Else
		cTexto += STR0053 + Chr(13) + Chr(10)
	EndIf
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	RCC->(DbCloseArea())
EndIf
RestArea(aArea)
lRet := .T.
Return (lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³updDeslSRV ³ Autor ³ Emerson Campos        ³ Data ³04/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atauliza a tabela de parametro X32 - Mot de desligamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., se a gravação foi bem sucedida                         ³±±
±±³          ³ .F., caso contrário                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function updDeslSRX()
Local aArea       	:= GetArea()
Local lRet        	:= .F.
Local lAlter		:= .F.
Local aDeslig		:= {}
Local cTip			:= '32'
Local nPosicao		:= 0
Local nQuantos		:= 0
Local cTexto:=""

If lOkFs2
	//aAdd( aDeslig, { "COD", "Descricao", [.T. Inclui / .F. Altera] })
	aAdd(aDeslig, {"2", "202 - Rescisão sem justa causa, por iniciativa do empregador;", .F.})
	aAdd(aDeslig, {"Z", "I18 - Aposentadoria Compulsória;", .F.})


	cTexto += Replicate("-",128) + CHR(13)+CHR(10)

	dbSelectArea("SR5")
	SR5->(dbSetOrder(1))

	dbSelectArea("SRX")
	SRX->(dbSetOrder(1))
	SRX->(dbSeek( xFilial('SRX') + cTip ))
	While SRX->(!Eof()) .And. SRX->RX_FILIAL == xFilial('SRX') .And. SRX->RX_TIP == cTip

		If SRX->RX_TIP == "32"

			If SR5->( dbSeek( RhTamFilial(xFilial('SR5')) + "X320126" ) )
				If Alltrim(SR5->R5_CAMPO) == "X32_MOTDES"
					nPosicao := SR5->R5_DE
					nQuantos := SR5->R5_QUANTOS
				EndIf
			EndIf

			If SubStr(SRX->RX_TXT,nPosicao,nQuantos) == "Z"
				lAlter	:= .T.
				cTexto +=	"No parâmetro "+SRX->RX_TIP+" "+"Tipo Rescisão:"+Alltrim(SRX->RX_COD)+" "+"o campo 'Mot eSocial' alteramos o conteúdo de 'Z' para vazio, pois este código não exite mais no eSocial. Por favor reavaliar este cadastro." + Chr(13) + Chr(10)

				SRX->(RecLock("SRX",.F.))
				SRX->RX_TXT	:=  SubStr(SRX->RX_TXT,1 ,(nPosicao-1))+" "
				SRX->( MsUnlock() )
			EndIf
	    EndIf

		SRX->(dbSkip())
	EndDo

	If lAlter
		cTexto += STR0057 + Chr(13) + Chr(10) + Chr(13) + Chr(10) //"Fim das alterações na tabela SRX."
	Else
		cTexto := ""
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)
	dbSeek(xFilial("RCC") + "S056")
	While RCC->(!EOF()) .AND. xFilial('RCC') + "S056" == RCC->RCC_FILIAL+RCC->RCC_CODIGO
		//Deleta todos motivos de desligamento relativos a fase 1
		If AllTrim(RCC->RCC_CODIGO) == "S056"
			RCC->(RecLock("RCC",.F.))
			RCC->( dbDelete() )
			RCC->( MsUnlock() )
		EndIf
		RCC->(dbSkip())
	Enddo

	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	RCC->(DbCloseArea())
	SRX->(DbCloseArea())
	SR5->(DbCloseArea())
EndIf
RestArea(aArea)
lRet := .T.
Return (cTexto)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³updMotAfast³ Autor ³ Emerson Campos        ³ Data ³04/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza campo R8_TPEFD com os novos Mot. Afastamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., se a gravação foi bem sucedida                         ³±±
±±³          ³ .F., caso contrário                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function updMotAfast()
Local aArea       	:= GetArea()
Local lRet        	:= .F.
Local lAlter		:= .F.
Local aMotAfast		:= {}
Local nPos			:= 0
Local nTam			:= 0
Local cQuery 	 	:= ""

If lOkFs2
	//aAdd(aMotAfast, {"DE","PARA","Descrição",[.T. Inclui / .F. Altera], [.T. Exclui / .F. Não Exclui]})
	aAdd(aMotAfast, {"08","06","Aborto não criminoso;",.F.})
	aAdd(aMotAfast, {"09","06","Prestação de Serviço Militar",.F.})
	aAdd(aMotAfast, {"10","06","Exercício de mandato sindical",.F.})
	aAdd(aMotAfast, {"11","08","Licença sem Vencimentos;",.F.})
	aAdd(aMotAfast, {"12","09","Exercício de mandato eleitoral;",.F.})
	aAdd(aMotAfast, {"13","10","Participação de curso ou programa de qualificação - Art. 476A da CLT",.F.})
	aAdd(aMotAfast, {"14","11","Aposentadoria por Invalidez;",.F.})
	aAdd(aMotAfast, {"15","12","Gozo de férias;",.F.})
	aAdd(aMotAfast, {"16","13","Cessão de Trabalhador",.F.})
	aAdd(aMotAfast, {"17","14","Cárcere;",.F.})
	aAdd(aMotAfast, {"18","15","",})
	aAdd(aMotAfast, {"19","16","",})
	aAdd(aMotAfast, {"20","17","",})

	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	cTexto += STR0061 + Chr(13) + Chr(10)   //"Iniciando a analise dos motivos de afastamentos salvos na tabela SR8..."

	#IFDEF TOP
		nTam := Len(aMotAfast)
		For nPos := 1 To nTam
			cQuery := ""
			cQuery += " UPDATE " +RetSQLName( "SR8" )+ " SET R8_TPEFD = '"+ aMotAfast[nPos,2] +"'"
			cQuery += " WHERE  R8_FILIAL = '" + xFilial("SR8") + "'"
			cQuery += " AND R8_TPEFD ='"+ aMotAfast[nPos,1] +"'"
			cQuery += " AND D_E_L_E_T_ = ' ' "

			If (TCSQLExec(cQuery) < 0)
				MsgAlert(STR0004 + TCSQLError())
			Else
				lAlter	:= .T.
				cTexto += STR0071 + " " + aMotAfast[nPos,1] + " " + STR0072 + " " + aMotAfast[nPos,2] + Chr(13) + Chr(10) // "O Motivo de Afastamento:" + aMotAfast[nPos,1] + "foi alterado para:" + aMotAfast[nPos,2]
			EndIf
		Next nPos

		TcRefresh(RetSqlName("SR8"))
	#ELSE
		DbSelectArea( "SR8" )
		DbGoTop()
		While SR8->(!Eof())
			nPos	:= 0
			nPos 	:= aScan(aMotAfast,{|x| AllTrim(x[1]) == SR8->R8_TPEFD})
			If nPos > 0
				lAlter	:= .T.
				cTexto +=	STR0062 + SR8->R8_FILIAL+SR8->R8_MAT+DTOS(SR8->R8_DATAINI)+SR8->R8_TIPO + STR0063 + SR8->R8_TPEFD + STR0049 + aMotAfast[nPos][2]+Chr(13) + Chr(10) //"O registro da tabela SR8 (Filil+Mat+Dt.Ini+Tipo): " #### ", foi alterada o Mot. de Afastamento de: " ####  " para:"

				RecLock("SR8",.F.)
					SR8->R8_TPEFD := aMotAfast[nPos,2]
				MsUnlock()
			EndIf
			SR8->(DbSkip())
		EndDo
	#ENDIF

	If lAlter
		cTexto += STR0064 + Chr(13) + Chr(10) + Chr(13) + Chr(10) //"Fim das alterações na tabela SR8."
	Else
		cTexto += STR0065 + Chr(13) + Chr(10) + Chr(13) + Chr(10) //"Não ocorreu alteraçãos na tabela SR8."
	EndIf

	//Esse item para a tabela S047 foi adicionado aqui pois nao necessita participar do De/Para
	//da tabela SR8, necessario apenas para corrigir a descricao do afastamento.
	aAdd(aMotAfast, {"07","07","Licença maternidade - (a partir de 120 dias até 180 dias)",.F.})

	lAlter	:= .F.
	DbSelectArea("RCC")
	DbSetOrder(1)
	dbSeek(xFilial("RCC") + "S048")
	While RCC->(!EOF()) .AND. xFilial('RCC') + "S048" == RCC->RCC_FILIAL+RCC->RCC_CODIGO
		//Deleta os Motivos de Afastamento que não serão utilizadas na fase 2

		If Substr(RCC->RCC_CONTEU,1,2) $ "18*19*20"
			lAlter	:= .T.
			RCC->(RecLock("RCC",.F.))
			RCC->( dbDelete() )
			RCC->( MsUnlock() )
		Else
			lAlter	:= .T.
			//Altera a descrição das rubricas na fase 2
			nPos	:= 0
			nPos 	:= aScan(aMotAfast,{|x| AllTrim(x[1]) == Substr(RCC->RCC_CONTEU,1,2)})
			If nPos > 0
				RCC->(RecLock("RCC",.F.))
				RCC->RCC_CONTEU	:=  aMotAfast[nPos,1]+aMotAfast[nPos,3]
				RCC->( MsUnlock() )
			EndIf
		EndIf
		RCC->(dbSkip())
	Enddo
	If lAlter
		cTexto += STR0066 + Chr(13) + Chr(10) //"A tabela auxiliar S048 - Motivo do Afastamento foi atualizado com sucesso na tabela RCC."
	Else
		cTexto += STR0067 + Chr(13) + Chr(10) //"Não ocorreu alteração na tabela auxiliar S048 - Motivo do Afastamento na tabela RCC"
	EndIf
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	RCC->(DbCloseArea())
EndIf
RestArea(aArea)
lRet := .T.
Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³updMotEstab³ Autor ³ Emerson Campos        ³ Data ³26/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza com os novos Motivos de Estabilidade do eSocial.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., se a gravação foi bem sucedida                         ³±±
±±³          ³ .F., caso contrário                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function updMotEstab()
Local aArea       	:= GetArea()
Local lRet        	:= .F.
Local lAlter		:= .F.
Local aMotEstab		:= {}
Local nPos			:= 0
Local nTam			:= 0
Local cQuery		:= ""
Local lCtextoIsC	:= Type("cTexto") == "C"

dbSelectArea("RCB")
RCB->(dbSetOrder(3))
RCB->(dbSeek(xFilial("RCB")+"MOTEST    "+"S053"))

If AllTrim(RCB->RCB_CAMPOS) == "MOTEST" .AND. RCB->RCB_TAMAN == 1
	RCB->(RecLock("RCB",.F.))
	RCB->RCB_TAMAN := 2
	RCB->( MsUnlock() )
	lOk	:= .T.
EndIf

RCB->(dbSetOrder(1))

//aAdd(aMotEstab, {"DE","PARA")
aAdd(aMotEstab, {"1","01"})
aAdd(aMotEstab, {"2","07"})
aAdd(aMotEstab, {"3","02"})
aAdd(aMotEstab, {"4","03"})
aAdd(aMotEstab, {"5","04"})
aAdd(aMotEstab, {"6","05"})
aAdd(aMotEstab, {"7","06"})
aAdd(aMotEstab, {"9","99"})

If lCtextoIsC
	cTexto += Replicate("-",128) + CHR(13) + CHR(10)
	cTexto += STR0076 + Chr(13) + Chr(10)   //"Iniciando a analise dos tipos de estabilidades salvos na tabela RCC..."
EndIf

lAlter	:= .F.
DbSelectArea("RCC")
DbSetOrder(1)
dbSeek(xFilial("RCC") + "S053")
While RCC->(!EOF()) .AND. xFilial('RCC') + "S053" == RCC->RCC_FILIAL+RCC->RCC_CODIGO

	If Len(AllTrim(RCC->RCC_CONTEU)) == 104 //Na fase 1 serão 104 posicoes na fase 2 105 posicoes

		lAlter	:= .T.
		//Altera a descrição das rubricas na fase 2
		nPos	:= 0
		nPos 	:= aScan(aMotEstab,{|x| AllTrim(x[1]) == Substr(RCC->RCC_CONTEU,104,1)})
		If nPos > 0
			RCC->(RecLock("RCC",.F.))
			RCC->RCC_CONTEU	:=  Substr(RCC->RCC_CONTEU,1,103)+aMotEstab[nPos,2]
			RCC->( MsUnlock() )
			If lCtextoIsC
				cTexto += STR0075 + " " + aMotEstab[nPos,1] + " " + STR0072 + " " + aMotEstab[nPos,2] + Chr(13) + Chr(10) // "O Tipo de Estabilidade:" + aMotAfast[nPos,1] + "foi alterado para:" + aMotAfast[nPos,2]
			Endif
		EndIf
	EndIf
	RCC->(dbSkip())
Enddo
If lCtextoIsC
	If lAlter
		cTexto += STR0073 + Chr(13) + Chr(10) //"A tabela auxiliar S053 - Tipos de Estabilidades foi atualizado com sucesso na tabela RCC."
	Else
		cTexto += STR0074 + Chr(13) + Chr(10) //"Não ocorreu alteração na tabela auxiliar S053 - Tipos de Estabilidades na tabela RCC"
	EndIf
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
EndIf
RCC->(DbCloseArea())

RestArea(aArea)
lRet := .T.
Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fUpdSRAv11 ³ Autor ³ Glaucia Messina       ³ Data ³13/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os campos RA_TPLOGR, RA_TPCTSAL e RA_PORTDEF       ³±±
±±³          ³ conforme novo leiaute 1.1 eSocial.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., se a gravação foi bem sucedida                         ³±±
±±³          ³ .F., caso contrário                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fUpdSRAv11()

Local aArea       	:= GetArea()
Local lRet        	:= .F.
Local aTpLograd		:= {}
Local lAltLogr		:= .F.
Local lAltCta		:= .F.
Local lAltDefic		:= .F.
Local nPos			:= 0
Local cNovoDef		:= ''
Local lTpCtaNovo	:=	.F.
Local lTpCta1Fas	:=	.F.
Local lTpLOGR		:=	.F.
Local lTpDef		:=	.F.

DbSelectArea("SX3")
dbSetOrder( 2 )
lTpLOGR := dbSeek("RA_LOGRTP") .AND. TAMSX3("RA_LOGRTP")[1]==3
lTpDef	:= dbSeek("RA_PORTDEF") .AND. TAMSX3("RA_PORTDEF")[1]==6
lTpCta1Fas := dbSeek("RA_TPCTDEP")
lTpCtaNovo := dbSeek("RA_TPCTSAL")

aAdd(aTpLograd	, {"01","AER"})
aAdd(aTpLograd	, {"02","AL"})
aAdd(aTpLograd	, {"03","A"})
aAdd(aTpLograd	, {"04","AV"})
aAdd(aTpLograd	, {"05","CPO"})
aAdd(aTpLograd	, {"06","CH"})
aAdd(aTpLograd	, {"07","COL"})
aAdd(aTpLograd	, {"08","CON"})
aAdd(aTpLograd	, {"09","CJ"})
aAdd(aTpLograd	, {"10","DT"})
aAdd(aTpLograd	, {"11","ESP"})
aAdd(aTpLograd	, {"12","ETC"})
aAdd(aTpLograd	, {"13","EST"})
aAdd(aTpLograd	, {"14","FAV"})
aAdd(aTpLograd	, {"15","FAZ"})
aAdd(aTpLograd	, {"16","FRA"})
aAdd(aTpLograd	, {"17","JD"})
aAdd(aTpLograd	, {"18","LD"})
aAdd(aTpLograd	, {"19","LG"})
aAdd(aTpLograd	, {"20","LGA"})
aAdd(aTpLograd	, {"21","LRG"})
aAdd(aTpLograd	, {"22","O"})
aAdd(aTpLograd	, {"23","LOT"})
aAdd(aTpLograd	, {"24","O"})
aAdd(aTpLograd	, {"25","MRO"})
aAdd(aTpLograd	, {"26","NUC"})
aAdd(aTpLograd	, {"27","O"})
aAdd(aTpLograd	, {"28","PRQ"})
aAdd(aTpLograd	, {"29","O"})
aAdd(aTpLograd	, {"30","PSA"})
aAdd(aTpLograd	, {"31","PAT"})
aAdd(aTpLograd	, {"32","PC"})
aAdd(aTpLograd	, {"33","O"})
aAdd(aTpLograd	, {"34","Q"})
aAdd(aTpLograd	, {"35","REC"})
aAdd(aTpLograd	, {"36","RES"})
aAdd(aTpLograd	, {"37","ROD"})
aAdd(aTpLograd	, {"38","R"})
aAdd(aTpLograd	, {"39","ST"})
aAdd(aTpLograd	, {"40","SIT"})
aAdd(aTpLograd	, {"41","O"})
aAdd(aTpLograd	, {"42","TV"})
aAdd(aTpLograd	, {"43","TR"})
aAdd(aTpLograd	, {"44","TRV"})
aAdd(aTpLograd	, {"45","VLE"})
aAdd(aTpLograd	, {"46","VER"})
aAdd(aTpLograd	, {"47","V"})
aAdd(aTpLograd	, {"48","VD"})
aAdd(aTpLograd	, {"49","VLA"})
aAdd(aTpLograd	, {"50","VL"})


DbSelectArea( "SRA" )
SRA->( dbSetOrder( 1 ) )
SRA->(dbGoTop())
While SRA->(!Eof())
		lAltLogr	:= .F.
		lAltCta		:= .F.
		lAltDefic	:= .F.
		nPos		:= 0
		cNovoDef	:= ''

		If lTpLOGR  .AND. (!Empty(SRA->RA_LOGRTP))
			nPos 	:= aScan(aTpLograd,{|x| AllTrim(x[1]) == ALLTRIM(SRA->RA_LOGRTP)})
			lAltLogr	:= (nPos > 0)
		EndIf

		If lTpCta1Fas .AND. !Empty(SRA->RA_TPCTDEP) .AND. lTpCtaNovo .AND. !Empty(SRA->RA_TPCTSAL)
			lAltCta := .T.
		EndIf

		If lTpDef .AND. (!Empty(SRA->RA_PORTDEF)) .AND. (LEN(ALLTRIM(SRA->RA_PORTDEF))== 4)
			If AT('4',SRA->RA_PORTDEF) > 0
				//O codigo 4 era para definir funcionario reabilitado
				//no leiaute 28/12/13 - passa a ser 6
				cNovoDef:= SUBSTR(SRA->RA_PORTDEF,1,3) + '**6'
			Else
				cNovoDef:= ALLTRIM(SRA->RA_PORTDEF)+'**'
			EndIf
		EndIf

		Begin Transaction
			If lAltLogr	.OR. lAltCta .OR. cNovoDef<>''
				RecLock("SRA",.F.)
					If lAltLogr
						SRA->RA_LOGRTP := aTpLograd[nPos,2]
					Endif

					If lAltCta
						SRA->RA_TPCTSAL := SRA->RA_TPCTDEP
					EndIf

					If (cNovoDef <>'')
						SRA->RA_PORTDEF := cNovoDef
					EndIf
				SRA->(MsUnlock())
				SRA->(dbCommit())

				lRet:= .T.
			EndIf
		End Transaction
	SRA->(DbSkip())
EndDo

RestArea(aArea)

Return lRet



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ updCatTrab³ Autor ³ Emerson Campos        ³ Data ³13/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera a tabela S049 para inserir o novo tipo 306 -         ³±±
±±³          ³ SERVIDOR PUBLICO - CONTRATO TEMPORARIO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ RHUPDGPE                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function updCatTrab()
Local aArea 		:= GetArea()
Local aTabela		:= {}
Local lRet			:= .T.
Local cFilRCC		:=	xFilial("RCC")
Local cNomeArq		:= 'S049'
Local cFilRCC_Us 	:= Replicate( " ", Len( xFilial("RCC") ) )
Local nI			:= 0
Local lAlter		:= .F.

If Empty(fDescRCC('S049','306',1,3,6,100))
	If Type("cTexto") == "C"
		cTexto += Replicate("-",128) + CHR(13) + CHR(10)
		cTexto += STR0077 + Chr(13) + Chr(10)   //"Iniciando a analise dos contratos temporarios salvos na tabela RCC..."
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)
	dbSeek(xFilial("RCC") + "S049")
	While RCC->(!EOF()) .AND. xFilial('RCC') + "S049" == RCC->RCC_FILIAL+RCC->RCC_CODIGO
		//Deleta todos os registros da S049 para serem recriados

		If RCC->RCC_CODIGO	== 'S049'
			lAlter	:= .T.
			RCC->(RecLock("RCC",.F.))
			RCC->( dbDelete() )
			RCC->( MsUnlock() )
		EndIf
		RCC->(dbSkip())
	Enddo

	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','10101EMPREGADO-GERAL                                                                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','102  EMPREGADO-TRABALHADOR RURAL POR PEQUENO PRAZO DA LEI 11.718/2008                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','10307EMPREGADO-APRENDIZ                                                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','10406EMPREGADO-DOMESTICO                                                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','10504EMPREGADO-CONTRATO A TERMO FIRMADO NOS TERMOS DA LEI 9601/98                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','106  EMPREGADO-CONTRATO POR PRAZO DETERMINADO NOS TERMOS DA LEI 6019/74                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','10703TRABALHADOR NAO VINCULADO AO RGPS COM DIREITO AO FGTS                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','20102TRABALHADOR AVULSO-PORTUARIO                                                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','20202TRABALHADOR AVULSO-NAO PORTUARIO (INFORMACAO DO SINDICATO)                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','203  TRABALHADOR AVULSO-NAO PORTUARIO (INFORMACAO DO CONTRATANTE)                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','30121SERVIDOR PUBLICO-TITULAR DE CARGO EFETIVO                                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','30220SERVIDOR PUBLICO-OCUPANTE DE CARGO EXCLUSIVO EM COMISSAO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','013','30319SERVIDOR PUBLICO-EXERCENTE DE MANDATO ELETIVO                                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','014','30412SERVIDOR PUBLICO-AGENTE PUBLICO                                                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','015','305  SERVIDOR PUBLICO VINC RPPS IND P/ CONS OU ORG REPRESENTATIVO, REPRES GOV, ORGAO OU ENT ADM PUB. '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','016','306  SERVIDOR PUBLICO - CONTRATO TEMPORARIO                                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','017','40126DIRIGENTE SINDICAL-EM RELACAO A REMUNERACAO RECEBIDA NO SINDICATO                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','018','701  CI-AUTONOMO CONTRATADO POR EMPRESAS EM GERAL                                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','019','70222CI-AUTONOMO CONTRAT POR CI, PF EM GERAL, OU POR M.DIPLOMATICA E REPART CONSULAR C.ESTRANGEIRAS  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','020','703  CI-AUTONOMO CONTRATADO POR ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','021','71115CI-TRANSPORTADOR AUTONOMO CONTR. POR EMPRESAS EM GERAL                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','022','71223CI-TRANSPORTADOR AUTONOMO CONTR. POR CI, PF GERAL, OU M.DIPLOMAT E REPAR CONSULAR C.ESTRANGEIRAS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','023','713  CI-TRANSPORTADOR AUTONOMO CONTR. POR ENTIDADE BENEFICENTE ASSISTENCIA SOCIAL ISENT COTA PATRONAL'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','024','72105CI-DIRETOR NAO EMPREGADO COM FGTS                                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','025','72211CI-DIRETOR NAO EMPREGADO SEM FGTS                                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','026','73117CI-COOPERADO QUE PRESTA SERVICOS A EMPRESA POR INTERMEDIO DE COOPERATIVA DE TRABALHO            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','027','73224CI-COOPERADO QUE PRESTA SERVICOS ENT. BENEFICENTE ASSISTENCIA SOCIAL ISENTA COTA PATRONAL OU PF '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','028','733  CI-COOPERADO ELEITO PARA DIRECAO DA COOPERATIVA                                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','029','73418CI-TRANSPORTADOR COOPERADO QUE PRESTA SERVICOS A EMPRESA POR INTERMEDIO DE COOPERATIVA TRABALHO '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','030','73525CI-TRANSPORTADOR COOPERADO PRESTA SERV. ENT BENEF. ASSISTENCIA SOC. ISENTA COTA PATRONAL OU PF  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','031','736  CI-TRANSPORTADOR COOPERADO ELEITO PARA DIRECAO DA COOPERATIVA                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','032','74113CI-COOPERADO FILIADO A COOPERATIVA DE PRODUCAO                                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','033','751  CI-MICRO EMPREENDEDOR INDIVIDUAL, QUANDO CONTRATADO POR PJ                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','034','901  ESTAGIARIO                                                                                      '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
EndIf
If Type("cTexto") == "C"
	If lAlter
		cTexto += STR0078 + Chr(13) + Chr(10) //"A tabela auxiliar S049 - Contratos Temporários foi atualizado com sucesso na tabela RCC."
	Else
		cTexto += STR0079 + Chr(13) + Chr(10) //"Não ocorreu alteração na tabela auxiliar S049 - Contratos Temporários na tabela RCC"
	EndIf
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGM17Nivel³ Autor ³ Glaucia Messina       ³ Data ³ 25/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliar se o usuario logado na rotina enviada por parametro³±±
±±³          ³ possui a devida permissão de acesso, para uso da rotina com³±±
±±³          ³ as funcionalidades do eSocial.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ Em diversas rotinas do modulo SIGAGPE/SIGAPON              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nome da rotina chamado e versao do eSocial em uso.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fGM17Nivel(cRotina)
Local aArea	:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local nCount	:= 0
Local lReturn	:= .T.
Local aEsocial	:= {}
//"Usuário sem acesso aos campos necessários ao eSocial, não será possível incluir e alterar funcionários."
//"Contate o administrador do Sistemas."
Local cMsg :=""

Local lNT15	:= .F.
Local cVersGPE	:= ""

If FindFunction("fVersEsoc")
	fVersEsoc("S2200", .F.,,,,@cVersGPE, , @lNT15)
Else
	cVersGPE := "2.3"
Endif

	If cRotina=="GPEA080"
		aEsocial	:={"R6_TPJORN", "R6_DTPJOR"}
	ElseIf (cRotina == "GPEA010" .AND. !IsInCallStack("TRMA100") .And. !IsInCallStack("RSPM001")) .Or. cRotina == "TRMRSP"
		aEsocial:={ "RA_MUNICIP","RA_NACIONC","RA_NOMECMP","RA_NRPROC",;
					"RA_NUMENDE","RA_PAISEXT","RA_TPREINT","RA_RGUF","RA_DTEMCNH","RA_DTVCCNH",;
					"RA_OCDTEXP","RA_OCDTVAL","RA_RNEDEXP","RA_ANOCHEG","RA_NACIONA",;
					"RA_RACACOR","RA_TPDEFFI","RA_PORTDEF","RA_CATEFD","RA_CIC","RA_REGRA",;
					"RA_SEQTURN","RA_BCDEPSA","RA_CTDEPSA","RA_TPPREVI","RA_TPCONTR",;
					"RA_RESEXT", "RA_CPAISOR","RA_CLASEST",;
					"RA_LOGRDSC","RA_ESTADO","RA_CODMUN","RA_CEP","RA_NASC","RA_ADMISSA",;
					"RA_EAPOSEN","RA_TPJORNA","RA_CARGO","RA_TPCTSAL","RA_ESTCIVI"}
		if !lNT15
			aAdd(aEsocial, "RA_CODMUNN")
			aAdd(aEsocial, "RA_NJUD14")
			aAdd(aEsocial, "RA_LOGRTP")
		endif
		If cVersGPE >= "9.0"
			aAdd(aEsocial, "RA_TIPOVIA")
			aAdd(aEsocial, "RA_CTPCD")
			aAdd(aEsocial, "RA_SALARIO")
			aAdd(aEsocial, "RA_VIEMRAI")
			aAdd(aEsocial, "RA_OPCAO")
			aAdd(aEsocial, "RA_HRSEMAN")
			aAdd(aEsocial, "RA_TIPOADM")
		Else
			aAdd(aEsocial, "RA_PIS")
			aAdd(aEsocial, "RA_DATCHEG")
			aAdd(aEsocial, "RA_CASADBR")
			aAdd(aEsocial, "RA_FILHOBR")
			aAdd(aEsocial, "RA_EMAIL2")
		EndIf
	EndIf

	For nCount:=1 to len(aEsocial)
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(aEsocial[nCount])
			IF (!(X3Uso(SX3->X3_USADO)) .OR. (cNivel < SX3->X3_NIVEL))
				If cRotina == "TRMRSP"
					cMsg := STR0412 //"Usuário ou módulo sem acesso aos campos necessários ao eSocial. A informação será atualizada somente na base do GPE, sem integração do evento."
				Else
					cMsg := IIf(cRotina == "GPEA010", OemToAnsi(STR0080)+CRLF+OemToAnsi(STR0081),OemToAnsi(STR0105)+CRLF+OemToAnsi(STR0081))	//"Usuario sem acesso aos campos necessários ao eSocial, não será possível incluir e alterar funcionaios." ## "Contate o administrador do Sistemas."
				EndIf
				lReturn := .F.
				Exit
			EndIf
		Else
			cMsg := IIf(cRotina == "GPEA010", OemToAnsi(STR0080)+CRLF+OemToAnsi(STR0081),OemToAnsi(STR0105)+CRLF+OemToAnsi(STR0081))
			lReturn	:= .F.
			Exit
		EndIf
	Next nCount


RestArea( aAreaSX3 )
RestArea(aArea)
Return {lReturn, cMsg}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGPM17T2  ³ Autor ³ Glaucia Messina       ³ Data ³ 29/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ when dos campos CTT_TIPO2 e CTT_CEI2                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao se aplica.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Boolean                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17T2(cTipo2Incr)
Local aArea		:= GetArea()
Local lRetorno := .F.

lRetorno := !(cTipo2Incr $ '  *10*21*24*90')

RestArea(aArea)
Return (lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGPM17Conv³ Autor ³ Glaucia Messina       ³ Data ³ 17/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Correcao do conversor Fase1_1                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao se aplica.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Boolean                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGPM17Conv()
Local aArea		:= GetArea()
Local lRetorno	:= .T.
Local cTpLogr	:= ""
Local aCorreto	:= {"AER","AL","A","AV","CPO","CH","COL","CON","CJ","DT","ESP","ETC","EST","FAV","FAZ","FRA","JD","LD","LG","LGA","LRG","NUC","PRQ"}
Local aTpLograd:= {}
Local nPos		:= 0
Local n2Pos		:= 0

aAdd(aTpLograd	, {"PSA","O"})
aAdd(aTpLograd	, {"PC","O"})
aAdd(aTpLograd	, {"Q","PSA"})
aAdd(aTpLograd	, {"REC","PAT"})
aAdd(aTpLograd	, {"RES","PC"})
aAdd(aTpLograd	, {"ROD","O"})
aAdd(aTpLograd	, {"R","Q"})
aAdd(aTpLograd	, {"ST","REC"})
aAdd(aTpLograd	, {"SIT","RES"})
aAdd(aTpLograd	, {"TV","ROD"})
aAdd(aTpLograd	, {"TR","R"})
aAdd(aTpLograd	, {"TRV","ST"})

DbSelectArea("SRA")
SRA->(dbGoTop())

While SRA->(!Eof())
	//Garatimos que so corrigira campo RA_LOGRTP com conteudo
	If !EMPTY(SRA->RA_LOGRTP)  .AND. (n2Pos := aScan(aCorreto,{|x| x == AllTrim(SRA->RA_LOGRTP)})) == 0
		If !EMPTY(SRA->RA_ENDEREC)
			cTpLogr := fGP17TPLgr(SRA->RA_ENDEREC)
			If !EMPTY(cTpLogr)
				RecLock("SRA", .F.)
				SRA->RA_LOGRTP := cTpLogr
				SRA->(MsUnlock())
			EndIf
		EndIf
	EndIf
	SRA->(dbSkip())
EndDo

RestArea(aArea)
Return (lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGPM17Jud ³ Autor ³ Marcia Moura			³ Data ³ 17/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validador de Idade Funcionario - Replica do P10            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial -  Cada Funcionario                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	                                                          ³±±
±±³          ³ 	 Data de Nascimento, Admissao e Categoria                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fGPM17Jud(dNasc,dAdm,cCat)
Local aArea		:= GetArea()
Local lRet		:=	.F.

Default dNasc	:= SRA->RA_NASC
Default dAdm	:= SRA->RA_ADMISSA
Default cCat	:= ""

if DateDiffYear( dNasc , dAdm)<= 14
	lRet	:=  .T.
Endif

if (DateDiffYear( dNasc, dAdm)> 14 .and. DateDiffYear( dNasc , dAdm)<= 16) .and. cCAT <> "103"
	lRet	:=  .T.
Endif

RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP17TPLgr³ Autor ³ Glaucia M.		    ³ Data ³ 19/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Recebe o campo RA_ENDEREC e retorna o codigo do tipo de     ³±±
±±³          ³logradouro conforme leiaute 1.1                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP17TPLgr(nOpc) 									 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ RA_ENDEREC                                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ P11                                  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGP17TPLgr(cRA_ENDERE)
Local aArea		:= GetArea()
Local x			:= 0
Local y			:= 0
Local nPos1		:= 0
Local nPos2		:= 0
Local cTipoLogr	:=""
Local aLogr		:={}
Local cEnd
Local cRet		:= ""

If Valtype(aTLogr1) != "A"
	aTLogr1		:={}

	dbSelectArea("RCC")
	dbSetOrder(1)
	MsSeek(xFilial("RCC")+"S054")
	While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+"S054"
		aLogr:= {}
		Aadd(aLogr, {Alltrim(Substr(RCC->RCC_CONTEU,4,20))})

		nPriPos := At("|", Alltrim(Substr(RCC->RCC_CONTEU,0,len(RCC->RCC_CONTEU))) )
		cEnd	:= Substr(RCC->RCC_CONTEU,nPriPos,len(RCC->RCC_CONTEU))

		While len(cEnd)> 0
			nPos1	:=	At("|", Substr(cEnd,1,len(cEnd)) )
			nPos2	:=  At("|", Substr(cEnd,nPos1+1,len(cEnd)) )
			If nPos2 == 0
				cEnd:= ""
			Else
				Aadd(aLogr, {Substr(cEnd,nPos1+1,nPos2-1)})
				cEnd	:= Substr(cEnd,nPos1+nPos2,len(cEnd))
			Endif
		End
		Aadd (aTLogr1,aLogr)
		dBSkip()
	End
EndIf

If !empty(cRA_ENDERE)
	For x:=1 to len(aTLogr1)
		For y:=1 to len(aTLogr1[x])
			If at(UPPER(aTLogr1[x,y,1]),cRA_ENDERE) == 1
				cTipoLogr:= aTLogr1[x,1,1]
				exit
			Endif
		Next y
	Next x
EndIf

If !Empty(cTipoLogr)
	cRet := fDescRCC("S054",cTipoLogr,4,20,1,3)
EndIf

RestArea(aArea)
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP17VrTaf³ Autor ³ Alessandro Santos     ³ Data ³ 26/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se todos os campos Taf utilizados na integracao    ³±±
±±³          ³estao presentes.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP17VrTaf()		 									 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 				                                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM017                              					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGP17VrTaf()
Local aArea	:= GetArea()
Local lRet := .F.

If AliasInDic("C90") .And. AliasInDic("C92") .And. AliasInDic("C93") .And. AliasInDic("C9A") .And. AliasInDic("C8R") .And.;
	AliasInDic("C99") .And. AliasInDic("C8W") .And. AliasInDic("C8V") .And. AliasInDic("C8X") .And. AliasInDic("CRL") .And.;
	AliasInDic("CR9") .And. AliasInDic("C9V") .And. AliasInDic("CUU") .And. AliasInDic("C9Y") .AND. AliasInDic("CUP") .And.;
	AliasInDic("CMG") .And. AliasInDic("CRQ") .And. ;
	Findfunction("FTafVldOpe") .AND. Findfunction("TAFA279") .AND. Findfunction("TAFA256")

	lRet := .T.
EndIf

RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} fGp17VlLot
Validacao para o campo CTT_TIPO2
@author  Alessandro Santos
@since   02/04/2014
@param cTpLot, caracter, Tipo de lotação campo CTT_TPLOT
@param cTipo2, caracter, Tipo de inscrição do estabelecimento - campo CTT_TIPO2
@return lRet, logical, Indica se o tipo de inscrição é válido para o tipo de lotação de acordo com o layout do eSocial
/*/
Function fGp17VlLot(cTpLot, cTipo2)

	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cTipos	:= ""
	Local cTipos2	:= ""

	If ! Empty(cTpLot) .And. ! Empty(cTipo2)
		If cTpLot $ "04|05|06|08" .And. ! cTipo2 == "1"
			lRet := .F.
			cTipos := "04, 05, 06, e 08"
			cTipos2 := "1"
		ElseIf cTpLot $ "03|07" .And. ! cTipo2 == "2"
			lRet := .F.
			cTipos := "03 e 07"
			cTipos2 := "2"
		ElseIf cTpLot $ "01|02" .And. ! cTipo2 == "4"
			lRet := .F.
			cTipos := "01 e 02"
			cTipos2 := "4"
		ElseIf cTpLot $ "09" .And. ! cTipo2 $ "1|2"
			lRet := .F.
			cTipos := "09"
			cTipos2 := "1 e 2"
		EndIf
	EndIf

	If ! lRet
		// Tipo de Tomador # "Tipo de Tomador eSocial Inválido" #  Para os tipos de lotação # deve-se utilizar o tipo de inscrição # " para o eSocial."
		Help(NIL, NIL, STR0220, NIL, STR0095, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0221 + cTipos + STR0222 + cTipos2 + STR0223})
	EndIf

	RestArea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fG17TAF   ³ Autor ³ Glaucia M             ³ Data ³ 10/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função que define o comportamento do sistema conforme a de ³±±
±±³          ³ teccao integracao com o modulo TAF e SIGAGPE.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Obtem conteudo do parametro MV_INTTAF.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. - TAF Integrado com o SIGAGPE                          ³±±
±±³          ³ .F. - TAF Nao Integrado com o SIGAGPE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fG17TAF()
Local aArea		:= GetArea()
Local lRet		:= .F.

lRet := .F. // Futuramente tratará o parâmetro MV_RHTAF

RestArea(aArea)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fG17TRAB  ³ Autor ³ Glaucia M             ³ Data ³ 25/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função que define o comportamento do sistema conforme a de ³±±
±±³          ³ teccao integracao com o modulo TAF e SIGAGPE.              ³±±
±±³          ³ Copia da funcao TafRetFun, mas o array de retorno com      ³±±
±±³          ³ ID do trabalhador encontrado no TAF.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCPF do trabalhador a ser avaliado.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array com informacoe pertinentes ao Trabalhador            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fG17TRAB( cCPF, cFilEnv )
Local aRet := {}
Local aAreaCUP := ("CUP")->( GetArea() )
Local aAreaCUU := ("CUU")->( GetArea() )
Local aAreaC9V := ("C9V")->( GetArea() )
Local cMatric := ""
Local cCateg := ""
("C9V")->(DBSetOrder(3))
If ("C9V")->( MsSeek( FwxFilial("C9V", cFilEnv) + cCPF + "1"))
//Percorro toda a tabela C9V, onde são armazenadas informações sobre o funcionário com ou sem vínculo.
	While ( ("C9V")->(!Eof()) .And. AllTrim(("C9V")->C9V_CPF) == AllTrim(cCPF))
		IF ("C9V")->C9V_ATIVO == "1" .AND. ("C9V")->C9V_STATUS <> "E" //Só retorna algo se for ativo;
			cMatric := ""
			cCateg := ""
			("CUP")->(DBSetOrder(1)) //Filial + ID + Versao ( + Matricula )
			If ("CUP")->( MsSeek( FwxFilial("CUP", cFilEnv) + ("C9V")->C9V_ID + ("C9V")->C9V_VERSAO))
				cMatric := ("CUP")->CUP_MATRIC
				cCateg := Posicione("C87",1, FwxFilial("C87" , cFilEnv) + ("CUP")->(CUP_CODCAT),"C87_CODIGO")
			Else
				//Se não encontrou a matricula, significa que é sem vínculo. Então busca a categoria na CUU.
				("CUU")->(DBSetOrder(1)) //Filial + ID + Versao
				If ("CUU")->( MsSeek( FwxFilial("CUU", cFilEnv) + ("C9V")->C9V_ID + ("C9V")->C9V_VERSAO))
					If !Empty(("CUU")->(CUU_CATAV))
						cCateg := Posicione("C87",1,FwxFilial("C87", cFilEnv) + ("CUU")->(CUU_CATAV),"C87_CODIGO")
					ElseIf !Empty(("CUU")->(CUU_CATCI))
						cCateg := Posicione("C87",1, FwxFilial("C87", cFilEnv) + ("CUU")->(CUU_CATCI),"C87_CODIGO")
					ElseIf !Empty(("CUU")->(CUU_CATSP))
						cCateg := Posicione("C87",1, FwxFilial("C87",cFilEnv) + ("CUU")->(CUU_CATSP),"C87_CODIGO")
					ElseIf !Empty(("CUU")->(CUU_CATDS))
						cCateg := Posicione("C87",1,FwxFilial("C87", cFilEnv) + ("CUU")->(CUU_CATDS),"C87_CODIGO")
					ElseIf !Empty(("CUU")->(CUU_CATODS))
						cCateg := Posicione("C87",1, FwxFilial("C87",cFilEnv) + ("CUU")->(CUU_CATODS),"C87_CODIGO")
					ElseIf !Empty(("CUU")->(CUU_CATES))
						cCateg := Posicione("C87",1, FwxFilial("C87",cFilEnv) + ("CUU")->(CUU_CATES),"C87_CODIGO")
					EndIf
				EndIf
			EndIf

			//Adiciono ao array de retorno as informações sobre o funcionário
			aAdd(aRet, {("C9V")->C9V_NOMEVE, ("C9V")->C9V_STATUS, ("C9V")->C9V_EVENTO, cCateg, cMatric,("C9V")->C9V_FILIAL + ("C9V")->C9V_ID + ("C9V")->C9V_VERSAO + ("C9V")->C9V_NOMEVE }  )
		EndIf
		("C9V")->(DBSkip())
	EndDo
EndIf
RestArea( aAreaC9V )
RestArea( aAreaCUU )
RestArea( aAreaCUP )
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fG17VSRA  ³ Autor ³ Marcia M              ³ Data ³ 16/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida dados do SRA                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias SRA                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array com informacoe pertinentes ao Trabalhador            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fG17VSRA( cAliasSRA, nProg, nOpc, aAuxDados, cVersEnvio )
	Local cVersGPE		:= ""
	Local aArea 		:= GetArea()
	Local nX := 0
	Local lRet 			:= .T.
	Local dDtIniCarg  	:= SuperGetMv("MV_DTCGINI",, StoD("//"))
	Local lEFDQA  		:= SuperGetMv("MV_EFD",, .F.)
	Local lOrgPbl		:= SuperGetMv("MV_ORGPB",, .F.)
	Local lRS9_INDCE	:= .F.
	Local lValNewRS9	:= .F.
	Local lAchou		:= .F.
	Local lVerCNH		:= .F.
	Local lVerOC		:= .F.
	Local lErroCNH		:= .F.
	Local lErroOC		:= .F.
	Local nIdade		:= 0
	Local cDef			:= ""
	Local cCateg		:= ""
	Local aCampos		:= {}
	Local aCamposT		:= {}
	Local aCamLogrBR	:= {}
	Local aCamLogrBT	:= {"RA_LOGRDSC","RA_ESTADO","RA_CODMUN","RA_CEP"}
	Local aCamLogrEX	:= {}
	Local aCamLogrET	:= {"RA_LOGRDSC", "RA_MUNICIP","RA_PAISEXT","RA_LOGRNUM"}
	Local aCpoEstran	:= {}
	Local aCpoEstraT	:= {}
	Local aCpoDepend	:= {"SRB->RB_TPDEP","SRB->RB_NOME","SRB->RB_DTNASC","SRB->RB_TIPIR","SRB->RB_TIPSF"}
	Local aCpoDepenT	:= {"RB_TPDEP","RB_NOME","RB_DTNASC","RB_TIPIR","RB_TIPSF"}

	Local x				:= 0
	Local cSConselho	:= "305" 			//Servidor Publico vinculado a RPPS indicado para conselho ou orgao representativo
	Local cCI			:= fCatTrabEFD("TSV") //"201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903" //Contribuinte Individual
	Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
	Local cCbo			:= ""
	Local cRaCbo		:= ""
	Local aCposImp		:= {}
	Local nS			:= 0
	Local aAreaRBW		:= {}
	Local aAreaRFS		:= {}
	Local aAreaRS9		:= {}
	Local lNT15			:= .F.
	Local aAreaSR6      := {}

	Default cVersEnvio	:= ""
	Default nProg		:= 0
	Default aAuxDados	:= {}
	Default nOpc		:= 0

	Private aFldRot 	:= {'RA_NOME'}
	Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
	Private lOfuscaNom	:= .F.
	Private aFldOfusca 	:= {}

	If aOfusca[2]
		aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
			lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
		ENDIF
	ENDIF

	If FindFunction("fVersEsoc")
		fVersEsoc("S2200", .F.,,,,@cVersGPE, , @lNT15)
	Else
		cVersGPE := "2.3"
	Endif

	if !lNT15
		aadd(aCamLogrBT, "RA_LOGRTP")
	endif

	If nProg == 2 .Or. (FunName() == "GPEA010" .And. lGp010Auto)
		//---------------------------------------------
		//| Se vier da persistência ou carga inicial
		//| Posiciona no banco e da carga para memória
		//---------------------------------------------
		DbSelectArea("SRA")
		DbSetOrder(1)
		DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT )
		RegToMemory("SRA",,,.F.)
	EndIf

	nIdade := DateDiffYear( M->RA_NASC , M->RA_ADMISSA )

	cCateg		:= M->RA_CATEFD

	if M->RA_CATEFD $ cTrabVincu .or. empty(M->RA_CATEFD)     // trabalhador com vinculo ou em branco
		aCampos	:= {M->RA_CIC,M->RA_RACACOR,M->RA_CPAISOR,M->RA_NACIONC,;
					M->RA_CATEFD,If(lOfuscaNom,Replicate('*',15),M->RA_NOME),M->RA_SEXO,M->RA_GRINRAI,M->RA_NASC,;
					M->RA_ADMISSA,M->RA_VIEMRAI,M->RA_CC,M->RA_OPCAO,;
					M->RA_NATURAL,M->RA_LOGRNUM,M->RA_HOPARC,M->RA_SINDICA }
		aCamposT:= {"RA_CIC","RA_RACACOR","RA_CPAISOR","RA_NACIONC","RA_CATEFD","RA_NOME","RA_SEXO","RA_GRINRAI","RA_NASC",;
					"RA_ADMISSA","RA_VIEMRAI","RA_CC","RA_OPCAO","RA_NATURAL","RA_LOGRNUM","RA_HOPARC","RA_SINDICA" }

	Endif
	if M->RA_CATEFD $ cCI .or. M->RA_CATEFD $ cSConselho .and. M->RA_CATEFD <> "721"     // trabalhador sem vinculo ou em branco
		aCampos	:= {M->RA_CIC,M->RA_RACACOR,M->RA_CPAISOR,M->RA_NACIONC,;
					If(lOfuscaNom,Replicate('*',15),M->RA_NOME),M->RA_SEXO,M->RA_GRINRAI,M->RA_NASC,M->RA_LOGRNUM}
		aCamposT:= {"RA_CIC","RA_RACACOR","RA_CPAISOR","RA_NACIONC","RA_NOME","RA_SEXO","RA_GRINRAI","RA_NASC","RA_LOGRNUM"}
	Endif

	if M->RA_CATEFD $ "721"
		aCampos	:= {M->RA_CIC,M->RA_RACACOR,M->RA_CPAISOR,M->RA_NACIONC,;
					If(lOfuscaNom,Replicate('*',15),M->RA_NOME),M->RA_SEXO,M->RA_GRINRAI,M->RA_NASC,M->RA_OPCAO}
		aCamposT:= {"RA_CIC","RA_RACACOR","RA_CPAISOR","RA_NACIONC","RA_NOME","RA_SEXO","RA_GRINRAI","RA_NASC","RA_OPCAO"}
	Endif

	cDef		:= M->RA_PORTDEF
	aCamLogrBR	:= {M->RA_LOGRDSC,M->RA_ESTADO,M->RA_CODMUN,M->RA_CEP}
	if !lNT15
		aadd(aCamLogrBR, M->RA_LOGRTP)
	ENDIF

	aCamLogrEX	:= {M->RA_LOGRDSC, M->RA_MUNICIP,M->RA_PAISEXT,M->RA_LOGRNUM}


	If cVersEnvio >= "9.0.00"
		aCpoEstraT	:= {"RA_CLASEST"}
		aCpoEstran	:= {M->RA_CLASEST}
	ElseIf cVersEnvio >= "2.4.02"
		aCpoEstraT	:= {"RA_CASADBR","RA_FILHOBR","RA_CLASEST"}
		aCpoEstran	:= {M->RA_CASADBR,M->RA_FILHOBR,M->RA_CLASEST}
	Else
		aCpoEstraT	:= {"RA_DATCHEG", "RA_CASADBR","RA_FILHOBR","RA_CLASEST"}
		aCpoEstran	:= {M->RA_DATCHEG,M->RA_CASADBR,M->RA_FILHOBR,M->RA_CLASEST}
	Endif

	dbSelectArea("SX3")
	dbSetOrder(2)
	SX3->(dbGoTop())

	IF !lNT15
		If M->RA_CPAISOR == "01058" .And. Empty(M->RA_CODMUNN)
			AAdd(aCposImp,{"RA_CODMUNN",STR0107 + " " + STR0200}) //Campo não preenchido e o pais de origem é Brasil.
		Endif

		If Empty(M->RA_UFCP) .And. (!Empty(M->RA_NUMCP) .OR. !Empty(M->RA_SERCP))
			AAdd(aCposImp,{"RA_UFCP",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_NUMRIC) .And. (!Empty(M->RA_EMISRIC))
			AAdd(aCposImp,{"RA_NUMRIC",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_EMISRIC) .And. (!Empty(M->RA_NUMRIC))
			AAdd(aCposImp,{"RA_EMISRIC",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_RG) .And. (!Empty(M->RA_RGEXP))
			AAdd(aCposImp,{"RA_RG",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_RGEXP) .And. (!Empty(M->RA_RG))
			AAdd(aCposImp,{"RA_RGEXP",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_RNE) .And. (!Empty(M->RA_RNEORG))
			AAdd(aCposImp,{"RA_RNE",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_RNEORG) .And. (!Empty(M->RA_RNE))
			AAdd(aCposImp,{"RA_RNEORG",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_OCEMIS) .And. (!Empty(M->RA_CODIGO))
			AAdd(aCposImp,{"RA_OCEMIS",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_CODIGO) .And. (!Empty(M->RA_OCEMIS))
			AAdd(aCposImp,{"RA_CODIGO",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_HABILIT) .And. ( (!Empty(M->RA_UFCNH)) .Or. (!Empty(M->RA_DTVCCNH)) .Or. (!Empty(M->RA_CATCNH)) )
			AAdd(aCposImp,{"RA_HABILIT",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_UFCNH) .And. ( (!Empty(M->RA_HABILIT)) .Or. (!Empty(M->RA_DTVCCNH)) .Or. (!Empty(M->RA_CATCNH)) )
			AAdd(aCposImp,{"RA_UFCNH",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_DTEMCNH) .And. ( (!Empty(M->RA_HABILIT)) .Or. (!Empty(M->RA_UFCNH)) .Or. (!Empty(M->RA_CATCNH)) )
			AAdd(aCposImp,{"RA_DTEMCNH",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_DTVCCNH) .And. ( (!Empty(M->RA_HABILIT)) .Or. (!Empty(M->RA_UFCNH)) .Or. (!Empty(M->RA_CATCNH)) )
			AAdd(aCposImp,{"RA_DTVCCNH",STR0107}) //Campo não preenchido
		Endif

		If Empty(M->RA_CATCNH) .And. ( (!Empty(M->RA_HABILIT)) .Or. (!Empty(M->RA_UFCNH)) .Or. (!Empty(M->RA_DTVCCNH)) )
			AAdd(aCposImp,{"RA_CATCNH",STR0107}) //Campo não preenchido
		Endif
	ENDIF

	If SRA->(ColumnPos("RA_DESEPS")) > 0
		If Empty(M->RA_DESEPS) .And. M->RA_CATFUNC $ "C/T" .And. Empty(M->RA_SALARIO)
			AAdd(aCposImp,{"RA_DESEPS",STR0107}) //Campo não preenchido
		Endif
	Endif

	If Empty(M->RA_CLAURES) .And. M->RA_TPCONTR == "2"
		AAdd(aCposImp,{"RA_CLAURES",STR0107}) //Campo não preenchido
	Endif
	If SRA->(ColumnPos("RA_TIPOCON")) > 0	//Tp Prazo Cont. Deter.
		If M->RA_TPCONTR == "1" .And. !Empty(M->RA_TIPOCON)
			AAdd(aCposImp,{"RA_TIPOCON",STR0243}) //Não deve ser preenchido para contrato indeterminado.
		ElseIf M->RA_TPCONTR == "2"
			If M->RA_TIPOCON != "1" .And. Empty(M->RA_DTFIMCT)
				AAdd(aCposImp,{"RA_DTFIMCT",STR0107}) //Campo em Branco
			ElseIf M->RA_TIPOCON == "1" .And. !Empty(M->RA_DTFIMCT)
				AAdd(aCposImp,{"RA_DTFIMCT",STR0244}) //Não deve ser preenchido para contrato determinado por ocorrência de fato.
			Endif
		Endif
	ElseIf M->RA_TPCONTR == "2" .And. Empty(M->RA_DTFIMCT)
		AAdd(aCposImp,{"RA_DTFIMCT",STR0107}) //Campo em Branco
	EndIf

	For x:=1 to len(aCampos)
		If EMPTY(aCampos[x])
			AAdd(aCposImp,{aCamposT[x],STR0107}) //Campo não preenchido
		EndIf
	Next x

	If M->RA_CATEFD <> "901" .And. Empty(M->RA_PIS) .And. cVersEnvio < "9.0.00" //PIS, não deve ser validado para estagiários
		AAdd(aCposImp,{"RA_PIS",STR0107}) //Campo não preenchido
	EndIf

	If M->RA_RESEXT == "1" //UM E PORQUE RESIDE NO EXTERIOR / 2 RESIDE NO EXTERIOR
		For x:=1 to len(aCamLogrEX)
			If EMPTY(aCamLogrEX[x])
				AAdd(aCposImp,{aCamLogrET[x],STR0107}) //Campo não preenchido
			EndIf
		Next x
	Else
		For x:=1 to len(aCamLogrBR)
			If EMPTY(aCamLogrBR[x])
				AAdd(aCposImp,{aCamLogrBT[x],STR0107}) //Campo não preenchido
			EndIf
		Next x
	EndIf

	If !EMPTY(M->RA_CPAISOR) .AND. M->RA_CPAISOR <> '01058'	//Estrangeiro (nao existe definicao para estrangeiro no leiaute)
		For x:=1 to len(aCpoEstran)
			If Empty(aCpoEstran[x])
				AAdd(aCposImp,{aCpoEstraT[x],STR0107}) //Campo não preenchido
			EndIf
		Next x

		If cVersEnvio >= "2.4.02" .And. M->RA_CLASEST <> "06" .And. cVersEnvio < "9.0.00"
			If Empty(M->RA_DATCHEG)
				AAdd(aCposImp,{"RA_DATCHEG",STR0107}) //Campo não preenchido
			Endif
		Endif

	EndIf

	If !Empty( M->RA_TPDEFFI) .AND. ( M->RA_TPDEFFI #'0' .AND.  Empty(M->RA_PORTDEF))		//Portador de deficiencia fisica
		AAdd(aCposImp,{"RA_PORTDEF",STR0107}) //Campo não preenchido
	EndIf


	If cCateg $ cTrabVincu .OR. cCateg == ""+space(Len(M->RA_CATEFD))
		//infoCota
		If Empty(M->RA_CTPCD) .And. ( !Empty(M->RA_PORTDEF) .And. M->RA_PORTDEF <> "******" )
			If (cVersEnvio < "9.0" .Or. !(M->RA_VIEMRAI $ "30|31|35"))
				AAdd(aCposImp,{"RA_CTPCD",STR0107}) //Campo não preenchido
			EndIf
		ElseIf cVersEnvio >= "9.0" .And. M->RA_CTPCD == "1" .And. ( Empty(M->RA_PORTDEF) .Or. M->RA_PORTDEF == "******" )
			AAdd(aCposImp,{"RA_CTPCD",STR0424}) //"Somente pode ser 1=Sim se informado pelo menos um dos tipos de Deficiência eSocial (RA_PORTDEF)"
		Endif

		//Validacao Tp Jorn Trab
		If Empty(M->RA_TPJORNA)
			AAdd(aCposImp,{"RA_TPJORNA",STR0107}) //Campo não preenchido
		EndIf

		//A regra abaixo so valera para tipo de jornada "submetido a jornada de trabalho"
		If M->RA_TPJORNA =='1'
			//Validacao Regra de Apontamento
			If Empty(M->RA_REGRA)
				AAdd(aCposImp,{"RA_REGRA",STR0107}) //Campo não preenchido
			EndIf

			//Validacao Sequencia Inicio Turno
			If Empty(M->RA_SEQTURN)
				AAdd(aCposImp,{"RA_SEQTURN",STR0107}) //Campo não preenchido
			EndIf
		EndIf

		If Empty(M->RA_TPPREVI)
			AAdd(aCposImp,{"RA_TPPREVI",STR0107}) //Campo não preenchido
		ElseIf M->RA_TPPREVI == '2' .And. cCateg $ "101|102|103|105|106|107|108|111|"
			AAdd(aCposImp,{"RA_TPPREVI",STR0219}) //"Para categorias 101, 102, 103, 105, 106 e 111 o campo não pode ser preenchido com '2'."
		EndIf

		If Empty(M->RA_TPCONTR)
			AAdd(aCposImp,{"RA_TPCONTR",STR0107}) //Campo não preenchido
		EndIf

	EndIf

	If (cVersEnvio >= "9.0.00")
		If (!Empty(M->RA_TNOTRAB))
			DbSelectArea("SR6")
			If (FieldPos("R6_ESNOTU") > 0)
				aAreaSR6 := SR6->(GetArea())

				SR6->(DbSetOrder(1))
				If (SR6->(DbSeek(xFilial("SR6") + PadR(M->RA_TNOTRAB, TamSX3("R6_TURNO")[1]))))
					If (Empty(SR6->R6_ESNOTU))
						AAdd(aCposImp,{"RA_TNOTRAB",STR0395}) //"Campo 'Jorn Sem Not' (R6_ESNOTU) não preenchido no Turno de Trabalho."
					Endif
				Endif
				RestArea(aAreaSR6)
			Endif
		Endif

		If Len(AllTrim(M->RA_CLASEST)) == 2
			aAdd(aCposImp,{"RA_CLASEST", OemToAnsi(STR0404)}) // "Conteúdo referente ao leiaute 2.5. Favor corrigir o campo conforme Leiaute S-1.0."
		EndIf
		If cPaisLoc == "BRA" .And. SRA->(ColumnPos("RA_TIPOVIA")) > 0
			If M->RA_CPAISOR <> '01058' .And. dToS(M->RA_ADMISSA) >= "20210510" .And. Empty(M->RA_TIPOVIA)
				AAdd(aCposImp, {"RA_TIPOVIA", OemToAnsi(STR0398) + AllTrim(TITSX3("RA_TIPOVIA")[1]) + OemToAnsi(STR0399)}) // "Para funcionário de origem estrangeira o preenchimento do campo: "###" é obrigatório."
			ElseIf M->RA_TIPOVIA == '1' .And. M->RA_CLASEST $ '2 |5 '
				AAdd(aCposImp, {"RA_CLASEST", OemToAnsi(STR0402)}) // "Para o Tempo de Residência = 1 (indeterminado) não podem ser informadas as Classificações de Estrangeiro 2 ou 5."
			ElseIf M->RA_TIPOVIA == '2' .And. M->RA_CLASEST == '1 '
				AAdd(aCposImp, {"RA_CLASEST", OemToAnsi(STR0403)}) // "Para o Tempo de Residência = 2 (determinado) não pode ser informada a Classificação de Estrangeiro 1."
			EndIf
		EndIf
	Endif

	If (cCateg=='901')
		aAreaRFS := RFS->(GetArea())
		dbselectArea("RFS")
		RFS->(dbSetOrder(1))
		If !(MsSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT ))
			AAdd(aCposImp,{"RA_CATEFD",STR0115}) //"Conforme Categoria eSocial - Preencher Dados do Estagio - RFS"
		Else
			IF empty(RFS->RFS_NATUR) .or.  empty(RFS->RFS_NIVEL) .or. empty(RFS->RFS_DTFIM)
				AAdd(aCposImp,{"RA_CATEFD",STR0115}) //"Conforme Categoria eSocial - Preencher Dados do Estagio - RFS"
			Endif
		Endif

		RestArea(aAreaRFS)
	Endif

	If !(FunName() $ "GPEA010|GPEA011") .And. M->RA_VIEMRAI $ '30|31|35'  .And. !(M->RA_CATEFD $ cCI)

		If ChkFile("RS9")
			aAreaRS9 := RS9->(GetArea())
			dbselectArea("RS9")
			RS9->(dbSetOrder(1))
			//Verifica a existência dos novos campos da RS9
			lRS9_INDCE := RS9->(ColumnPos("RS9_INDCE")) > 0

			If Year(dDtIniCarg) == 2019 .And. lOrgPbl .And. ( Year(dDtIniCarg) == Year(dDataBase) .Or. lEFDQA )
				lValNewRS9 := .T.
			Endif

			If cVersEnvio >= "9.0.00" .And. M->RA_CTPCD == "1" .And. (MsSeek( (cAliasSRA)->RA_FILIAL + M->RA_MAT) )
					AAdd(aCposImp,{"RA_CTPCD",STR0396 + STR0397}) //"A informação de Cota de PCD só pode ser informada para tipo de Regime de trabalho igual a 1 - CLT. "
			ElseIf !(MsSeek( (cAliasSRA)->RA_FILIAL + M->RA_MAT) )
				AAdd(aCposImp,{"RS9_TPPROV",STR0176}) //"Conforme Categoria eSocial - Preencher Dados do Agente Público - RS9"
			Else
				If lValNewRS9 .And. !lRS9_INDCE
					AAdd(aCposImp,{STR0210}) //"Não foram encontrados os novos campos da tabela RS9, favor executar o UPDDISTR."
				Endif
				IF Empty(RS9->RS9_PROES)
					AAdd(aCposImp,{"RS9_PROES",STR0176}) //"Conforme Categoria eSocial - Preencher Dados do Agente Público - RS9"
				Else
					If RS9->RS9_PROES == '3'
						AAdd(aCposImp,{"RS9_PROES",STR0180}) //"Opção 3 inválida para o campo RS9_PROES, a partir do leiaute 2.4."
					EndIf
				Endif
				IF cVersEnvio < "9.0.00" .And. Empty(RS9->RS9_TPPROV)
					AAdd(aCposImp,{"RS9_TPPROV",STR0176}) //"Conforme Categoria eSocial - Preencher Dados do Agente Público - RS9"
				ElseIf cVersEnvio >= "9.0.00" .And. Empty(RS9->RS9_TIPPRV)
					AAdd(aCposImp,{"RS9_TIPPRV",STR0176}) //"Conforme Categoria eSocial - Preencher Dados do Agente Público - RS9"
				Elseif lValNewRS9 .And. lRS9_INDCE .And. cVersEnvio < "9.0.00"
					If !Alltrim(RS9->RS9_TPPROV) $ "1#2#3#4#5#6#7#8#9#99"
						AAdd(aCposImp,{"RS9_TPPROV",STR0202}) //"Conteúdo do campo RS9_TPPROV inválido, valores válidos (1, 2, 3, 4, 5, 6, 7, 8, 9 ou 99).""
					Endif
				Endif

				IF Empty(RS9->RS9_DTEX)
					AAdd(aCposImp,{"RS9_DTEX",STR0176}) //"Conforme Categoria eSocial - Preencher Dados do Agente Público - RS9"
				Endif

				IF cVersEnvio < "9.0.00"
					If M->RA_TPPREVI == '2' .And. Empty(RS9->RS9_SEG)
						AAdd(aCposImp,{"RS9_SEG", "Valor de RA_TPPREVI = " + M->RA_TPPREVI + " - " + STR0416}) //Quando o campo RA_TPPREVI é igual a 2 o campo RS9_SEG deve ser preenchido."
					ElseIf M->RA_TPPREVI $ ' |1' .And. !Empty(RS9->RS9_SEG)
						AAdd(aCposImp,{"RS9_SEG", "Valor de RA_TPPREVI = " + M->RA_TPPREVI + " - " + STR0415}) //"O campo RS9_SEG deve ser preenchido somente quando o campo RA_TPPREVI for igual a 2."
					Elseif lValNewRS9 .And. lRS9_INDCE .And. !(RS9->RS9_SEG $ "0#1#2#3")
						AAdd(aCposImp,{"RS9_SEG",STR0203}) //"Conteúdo do campo RS9_SEG inválido, valores válidos (0, 1, 2 ou 3)."
					EndIf
				ElseIf cVersEnvio >= "9.0.00"
					If M->RA_TPPREVI == '2' .And. Empty(RS9->RS9_SEGR)
						AAdd(aCposImp,{"RS9_SEGR", "Valor de RA_TPPREVI = " + M->RA_TPPREVI + " - " + STR0417}) //Quando o campo RA_TPPREVI é igual a 2 o campo RS9_SEGR deve ser preenchido."
					ElseIf M->RA_TPPREVI $ ' |1' .And. !Empty(RS9->RS9_SEGR)
						AAdd(aCposImp,{"RS9_SEGR", "Valor de RA_TPPREVI = " + M->RA_TPPREVI + " - " + STR0414}) //"O campo RS9_SEGR deve ser preenchido somente quando o campo RA_TPPREVI for igual a 2."
					EndIf
				Endif

				//Novos campos da tabela RS9
				If lValNewRS9 .And. lRS9_INDCE
					IF (Alltrim(RS9->RS9_TPPROV) $ "1#2" .And. Empty(RS9->RS9_DTNOM)) .Or. (!AllTrim(RS9->RS9_TPPROV) $ "1#2" .And. !Empty(RS9->RS9_DTNOM))
						AAdd(aCposImp,{"RS9_DTNOM",STR0204}) //"Conteúdo do campo RS9_DTNON inválido, este campo deve ser preenchido se o tipo de provimento for igual a 1 ou 2 e não deve ser preenchido nos demais casos."
					Endif
					IF (Alltrim(RS9->RS9_TPPROV) == "1" .And. Empty(RS9->RS9_DTPOSS)) .Or. (Alltrim(RS9->RS9_TPPROV) <> "1" .And. !Empty(RS9->RS9_DTPOSS))
						AAdd(aCposImp,{"RS9_DTPOSS",STR0205}) //"Conteúdo do campo RS9_DTPOSS inválido, este campo deve ser preenchido se o tipo de provimento for igual a 1 e não deve ser preenchido nos demais casos."
					Endif
					IF Empty(RS9->RS9_INGSP)
						AAdd(aCposImp,{"RS9_INGSP",STR0176}) //"Conforme Categoria eSocial - Preencher Dados do Agente Público - RS9"
					Endif
					IF (M->RA_TPPREVI == '2' .And. Empty(RS9->RS9_IDABON)) .or. (M->RA_TPPREVI $ ' |1' .And. !Empty(RS9->RS9_IDABON))
						AAdd(aCposImp,{"RS9_IDABON",STR0206}) //"O campo RS9_IDABON deve ser preenchido somente se o campo RA_TPPREVI for igual a 2."
					Endif
					IF (RS9->RS9_IDABON == '1' .And. Empty(RS9->RS9_DTABON)) .or. (RS9->RS9_IDABON $ ' |2' .And. !Empty(RS9->RS9_DTABON))
						AAdd(aCposImp,{"RS9_DTABON",STR0207}) //"O campo RS9_DTABON deve ser preenchido somente se o campo RS9_IDABON for igual a 1."
					Endif
					IF (RS9->RS9_IDEPR == '1' .And. Empty(RS9->RS9_DTINPR)) .or. (RS9->RS9_IDEPR $ ' |2' .And. !Empty(RS9->RS9_DTINPR))
						AAdd(aCposImp,{"RS9_DTINPR",STR0208}) //"O campo RS9_DTINPR deve ser preenchido somente se o campo RS9_IDEPR for igual a 1."
					Endif
					IF (M->RA_CATEFD == '304' .And. Empty(RS9->RS9_INDCE)) .or. (M->RA_CATEFD <> '304' .And. !Empty(RS9->RS9_INDCE))
						AAdd(aCposImp,{"RS9_INDCE",STR0209}) //"O campo RS9_INDCE deve ser preenchido somente se o campo RA_CATEFD for igual a 304."
					Endif
				Endif
			Endif

			RestArea(aAreaRS9)
		Else
			AAdd(aCposImp,{STR0179}) //Não foi encontrada a tabela RS9-Agentes Públicos, favor executar o UPDDISTR
		Endif
	Endif

	If !Upper(AllTrim(FunName())) $ "GPEA010|GPEA011" .And. cCateg == "106" .And. M->RA_TPCONTR == "2"
		aAreaRBW := RBW->(GetArea())
		dbselectArea("RBW")
		RBW->(dbSetOrder(1))
		If ! (MsSeek((cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT))
			AAdd(aCposImp,{"RBW_MOTIVO",STR0116}) //"Conforme Categoria eSocial - Preencher Dados do Temporario - RBW"
		Else
			IF empty(RBW->RBW_MOTIVO) .or. (RBW->RBW_MOTIVO == "1" .and. EMPTY(RBW->RBW_CPFSUB))
				AAdd(aCposImp,{"RBW_MOTIVO",STR0116}) //"Conforme Categoria eSocial - Preencher Dados do Temporario - RBW"
			EndIf
		Endif

		RestArea(aAreaRBW)
	EndIf

	//DEPENDENTES
	aAreaSRB := GetArea()
	DbSelectArea( "SRB" )
	DbSetOrder( 1 )
	If SRB->(dbSeek((cAliasSRA)->RA_FILIAL+M->RA_MAT))
		While SRB->( !EOF() ) .And. SRB->RB_FILIAL + SRB->RB_MAT == (cAliasSRA)->RA_FILIAL+M->RA_MAT
			nIdade := CALC_IDADE(DDATABASE,SRB->RB_DTNASC)
			For x:=1 to LEN(aCpoDepend)
				If Empty(&(aCpoDepend[x]))
					AAdd(aCposImp,{aCpoDepent[x],STR0107}) //"Campo em branco"
				EndIf
			Next x
			IF cVersEnvio >= "2.5.00"
				If SRB->RB_TIPIR <> "4" .And. Empty(SRB->RB_CIC)
					AAdd(aCposImp,{"RB_CIC", STR0224}) //"Dependente com IR sem CPF preenchido"
				EndIf
			ELSE
				If nIdade >= 8 .And. SRB->RB_TIPIR <> "4" .And. Empty(SRB->RB_CIC)
					AAdd(aCposImp,{"RB_CIC", STR0201}) //"Dependente maior de 8 anos sem CPF preenchido"
				EndIf
			ENDIF
			SRB->( DbSkip() )
		EndDo
	EndIf
	RestArea(aAreaSRB)

	//Validação do preenchimento da CNH para motoristas
	If Empty(aTabS130)
		fCarrTab( @aTabS130, "S130", dDataBase, .T. )
	EndIf
	nTamS :=  LEN(aTabS130)

	If lCargSQ3
		If SQ3->(dbSeek(xFilial("SQ3", M->RA_FILIAL) + M->RA_CARGO))
			cRaCbo := SQ3->Q3_CBO
		EndIf
	Else
		If SRJ->(dbSeek(xFilial("SRJ", M->RA_FILIAL) + M->RA_CODFUNC))
			cRaCbo := SRJ->RJ_CODCBO
		EndIf
	EndIf

	If nTamS > 0
		For nS := 1 to nTamS
			//Posição 6 = CBO
			cCBO := AllTrim(strTran(aTabS130[nS,6], "-", ""))
			If Len(cCBO) > 4
				If ( nPosTab := Ascan(aTabS130,{ |x| x[2] == M->RA_FILIAL .And. cCBO == cRaCbo })) > 0
					lAchou := .T.
				ElseIf ( nPosTab := Ascan(aTabS130,{ |x| x[2] == Space(FwGetTamFilial) .And. cCBO == cRaCbo })) > 0
					lAchou := .T.
				EndIf
			Else
				cRaCbo := Left(cRaCbo,4)

				If (nPosTab := Ascan(aTabS130,{ |x| x[2] == M->RA_FILIAL .And. cCBO == cRaCbo})) > 0
					lAchou := .T.
				ElseIf (nPosTab := Ascan(aTabS130,{ |x| x[2] == Space(FwGetTamFilial) .And. cCBO == cRaCbo})) > 0
					lAchou := .T.
				EndIf
			EndIf
			If lAchou
				//Posição 5 = Tipo de Documento
				If aTabS130[nS,5] == "01"
					lVerCNH := .T.
				Else
					lVerOC := .T.
				EndIf
			EndIf
			If lVerCNH
				If Empty(M->RA_HABILIT)
					AAdd(aCposImp,{"RA_HABILIT",STR0107}) //Campo não preenchido
					lErroCNH := .T.
				EndIf
				If Empty(M->RA_UFCNH)
					AAdd(aCposImp,{"RA_UFCNH",STR0107}) //Campo não preenchido
					lErroCNH := .T.
				EndIf
				If Empty(M->RA_DTEMCNH)
					AAdd(aCposImp,{"RA_DTEMCNH",STR0107}) //Campo não preenchido
					lErroCNH := .T.
				EndIf
				If Empty(M->RA_DTVCCNH)
					AAdd(aCposImp,{"RA_DTVCCNH",STR0107}) //Campo não preenchido
					lErroCNH := .T.
				EndIf
				If Empty(M->RA_CATCNH)
					AAdd(aCposImp,{"RA_CATCNH",STR0107}) //Campo não preenchido
					lErroCNH := .T.
				EndIf
				If Empty(M->RA_DTINCON)
					AAdd(aCposImp,{"RA_DTINCON",STR0107}) //Campo não preenchido
					lErroCNH := .T.
				EndIf
				Exit
			EndIf
			If lVerOC
				If Empty(M->RA_CODIGO)
					AAdd(aCposImp,{"RA_CODIGO",STR0107}) //Campo não preenchido
					lErroOC := .T.
				EndIf
				If Empty(M->RA_OCEMIS)
					AAdd(aCposImp,{"RA_OCEMIS",STR0107}) //Campo não preenchido
					lErroOC := .T.
				EndIf
				If Empty(M->RA_OCDTEXP)
					AAdd(aCposImp,{"RA_OCDTEXP",STR0107}) //Campo não preenchido
					lErroOC := .T.
				EndIf
				Exit
			EndIf
		Next nS
	Endif

	SX3->(dbSetOrder(2))

	If lErroCNH
		AAdd(aAuxDados, STR0230)//"De acordo com o CBO do funcionário é necessário informar os dados da CNH (RA_HABILIT) - Verifique Cadastro de Funcionários e Cadastro de Função"
	ElseIf lErroOC
		AAdd(aAuxDados, STR0231)//"De acordo com o CBO do funcionário é necessário informar os dados do Órgão de Classe (RA_CODIGO) - Verifique Cadastro de Funcionários e Cadastro de Função"
	EndIf

	If Len(aCposImp) > 0
		lRet := .F.
		If !(FunName() $ "GPEA010|GPEA011") .And. Type("aLogProc") == "A"
			aAdd( aLogProc, OemtoAnsi(STR0113) + ": " + SRA->RA_FILIAL + " - " + OemToAnsi(STR0114) + ": " + M->RA_MAT + "-" + If(lOfuscaNom,Replicate('*',15),M->RA_NOME) ) //##"Filial:" ### Matricula

			For nX := 1 to len(aCposImp)
				If "tabela RS9" $ aCposImp[nX,1]
					aAdd(aLogProc, aCposImp[nX,1])
					aAdd(aAuxDados, aCposImp[nX,1])
				ElseIf SX3->(MsSeek(aCposImp[nX,1]))
					aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC) + " - Mot.: "+aCposImp[nX,2])
					aAdd(aAuxDados, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC) + " - Mot.: "+aCposImp[nX,2])
				EndIf
			Next nI
			aAdd(aLogProc, "")
		Endif
	Endif

	RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fG17VSRV  ³ Autor ³ Marcia M              ³ Data ³ 16/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida dados do SRA                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias SRA                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array com informacoe pertinentes ao Trabalhador            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fG17VSrv(cAliasSRV, aAuxErro,cVersEnvio,cAnoMes)
	Local aCampos	:= {}
	Local nX		:= 0
	Local cAliasTst := cAliasSRV
	Local aArea		:= GetArea()
	Local cVersGPE	:= ""
	Local lRet		:= .T.
	Local lOrgPb	:= SuperGetMv("MV_ORGPB",,.F.)

	Default aAuxErro	:= {}
	Default cVersEnvio	:= ""
	Default cAnoMes		:= ""

	If Empty(cVersEnvio)
		If FindFunction("fVersEsoc")
			fVersEsoc("S1010", .T.,/**/,/**/,@cVersEnvio,@cVersGPE)
		ELSE
			cVersGPE := "2.3"
		Endif
	Else
		cVersGPE := cVersEnvio
	EndIf

	If !(cVersGPE >= "2.4")
		aCampos := 	{"RV_NATUREZ", "RV_TIPOCOD", "RV_INCIRF", "RV_INCSIND", "RV_INCCP","RV_INCFGTS", "RV_DSRHE","RV_MED13", "RV_MEDFER","RV_MEDAVI"}
	ELSE
		aCampos := 	{"RV_NATUREZ", "RV_TIPOCOD", "RV_INCIRF", "RV_INCCP","RV_INCFGTS"}
	Endif

	//De acordo com NDE 02.2018, tetoRemum é de preenchimento obrigatório se a natureza jurídica do declarante for Administração Pública
	If lOrgPb .AND. (cAliasTst)->(ColumnPos("RV_REMESP")) > 0
		Aadd(aCampos, "RV_REMESP")
	Endif

	aCposImp := {}

	If !Empty((cAliasTst)->RV_NATUREZ)
		if Empty((cAliasTst)->RV_INCCP)
			AAdd(aCposImp,{"RV_INCCP",STR0107}) //Campo não preenchido
		Endif
		if Empty((cAliasTst)->RV_INCIRF)
			AAdd(aCposImp,{"RV_INCIRF",STR0107}) //Campo não preenchido
		Endif
		if Empty((cAliasTst)->RV_INCFGTS)
			AAdd(aCposImp,{"RV_INCFGTS",STR0107}) //Campo não preenchido
		Endif
		if cVersGPE < '9.0' .And. Empty((cAliasTst)->RV_INCSIND)
			AAdd(aCposImp,{"RV_INCSIND",STR0107}) //Campo não preenchido
		Endif
	Endif

	for nX := 1 to  len(aCampos)
		If empty(Alltrim((cAliasTst)->&(aCampos[Nx])))
			AAdd(aCposImp,{aCampos[nX],STR0107}) //Campo não preenchido
		endif
	Next nX

	if (cVersGPE >= "2.4")
		fGp17SRVEs(@aCposImp,cAliasTst)
	EndIf
	If cVersGPE >= '9.0'
		If (cAliasTst)->RV_INCCP $ '23|24|61'
			AAdd(aCposImp,{"RV_INCCP",STR0400}) //"O conteúdo 23, 24, 61 não pode mais ser usado no Leiaute S-1.0"
		EndIf
		If (cAliasTst)->RV_INCIRF $ '0   |1   |15  |35  |44  |55  |78  |81  |82  |83  |91  |92  |93  |94  |95  ' .And. cAnoMes >="202105"
			AAdd(aCposImp,{"RV_INCIRF",STR0401}) //"A partir do dia 01/05/2021 as verbas não poderão ser aceitas com este código de incidência de IRRF"
		EndIf
	EndIf

	SX3->(dbSetOrder(2))

	If Len(aCposImp)>0
		lRet := .F.
		aAdd(aLogProc, OemToAnsi(STR0108) + OemToAnsi((cAliasTst)->RV_FILIAL)+OemToAnsi((cAliasTst)->RV_COD) + " -> " + OemToAnsi((cAliasTst)->RV_DESC)) //##"Verba: "
		For nX := 1 to len(aCposImp)
			//Limita a quantidade de caracteres por linha
			fGp17LmtDsc(@aLogProc, aCposImp[nX,1], aCposImp[nX,2])

		Next nI
		aAdd(aLogProc, "")

	Endif
	aAuxErro := {}
	aAuxErro := aClone(aCposImp)
	RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fG17VRE0  ³ Autor ³ Marcia M              ³ Data ³ 18/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida dados do RE0                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias RE0                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fG17VRE0(cAliasRE0)
	Local cCampos := {}
	Local lRet := .T.
	Local nX := 0
	Local cAliasTst := cAliasRE0
	Local aArea		:= GetArea()

	cCampos := 	{"RE0_TPPROC"	,"RE0_PROJUD"	, "RE0_INDDEC"	,"RE0_DTDECI"	,"RE0_IDDEP"}
	aCposImp := {}


	If (ALLTRIM((cAliasTst)->RE0_TPPROC) == "J")
		If Empty((cAliasTst)->RE0_VARA)
			AAdd(aCposImp,{"RE0_VARA",STR0109}) //Codigo da vara deve estar preenchido
		endif
	Endif
	If (ALLTRIM((cAliasTst)->RE0_TPPROC) == "A") .And. !(ALLTRIM((cAliasTst)->RE0_INDDEC)) $ "1|3|5|9"
			AAdd(aCposImp,{"RE0_INDDEC",STR0110}) //Para processos administrativos Indicativo Decisao 1,3,5 ou 9
	Endif
	If (ALLTRIM((cAliasTst)->RE0_TPPROC) == "J") .And. !(ALLTRIM((cAliasTst)->RE0_INDDEC)) $ "1|2|3|4|9"
			AAdd(aCposImp,{"RE0_INDDEC",STR0110}) //Para processos Judiciais Indicativo Decisao 1,2,3,4 ou 9
	Endif

	for nX := 1 to len(cCampos)
		if cCampos[nX] <> "RE0_VARA"
			If empty((cAliasTst)->&(cCampos[Nx]))
				AAdd(aCposImp,{cCampos[nX],STR0107}) //Campo não preenchido
			endif
		Endif
	Next nX

	SX3->(dbSetOrder(2))

	if len(aCposImp)>0
		lRet := .F.
		aAdd(aLogProc, OemToAnsi(STR0111) + OemToAnsi((cAliasTst)->RE0_FILIAL)+OemToAnsi((cAliasTst)->RE0_NUM) + " -> " + OemToAnsi((cAliasTst)->RE0_DESCR)) //##"Processo "
		for nX := 1 to len(aCposImp)
			If SX3->(MsSeek(aCposImp[nX,1]))
					aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC)+" - Mot.: "+aCposImp[nX,2])
				//	cMsgLog += " - " + AllTrim(SX3->X3_CAMPO)
			EndIf
		Next nI
		aAdd(aLogProc, "")
	Endif

	RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fG17VSR6  ³ Autor ³ Christiane Vieira     ³ Data ³ 11/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida dados do sr6                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAliasSR6, aHorar                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fG17VSR6(aHorar, aLogProc, aTurnoAux, nOpcAP)
Local lRet			:= .T.
Local lTitulo		:= .F.
Local lGPM035		:= FunName() == "GPEM035"
Local nX			:= 0
Local aArea			:= GetArea()
Local nColsMarc		:= SuperGetmv( "MV_COLMARC" , NIL , 2 , cFilAnt )
Local cVersEnvio	:= ""
Local lTpJorn1      := SR6->(ColumnPos("R6_TPJOR1")) > 0

Default aLogProc	:= {}
Default aTurnoAux	:= {}
Default nOpcAP		:= 1

fVersEsoc("S1050", .F.,,,,,@cVersEnvio,,)

//	cXml += '					<codHorContrat>'+ aHorario[nZ,2]			+ '</codHorContrat>'

aCposImp := {}

If Empty(aHorar[19]) .And. nOpcAP < 5
	If cVersEnvio >= "9.0.00" .And. lTpJorn1
		AAdd(aCposImp,{"R6_TPJOR1", STR0405}) //"Campo necessário nos eventos dos funcionários vinculados ao turno"
	Else
		AAdd(aCposImp,{"R6_TPJORN", STR0405}) //"Campo necessário nos eventos dos funcionários vinculados ao turno"
	Endif
EndIf

If aHorar[5] == 0

	AAdd(aCposImp,{"PJ_ENTRA1",STR0141}) //A duração da Jornada deve estar preenchida.
	AAdd(aCposImp,{"PJ_SAIDA1",STR0141}) //A duração da Jornada deve estar preenchida.

	If nColsMarc > 1
		AAdd(aCposImp,{"PJ_ENTRA2",STR0141}) //A duração da Jornada deve estar preenchida.
		AAdd(aCposImp,{"PJ_SAIDA2",STR0141}) //A duração da Jornada deve estar preenchida.
	Endif

	If nColsMarc > 2
		AAdd(aCposImp,{"PJ_ENTRA3",STR0141}) //A duração da Jornada deve estar preenchida.
		AAdd(aCposImp,{"PJ_SAIDA3",STR0141}) //A duração da Jornada deve estar preenchida.
	Endif

	If nColsMarc > 3
		AAdd(aCposImp,{"PJ_ENTRA4",STR0141}) //A duração da Jornada deve estar preenchida.
		AAdd(aCposImp,{"PJ_SAIDA4",STR0141}) //A duração da Jornada deve estar preenchida.
	Endif

Endif

If aHorar[8] > 0
	If aHorar[10] == 0
		AAdd(aCposImp,{"PJ_HRSINT1",STR0142}) //A duração do primeiro intervalo deve estar preenchida.
	Endif
Endif

If aHorar[11] > 0
	If aHorar[13] == 0
		AAdd(aCposImp,{"PJ_HRSINT2",STR0144}) //A duração do segundo intervalo deve estar preenchida.
	Endif
Endif

If aHorar[14] > 0
	If aHorar[16] == 0
		AAdd(aCposImp,{"PJ_HRSINT3",STR0146}) //A duração do terceiro intervalo deve estar preenchida.
	Endif
Endif

If aHorar[19] == "09"
	If Empty(Alltrim(aHorar[20]))
		If aScan(aTurnoAux, {|x| AllTrim(aHorar[21]) == x}) == 0
			AAdd(aCposImp,{"R6_DTPJOR",OemToAnsi(STR0174) })//"A descrição do turno é obrigatório quando o turno (R6_TPJORN) está preenchido como '09'"
			Aadd(aTurnoAux, aHorar[21])
		EndIf
	Endif
Endif

SX3->(dbSetOrder(2))

If Len(aCposImp) > 0
	lRet := .F.
	For nX := 1 to Len(aCposImp)
		If SX3->(MsSeek(aCposImp[nX,1]))
			//Verifica se o campo esta vindo da SPJ ou SR6
			If AllTrim(SX3->X3_ARQUIVO) == "SPJ"
				If !lTitulo
					lTitulo := .T.
					aAdd(aLogProc, OemToAnsi(STR0138) + " -> " + OemToAnsi(aHorar[17])+ "--" + OemToAnsi(aHorar[18]) ) //##"Filial/Turno/Semana/Dia"
				Endif
			Else
				aAdd(aLogProc, OemToAnsi(STR0175)+ " -> " + OemToAnsi(aHorar[21]) + "--" + OemToAnsi(aHorar[18]) ) //##"Turno
			EndIf

			aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC)+" - Mot.: " + aCposImp[nX,2])
		EndIf
		If !lGPM035
			aAdd(aLogProc, "")
		Endif
	Next nI
	If lGPM035
		aAdd(aLogProc, "")
	Endif
Endif

RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fTpIdPCD  ³ Autor ³ Marcia Moura		    ³ Data ³ 13/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecionar Indicador pessoa com deficiencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fTpIdPCD   											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TAbela S61                                				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fTpIdPCD()

Local cTitulo:= OemtoAnsi(STR0148) //"Indicativo cotnratcao PCD" //
Local MvPar
Local MvParDef := "0129"
Local lRet := .T.
Local lOpt := .F.
Local cAlias := Alias()

Static aCat5:={	OemtoAnsi(STR0149),;  	//0 - desobrigado
		      	OemtoAnsi(STR0150),; 	//1 - dispensado parcialmente
		      	OemtoAnsi(STR0159),;	//2 - Com exibilidade suspensa, mesmo que parcialmente em virtude de Termo de Compromisso firmado com o Ministério do Trabalho
			  	OemtoAnsi(STR0160)}  	//9 - Obrigado


	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

// Chama funcao f_Opcoes
	lOpt := f_Opcoes(@MvPar,cTitulo,aCat5,MvParDef,12,49,.T.)

	If lOpt
		&MvRet :=  MvPar
	EndIf

	VAR_IXB := MvPar

Return( lRet )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fTpIdAPD  ³ Autor ³ Marcia Moura		    ³ Data ³ 13/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecionar Indicador Contrta. Aprendiz                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fTpIdAPD   											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TAbela S62                                				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fTpIdAPD()

Local cTitulo:= OemtoAnsi(STR0152) //"Indicativo cotnratcao Menor Aprendiz
Local MvPar
Local MvParDef := "012"
Local lRet := .T.
Local lOpt := .F.
Local cAlias := Alias()

Static aCat6:={	OemtoAnsi(STR0149),;  	//0 - Desobrigado
		      	OemtoAnsi(STR0150),; 	//1 - Dispensado parcialmente
			  	OemtoAnsi(STR0151)}		//2 - Obrigado


	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

// Chama funcao f_Opcoes
	lOpt := f_Opcoes(@MvPar,cTitulo,aCat6,MvParDef,12,49,.T.)

	If lOpt
		&MvRet :=  MvPar
	EndIf

	VAR_IXB := MvPar

Return( lRet )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fTpIdIE   ³ Autor ³ Marcia Moura		    ³ Data ³ 13/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecionar Indenficador da Instituicao Educativa            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fTpIdIE   											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TAbela S62                                				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fTpIdIE()

Local cTitulo:= OemtoAnsi(STR0156) //"Indicativo cotnratcao Menor Aprendiz
Local MvPar
Local MvParDef := "12"
Local lRet := .T.
Local lOpt := .F.
Local cAlias := Alias()

Static aCat:={OemtoAnsi(STR0157),;  //Sim
			  OemtoAnsi(STR0158)}  //Nao


	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

// Chama funcao f_Opcoes
	lOpt := f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.T.)

	If lOpt
		&MvRet :=  MvPar
	EndIf

	VAR_IXB := MvPar

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fEFDMsg   ³ Autor ³ Marcos Coutinho	     ³ Data ³ 18/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o usuário deseja ou não emitir msg de           ³±±
±±³          ³confirmação ao realizar a integração de um registro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fEFDMsg   											 	  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Varias funcoes irão utilizar                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fEFDMsg(cCompleMsg)

	Local cEFDMsg		:= ""
	Default cCompleMsg	:= ""

	If lEFDMsg
		//     Atenção              Registro enviado ao TAF com sucesso
		cEFDMsg	:= IIf(lMiddleware, OemtoAnsi(STR0257), OemtoAnsi(STR0161)) + CHR(10)+CHR(13) + cCompleMsg
		If IsInCallStack("TCFA040Atende") .And. !IsBlind()
			MsgInfo( cEFDMsg, STR0045 )
		Else
			Aviso( OemtoAnsi(STR0045), cEFDMsg, { STR0162 } )
		EndIf
	EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³MsgErro   ³ Autor ³ Eduardo	     ³ Data ³ 18/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o usuário deseja ou não emitir msg de           ³±±
±±³          ³com o aviso do erro gerado 						       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fEFDMsg   											 	  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Varias funcoes irão utilizar                    			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fEFDMsgErro(cMsgErro)
Default cMsgErro:= ""
	If lEFDMsg
		//     Atenção
		Aviso( OemtoAnsi(STR0045) , cMsgErro,	{ STR0162 } )
	EndIf
Return

/*/{Protheus.doc} fStatusTAF(@aTpAlt,cStatus,cStat1)
Retorna o array aTpAlt que irá definir qual será o leiaute a ser gerado no TAF:
por exemplo (aTpAlt[3] = .T. refere-se a alteração contratual evento S-2206)

@type function
@sample	fStatusTAF(@aTpAlt,cStatus,cStat1,cFuncaoPai,aContainer)
@param		aTpAlt  - Carregada com as posições que poderão gerar os eventos do eSocial, ex: {.T.,.F.,.T.} irá gerar o evento S-2200
@param		cStatus - Retorna o Status do evento S-2200, a partir da função TAFGetStat
@param		cStat1  - Retorna o Status do evento S-2100, a partir da função TAFGetStat
@param		cFuncaoPai - Armazena o nome da função pai (Usado em validações especificas)
@param		aContainer - Armazena os valores de lRetif, lAltCad e lAltCon
@return	aTpAlt  - devolve por referência
@author	Claudinei Ribeiro Soares
@since		12/16/2017
@version	P12

Tipos de retorno do Status:
"-1": Registro não encontrado na base do TAF
" ": Registro encontrado no TAF - não submetido ao processo de validação
"0": Registro encontrado no TAF - válido
"1": Registro encontrado no TAF - inválido
"2": Registro encontrado no TAF - transmitido e aguardando retorno do Governo
"3": Registro encontrado no TAF - transmitido e não autorizado ( retornado com erro )
"4": Registro encontrado no TAF - transmitido e autorizado
"6": Registro encontrado no TAF - pendente de exclusão no Governo ( S-3000 )
"7": Registro encontrado no TAF - exclusão validada pelo Governo ( S-3000 )

/*/
Function fStatusTAF(aTpAlt,cStatus,cStat1,cFuncaoPai,aContainer)
Local lRetif
Local lAltCad
Local lAltCon
Local lRet			:= .T.

Default cStatus		:= ""
Default cStat1		:= ""
Default aTpAlt		:= {}
Default cFuncaoPai	:= ""
Default aContainer	:= {}


//	cStatus := TAFGetStat( "S-2100", cCPF)
//	cStat1  := TAFGetStat( "S-2200", cCPF)
//	cStat2  := TAFGetStat( "S-2299", cCPF)

	//-----------------------
	//| Validação cFuncaoPai
	//| Se cFuncaoPai estiver preenchida é que possui sua 'própria' regra de validação
	//----------------------------------------------------------------------------------
	If Empty( cFuncaoPai )
		If (cStatus == "-1" .and. cStat1  == "-1")
			aTpAlt := {.T.,.F.,.F.,.F.} // o evento pesquisado nao existe
		Elseif (cStatus  $ " |0|1|3")
			aTpAlt := {.T.,.F.,.F.,.F.} // gerar o 2200
		Elseif (cStat1  $ " |0|1|3")
			aTpAlt := {.F.,.T.,.F.,.F.} // gerar o 2100
		Elseif (cStatus == "4" .or. cStat1 == "4")
			aTpAlt := {.F.,.F.,.T.,.F.} // gerar o 2206 ou o nao periodico que o cliente quiser enviar
		Endif
	Elseif( cFuncaoPai == "GPEA926" )
		If (cStatus <> "2") //Só não deverá gerar o evento, caso o status no TAF seja igual a 2 > Registro já transmitido ao Governo, aguardando retorno.
			aTpAlt := {.T.,.F.,.F.,.F.}
		ELSEIF (cStat1 <> "2")
			aTpAlt := {.F.,.T.,.F.,.F.}
		ENDIF
	ElseIf( cFuncaoPai == "GPEA010" )
		//---------------------------------------
		//| Função de validação vinda da GPEA010
		//---------------------------------------
		//| Registro não encontrado
		//| Se ele não encontrar o registro na tabela C9V, ele gerará um registro novo
		//| Eventos: S2200 e S2300
		//----------------------------------
		lRetif	:= aContainer[1,1]
		lAltCad	:= aContainer[1,2]
		lAltCon	:= aContainer[1,3]

		If  ( cStatus == "-1" .and.  cStat1 == "-1" ) .OR. (cStatus  $ " |0|1|3")
			aTpAlt := {.T.,.F.,lAltCad,lAltCon}
		Else
			//----------------------------------
			//| Aguardando Retorno
			//| Se ele encontrar o registro, mas ele esta em transito, ele não realiza nenhuma alteração
			//| Eventos: Todos
			//----------------------------------
			If cStatus == "2" .or. cStat1 == "2"
				If !lMiddleware
					MsgAlert(OemToAnsi(STR0163))//"eSocial: Registro de admissão do funcionário em trânsito TAF x RET. A alteração não será efetivada."
				Else
					MsgAlert(OemToAnsi(STR0260))//"eSocial: Registro de admissão do funcionário em trânsito ao RET. A alteração não será efetivada."
				EndIf
				aTpAlt := {.F.,.F.,.F.,.F.}
				lRet := .F.

			//----------------------------------
			//| Alteração Retificadora
			//| Entrou pelo 2100, mas esta com erro entao sobrepoe o 2100 como retiricadora
			//| Eventos: 2100
			//----------------------------------
			ElseIf (cStatus == "-1" .and.  cStat1  $ " |0|1|3") //
				aTpAlt := {.F.,.T.,.F.,.F.}

			//----------------------------------
			//| Alteração Cadastral ou Contratual
			//| Se 2100 com sucesso OU 2200 validado OU erro de validacao
			//| Envia retificadora da 2100, alteracao cadastral e contratual
			//| Eventos: 2100
			//----------------------------------
			ElseIf cStat1 == "4" .or. (Val(cStatus) >= 0 .and. Val(cStatus) < 2 )
				aTpAlt := {.F.,lRetif,lAltCad,lAltCon}

			//----------------------------------
			//| Alteração Cadastral e Contratual
			//| Envia retiricadora da 2200 ou 2300 -> alteracao contratual e cadastral
			//| Eventos: 2200, 2300
			//----------------------------------
			ElseIf cStatus  == "4"
				aTpAlt := {lRetif,.F.,lAltCad,lAltCon}
			EndIf
		EndIf

	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FeSoc2Err
Função criada para fazer o de/para dos erros criados nas funções GRV() do eSocial com os erros utilizados no gerenciador de integração.
Durante o desenvolvimento da fila de integração foi iniciado um trabalho de padronização desses códigos, visto que a relação sendo 1x1 não existe
@Param	cErro	- Erro do eSocial a ser convertido para o erro de integraçãdo - FeSoc2Err()
@Param	cErroXERP- Descrição do Erro(PASSAR POR REFERÊNCIA)
@Param	nMsg	- Tipo de Mensagem (1= Erro ou 2 = Alerta )
@Author	Eduardo
@Since	19/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
function FeSoc2Err( cErro, cErroXERP ,nMsg)

Local	cErroDePara	:= ""
Local	aErros		:= {}
Local 	aWarn		:= {}
Local	nPosErr		:= 0

default cErro		:= ""
default cErroXERP	:= ""
default nMsg 		:= 1
cErroDePara	:=	''
nPosErr		:=	0

aErros 		:= { 	;
						{ 'ERRO01' , "Verificação para validação da integração 2230, Existe um registro com essa mesma chave e com data término em branco'" } ,;
						{ 'ERRO02' , "Para a integração dos eventos de alteração S-2205 (Alteração de Dados Cadastrais do Trabalhador) ou S-2206 (Alteração de Contrato de Trabalho), é necessário que exista o evento S-2100 (Cadastramento Inicial do Vínculo) ou S-2200 (Admissão de Trabalhador) correspondente ao evento de alteração do trabalhador."},;
						{ 'ERRO04' , "O evento de alteração do trabalhador integrado, S-2205 (Alteração de Dados Cadastrais do Trabalhador) ou S-2206 (Alteração de Contrato de Trabalho), possui um evento pai S-2100 (Cadastramento Inicial do Vínculo) ou S-2200 (Admissão de Trabalhador) com inconsistência ou não validado pelo RET."},;
						{ "000001" , "Erro de estrutura, favor verificar o Layout TAF."},;
						{ "000002" , "Filial não cadastrada no Cadastro de Complemento de Empresa do TAF."},;
						{ "000003" , "Erro na exclusão do registro."},;
						{ "000004" , "Erro de integridade, registro não pode ser excluído."},;
						{ "000005" , "Erro de duplicidade de registro. Clique em Depurar para mais informações!"},;
						{ "000006" , "Ambiente Desatualizado, o cadastro referente ao evento não existe no repositório de dados do ambiente."},;
						{ "000007" , "A operação solicitada no XML está em desacordo com o cenário do registro na base do TAF"},;
						{ "000008" , "Existem TAG´s do XML com informações duplicadas, a integração não será realizada"},;
						{ "000009" , "Registro não integrado. Duplo clique para mais informações!"},;
						{ "000010" , "Para a integração dos eventos de alteração S-2205 (Alteração de Dados Cadastrais do Trabalhador) ou S-2206 (Alteração de Contrato de Trabalho), é necessário que exista o evento S-2100 (Cadastramento Inicial do Vínculo) ou S-2200 (Admissão de Trabalhador) correspondente ao evento de alteração do trabalhador."},;
						{ "000011" , "Para a integração do evento de alteração S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou término S-2399 (Trabalhador Sem Vínculo - Término), é necessário que exista o evento S-2300 (Trabalhador Sem Vínculo - Início) correspondente ao evento de alteração ou término do trabalhador sem vínculo."},;
						{ "000012" , "O evento de alteração do trabalhador integrado, S-2205 (Alteração de Dados Cadastrais do Trabalhador) ou S-2206 (Alteração de Contrato de Trabalho), possui um evento pai S-2100 (Cadastramento Inicial do Vínculo) ou S-2200 (Admissão de Trabalhador) com inconsistência ou não validado pelo RET."},;
						{ "000013" , "O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) com inconsistência ou não validado pelo RET."},;
						{ "000014" , "Existe um registro com essa mesma chave e com data término em branco"},;
						{ "000015" , "Existem campos da chave que não foram enviados na mensagem, não foi possível realizar a integração deste registro"},;
						{ "000016" , "Ocorreu um erro interno do sistema durante a integração deste registro, tente novamente"},;
						{ "000017" , "Não é possível integrar um evento de Alteração quando houver uma Finalização ativa."},;
						{ "000018" , "Não é possível integrar este evento, pois existe um 'Cancelamento' ativo para este Afastamento."},;
						{ "000019" , "Não é permitido a integração deste evento, enquanto houver outra alteração pendente de transmissão"},;
						{ "000020" , "Não é possível integrar um evento de retificação, referente ao Início do Afastamento, quando houver uma Alteração ou Finalização ativa"},;
						{ "000021" , "Erro de Concorrência - Não foi possível realizar a gravação do registro pois estava reservado por outro usuário"},;
						{ "000022" , "Erro de chave duplicada, favor verificar as informações que estão sendo integradas."},;
						{ '000023' , "O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) aguardando retorno do Governo." } ,;
						{ '000024' , "O evento de alteração do trabalhador integrado, S-2205 (Alteração de Dados Cadastrais do Trabalhador) ou S-2206 (Alteração de Contrato de Trabalho), possui um evento pai S-2100 (Cadastramento Inicial do Vínculo) ou S-2200 (Admissão de Trabalhador) com inconsistência ou não validado pelo RET." } ,;
						{ '000025' , "Não é permitido a integração deste evento, enquanto outro estiver pendente de transmissão." } ,;
						{ '000026' , "Exclusão direta de Evento no TAF - A chave do evento enviado no S-3000 não estava transmitida ao Governo." },;
						{ 'ERRO15' , "Verificação para validação de EventosNão Periódicos, Existem campos da chave que não foram enviados na mensagem, não foi possível realizar a integração deste registro" } ,;
						{ 'ERRO16' , "Verificação para validação de EventosNão Periódicos, Ocorreu um erro interno do sistema durante a integração deste registro, tente novamente" } ,;
						{ 'ERRO17' , "Verificação para validação de EventosNão Periódicos, Não é possível integrar um evento de Alteração quando houver uma Finalização ativa.'" } ,;
						{ 'ERRO18' , "Verificação para validação de EventosNão Periódicos, Não é possível integrar este evento, pois existe um 'Cancelamento' ativo para este Afastamento." } ,;
						{ 'ERRO19' , "Verificação de chave duplicada, Erro de chave duplicada, favor verificar as informações que estão sendo integradas." }}

if ( nPosErr := aScan( aErros , {|x| x[ 1 ] == allTrim( cErro ) } ) ) > 0
	cErroDePara := "000009"
	cErroXERP   := aErros[ nPosErr  , 2 ]
else
	cErroXERP:= cErro
endif

return cErroDePara

//-------------------------------------------------------------------
/*/{Protheus.doc} fVersEsoc
Função criada para fazer a verificação e comparação dos layout disponível entre os ambientes SIGAGPE e SIGATAF.
@Param	cEvento...(C):	Armazena qual eventos queremos verificar
@Param	lExbAlert.(L):	Informa se deseja ou não que a função exiba a mensagem de alerta sobre qual layout esta o GPExTAF
@Param	aRetGPE...(A):	Retorna - Armazena qual versão esta o layout dentro do GPE
                               [1][1] - (L) Existe no GPE
                               [1][2] - (C) Layout no GPE
@Param	aRetTAF...(A):	Retorna - Armazena qual versão esta o layout dentro do TAF
                               [1][1] - (L) Existe no TAF
                               [1][2] - (C) Layout no TAF
@Param	cVersEnvio(C):	Retorna - Qual layout esta sendo validado
@Param	lRet......(L):	Retorno lógico se pode ou não realizar a integração

@Return	lRet......(L): Retorno se é permitido ou não fazer a integração
@Author	Marcos Coutinho
@Since	11/09/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function fVersEsoc( cEvento, lExbAlert, aRetGPE, aRetTAF, cVersEnvio, cVersGPE, cVersMW, lNT15, cGpeAmbe )
	Local aArea			:= {}
	Local aAreaSX3		:= SX3->(GetArea())
	Local lRet			:= .T.
	Local nPosEvnt		:= 0
	Local lIntTAF		:= (SuperGetMv("MV_RHTAF",, .F.) == .T.) .OR. FUNNAME() == "GPEM023"//Integracao com TAF
	Local lMiddleware	:= SuperGetMv("MV_MID",, .F.)
	Local cTafAmbe		:= SuperGetMv('MV_TAFAMBE', .F., "2")
	Local aLayDspGpe	:= {	"S1005", "S1010", "S1020", "S1030", "S1035", "S1040", "S1050",;
								"S1200", "S1202", "S1210", "S1280", "S1295", "S1298", "S1299",;
								"S1300", "S2100", "S2190", "S2200", "S2205", "S2206", "S2230",;
								"S2250", "S2260", "S2298", "S2299", "S2300", "S2306", "S2399", "S3000", "S1000"}
	Local cVerTaf		:= StrTran( StrTran(SuperGetMv("MV_TAFVLES",, "2.4"),"_",".") ,"0", "", 1, 2)
	Local cVlesoc		:= GetNewPar("MV_VLESOC", "02_05_00")

	Default cEvento		:= ""
	Default lExbAlert	:= .T.
	Default cVersEnvio	:= ""
	Default aRetGPE		:= array(2)
	Default aRetTAF		:= array(2)
	Default cVersGPE	:= ""
	Default cVersMW		:= ""
	Default lNT15		:= .F.
	Default cGpeAmbe	:= SuperGetMv('MV_GPEAMBE',, "2")

	If cPaisLoc == 'BRA' .And. !IsInCallStack("MPVIEW")

		aArea := GetArea()
		Iif(Len(aRetGPE) = 0, aRetGPE := array(2),)
		Iif(Len(aRetTAF) = 0, aRetTAF := array(2),)

		cVerTaf:= StrTran( Iif(cVerTaf == "2.4.01","2.4",cVerTaf), "S.1", "9")

		dbSelectArea("SX3")
		SX3->(DbSetorder(2))

		If cVlesoc == "S_01_01_00"
			aRetGPE[2] := '9.1.00'
			cVersMW	   := "_S_01_01_00"
		ElseIf ChkFile("RJO") .AND. RJO->(ColumnPos("RJO_INCOP")) > 0 .And. (cVlesoc == "S_01_00_00")
			aRetGPE[2] := '9.0.00'
			cVersMW	   := "_S_01_00_00"
		ElseIf ChkFile("SVA") .AND. SVA->(ColumnPos("VA_TP")) > 0
			aRetGPE[2] := '2.5.00'
			cVersMW	   := "02_05_00"
		ElseIf ChkFile("SR8") .AND. SR8->(ColumnPos("R8_NRPRCJU")) > 0 .And. TAMSX3("R8_NRPRCJU")[1] > 20
			aRetGPE[2] := '2.4.02'
			cVersMW	   := "02_04_02"
		ElseIf ( ChkFile("SRK") .AND. ChkFile("SR8") .AND. SRK->(ColumnPos("RK_CONSFGT")) > 0 .And. SR8->(ColumnPos("R8_TPPROC")) > 0 ) .Or. ( ChkFile("RFZ") .AND. RFZ->(ColumnPos("RFZ_ONUS")) > 0 )
			aRetGPE[2] := '2.4'
			cVersMW	   := "02_04_00"
		ElseIf ( ChkFile("SR8") .AND. SR8->(ColumnPos("R8_TPPROC")) > 0 ) .Or. ( ChkFile("RFZ") .AND. RFZ->(ColumnPos("RFZ_ONUS")) > 0 )
			aRetGPE[2] := '2.3'
			cVersMW	   := "02_03_00"
		ElseIf ChkFile("SRA") .AND. SRA->(ColumnPos("RA_NSOCIAL")) > 0
			aRetGPE[2] := '2.2'
			cVersMW	   := "02_02_00"
		ElseIf ChkFile("SRA") .AND. SRA->(ColumnPos("RA_CLASEST")) > 0
			aRetGPE[2] := '2.1'
			cVersMW	   := "02_01_00"
		ElseIf ChkFile("CTT") .AND. CTT->(ColumnPos("CTT_TPLOT")) > 0
			aRetGPE[2] := '1.1'
			cVersMW	   := "01_01_00"
		ElseIf cEfdAvis <> "9"
			aRetGPE[2] := '1.0'
			cVersMW	   := "01_00_00"
		Else
			aRetGPE[2] := ''
		Endif

		If !Empty( cEvento )
			cEvento	:= AllTrim( StrTran( cEvento, "-", "" ) )
			nPosEvnt := aScan(aLayDspGpe,{|x| AllTrim(x) == cEvento })

			If( nPosEvnt > 0 )
				aRetGPE[1] := .T.
			Else
				aRetGPE[1] := .F. //GPE
			EndIf

		Else
			aRetGPE[1] := .F. //GPE
		EndIf

		If lIntTAF .And. !lMiddleware
			aRetTAF	:= TafExisEsc( cEvento )
			aRetTAF[2]:= cVerTaf
			//Só faz o processo se encontrar no TAF
			If!( aRetTAF[1] == .T. .AND. !Empty(aRetTAF[2])  )
				//Como não existe o evento no TAF, já aplica um retorno negativo
				//##EVENTO - ##### ##"Evento não disponível ou não compatibilizado para o layout corrente."
				Help( ,, OemToAnsi(STR0166) + cEvento,,OemToAnsi(STR0171) , 1, 0 )
				Return .F.
			EndIf
		EndIf

		//-------------------------------------------------------
		//| Realiza a comparação para ver se o layout disponivel
		//| no módulo GPE é igual ao disponível no módulo TAF
		//-------------------------------------------------------
		If lIntTAF .AND. !lMiddleware .And. Val( StrTran(aRetTAF[2],".","") ) > Val( StrTran(aRetGPE[2],".","") )
			lRet := .F.
			cVersEnvio := aRetTAF[2]
			cVersGPE   := aRetGPE[2]
		Else
			If lIntTAF .And. !lMiddleware
				lRet := .T.
				cVersEnvio := aRetTAF[2]
				cVersGPE   := aRetGPE[2]
			Else
				If !lMiddleware
					lRet := .F.
				EndIf
				cVersEnvio := aRetGPE[2]
				cVersGPE   := aRetGPE[2]
			EndIf
		EndIf

		If lIntTaf .AND. !lMiddleware .And. !lRet .And. lExbAlert
			//    "Atencao - Evento:   #####"##    "A versão de leiaute eSocial do TAF está incompatível com a versão de leiaute eSocial do GPE"##"Ok"
			Help( ,, OemToAnsi(STR0166) + cEvento,,OemToAnsi(STR0167) + CRLF + CRLF + "GPE: " + aRetGPE[2] + " | " + "TAF: " + aRetTAF[2] , 1, 0 )
		EndIf

		If lMiddleware .Or. cVersEnvio >= "2.5" .And. ( (cTafAmbe == "2" .And. dDataBase >= cToD("08/10/2019")) .Or. (cTafAmbe == "1" .And. dDataBase >= cToD("11/11/2019")) )
			If lMiddleware .Or. !X3Obrigat("RBW_TPCONT")
				lNT15 := .T.
			EndIf
		EndIf

		SX3->(RestArea(aAreaSx3))
		RestArea(aArea)

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GPECadFilEvent
Fonte de instalação de eventos no cadatros de empresas
@param oModel - Modelo definido pela FwCadFilial que deverá ser usado para instalar o evento
@return Nil
@obs A criação e instalação do evento é útil para toda GDP que precisa realizar alguma ação após a manutenção
do cadastro de empresas, como por exemplo o envio de informações para o eSocial.
O evento de cada GDP deverá ser desenvolvivo em classes separadas(em fontes separados) que extendam a classe FWModelEvent.
Depois de desenvolvida a classe, um objeto deve ser instanciado e instalado no oModel que vem como parâmetro
@sample
@author Vinicius Ledesma
@since 04/11/2016
@version P12
/*/
//-------------------------------------------------------------------
Class GPECadFilEvent FROM FWModelEvent
	Data lRet
	Data lCNAE
	Data lFPAS
	Method new()
	Method AfterTTS()
	Method ModelPosVld()
End Class
Method ModelPosVld(oModel, cModelId) Class GPECadFilEvent
	lRet:= fInt005Vl(oModel,cModelId,@self:lCNAE,@self:lFPAS)
return lRet

Method AfterTTS(oModel, cModelId) Class GPECadFilEvent
	lRet:= fIntExt005(oModel,cModelId,self:lCNAE,self:lFPAS)
return lRet
Method new()  Class GPECadFilEvent
	lRet:= .T.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntExt005
Função responsável pela integração com o TAF
@param oMdl - Modelo definido pela FwCadFilial que deverá ser usado para instalar o evento
@return Nil
@obs Responsável por realizar os devidos tratamentos e envio para o TAF
@sample
@author Eduardo Vicente
@since 13/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function fIntExt005(oMdl, cModelId, lCNAE, lFPAS, lRot941B, nOperMdl, cMsgErro)

	Local aEstObras		:= {}
	Local aX14			:= {}
	Local aTabS120		:= {}
	Local aTabS119		:= {}
	Local aEstEd		:= {}
	Local aErros		:= {}
	Local aTpAlt		:= {}
	Local aRetGPE		:= array(2)
	Local aRetTAF		:= array(2)
	Local aInfRAIS		:= {}
	Local aArrayFil		:= {}
	Local aFilInTaf		:= {}
	Local aLogProc		:= {}
	Local aDados		:= {}
	Local aTitle 		:= {}
	Local aResumo		:= {}
	Local aIncons		:= {}
	Local nE			:= 1
	Local nR			:= 1
	Local dDtRef   		:= CtoD("//")
	Local cAnoMes		:= fPerAll() //Ultimo dia do periodo de calculo
	Local cMesCh		:= StrZero( Month( dDataBase ), 2 )
	Local cAnoCh		:= Alltrim( Str( Year( dDataBase ) ) )
	Local cTpApr		:= ""
	Local cNrApr		:= ""
	Local cTpEEn		:= ""
	Local cTpPcd		:= ""
	Local cNrPcd		:= ""
	Local cSub			:= ""
	Local cVersEnvio	:= ""
	Local cFPAS			:= ""
	Local cMsg			:= ""
	Local cChave		:= ""
	Local cStatus		:= ""
	Local cInfoRais		:= ""
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local nOpc			:= oMdl:GetOperation()
	Local nPos1,nPos2	:= 0
	Local nRat			:= 0
	Local nFap			:= 0
	Local nS119     	:= 0
	Local nPos2			:= 0
	Local nPos			:= 0
	Local nOpcAux		:= 0
	Local lRet			:= .T.
	Local lVerBlq		:= iif(ExistFunc("fVersEsoc"), fVersEsoc( "S1005", .F., @aRetGPE, @aRetTAF, @cVersEnvio ),.T.)
	Local nTamFil		:= If(FindFunction("FWSizeFilial"), FwSizeFilial(), Len(cFilAnt))
	Local cFilSM0		:= IIF(!EMPTY(SM0->M0_CODFIL), SubStr(SM0->M0_CODFIL, 1, nTamFil), "")
	Local cStatRJE		:= ""
	Local lVld1000		:= .T.
	Local lAdmPubl		:= .F.
	Local cFunc			:= ""
	Local cMsgDesatu	:= ""
	Local cTpProc		:= ""
	Local cNrProc		:= ""
	Local cCSusp		:= ""
	Local cTp			:= ""
	Local lTemRJL		:= ChkFile("RJL")
	Local cCNPJR		:= ""

	Default lRot941B	:= .F.
	Default nOperMdl	:= 0
	Default cMsgErro	:= ""

	If lRot941B
		nOpc := nOperMdl
	EndIf

	If lMiddleware .And. !ChkFile("RJE") .And. !ChkFile("RJ9")
		cMsgDesatu := CRLF + OemToAnsi(STR0258) + CRLF
		MSGINFO(cMsgDesatu,STR0228)
		lRet := .F.
		Return lRet
	EndIf

	If AllTrim(CvaltoChar(SM0->M0_TPINSC)) $ "2/3"
		cTpInsc		:= "1"
		cNrInsc		:= SM0->M0_CGC
	ElseIf SM0->M0_TPINSC == 1
		cTpInsc		:= "4"
		cNrInsc		:= SM0->M0_CEI
	EndIf

	//C92_FILIAL, C92_TPINSC, C92_NRINSC, C92_DTINI, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	cChave := iif(lMiddleware,cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14 ) + "S1005" + Padr( cFilSM0 + cNrInsc, fTamRJEKey(), " ") + AnoMes(dDataBase),cTpInsc + ";" + cNrInsc + ";" + cMesCh + cAnoCh)

	if lMiddleware
		cStat1005 := "-1"
		GetInfRJE( 2,cChave,@cStat1005)

		If cStat1005 $ "-1|1|3" .And. nOpc <> 5
			nOpcAux := 3

		ElseIf cStat1005 == "2"
			nOpcAux := 0
			lRet := .F.
		ElseIf cStat1005 == "4" .And. nOpc <> 5
			nOpcAux := 4
		Elseif nOpc == 5
			nOpcAux := 5
		EndIf
	Else
		nOpcAux := fVerExtemp( "S-1005", cChave, nOpc, @cStatus )
		//Força a valida do Tipo de Alteração
		aTpAlt := {.F., .F., .F.}
		lRet:= fStatusTAF(@aTpAlt,cStatus,"",/*cFuncaoPai*/, /*aContainer*/)
	EndIf

	if ( cStatus=="-1" .And. cValToChar(nOpc) $ "3#5") .Or. (!lCNAE .And. !lFPAS)
		lRet:= .F.
	EndIf

	nOpc := nOpcAux

	If  lRet
		dDtRef	:= cToD( "01/" + SubStr( cAnoMes, 5, 6 ) + "/" + SubStr( cAnoMes, 1, 4 ) )

		If cVersEnvio < "2.3"
			//Busca informacoes do Parametro45 // ponto
			fCar_RAIS(@aInfRAIS, cFilSM0, .F., cAnoMes)
		Endif

		//Busca informacoes do Parametro14
		fInssEmp(cFilSM0,@aX14,.F.,cAnoMes)

		nRAT	:= aX14[29, 1] * 100
		nFAP	:= (aX14[3, 1] * 100) / (aX14[29, 1] * 100)
		cFPAS	:= alltrim(Str(Val(SM0->M0_FPAS)))

		//Busca somente o campo 30 (Sub Patronal) , que nao consta no fInssEmp.
		If SM0->M0_TPINSC == 1
            cSub := aX14[31,1]
        EndIf

		//carrega dados de contratacao pessoa com deficiencia
		fCarrTab( @aTabS119, "S119", dDtRef,.T. )
		//
		If Len(aX14) > 0
			// Dados da Filial
			cNrPcd := cTpPcd := cTpReg := cTpApr := cNrApr := cTpEEn := ""


			While nPos == 0 .And. nS119 <= 7
				nS119++
			    nPos := Ascan(aTabS119,{|x| AllTrim(x[2])+ AllTrim(x[3])== fChav119(nS119,.F.,cFilSM0,cAnoMes,"")})
			EndDo

			if nPos > 0
				cTpReg := AllTrim(aTabS119[nPos][9])
				cTpApr := aTabS119[nPos][10]
				cNrApr := aTabS119[nPos][11]
				cTpEEn := aTabS119[nPos][12]
				cTpPcd := aTabS119[nPos][6]
				cNrPcd := aTabS119[nPos][7]
				If Len(aTabS119[nPos]) >= 14
					cCNPJR:= aTabS119[nPos][14] // CNPJ Responsavel
				Endif
			endif
		EndIf
		//carrega as entidades de ensino dos tomadores
		fCarrTab( @aTabS120, "S120", dDtRef , .T.)

		IF len(aEstEd) == 0  // so deve carregar uma vez este array
			nS119:=0
			nPos:= 0
			While nPos == 0 .And. nS119 <= 7
				nS119++
			    nPos := Ascan(aTabS120,{|x| AllTrim(x[2])+ AllTrim(x[3])== fChav119(nS119,.F.,cFilSM0,cAnoMes,"")})
			EndDo
			if nPos > 0
				Aadd(aEstEd, aTabS120[nPos,7] )
			Endif
		Endif

		if cVersEnvio < "2.3" .And. Len(aInfRAIS)<=0
			cInfoRais:= aInfRAIS[14]
		Else
			cInfoRais:= ""
		EndIf

		If lRot941B
			If oMdl:GetOperation() != MODEL_OPERATION_DELETE
				cTpProc		:= oMdl:GetValue('MDLGPEA941B','RJL_TPPROC')
				cNrProc		:= oMdl:GetValue('MDLGPEA941B','RJL_NRPROC')
				cCSusp		:= oMdl:GetValue('MDLGPEA941B','RJL_CSUSP')
				cTp			:= oMdl:GetValue('MDLGPEA941B','RJL_TP')
			EndIf
		Else
			If lTemRJL .And. RJL->( dbSeek( xFilial("RJL", SM0->M0_CODFIL)+SubStr(SM0->M0_CODFIL, 1, FwSizeFilial()) ) )
				While RJL->( !EoF() ) .And. RJL->RJL_FILIAL+RJL->RJL_FIL == xFilial("RJL", SM0->M0_CODFIL)+SubStr(SM0->M0_CODFIL, 1, FwSizeFilial())
					If Empty(RJL->RJL_CC) .And. cAnoCh+cMesCh >= RJL->RJL_COMPET
						cTpProc		:= RJL->RJL_TPPROC
						cNrProc		:= RJL->RJL_NRPROC
						cCSusp		:= RJL->RJL_CSUSP
						cTp			:= RJL->RJL_TP
					EndIf
					RJL->( dbSkip() )
				EndDo
			EndIf
		EndIf

		//Array a ser enviado para o TAF no XML
		Aadd(aEstObras,	{	AllTrim(SM0->M0_CODFIL),			;//1-Filial
							cTpInsc,							;//2-Tipo de Inscricao
							cNrInsc,							;//3-Incriçao
							AllTrim(CvaltoChar(SM0->M0_FPAS)),	;//4-FPAS
							aX14[25,1],							;//5-cod terceiro !
							Alltrim(SM0->M0_CNAE),				;//6-CNAE
							Round(nRAT, 0),						;//7-RAT
							nFAP,								;//8-FAP
							(aX14[3,1]*100),					;//9-Perc Acidente
							Nil,								;//10-CC
							cSub,								;//11-Sub Patronal
							IIF(cVersEnvio == '2.3', cTpReg ,cInfoRais),;//12-Tipo de Registro de Ponto
							cTpApr,								;//13-Contrata aprendiz
							cNrApr,								;//14-Numero de Processo
							cTpEEn,								;//15-Tipo de entidade educacional
							cMesCh + cAnoCh,					;//16-Mes/Ano
							Nil,							 	;//17-Numero processo PCD
							cTpProc, 							; //18
							cNrProc, 							; //19
							cCSusp, 							; //20
							cTp,								; //21
							cCNPJR								})//22 CNPJ Responsavel


		//Fazer o tratamento necessário aqui, toda vez que o cadastro de empresas for alterado
		If lCNAE .Or. lRot941B
			cFunc := "Mat"
			lRet:= fCarrCTT( aEstObras, cMesCh + cAnoCh, aEstEd, aErros, cFilSM0, nOpc, 1, cFunc, lRot941B, @cMsgErro )
		Endif

		If lFPAS .And. !lMiddleware
			AADD(aArrayFil, Alltrim(SM0->M0_CODFIL)+ " ")
			fGp23Cons(aFilInTaf, aArrayFil)
			If !Empty(aFilInTaf)
				FWMsgRun(,{|| lRet:= fCargLota(cMesCh + cAnoCh, 1, @aLogProc, @aDados, aFilInTaf[1], , cVersEnvio, .T.,@aErros)	   },OemtoAnsi(STR0198),OemtoAnsi(STR0197))
			Else
				Return .T.
			EndIf
		Endif
	EndIf

	If Len( aErros ) <= 0 .And. Len( aDados ) <= 0 .And. Len(aEstObras)>0
		fEFDMsg()
	Else
		If lCNAE
			If !lMiddleware
				cMsg := ""
				cMsg += OemtoAnsi(STR0172)					//"Verifique informaçoes desta Empresa(Cad.Estabelecimentos) no módulo TAF."
				Help("",1,"HELP",,cMsg,1,0)		//"Carga TAF não realizada"
			Endif
		Endif

		If lFPAS
			//
			If Len(aDados) > 1
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Apresenta com Log de Ocorrências ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

				For nE := 1 to Len(aDados)
					aResumo := FWTxt2Array( aDados[nE], 131)
					For nR := 1 to Len(aResumo)
						Aadd(aIncons, aResumo[nR])
					Next nR
				Next nE

				aDados := {}

				For nE := 1 To Len(aIncons)
					Aadd( aDados, aIncons[nE] )
				Next nE

				fMakeLog({aDados}, aTitle, Nil, Nil, "Filial", OemToAnsi(STR0196), "M", "P",, .F.) //"Log de Ocorrências - Carga de filial - Evento S-1020."
			Else
				MsgAlert(OemToAnsi(STR0071)) //##"Não existem informações para serem carregadas"
			EndIf
		Endif
			//
	EndIf

Return lRet

/*/{Protheus.doc} fPerAll
Função responsável por retornar o periodo aberto ou fechado mais recente.
@param cFilProc - Filial que está sendo processada - Utilizada na busca na tabela RCH
@return cPer, caractere,
@obs Responsável por realizar os devidos tratamentos e envio para o TAF
@author Eduardo Vicente
@since 13/10/2017
@version P12
@history 05/07/2018, Cícero Alves, Alterada a busca para retornar apenas os períodos selecionados ou fechados
/*/
Function fPerAll( cFilProc )

	Local cPer		:= ""
	Local cAlsRCH 	:= GetNextAlias()

	cFilProc := xFilial("RCH", cFilProc)

	BeginSQL Alias cAlsRCH

		SELECT DISTINCT( RCH_PER )
		FROM %Table:RCH%
		WHERE RCH_FILIAL = %Exp:cFilProc%
		AND (RCH_DTFECH <> '' OR RCH_PERSEL = "1")
		ORDER BY RCH_PER DESC

	EndSQL

	(cAlsRCH)->(DBGOTOP())

	cPer:= (cAlsRCH)->RCH_PER
	(cAlsRCH)->(dbCloseArea())

Return cPer

//-------------------------------------------------------------------
/*/{Protheus.doc} fChav119
Função que monta a chave de busca para pesquisa da tabela S119
@param nS119 , numeric, Modelo definido pela FwCadFilial que deverá ser usado para instalar o evento
@param lCCusto , boolean,Modelo definido pela FwCadFilial que deverá ser usado para instalar o evento
@param cFil , caractere,Filial pra montagem de chave
@param cPer , caractere, periodo para montagem de chave
@param cCC , caractere, Centro de Custo para montagem da chave
@return cChave, caractere, Chave para busca
@obs Responsavel pela montagem da busca para S119
@sample
@author Eduardo Vicente
@since 18/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function fChav119(nS119,lCCusto,cFil,cPer,cCC)
Local cChave    := ""

Default cPer	:=	""
Default cCC		:= 	""
Default cFil	:= 	xFilial("CTT")
Default lCCusto := .F.
Default nS119   := 0

If lCCusto
    Do Case
        Case nS119 == 1
            cChave:= cFil+cPer+cCC
        Case nS119 == 2
            cChave:= cFil+cPer
        Case nS119 == 3
            cChave:= cFil+cCC
        Case nS119 == 4
            cChave:= cFil
        Case nS119 == 5
            cChave:= cPer+cCC
        Case nS119 == 6
            cChave:= cPer
        Case nS119 == 7
              cChave:= cCC
        Case nS119 == 8
            cChave:= ""
    End Case
Else
    Do Case
        Case nS119 == 1
            cChave:= cFil+cPer
        Case nS119 == 2
            cChave:= cFil
        Case nS119 == 3
            cChave:= cPer
        Case nS119 == 4
            cChave:= ""
    End Case
Endif
Return AllTrim(cChave)
//-------------------------------------------------------------------
/*/{Protheus.doc} fInt005Vl
Função responsável por realizar as validações devidas pra envio de dados para o TAF.
@param oModel - Modelo ativo
@param cModelId - Id do Modelo
@return lRet, boolean, Bloqueia ou não a gravação
@obs Responsável por realizar os devidos tratamentos e envio para o TAF
@sample
@author Eduardo Vicente
@since 20/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function fInt005Vl(oModel, cModelId, lCNAE, lFPAS, lRot941B, nOperMdl)
Local lRet		:= .T.
Local lS1005	:= .T.
Local cMsgRet	:= ""
Local nOper		:= oModel:GetOperation()
Local cAnoMes 	:= AnoMes(dDataBase)
Local cIniVld 	:= SubStr(cAnoMes, 5, 2) + SubStr(cAnoMes, 1, 4)
Local aTabsTAF	:= {"C92", "C1E", "CR9"}
Local aTabsMID	:= {"RJ9"}
Local nCont		:= 0
Local cBkpEmp	:= ""
Local cBkpFil	:= ""
Local cTpInsc	:= ""
Local cChave	:= ""
Local cStat1005	:= ""
Local cStatRJE	

Default lRot941B:= .F.
Default nOperMdl:= 0

If lRot941B
	nOper := nOperMdl
EndIf

If nOper == 4 .And. (oModel:GetModel("SIGAMAT_SM0") != Nil .Or. lRot941B)
	If SM0->M0_CODIGO != cEmpAnt .Or. SM0->M0_CODFIL != cFilAnt
		cBkpEmp := cEmpAnt
		cBkpFil := cFilAnt
		If lMiddleware
			ChangeNew(aTabsMID, SM0->M0_CODIGO, SM0->M0_CODFIL, .T.)
		Else
			ChangeNew(aTabsTAF, SM0->M0_CODIGO, SM0->M0_CODFIL, .T.)
		EndIf
		cEmpAnt := SM0->M0_CODIGO
		cFilAnt := SM0->M0_CODFIL
	EndIf

	If lMiddleware

		lVld1000 := fVld1000( AnoMes(dDataBase), @cStatRJE )

		If lVld1000

			cTpInsc	:= If( AllTrim(cValToChar(SM0->M0_TPINSC)) $ "2/3", "1", "4" )
			If lMiddleware
				cChave:= cTpInsc + PADR( If( SM0->M0_TPINSC == 2 .Or. SM0->M0_TPINSC == 3, SubStr(SM0->M0_CGC, 1, 8),SM0->M0_CEI), 14 ) + "S1005" + Padr(cFilAnt + SM0->M0_CGC, fTamRJEKey(), " ") + AnoMes(dDataBase)
				cStat1005 := "-1"
				GetInfRJE( 2,cChave,@cStat1005)
				If cStat1005 == "-1"
					lS1005 := .F.
				ElseIf cStat1005 == "2"
				 	cMsg := ""
				 	cMsg += OemtoAnsi(STR0259)
					Help("",1,"HELP",,cMsg,1,0)
					lRet := .F.
					Return lRet
				EndIf
			EndIf
			If !(iif(lMiddleware, lS1005, TAFGetStat( "S-1005", cTpInsc + ";" + If( SM0->M0_TPINSC == 2 .Or. SM0->M0_TPINSC == 3, SM0->M0_CGC, SM0->M0_CEI ) + ";" + cIniVld, SM0->M0_CODIGO, SM0->M0_CODFIL ) $ "-1/7"))
				if lRot941B .Or. oModel:GetValue("SIGAMAT_SM0","M0_TPINSC") == SM0->M0_TPINSC
					if SM0->M0_TPINSC==1
						if !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_CEI") !=  SM0->M0_CEI
							lRet:= .F.
							cMsgRet+= "CEI"
						EndIf
					Else
						if !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_CGC") != SM0->M0_CGC
							lRet:= .F.
							cMsgRet+= "CNPJ\CPF"
						EndIf
					EndIf
				Else
					cMsgRet+= "Tipo de Inscrição"
					lRet:= .F.
				EndIf
			EndIf
			If !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_CNAE") != SM0->M0_CNAE
				lCNAE := .T.
			Else
				lCNAE := .F.
			Endif

			If !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_FPAS") != SM0->M0_FPAS
				lFPAS := .T.
			Else
				lFPAS := .F.
			Endif
			If !EMPTY(cBkpEmp) .AND. SM0->M0_CODIGO != cBkpEmp
				For nCont := 1 To Len(aTabsTAF)
					(aTabsTAF[nCont])->( dbCloseArea() )
				Next nCont
				cEmpAnt := cBkpEmp
				cFilAnt := cBkpFil
				fOpenSx2(cEmpAnt)
				FWClearXFilialCache()
			EndIf
		Else
			cMsg := ""
			do Case
				case cStatRJE == "-1" // nao encontrado na base de dados
					cMsg += OemtoAnsi(STR0252) //"Registro do evento S-1000 não localizado na base de dados"
				case cStatRJE == "1" // nao enviado para o governo
					cMsg += OemtoAnsi(STR0253) //"Registro do evento S-1000 não transmitido para o governo"
				case cStatRJE == "2" // enviado e aguardando retorno do governo
					cMsg += OemtoAnsi(STR0254) //"Registro do evento S-1000 aguardando retorno do governo"
				case cStatRJE == "3" // enviado e retornado com erro
					cMsg += OemtoAnsi(STR0255) //"Registro do evento S-1000 retornado com erro do governo"
			endcase
			Help("",1,"Problema com o Evento S-1000",,cMsg,1,0)
			lRet := .F.
			Return lRet
		Endif
	Else
	 	If nOper == 4 .And. (oModel:GetModel("SIGAMAT_SM0") != Nil .Or. lRot941B)
			If SM0->M0_CODIGO != cEmpAnt
				cBkpEmp := cEmpAnt
				cBkpFil := cFilAnt
				ChangeNew(aTabsTAF, SM0->M0_CODIGO, SM0->M0_CODFIL, .T.)
				cEmpAnt := SM0->M0_CODIGO
				cFilAnt := SM0->M0_CODFIL
			EndIf
			cTpInsc	:= If( AllTrim(cValToChar(SM0->M0_TPINSC)) $ "2/3", "1", "4" )
			If !(TAFGetStat( "S-1005", cTpInsc + ";" + If( SM0->M0_TPINSC == 2 .Or. SM0->M0_TPINSC == 3, SM0->M0_CGC, SM0->M0_CEI ) + ";" + cIniVld, SM0->M0_CODIGO, SM0->M0_CODFIL ) $ "-1/7")
				if lRot941B .Or. oModel:GetValue("SIGAMAT_SM0","M0_TPINSC") == SM0->M0_TPINSC
					if SM0->M0_TPINSC==1
						if !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_CEI") !=  SM0->M0_CEI
							lRet:= .F.
							cMsgRet+= "CEI"
						EndIf
					Else
						if !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_CGC") != SM0->M0_CGC
							lRet:= .F.
							cMsgRet+= "CNPJ\CPF"
						EndIf
					EndIf
				Else
					cMsgRet+= "Tipo de Inscrição"
					lRet:= .F.
				EndIf
			EndIf
			If !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_CNAE") != SM0->M0_CNAE
				lCNAE := .T.
			Else
				lCNAE := .F.
			Endif

			If !lRot941B .And. oModel:GetValue("SIGAMAT_SM0","M0_FPAS") != SM0->M0_FPAS
				lFPAS := .T.
			Else
				lFPAS := .F.
			Endif
			If !EMPTY(cBkpEmp) .AND. SM0->M0_CODIGO != cBkpEmp
				For nCont := 1 To Len(aTabsTAF)
					(aTabsTAF[nCont])->( dbCloseArea() )
				Next nCont
				cEmpAnt := cBkpEmp
				cFilAnt := cBkpFil
				fOpenSx2(cEmpAnt)
				FWClearXFilialCache()
			EndIf
		EndIf
	EndIf
EndIf

If !lRet .And. !Empty(cMsgRet)
	cMsgRet:= iif(lMiddleware,OemToAnsi(STR0256),OemToAnsi(STR0173))+ CRLF + cMsgRet
	Help( ,, 'HELP','HELP',OemToAnsi(cMsgRet) , 1, 0 )	//O Processo não pode ser concluido, pois os campos abaixo fazem parte do indice de busca no TAF:
EndIf

Return lRet

Function VldEntEdu()
Local lRet:= .T.

if __READVAR == "M->TPAPD"
	If aCols[n][9] $ "1$2" .And. Empty(M->TPAPD)
		lRet:= .F.
	EndIf
EndIF
Return lRet

/*/{Protheus.doc} fCatTrabEFD
Função responsável por retornar quais são os tipos de trabalhadores em cada categoria do eSocial
@param cTipoCateg , caracter, Recebe o tipo de trabalhador desejado
@return cGrupoCateg, caractere, Opções válidas para a categoria
@sample fCatTrabEFD( "TSV" ) ou fCatTrabEFD( "TCV" )
@author Marcos Coutinho Araujo
@since 05/12/2017
@version P11 ou P12
/*/
Function fCatTrabEFD(cTipoCateg)
Local		cTCV := "101|102|103|104|105|106|107|108|111|"
Local		cAVU := "201|202|"
Local	 cAGETCV := "301|302|303|306|307|309|"
Local	 cAGETSV := "304|305|308|"
Local		cCES := "401|410|"
Local	cDirSind := "501|"
Local		cTSV := "701|711|712|712|721|722|723|731|734|738|741|751|761|771|781|"
Local		cBOL := "901|902|903|904|905|906|"
Local 	cGrupoCateg := ""
Default 	cTipoCateg := ""

//-----------------------------------------------
//| Separado todos os grupos por categoria
//| Concatendo os grupos de acordo com TSV e TCV
//-----------------------------------------------
If cTipoCateg == "TCV"
	cGrupoCateg := cTCV + cAGETCV

ElseIf cTipoCateg == "TSV"
	cGrupoCateg := cAVU + cCES + cTSV + cBOL + cAGETSV + cDirSind

ElseIf cTipoCateg == "AVU"
	cGrupoCateg := cAVU

ElseIf cTipoCateg == "AGE"
	cGrupoCateg := cAGETCV + cAGETSV

ElseIf cTipoCateg == "CES"
	cGrupoCateg := cCES

ElseIf cTipoCateg == "BOL"
	cGrupoCateg := cBOL

EndIf
Return cGrupoCateg

/*/{Protheus.doc} fGp17SRVEs
Funcção de Validação de verbas
@type function
@author Eduardo
@since 27/12/2017
@version 1.0
@param aIncons, Array, Array com as inconsistências vindas da rotina acionadora
@param cAlsSrv, $lias, Alias com os dados do registro posicionado
@param cIncons, String, String que será concatenada os textos de inconsistências
@return lRet, Retorno se localizou ou não inconsistencia no cadastro de verbas.
/*/
Function fGp17SRVEs(aIncons,cAlsSrv,cIncons)
	Local lRet			:= .F.
	Local cFgts,cIncFGT	:= ""
	Local lBase			:= .F.

	Default aIncons		:= {}
	Default cAlsSrv		:= Nil
	Default cIncons		:= ""

	if cAlsSrv == nil
		cFgts		:= M->RV_FGTS
		cIncFGT		:= M->RV_INCFGTS
		lBase		:= M->RV_TIPOCOD $ "3|4"
	Else
		cFgts		:= (cAlsSrv)->RV_FGTS
		cIncFGT		:= (cAlsSrv)->RV_INCFGTS
		lBase		:= (cAlsSrv)->RV_TIPOCOD $ "3|4"
	EndIf

	If !lBase
		//VALIDAÇÃO DO FGTS
		If cFgts == "S" .And. (cIncFGT == '00' .Or. cIncFGT >= '91')
			aAdd(aIncons,{"RV_FGTS",OemToAnsi(StrTran(STR0181,"[X]"," FGTS "))})
			aAdd(aIncons,{"RV_INCFGTS",OemToAnsi(StrTran(STR0181,"[X]"," FGTS "))})
			//"Checar campo(s) de [X], pois estão divergentes a(s) incidência(s), onde pode vir a trazer problemas futuros na integração com o eSocial."
			cIncons+= OemToAnsi(StrTran(STR0181,"[X]"," FGTS,Cd.Inc.FGTS ")) + CRLF
		endif
	Endif

	if !Empty(cIncons)
		lRet:= .T.
	EndIf
Return lRet

/*/{Protheus.doc} fGp17LmtDsc
Função responsável por unificar em uma unica linha o campo + problema e limitar
a quantidade de caracteres por linha
@type static function
@author Marcos Coutinho
@since 05/01/2018
@version 1.0
@param aLogDados -> Passado por referencia @
@param cCampo Nome do campo X3_CAMPO
@param cDescricao Descrição do problema do campo
@return
/*/
Function fGp17LmtDsc(aLogDados, cCampo, cDescricao)
Local nY := 1
Local aMensagem := {}

Default cCampo := ""
Default cDescricao := ""

If SX3->( MsSeek(cCampo) )
	cDescricao := AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC) + " - Mot.: " + cDescricao

	// Limitando a mensagem a 125 caracteres por linha dentro do array
	aMensagem := FWTxt2Array( cDescricao, 125)

	For nY := 1 To len(aMensagem)
		If nY == 1
			aAdd(aLogDados, "Mot.: " + aMensagem[nY] )
		Else
			aAdd(aLogDados, aMensagem[nY])
		EndIf
	Next
EndIf

Return


/*/{Protheus.doc} VldRotTab
Rotina para montagem de informações referente a checagem do modo de acesso
das tabelas do taf comparar as tabelas do GPE
@type function
@author Eduardo
@since 02/01/2018
@version 1.0
@param aOpcoes, array, (Descrição do parâmetro)
@param aDados, array, (Descrição do parâmetro)
@param aEvent, array, (Descrição do parâmetro)
@return $lRet, Valor lógico para checagem do se bloqueia ou não a continuidade da carga inicial
/*/Function VldRotTab(aOpcoes,aDados,aEvent)
Local nX			:= 0
Local cTbGpe,cTbTaf	:= ""
Local aEvtTafRt		:= {}
Local lRet			:= .T.
Local lNovoCTT		:= .F.	//identifica que está utilizando o novo controle de obras/lotações para o e-Social
Local lParcial 		:= .F.	//Verifica se a base está parcialmente utilizando o novo controle de obras/lotações para o e-Social
Local lRJs			:= .F.

default aOpcoes		:= {}
default aEvent		:= {}

If len(aEvent)==0

	//Chama a função verificadora do novo controle de obras/lotações para o e-Social
	If lNovoCTT:= fVldObraRJ(@lParcial, .F.)
		If !lParcial
			lRJs := .T.
		Endif
	Else
		If "GPEA934" $ FunName()
			lRJs := .T.
		Endif
	Endif

				//EVENTO 	,TABELA					,MODOACCESS	,TAMFILIAL								,FILBKP	,FILHIBR
	aEvent	:= {{"S-1005"	,If(lRJs,"RJ4","CTT")	,""			,LEN(FWxFilial(If(lRJs,"RJ4","CTT")))	,{}		,.F.},;
				{"S-1010"	,"SRV"					,""			,LEN(FWxFilial("SRV"))					,{}		,.F.},;
				{"S-1020"	,If(lRJs,"RJ3","CTT")	,""			,LEN(FWxFilial(If(lRJs,"RJ3","CTT")))	,{}		,.F.},;
				{"S-1030"	,"SRJ"					,""			,LEN(FWxFilial("SRJ"))					,{}		,.F.},;
				{"S-1050"	,"SR6"					,""			,LEN(FWxFilial("SR6"))					,{}		,.F.},;
				{"S-2200"	,""						,""			,0					 					,{}		,.F.},;
				{"S-2100"	,""						,""			,0					 					,{}		,.F.},;
				{"S-2300"	,""						,""			,0					 					,{}		,.F.},;
				{"S-1035"	,""						,""			,0					 					,{}		,.F.},;
				{"S-1040"	,""						,""			,0					 					,{}		,.F.}}
EndIf

If lCargSQ3
	aEvent[4,2] := "SQ3"
	aEvent[4,4] := LEN(FWxFilial("SQ3"))
Endif

for nX:= 1 to len(aOpcoes)
	if nX <= 5 .And. aOpcoes[nX]
		//ARRAY DO TAF COM OS DADOS DE TABELA/ROTINA/INDICE USADOS NO TAF
		aEvtTafRt:= TAFRotinas(aEvent[nX][1],4,.F.,2)

		//CHECAGEM DO MODO DE ACESSO DAS TABELAS
		cTbGpe := FWModeAccess( aEvent[nX][2], 1) + FWModeAccess( aEvent[nX][2], 2) + FWModeAccess( aEvent[nX][2], 3)
		cTbTaf := FWModeAccess( aEvtTafRt[3], 1) + FWModeAccess( aEvtTafRt[3], 2) + FWModeAccess( aEvtTafRt[3], 3)

		//DADOS DO ACESSO DA TABELA COMPLETO, SERÁ UTILIZADO NA FUNÇÃO DE CARGA INICIAL
		aEvent[nX][3]:= UPPER(cTbGpe)

		//IDENTIFICANDO SE TABELAS ESTÃO CONFIGURADAS DE FORMA ERRADA
		If aEvent[nX][2] == 'SR6'
			If cTbGpe <> cTbTaf .OR. (FWModeAccess('SPJ',1) + FWModeAccess('SPJ',2) + FWModeAccess('SPJ',3)) <> cTbTaf
				aAdd( aDados,StrTran(StrTran(STR0182,"[X]",aEvent[nX][2]+'/SPJ'),"[Y]",aEvtTafRt[3]))
				lRet:=.F.
			Endif
		Elseif cTbGpe <> cTbTaf
		//"O compartilhamento da tabela ([X]) e ([Y]) estão divergentes, altere o modo de acesso atraves do Configurador. Arquivos ([X]) e ([Y])."
			aAdd( aDados,StrTran(StrTran(STR0182,"[X]",aEvent[nX][2]),"[Y]",aEvtTafRt[3]))
			lRet:=.F.
		endIf

	endIf
next
Return lRet

/*/{Protheus.doc} fVerExtemp
Função responsável por verificar o STATUS do evento a ser gerado extemporâneo na base do TAF
@type function
@author marcos.coutinho
@since 11/01/2018
@version 1.0
@param cEvento	(C) - Recebe o evento desejado
@param cChave	(C) - Recebe a chave para pesquisar no TAF
@param nOpc		(N) - Recebe a operação que esta sendo executado
@param cStatus	(C) - *Referência* Devolve valor do STATUS do registro no TAF
@param lContinua(L) - *Referência* Devolve valor do STATUS do registro no TAF
@param cFilEnv	(C) - Filial que se deseja verificar no TAF
@param aErros	(A) - *Referência* Devolve um array de resposta
@return nOpcao	(N) - Retorna valor numérico que decidirá qual evento gera (Inc/Alt/Del)
/*/
Function fVerExtemp( cEvento, cChave, nOpc, cStatus, lContinua, cFilEnv, aErros )
Local nOpcao := 0
Local cFilBKP := ""

Default cFilEnv := cFilAnt
Default lContinua := .T.
Default aErros := {}
/*
 ---------------------------------------------------------------------------------------------------
| Evento | Tab/Ind | Chave enviada RH                   | Chave processada no TAFGetStat            |
 ---------------------------------------------------------------------------------------------------
| S-1005 | C92 / 7 | CTT_TIPO2 + CTT_CEI2 + Data(MMAAAA)| C92 - >TPINSC + NRINSC +  DTINI + ATIVO   |
| S-1010 | C8R / 9 | CodRub + cIdTbRub + Data (MMAAAA)  | C8R -> FIL+ CODRUB+ IDTBRB+ DTINI + ATIVO |
| S-1020 | C99 / 5 | CTT_CUSTO + Data (MMAAAA)          |                                           |
| S-1030 | C8V / 6 | RJ_FUNCAO + Data (MMAAAA)          | C8V -> FILIAL + CODIGO + DTINI + ATIVO    |
| S-1035 | T5K / 6 | GY_CODIGO + Data (MMAAAA)          | T5K -> FILIAL + CODIGO + DTINI + ATIVO    |
| S-1040 | C8X / 5 | RJ_FUNCAO + Data (MMAAAA)          | C8X -> FILIAL + CODIGO + DTINI + ATIVO    |
| S-1050 | C90 / 5 | R6_FIL+R6_TRN+PA_CDG+PJ_SMN+cDia   | C90 -> FILIAL + CODIGO + DTINI + ATIVO    |
| S-1060 | NP      | Este evento não será processado pela rotina de carga inicial por enquanto      |
| S-1070 | NP      | Este evento não será processado pela rotina de carga inicial por enquanto      |
| S-1080 | NP      | Este evento não será processado pela rotina de carga inicial por enquanto      |
 ---------------------------------------------------------------------------------------------------
*/

//Retornando o STATUS do evento no TAF
cFilBKP := cFilAnt
cFilAnt := cFilEnv

cStatus := TAFGetStat( cEvento, cChave, cEmpAnt, cFilEnv)
cFilAnt := cFilBKP

If cStatus <> "-1" .And. nOpc <> 5 .And. (funname() <> 'GPEA934')  // Se foi encontrado no TAF e não for exclusão, será uma alteração
	nOpc := 4
EndIf

//----------------------------------------------------------
//| Se for uma inclusão, o evento sempre será de <inclusao>
//----------------------------------------------------------
If ( nOpc == 3 )
	nOpcao := 3

//-----------------------------------------------------
//| Se for uma alteracao, o evento será de <alteracao>
//-----------------------------------------------------
ElseIf ( nOpc == 4 )
	//-------------------------------------------------------------------------------------------------
	//| -1 | Não existe | Se por alguma motivo, não existir o evento no TAF, insere um novo <inclusao>
	//-------------------------------------------------------------------------------------------------
	If ( cStatus == "-1" )
		nOpcao := 3

	//------------------------------------------------------------------------------------
	//|  2 | Em Transito | Se o evento estiver em transito, bloqueia e espera o resultado
	//------------------------------------------------------------------------------------
	ElseIf ( cStatus $ "2" )
		If(!FunName() $ "GPEA320|GPEM023")
			//"Registro sendo enviado ao RET"##"O registro está em trânsito para o RET. Esta alteração não poderá ser realizada enquanto o envio não for concluído"
			Help( ,, OemtoAnsi(STR0045),,OemtoAnsi(STR0192)+ CRLF + OemtoAnsi(STR0191), 1, 0 )
		Else
			aAdd(aErros, OemtoAnsi(STR0191) )
		EndIf
		nOpcao := 0
		lContinua := .F.
	//-------------------------------------------------------------------------------
	//| 0134 | Se o evento ainda não estiver integrado com o TAF, insere <alteracao>
	//-------------------------------------------------------------------------------
	ElseIf ( cStatus $ " |0|1|3|4" )
		//Só realizará uma nova integração, caso haja alteração de campos importantes
		If Funname() == "CTBA030" .And. cEvento $ "S-1020|S-1005"
			If fAltCadCTT(cEvento, cStatus)
				nOpcao := 4
			Endif
		Else
			nOpcao := 4
		Endif
	EndIf

//----------------------------------------------------------
//| Se for uma exclusão, o evento sempre será de <exclusao>
//----------------------------------------------------------
ElseIf ( nOpc == 5 )
	//----------------------------------------
	//| Se o evento nem existir, não faz nada
	//----------------------------------------
	If ( cStatus $ "-1" )
		nOpcao := 0

	//-----------------------------------------------------------------
	//| Se o evento estiver em transito, bloqueia e espera o resultado
	//-----------------------------------------------------------------
	ElseIf ( cStatus $ "2" )
		If(!FunName() $ "GPEA320|GPEM023")
			//"Registro sendo enviado ao RET"##"O registro está em trânsito para o RET. Esta alteração não poderá ser realizada enquanto o envio não for concluído"
			Help( ,, OemtoAnsi(STR0045),,OemtoAnsi(STR0192)+ CRLF + OemtoAnsi(STR0191), 1, 0 )
		Else
			aAdd(aErros, OemtoAnsi(STR0191) )
		EndIf
		//"Registro sendo enviado ao RET"##"O registro está em trânsito para o RET. Esta alteração não poderá ser realizada enquanto o envio não for concluído"
		nOpcao := 0
		lContinua := .F.
	//-----------------------------------------------------------------------
	//| Se o evento ainda não estiver integrado com o TAF, insere <exclusao>
	//-----------------------------------------------------------------------
	ElseIf ( cStatus $ " |0|1|3|4" )
		nOpcao := 5
	EndIf
EndIf
Return nOpcao

/*/{Protheus.doc} fAltCadCTT
Verificar se a alteração realizada no cadastro de centro de custo
será considerada para o eSocial
@type function
@author Claudinei Soares
@since 15/01/2018
@version 1.0
@param cEvento	, Caracter	, Código do evento a ser verificado
@return lRet	, Lógico	, Retorno da função, se verdadeiro houve alteração
/*/
Function fAltCadCTT(cEvento, cStatus)

Local aArea 	:= GetArea()
Local lRet 		:= .F.
Local nI		:= 0
Local aCpos1020	:= {"CTT_FPAS","CTT_CODTER","CTT_TPINCT","CTT_NRINCT","CTT_TPINPR","CTT_NRINPR","CTT_TPLOT","CTT_TIPO2","CTT_CEI2"}
Local aCpos1005	:= {"CTT_FAP","CTT_PERRAT", "CTT_PERCAC","CTT_CNAE","CTT_TPLOT"}

Default cEvento := ""
Default cStatus := ""

If cPaisLoc == "BRA"

	If cEvento == "S-1020"
		For nI := 1 To Len(aCpos1020)
			If &('CTT->' + aCpos1020[nI])  <> GETMEMVAR(aCpos1020[nI])
				lRet := .T.
			Endif
		Next nI
	ElseIf cEvento == "S-1005" .Or. cEvento == "S1005"
		For nI := 1 To Len(aCpos1005)
			If &('CTT->' + aCpos1005[nI])  <> GETMEMVAR(aCpos1005[nI])
				lRet := .T.
			Endif
		Next nI
	Endif
EndIf

RestArea(aArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb030eSoc ³ Autor ³ Microsiga³ Data ³ 17/03/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza a validação dos campos envolvidos no E-Social       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb030eSc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Validação dos campos CTT envolvidos no E-Social            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb030eSoc(nOpc, lRotProc, cMsgRotPrc, oMdl941C, oMdl941B)

Local cValTp		:= if (SuperGetMv("MV_RHTAF",, .F.) .Or. lMiddleware, M->CTT_TPLOT, "")
Local cEFDAviso		:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
Local lSemFilial	:= .F.
Local lContinua		:= .T.
Local lMsgTAF		:= .F.
Local cCEI2			:= "CTT_CEI2"
Local cCodLot		:= ""
Local cMesAnoP		:= ""
Local cAnoMesP		:= ""
Local cLotInsc		:= "02|03|04|05|06|07|08|09"
Local cFPAS
Local nTerc
Local aInfoFil    	:= {}
Local aX14			:= {}
Local aFilInTaf		:= {}
Local aArrayFil		:= {}
Local cFilEnv		:= ""
Local aIncons		:= {}
Local aErros		:= {}
Local lRet			:= .T. //Se não tiver eSocial, passa como .T. e ja grava CTT
Local cMes			:= StrZero( Month( dDataBase ), 2 )
Local cAno			:= Alltrim( Str( Year( dDataBase ) ) )
Local cTpLot
Local cTp2
Local cInsEsoc
Local cTpInsCo
Local cNrInsCo
Local cTpInsPr
Local cNrInsPr
Local aArrAux		:= {}
Local aArrCpos		:= {}
Local lIntegra		:= .T.
Local nX			:= 1
Local cMsg			:= ""
Local cChaveTAF
Local cStatus		:= "-1"
Local nOpcao
Local aLogProc		:= {}
Local aDados		:= {}
Local dDataRef		:= SToD("  /  /    ")
Local cCnae			:= ""
Local cSubPat		:= ""
Local nPos
Local cTpReg
Local cTpApr
Local cNrApr
Local cTpEEn
Local aTabS119		:= {}
Local aTabS120		:= {}
Local aEstObras		:= {}
Local aEstEd		:= {}
Local z1			:= 0
Local lIntegEAI		:=	FWHasEai('CTBA030',,.T.,.T.)
Local lParcial 		:= .F.
Local lAuto 		:= IsInCallStack('MSEXECAUTO')
Local lCopiaTab     := ChkFile("RJ7") .And. ChkFile("RJ8")
Local aInfoC        := {}
Local aSM0    		:= FWLoadSM0(.T.,,.T.)
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local cNrInsc       := ""
Local nFilEmp       := 0
Local cFilEmp       := ""
Local cStat1005		:= ""
Local cMsgDesatu    := ""
Local cTpProc		:= ""
Local cNrProc		:= ""
Local cCSusp		:= ""
Local cTp			:= ""
Local lTemRJL		:= ChkFile("RJL")

Local cBkpFil	  	:= cFilAnt
Local cXml		 	:= ""
Local cMsgErro	 	:= ""
Local cVersMid	 	:= ""
Local cChave	 	:= ""
Local cMsgRJE	 	:= ""
Local aInfos	 	:= {}
Local dDtGer	 	:= Date()
Local cHrGer	 	:= Time()
Local cRetfNew	 	:= ""
Local cRetfRJE	 	:= ""
Local cRetKey	 	:= ""
Local cOperNew 	 	:= ""
Local cOperOld		:= "I"
Local cOperRJE	 	:= "I"
Local cRetfOld		:= "1"
Local cStatNew	 	:= ""
Local cStatOld		:= "-1"
Local lNovoRJE	 	:= .F.
Local nOpcao1020 	:= 3
Local nRecOld		:= 0
Local nRecRJE  	 	:= 0
Local lS1000 	 	:= .F.
Local nOpcAx	 	:= nOpc
Local cTpAmb		:= ""
Local cCNPJR		:= ""

Default nOpc		:= 0
Default lRotProc	:= .F.
Default cMsgRotPrc	:= ""
Default oMdl941C	:= Nil
Default oMdl941B	:= Nil

If nOpc == 5 .And. IsInCallStack('Ct030TudOk') //Foi incluída chamada ao TudOk da rotina na exclusão, evitar duplicidade
	Return lRet
EndIf

If lMiddleware .and. !ChkFile("RJE") .And. !ChkFile("RJ9")
	cMsgDesatu := CRLF + OemToAnsi(STR0258) + CRLF
	If !lRotProc
		MSGINFO(cMsgDesatu,STR0228)
	Else
		cMsgRotPrc := cMsgDesatu
	EndIf
	lRet := .F.
	Return lRet
Endif

//Verifica se está utilizando as novas tabelas para geração dos eventos S-1005 e S-1020, se sim não será enviado ao TAF.
If !fVldObraRJ(@lParcial, .T.) .And. !lParcial
	//-----------------------------------------------------------
	//| Verifica a existência do Campo importante para o eSocial
	//-----------------------------------------------------------
	If lMiddleware .Or. ( IIF(FindFunction("fChkFMat"),lRet:=fChkFMat("S-1020"),.F.))
		If M->CTT_TIPO $ '12' .AND. (Empty(M->CTT_CEI) .Or. M->CTT_CEI =='00000000000000')
			if !lAuto
				If !lRotProc
					MsgInfo(STR0237,STR0045) //STR0237 "O campo 'CNPJ/CEI Tomad' não poderá ficar vazio ou inválido, caso o campo 'T.Insc.Tomad' esteja preenchido" //STR0045 'Atenção!'
				Else
					cMsgRotPrc := STR0237
				EndIf
			else
				Conout(STR0045 + " - " + STR0237)
			endif
			Return .F.
		ENDIF
		If CTT->(ColumnPos("CTT_TPLOT")) > 0
			If nOpc == 5 .And. !Empty(M->CTT_TPLOT) .And. !lMiddleware	// Não enviar evento de exclusão
				If !IsBlind() .And. !MsgYesNo(STR0413 + CRLF + STR0410, STR0045)
				//"Caso existam eventos no TAF / RET relacionados a esta tabela, é necessário realizar a exclusão a partir do SIGATAF, certificando-se que não existem outros eventos relacionados ao mesmo. Caso prossiga, o registro será excluído apenas do GPE. Deseja continuar?"
					lRet := .F.
				EndIf

			Else
				//Se o Tipo de Lotação for 01
				If  M->CTT_TPLOT == "01"
					If ( M->CTT_TIPO2 == "4" )
						If Empty(M->CTT_CEI2)
							//"Caso o campo 'Tipo eSocial' esteja preenchido, o campo 'Insc eSocial' é de preenchimento obrigatório."
							cMsg += OemToAnsi(STR0190) + CRLF
							lRet := .F.
						ElseIf nOpc <> 3 .And. !Empty(CTT->CTT_CEI2) .And. CTT->CTT_CEI2 <> GETMEMVAR(cCEI2)
							Help( ,, 'HELP',,OemToAnsi(STR0193) , 1, 0 )	//"Não pode ser alterado o CNO, pois este campo é a chave do registro S-1005."
							lRet := .F.
						Endif
					Endif
				EndIf
				//Se o Tipo de Lotação for 02
				If  M->CTT_TPLOT == "02"
					if Empty(M->CTT_ICTPAT)
						//"O campo 'Ind. Cont. Pat' é de preenchimento obrigatório quando o Tipo de Lotação for igual a '02'."
						cMsg += OemToAnsi(STR0185) + CRLF
						lRet:= .F.
					EndIf
					If Empty(M->CTT_TPINCT) .Or. Empty(M->CTT_NRINCT) .Or. Empty(M->CTT_TPINPR) .Or. Empty(M->CTT_NRINPR)
						//"Os campos 'T. InsContrat', 'N.InsContrat', 'T.InsProprie' e 'N. InsProprie' são de preenchimento obrigatório quando o Tipo de Lotação for igual a '02'."
						cMsg += OemToAnsi(STR0186) + CRLF
						lRet:= .F.
					EndIf
				EndIf
				If ( M->CTT_TPLOT == "01" .and. M->CTT_TIPO2 == "4" .and. !Empty(M->CTT_CEI2) )
					aArrCpos:= {'CTT_CODTER','CTT_FPAS','CTT_TPLOT','CTT_TIPO2','CTT_CEI2','CTT_TPINCT','CTT_NRINCT','CTT_TPINPR','CTT_NRINPR','CTT_PERRAT','CTT_FAP','CTT_PERCAC','CTT_CUSTO'}
				Else
					aArrCpos:= {'CTT_CODTER','CTT_FPAS','CTT_TPLOT','CTT_TIPO2','CTT_CEI2','CTT_TPINCT','CTT_NRINCT','CTT_TPINPR','CTT_NRINPR'}
				Endif
				lIntegra:= INCLUI .Or. fAltVer(aArrCpos,"CTT") .Or. lRotProc
				//Se a validação inicial estiver Tudo OK
				If lRet .And. lIntegra
					cTpLot		:= M->CTT_TPLOT 		//Tipo Lotacao
					cTp2		:= M->CTT_TIPO2		//Tipo de Cadastro eSocial
					cInsEsoc	:= M->CTT_CEI2 		//Tipo Inscricao eSocial
					cTpInsCo	:= M->CTT_TPINCT	//Tipo Inscrição Contratante
					cNrInsCo	:= M->CTT_NRINCT	//Nro Inscricao Contratante
					cTpInsPr	:= M->CTT_TPINPR	//Tipo Inscricao Proprietario
					cNrInsPr	:= M->CTT_NRINPR	//Nro Inscricao Proprietario
					IF !Empty( M->CTT_TPLOT )
						//Tratamento de compartilhamento da tabela CTT
						lRet:= .T.
						If ( M->CTT_TPLOT $ "03|04|05|06|07|08|09" )
							If Empty(M->CTT_CUSTO) .OR. Empty(M->CTT_TIPO2) .OR. Empty(M->CTT_CEI2)
								aArrAux := {"CTT_CUSTO", "CTT_TIPO", "CTT_CEI2" }
								For nX := 1 To Len( aArrAux )
									If EMPTY( &("M->" + aArrAux[nX]) )
										//A partir da nova LIB deveremos substituir pela função FWSX3Util()
										SX3->(DBSETORDER(2))
										IF SX3->( DBSeek( aArrAux[nX] ) )
											cMsg += X3Titulo( aArrAux[nX] ) + CRLF
										ENDIF
									EndIf
								Next

								if !lAuto
									If !lRotProc
										Aviso(OemtoAnsi(STR0045), OemToAnsi(STR0194) + CRLF + CRLF + cMsg,{"Ok"},3) //"Atenção"##"Existem campos necessários ao eSocial em branco"##Campos##Ok
									Else
										cMsgRotPrc := STR0194//"Existem campos necessários ao eSocial em branco"
									EndIf
								else
									conout(OemtoAnsi(STR0045) + " - " + OemToAnsi(STR0194) + CRLF + CRLF + cMsg)
								endif
								lRet:= .F.
								cMsg := ""
							Endif

						ElseIf M->CTT_TPLOT == "02"
							IF Empty(M->CTT_CUSTO) .OR. Empty(M->CTT_TIPO2)	.OR. Empty(M->CTT_CEI2) .OR. Empty(M->CTT_TPINCT) .OR. Empty(M->CTT_NRINCT) .OR. Empty(M->CTT_TPINPR) .OR. Empty(M->CTT_NRINPR)
								aArrAux := { "CTT_CUSTO", "CTT_TIPO2", "CTT_CEI2", "CTT_TPINCT", "CTT_NRINCT", "CTT_TPINPR", "CTT_NRINPR"}

								For nX := 1 To Len( aArrAux )
									If EMPTY( &("M->" + aArrAux[nX]) )
										SX3->(DBSETORDER(2))
										IF SX3->(DBSeek( aArrAux[nX] ))
											cMsg += X3Titulo( aArrAux[nX] ) + CRLF
										ENDIF
									EndIf
								Next

								if !lAuto
									If !lRotProc
										Aviso(OemtoAnsi(STR0045), OemToAnsi(STR0194) + ": " + CRLF + CRLF + cMsg,{"Ok"},3) //"Atenção"##"Existem campos necessários ao eSocial em branco"##Campos##Ok
									Else
										cMsgRotPrc := STR0194//"Existem campos necessários ao eSocial em branco"
									EndIf
								else
									conout(OemtoAnsi(STR0045) + " - " + OemToAnsi(STR0194) + CRLF + CRLF + cMsg)
								endif
								lRet:= .F.
								cMsg := ""
							ENDIF
						ENDIF

						//Tratamento de compartilhamento da tabela CTT
						If FWModeAccess("CTT", 1) == "C" .AND. FWModeAccess("CTT", 2) == "C" .AND. FWModeAccess("CTT", 3) == "C" //CTT compartilhada
							lSemFilial := .T.
						EndIf
						//-------------------------------------------------------------
						//| Se não encontrar nenhuma inconsistencia na validacao acima
						//-------------------------------------------------------------
						If lRet
							If !lMiddleware
								fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
							EndIf
							cMesAnoP	:= cMes + cAno
							cAnoMesP	:= cAno + cMes

							If Empty(cFilEnv)
								cFilEnv := cFilAnt
							EndIf
							If lMiddleware
								fPosFil( cEmpAnt, cFilAnt )
							EndIf
							fInfo(aInfoFil, cFilEnv, cEmpAnt)

							fInssEmp(cFilEnv,@aX14,.F.,cAnoMesP)

							cFPAS	:= M->CTT_FPAS
							nTerc	:= M->CTT_CODTER

							If M->CTT_TPLOT $ "01|10|21|24|90"
								If Empty(cFPAS)
									cFPAS := aInfoFil[17]
								EndIf
								If Empty(nTerc)
									nTerc := aX14[25,1]
								EndIf
							Endif

							If lMiddleware
								lS1000 := fVld1000( cAnoMesP, @cStatus )
								/*
									* 1 - Não enviado - Gravar por cima do registro encontrado
									* 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e não continuar com o processo
									* 3 - Retorno com Erro - Gravar por cima do registro encontrado
									* 4 - Retorno com Sucesso -?Efetivar a gravação
								*/
								If !lS1000 .And. cEFDAviso != "2"
									lRet := .F.
									cMsgRJE := STR0251//"Problemas com evento S1020"
									Do Case
										Case cStatus == "-1" // nao encontrado na base de dados
											cMsgRJE := STR0252 //"Registro do evento S-1000 não localizado na base de dados"
										Case cStatus == "1" // nao enviado para o governo
											cMsgRJE := STR0253 //"Registro do evento S-1000 não transmitido para o governo"
										Case cStatus == "2" // enviado e aguardando retorno do governo
											cMsgRJE := STR0254 //"Registro do evento S-1000 aguardando retorno do governo"
										Case cStatus == "3" // enviado e retornado com erro
											cMsgRJE := STR0255 //"Registro do evento S-1000 retornado com erro do governo"
									Endcase

									// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
									If cEFDAviso == "0"
										Aviso(OemtoAnsi(STR0045),cMsgRJE,{OemtoAnsi("OK")})//"Atenção!"
									ElseIf cEFDAviso == "1"
										Help(" ", 1, OemToAnsi(STR0045),, cMsgRJE, 1, 0)//"Atenção!"
										Return .F.
									EndIf
								EndIf
							EndIf

							//----------------------------------------------------
							//| Realiza a integração do registro / Geração do XML
							//----------------------------------------------------
							cCodLot := IIf(lSemFilial, M->CTT_CUSTO, xFilial("CTT") + M->CTT_CUSTO)

							//------------------------------------------------------------------------------
							//| Realiza a geração do evento S-1005 - Estabelecimento/Obras/Orgãos Públicos
							//------------------------------------------------------------------------------
							If ( cTpLot == "01" .and. M->CTT_TIPO2 == "4" .and. !Empty(M->CTT_CEI2) )
								cChaveTAF	:= cTp2 + ";" + cInsEsoc + ";" + cMesAnoP

								//carrega dados de ponto e contratacao de aprendiz para os tomadores
								fCarrTab( @aTabS119, "S119", dDataRef, .t. )
								//carrega as entidades de ensino dos tomadores
								fCarrTab( @aTabS120, "S120", dDataRef, .t. )

								cCnae := AllTrim( StrTran( StrTran( M->CTT_CNAE, "-","" ), "/","" ) )
								If M->CTT_TIPO2 == "4"
									cSubPat := M->CTT_ICTPAT
								EndIf
								//Procura dados na tabela S119
								cTpReg :=  cTpApr := cNrApr := cTpEEn := ""

								If lSemFilial
									nPos1	:= Ascan(aTabS120,{|x| AllTrim(x[6]) == AllTrim( M->CTT_CUSTO) })
								Else
									nPos1	:= Ascan(aTabS120,{|x| AllTrim(x[2])+ AllTrim(x[6]) == AllTrim( CTT->CTT_FILIAL ) + AllTrim( M->CTT_CUSTO ) })
								EndIf
								If Len(aEstEd) == 0  // so deve carregar uma vez este array
									If nPos1 > 0
										For z1 = 1 To Len(aTabS120)
											If AllTrim(aTabS120[z1,6]) == AllTrim( M->CTT_CUSTO )
												Aadd(aEstEd, {;
													aTabS120[Z1,6],; //Centro de Custo
													aTabS120[z1,7]}) //Inst
											Endif
										Next z1
									Endif
								endif
								//nTpApr := 0
								if lSemFilial
									nPos	:= Ascan(aTabS119,{|x| AllTrim(x[8])== AllTrim( M->CTT_CUSTO ) })
								else
									nPos	:= Ascan(aTabS119,{|x| AllTrim(x[2])+ AllTrim(x[8]) == AllTrim(CTT->CTT_FILIAL) +  AllTrim (M->CTT_CUSTO) })
								endif
								If nPos > 0
									cTpReg := aTabS119[nPos][9]
									cTpApr := aTabS119[nPos][10]
									cNrApr := aTabS119[nPos][11]
									cTpEEn := aTabS119[nPos][12]
									If Len(aTabS119[nPos]) >= 14
										cCNPJR:= aTabS119[nPos][14] // CNPJ Responsavel
									Endif
								Endif

								If oMdl941B != Nil
									If oMdl941B:GetOperation() != MODEL_OPERATION_DELETE
										cTpProc		:= oMdl941B:GetValue('MDLGPEA941B','RJL_TPPROC')
										cNrProc		:= oMdl941B:GetValue('MDLGPEA941B','RJL_NRPROC')
										cCSusp		:= oMdl941B:GetValue('MDLGPEA941B','RJL_CSUSP')
										cTp			:= oMdl941B:GetValue('MDLGPEA941B','RJL_TP')
									EndIf
								Else
									If lTemRJL .And. RJL->( dbSeek( xFilial("RJL", cFilAnt)+xFilial("CTT", cFilAnt)+M->CTT_CUSTO ) )
										While RJL->( !EoF() ) .And. RJL->RJL_FILIAL+RJL->RJL_FIL+RJL->RJL_CC == xFilial("RJL", cFilAnt)+xFilial("CTT", cFilAnt)+M->CTT_CUSTO
											If SubStr(cMesAnoP,3,4)+SubStr(cMesAnoP,1,2) >= RJL->RJL_COMPET
												cTpProc		:= RJL->RJL_TPPROC
												cNrProc		:= RJL->RJL_NRPROC
												cCSusp		:= RJL->RJL_CSUSP
												cTp			:= RJL->RJL_TP
											EndIf
											RJL->( dbSkip() )
										EndDo
									EndIf
								EndIf

								//Adiciona Obras
								Aadd(aEstObras, {	CTT->CTT_FILIAL,;	//01
													M->CTT_TIPO2,;		//02
													M->CTT_CEI2,;		//03
													M->CTT_FPAS,;		//04
													M->CTT_CODTER,;		//05
													cCnae,;				//06
													M->CTT_PERRAT,;		//07
													M->CTT_FAP,;		//08
													M->CTT_PERCAC,;		//09
													M->CTT_CUSTO,;		//10
													cSubPat,;			//11
													cTpReg,;			//12
													cTpApr,;			//13
													cNrApr,;			//14
													cTpEEn,;            //15
													Nil,; 				//16
													Nil,;				//17
													cTpProc,; 			//18
													cNrProc,; 			//19
													cCSusp,; 			//20
													cTp,;				//21
													cCNPJR} ) 			//22

								If lMiddleware
									aInfoC := fXMLInfos()
									IF LEN(aInfoC) >= 4
										cTpInsc  := aInfoC[1]
										lAdmPubl := aInfoC[4]
										cNrInsc  := aInfoC[2]
									ELSE
										cTpInsc  := ""
										lAdmPubl := .F.
										cNrInsc  := "0"
									ENDIF
									If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
										cFilEmp := aSM0[nFilEmp, 2]
									Else
										cFilEmp := cFilAnt
									EndIf
									cChave  := cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14 ) + "S1005" + Padr(xFilial("CTT", cFilEmp) + M->CTT_CEI2, fTamRJEKey(), " ") + AnoMes(dDataBase)
									cStat1005 := "-1"
									GetInfRJE( 2,cChave,@cStat1005)


									If cStat1005 $ "-1|1|3" .And. nOpc <> 5
										nOpcao := 3
									ElseIf cStat1005 == "2"
										nOpcao := 0
									ElseIf cStat1005 == "4" .And. nOpc <> 5
										nOpcao := 4
									Elseif nOpc == 5
										nOpcao := 5
									EndIf

									fVersEsoc("S-1020", .F., /*@aRetGPE*/, /*@aRetTAF*/, ,,@cVersMid,,@cTpAmb)
									// verifica se ja existe o evento s1020 na base de dados
									cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1020" + Padr(cCodLot, fTamRJEKey(), " ") + cAno+cMes
									cStatus := "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE )
									//Alteração ou exclusão
									If nOpcAx == 4 .Or. nOpcAx == 5
										//Retorno pendente impede o cadastro
										If cStatus == "2" .Or. cStatOld == "2"
											cMsgRJE 	:= STR0247//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											lRet		:= .F.
										ElseIf cStatOld == "4" .And. (RJ3->RJ3_INI != M->RJ3_INI .Or. RJ3->RJ3_COD != M->RJ3_COD)
											cMsgRJE 	:= STR0263//"Não é permitido alterar a validade ou o código pois o evento já foi transmitido"
											lRet		:= .F.
										//ALTERACAO
										ElseIf nOpcAx == 4 .AND. cStatus <> "2"
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												lRet		:= .F.
											//Não existe na fila, será tratado como inclusão
											ElseIf cStatus == "-1"
												nOpcao1020	:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											//Evento sem transmissão, irá sobrescrever o registro na fila
											ElseIf cStatus $ "1/3"
												If cOperRJE == "A"
													nOpcao1020 	:= 4
												EndIf
												cOperNew 	:= cOperRJE
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .F.
											//Evento diferente de exclusão transmitido, irá gerar uma retificação
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												nOpcao1020	:= 4
												cOperNew 	:= "A"
												cRetfNew	:= "2"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											//Evento de exclusão transmitido, será tratado como inclusão
											ElseIf cOperRJE == "E" .And. cStatus == "4"
												nOpcao1020	:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
										//Exclusão
										ElseIf nOpcAx == 5
											nOpcao1020 		:= 5
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												lRet		:= .F.
											//Evento diferente de exclusão transmitido irá gerar uma exclusão
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												cOperNew 	:= "E"
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
										EndIf
									ElseIf nOpcAx == 3
										//Retorno pendente impede o cadastro
										If cStatus == "2"
											cMsgRJE 	:= STR0247//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											lRet		:= .F.
										//Evento de exclusão sem transmissão impede o cadastro
										ElseIf cOperRJE == "E" .And. cStatus != "4"
											cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
											lRet		:= .F.
										//Evento sem transmissão, irá sobrescrever o registro na fila
										ElseIf cStatus $ "1/3"
											nOpcao1020	:= Iif( cOperRJE == "I", 3, 4 )
											cOperNew 	:= cOperRJE
											cRetfNew	:= cRetfRJE
											cStatNew	:= "1"
											lNovoRJE	:= .F.
										//Evento diferente de exclusão transmitido, irá gerar uma retificação
										ElseIf cOperRJE != "E" .And. cStatus == "4"
											cOperNew 	:= "A"
											cRetfNew	:= "2"
											cStatNew	:=  "1"
											lNovoRJE	:= .T.
										//Será tratado como inclusão
										Else
											cOperNew 	:= "I"
											cRetfNew	:= "1"
											cStatNew	:= "1"
											lNovoRJE	:= .T.
										EndIf
									EndIf
								Else
									nOpcao := fVerExtemp("S-1005",cChaveTAF, nOpc, @cStatus, @lContinua)
								EndIf
								//--------------------------------------------
								//| A obra pode ser um evento S-1005 e S-1020
								//--------------------------------------------
								If nOpcao > 0
									//Gera evento S-1005 - Obras
									lRet := fCarrCTT(aEstObras, cMesAnoP, aEstEd, @aErros, cFilEnv, nOpcao, 1)

									//Ajusta a operação do evento S-1020
									If !lMiddleware
										nOpcao1020 	:= fVerExtemp( "S-1020", cCodLot + ";" + cMesAnoP, nOpc, @cStatus, @lContinua)
									EndIf

									//Gera evento S-1020 - Lotações
									//Se nOpcao1020 for 0 significa que não houve alterações nos campos que geram este evento
									If nOpcao1020 > 0 .And. (lRet := fCarrLot( cCodLot, cMesAnoP, cTpLot, cLotInsc, cTp2, cInsEsoc, cFPAS, nTerc, cTpInsCo, cNrInsCo, cTpInsPr, cNrInsPr, nOpcao1020, @aErros, cFilEnv, !lRotProc, @cXml, cVersMid, @cRetKey, cTpAmb, oMdl941C )) .And. lMiddleware
										aAdd( aDados, { xFilial("RJE", cFilAnt), xFilial("CTT", cFilAnt), cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1020", cAno+cMes, cCodLot, cRetKey, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )

										//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
										If !( nOpcAx == 5 .And. ((cOperRJE == "E" .And. cStatus == "4") .Or. cStatus $ "-1/1/3") )
											If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRecRJE ) )
												cMsgRJE := STR0249//"Ocorreu um erro na gravação do registro na tabela RJE"
											EndIf
										//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
										ElseIf nOpcAx == 5 .And. cStatus != "-1" .And. !(cOperRJE == "E" .And. cStatus == "4")
											If !( lRet := fExcluiRJE( nRecRJE ) )
												cMsgRJE := STR0250//"Ocorreu um erro na exclusão do registro na tabela RJE"
											EndIf
										EndIf
									EndIf
									lMsgTAF := .T.
								Else
									cMsgErro := OemtoAnsi(STR0247)
									Help( ,, 'HELP',,cMsgErro, 1, 0 )
									lRet := .F.
									cMsg := cMsgErro
								Endif
							//------------------------------------------------------------------------------
							//| Realiza a geração do evento S-1020 - Lotações
							//------------------------------------------------------------------------------
							Else
								cChaveTAF	:= cCodLot + ";" + cMesAnoP
								If !lMiddleware
									nOpcao1020 	:= fVerExtemp( "S-1020", cChaveTAF, nOpc, @cStatus, @lContinua)
								Else
									fVersEsoc("S-1020", .F., /*@aRetGPE*/, /*@aRetTAF*/, ,,@cVersMid,,@cTpAmb)
									aInfoC := fXMLInfos()
									If Len(aInfoC) >= 4
										cTpInsc  := aInfoC[1]
										lAdmPubl := aInfoC[4]
										cNrInsc  := aInfoC[2]
									Else
										cTpInsc  := ""
										lAdmPubl := .F.
										cNrInsc  := "0"
									EndIf
									If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
										cFilEmp := aSM0[nFilEmp, 2]
									Else
										cFilEmp := cFilAnt
									EndIf
									// verifica se ja existe o evento s1020 na base de dados
									cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1020" + Padr(cCodLot, fTamRJEKey(), " ") + cAno+cMes
									cStatus := "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE )
									//Alteração ou exclusão
									If nOpcAx == 4 .Or. nOpcAx == 5
										//Retorno pendente impede o cadastro
										If cStatus == "2" .Or. cStatOld == "2"
											cMsgRJE 	:= STR0247//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											nOpcao1020 	:= 0
										ElseIf cStatOld == "4" .And. (RJ3->RJ3_INI != M->RJ3_INI .Or. RJ3->RJ3_COD != M->RJ3_COD)
											cMsgRJE 	:= STR0263//"Não é permitido alterar a validade ou o código pois o evento já foi transmitido"
											nOpcao1020 	:= 0
										//ALTERACAO
										ElseIf nOpcAx == 4 .AND. cStatus <> "2"
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												nOpcao1020 	:= 0
											//Não existe na fila, será tratado como inclusão
											ElseIf cStatus == "-1"
												nOpcao1020	:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											//Evento sem transmissão, irá sobrescrever o registro na fila
											ElseIf cStatus $ "1/3"
												If cOperRJE == "A"
													nOpcao1020 	:= 4
												EndIf
												cOperNew 	:= cOperRJE
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .F.
											//Evento diferente de exclusão transmitido, irá gerar uma retificação
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												nOpcao1020	:= 4
												cOperNew 	:= "A"
												cRetfNew	:= "2"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											//Evento de exclusão transmitido, será tratado como inclusão
											ElseIf cOperRJE == "E" .And. cStatus == "4"
												nOpcao1020	:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
										//Exclusão
										ElseIf nOpcAx == 5
											nOpcao1020 		:= 5
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												nOpcao1020 	:= 0
											//Evento diferente de exclusão transmitido irá gerar uma exclusão
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												cOperNew 	:= "E"
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
										EndIf
									ElseIf nOpcAx == 3
										//Retorno pendente impede o cadastro
										If cStatus == "2"
											cMsgRJE 	:= STR0247//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											nOpcao1020 	:= 0
										//Evento de exclusão sem transmissão impede o cadastro
										ElseIf cOperRJE == "E" .And. cStatus != "4"
											cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
											nOpcao1020 	:= 0
										//Evento sem transmissão, irá sobrescrever o registro na fila
										ElseIf cStatus $ "1/3"
											nOpcao1020	:= Iif( cOperRJE == "I", 3, 4 )
											cOperNew 	:= cOperRJE
											cRetfNew	:= cRetfRJE
											cStatNew	:= "1"
											lNovoRJE	:= .F.
										//Evento diferente de exclusão transmitido, irá gerar uma retificação
										ElseIf cOperRJE != "E" .And. cStatus == "4"
											cOperNew 	:= "A"
											cRetfNew	:= "2"
											cStatNew	:=  "1"
											lNovoRJE	:= .T.
										//Será tratado como inclusão
										Else
											cOperNew 	:= "I"
											cRetfNew	:= "1"
											cStatNew	:= "1"
											lNovoRJE	:= .T.
										EndIf
									EndIf
								EndIf
								If nOpcao1020 > 0
									//------------------------------------------------------------------------------------------------------
									//| Quando for a geração do evento S-1020, não há necessidade de consultar as informações da tabela S037
									//| Com isso, foi criado um novo parâmetro na fInssEmp para desprezar a S037, caso seja o evento S-1020
									//-------------------------------------------------------------------------------------------------------
									fInssEmp(cFilEnv,@aX14,.F.,cAnoMesP,.T.)
									cFPAS	:= M->CTT_FPAS
									nTerc	:= M->CTT_CODTER

									If M->CTT_TPLOT $ "01|10|21|24|90"
										If Empty(cFPAS)
											cFPAS := aInfoFil[17]
										EndIf
										If Empty(nTerc)
											nTerc := aX14[25,1]
										EndIf
									Endif
									If (lRet := fCarrLot( cCodLot, cMesAnoP, cTpLot, cLotInsc, cTp2, cInsEsoc, cFPAS, nTerc, cTpInsCo, cNrInsCo, cTpInsPr, cNrInsPr, nOpcao1020, @aErros, cFilEnv, !lRotProc, @cXml, cVersMid, @cRetKey, cTpAmb, oMdl941C )) .And. lMiddleware
										aAdd( aDados, { xFilial("RJE", cFilAnt), xFilial("CTT", cFilAnt), cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1020", cAno+cMes, cCodLot, cRetKey, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )

										//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
										If !( nOpcAx == 5 .And. ((cOperRJE == "E" .And. cStatus == "4") .Or. cStatus $ "-1/1/3") )
											If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRecRJE ) )
												Help( ,, 'HELP',,STR0249, 1, 0 )//"Ocorreu um erro na gravação do registro na tabela RJE"
												lRet := .F.
											EndIf
										//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
										ElseIf nOpcAx == 5 .And. cStatus != "-1" .And. !(cOperRJE == "E" .And. cStatus == "4")
											If !( lRet := fExcluiRJE( nRecRJE ) )
												Help( ,, 'HELP',,STR0250, 1, 0 )//"Ocorreu um erro na exclusão do registro na tabela RJE"
												lRet := .F.
											EndIf
										EndIf
									EndIf
									lMsgTAF := .T.
								Else
									Help( ,, 'HELP',, If(Empty(cMsgRJE), OemtoAnsi(STR0247), cMsgRJE), 1, 0 )
									lRet := .F.
								EndIf
							EndIf
							//Exibe mensagem de integração
							If FindFunction("fEFDMsg") .and. lRet .and. lMsgTAF
								If !lAuto
									fEFDMsg()
								Else
									conout(OemtoAnsi(STR0045) + " - " + OemtoAnsi(STR0161))
								EndIf
							EndIf
						EndIf
					else

						If !lIntegEAI //Exibe mensagem se nao for integracao por mensagem unica
							//"Atencao"##"Para que este registro possa ser integrado com o TAF, você deve informar o campo CTT_TPLOT e suas respectivas parametrizações. O Registro será salvo mas não integrado."
							if !lAuto
								If !lRotProc
									Aviso(OemtoAnsi(STR0045),iif(lMiddleware,OemtoAnsi(STR0246),OemtoAnsi(STR0195)),{OemtoAnsi("OK")})
								Else
									cMsgRotPrc := Iif(lMiddleware,OemtoAnsi(STR0246),OemtoAnsi(STR0195))
								EndIf
							else
								conout(OemtoAnsi(STR0045) + " - " + OemtoAnsi(STR0195))
							endif
						EndIf
					ENDIF
				ENDIF
				If !lRet
					cMsg:= IIF(LEN(aErros)>0, aErros[1],cMsg)
				EndIf
				If !lRet
					//-------------------------------
					//| Cenários:
					//| Se for 0: Ele avisa do erro e segue mesmo assim (Salva CTT e Não TAF)
					//| Se for 1, ele avisa do erro e bloqueia o cadastro de tudo (Não CTT e Não TAF)
					//| Se for 2, ele não avisa nada (Se tiver erro, salva só CTT / Se não tiver, salva CTT + TAF)
					//---------------------------------------------------------------------------------------------
					lRet := cEFDAviso $ "0|2"
					If cEFDAviso <> "2"
						If cEFDAviso == "0" .AND. !Empty(cMsg)
							cMsg += CRLF + OemToAnsi(STR0189)//"E de acordo com o valor do parâmetro MV_EFDAVIS"
							cMsg += CRLF + IIF(lMiddleware,OemToAnsi(STR0261),OemToAnsi(STR0187)) //"O Registro será salvo mas não integrado com o TAF. Para corrigir, volte alterando o registro e informe os campos necessários."
						ElseIf cEFDAviso == "1" .AND. !Empty(cMsg)
							cMsg += CRLF + OemToAnsi(STR0189) //"E de acordo com o valor do parâmetro MV_EFDAVIS"
							cMsg += CRLF + IIF(lMiddleware,OemToAnsi(STR0262),OemToAnsi(STR0188)) //"O Registro não será salvo e nem integrado com o TAF. Corrija os campos informados para prosseguir com o cadastro."
						EndIf

						If !Empty(cMsg)
							if !lAuto
								If !lRotProc
									MsgInfo(cMsg,OemToAnsi(STR0045)) //"Atenção!"
								Else
									cMsgRotPrc := cMsg
								EndIf
							else
								conout(OemToAnsi(STR0045) + " - " + cMsg)
							endif
						EndIf
					Endif
				EndIf
			EndIf//exc
		EndIf
	ENDIF
ENDIF

If lMiddleware
	fPosFil( cEmpAnt, cBkpFil )
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Inclusão na Tabela RJ8 - Rotina de Cópia             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Grava na fila de processamento para a rotina de cópia das tabelas - Inclusão
If !isBlind() .And. lCopiaTab .And. lRet
	G936GeraCTT("CTT", xFilial("CTT") + M->CTT_CUSTO, nOpcAx)
EndIf

Return lRet

/*/{Protheus.doc} fChkFMat
Função responsável pela validação da filial matriz.
@type function
@author Eduardo
@since 28/02/2018
@version 1.0
/*/
Function fChkFMat(cEvent)

Local cMensagem     := ""
Local nPosEv        :=  0
Local nMatriz       :=  0
Local nCont         :=  0
Local lMatrizes     := .F.
Local lRet          := .T.
Local aFilsAll      :=  {}
Local aEvent        :=  {}
Local aDados        :=  {}
Local aCheck        :=  { .T., .T., .T., .T., .T., .F., .F., .F., .F. }

Default cEvent      :=  ""
//-------------------------------------------------------
//Busca todas as informações das filiais cadastradas no TAF
//-------------------------------------------------------
fGp23Cons(aFilsAll)
//-------------------------------------------------------
//Verifica o compartilhamento das tabelas GPE X TAF
//-------------------------------------------------------
VldRotTab(aCheck,@aDados,@aEvent)
//-------------------------------------------------------
//Contabiliza as filiais matrizes
//-------------------------------------------------------
AEVAL( aFilsAll, { | aFils  |  IIF (LEN(aFils)>= 4 .And. aFils[4],nMatriz++,)})
lMatrizes   := IIF(nMatriz > 1,.T.,.F.)

//-------------------------------------------------------
//Verifica a posição do evento para apresentar a mensagem para o usuário.
//-------------------------------------------------------
nPosEv:= ascan(aEvent,{|a| Alltrim(a[1]) == Alltrim(cEvent) })
aDados:= {}
If (lMatrizes .And. aEvent[nPosEv][3] == "CCC" )
    aAdd( aDados, "Tabela: "+ aEvent[nPosEv][2] + CRLF + OemToAnsi(STR0199))
    lRet:= .F.
EndIf
For nCont:= 1 to len(aDados)
    cMensagem += aDados[nCont]
Next nCont
If(Len(aDados)>=1)
	Help('' ,1, 'HELP',,cMensagem , 1, 0 )   //"Tipo de Lotação Inválida"
EndIf
Return lRet

/*/{Protheus.doc} fAltVer
Função de checagem de informação de campo de tabela com o campo da memória.
@type function
@author Eduardo
@since 12/06/2018
@version 1.0
@param cTab, String, nome da tabela a ser usada
@param aArrCPO, Array, Array com os campos
/*/Static Function fAltVer(aArrCPO,cTab)
Local lRet	:= .F.
Local nX		:= 0

For nX:= 1 to Len(aArrCPO)
	If &(cTab+"->"+aArrCPO[nX]) != &("M->"+ aArrCPO[nX]) .And. !lRet
		lRet	:= .T.
	EndIf
Next nX
Return lRet

/*/{Protheus.doc} fTipDocEso
Função Exibir os codigos para escolher o documento obrigatório para o eSocial (CNH,CRM e etc), na consulta padrão S130
@type function
@author Marco Nakazawa
@since 15/02/2019
@version 1.0
@param
/*/
Function fTipDocEso()
Local cTitulo  		:= OemToAnsi(STR0225) // "Documentos Específicos eSocial"
Local MvPar    		:= &(ReadVar())
Local MvParDef 		:= ""
Local MvStrRet		:= ""
Local lRet     		:= .T.
Local l1Elem   		:= .F.
Local nTipo			:= 0

Private aTipDoc	:= {}

VAR_IXB := MvPar

aTipDoc := {;
					OemToAnsi(STR0226),; //"01 - CNH"
					OemToAnsi(STR0227)}  //"02 - Órgão de Classe"
MvParDef := "0102"

If f_Opcoes(@MvPar,cTitulo,aTipDoc,MvParDef,,,l1Elem,2,1)
	For nTipo := 1 To Len(MvPar)
		If (SubStr(MvPar, nTipo, 1) # "*")
			MvStrRet += SubStr(mvpar, nTipo, 1)
		Else
			MvStrRet += Space(1)
		Endif
	Next nTipo
	VAR_IXB := AllTrim(MvStrRet)
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fValCbo
Função validadora do preenchimento do CBO para o eSocial na tabela S130
@author  Marco Nakazawa
@since   18/02/2019
@version 1
/*/
//-------------------------------------------------------------------
Function fValCbo(cConteudo)
Local lRet := .T.

cConteudo := AllTrim(StrTran(cConteudo,"-",""))

If Len(cConteudo) < 4
	Aviso(STR0228,STR0229,{"OK"}) //Atençäo ! ## "Campo 'CBO' precisa ter no mínimo 4 dígitos"
	lRet := .F.
EndIf

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ChangeNew ³ Autor ³                       ³ Data ³03/01/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Abrir tabelas para Consulta via Tecla F3                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cEmp - Empresa de Destino                                  ³
³          ³ cFil - Filial  de Destino                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ChangeNew(uAliasNewEmp, cEmp, cFil)
	Local nAT
	Local nX		:= 0
	Local cModo 	:= ""
	Local cAliaAux	:= ""

	fOpenSx2(cEmp)
	FWClearXFilialCache()

	For nX := 1 to Len(uAliasNewEmp)
		cAliaAux:= uAliasNewEmp[nX]
		UniqueKey( NIL , cAliaAux , .T. )
		EmpOpenFile(cAliaAux,cAliaAux,1,.T.,cEmp,@cModo)
	Next Nx

Return( .T. )

/*/{Protheus.doc} fOpenSx2
Função para abrir a SX2 de outra empresa
@author Rafael Reis
@since 29/12/2017
/*/
Static Function fOpenSx2(cEmp)
	Local lOk	:=	.T.

	SX2->(DBCloseArea())
	OpenSxs(,,,,cEmp,"SX2","SX2",,.F.)
	If Select("SX2") == 0
		lOk := .F.
	Endif

Return lOk


/*{Protheus.doc} fBuscaVrb
Função que servirá ao TAF para consulta de verbas para relatório.
@type function
@author guilherme.bertelli
@since 17/04/2019
@version 1.0
*/
FUNCTION fBuscaVrb(cPeriodo, cFilEvt)

	LOCAL cQrySt		:= ""
	LOCAL aVerbas		:= {}
	LOCAL aFilProc		:= {}
	LOCAL cSRDRot		:= GetNextAlias()
	LOCAL cRefVerba 	:= ""
	LOCAL cFilProc		:= ""
	LOCAL nParam		:= 0
	LOCAL cJoinRCxRV	:= FWJoinFilial( "SRC", "SRV" )
	LOCAL cJoinRDxRV	:= FWJoinFilial( "SRD", "SRV" )
	LOCAL cVersEnvio	:= ""
	LOCAL cIncIRF		:= ""

	DEFAULT cFilEvt  	:= cFilAnt

	IF EMPTY(cPeriodo)
		Return aVerbas
	ENDIF

	fVersEsoc("S1010", .F.,,,@cVersEnvio)

	cFilProc := StrTran(cFilEvt, "'", "")
	aFilProc := StrTokArr(cFilProc, ",")

	If __oSt1 == Nil

		__oSt1 := FWPreparedStatement():New()

		cQrySt := "SELECT DISTINCT * FROM ("
		cQrySt += "SELECT SRD.RD_FILIAL AS FILIAL, SRV.RV_COD, SRV.RV_DESC, SRV.RV_TIPOCOD, SRV.RV_REF13, SRV.RV_REFFER, "
		cQrySt += "SRV.RV_NATUREZ, SRV.RV_CODFOL, "
		cQrySt += "SRV.RV_INSS, SRV.RV_INCCP, "
		cQrySt += "SRV.RV_FGTS, SRV.RV_INCFGTS, "
		cQrySt += "SRV.RV_IR, SRV.RV_INCIRF "
		cQrySt += "FROM "
		cQrySt +=  RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRV') + " SRV ON " + cJoinRDxRV + " AND SRV.RV_COD = SRD.RD_PD "
		cQrySt +=  "WHERE "
		cQrySt += "SRD.RD_FILIAL IN (?) AND "
		cQrySt += "SRD.RD_PERIODO = ? AND "
		cQrySt += "SRV.D_E_L_E_T_ = '' AND "
		cQrySt += "SRD.D_E_L_E_T_ = '' "

		cQrySt += "UNION ALL "

		cQrySt += "SELECT SRC.RC_FILIAL AS FILIAL, SRV.RV_COD, SRV.RV_DESC, SRV.RV_TIPOCOD, SRV.RV_REF13, SRV.RV_REFFER, "
		cQrySt += "SRV.RV_NATUREZ, SRV.RV_CODFOL, "
		cQrySt += "SRV.RV_INSS, SRV.RV_INCCP, "
		cQrySt += "SRV.RV_FGTS, SRV.RV_INCFGTS, "
		cQrySt += "SRV.RV_IR, SRV.RV_INCIRF "
		cQrySt += "FROM "
		cQrySt +=  RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRV') + " SRV ON " + cJoinRCxRV + " AND SRV.RV_COD = SRC.RC_PD "
		cQrySt +=  "WHERE "
		cQrySt += "SRC.RC_FILIAL IN (?) AND "
		cQrySt += "SRC.RC_PERIODO = ? AND "
		cQrySt += "SRC.D_E_L_E_T_ = '' AND "
		cQrySt += "SRC.D_E_L_E_T_ = '' "
		cQrySt += ") Verbas "
		cQrySt += "ORDER BY Verbas.RV_COD "

		cQrySt := ChangeQuery(cQrySt)
		__oSt1:SetQuery(cQrySt)
	EndIf

	__oSt1:SetIn(++nParam, aFilProc)
	__oSt1:SetString(++nParam, cPeriodo)
	__oSt1:SetIn(++nParam, aFilProc)
	__oSt1:SetString(++nParam, cPeriodo)

	cQrySt := __oSt1:getFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cSRDRot,.T.,.T.)

	WHILE (cSRDRot)->(!Eof())
		cRefVerba := ""
		IF (cSRDRot)->(RV_REF13) == "N" .AND. (cSRDRot)->(RV_REFFER) == "N"
			cRefVerba := "1" // Folha
		ELSEIF (cSRDRot)->(RV_REF13) == "S"
			cRefVerba := "2" // Décimo terceiro
		ELSEIF (cSRDRot)->(RV_REFFER) == "S"
			cRefVerba := "3" // Férias
		ENDIF

		If cVersEnvio >= '2.6.00'
			cIncIRF := (cSRDRot)->(RV_INCIRF)
		Else
			cIncIRF := Substr((cSRDRot)->(RV_INCIRF),1,2)
		Endif

		//inclui no array aVerbas apenas 1x a verba por filial da tabela SRV.
		If Empty(aVerbas) .OR. !(aVerbas[Len(aVerbas),1] == xFilial("SRV",(cSRDRot)->(FILIAL)) .AND. aVerbas[Len(aVerbas),2] == (cSRDRot)->(RV_COD))
			aAdd(aVerbas, {;
				xFilial("SRV",(cSRDRot)->(FILIAL)),;		//Filial
				(cSRDRot)->(RV_COD),; 		//Código da verba
				(cSRDRot)->(RV_DESC),;		//Descrição da verba
				(cSRDRot)->(RV_TIPOCOD),;	//Código do Tipo de verba //1-Provento | 2-Desconto | 3-Base(Provento) | 4-Base(Desconto)
				cRefVerba,;					//Referência da Verba	  //1-Mensal | 2-Décimo terceiro | 3-Férias
				(cSRDRot)->(RV_NATUREZ),;	//Natureza da Verba
				(cSRDRot)->(RV_CODFOL),;	//Id de cálculo
				(cSRDRot)->(RV_INSS),;		//Incidência INSS p/ Folha
				(cSRDRot)->(RV_INCCP),;		//Incidência INSS p/ eSocial
				(cSRDRot)->(RV_FGTS),;		//Incidência FGTS p/ Folha
				(cSRDRot)->(RV_INCFGTS),;	//Incidência FGTS p/ eSocial
				(cSRDRot)->(RV_IR),;		//Incidência IRPF p/ Folha
				cIncIRF;					//Incidência IRPF p/ eSocial
			})
		EndIf
		(cSRDRot)->(dbSkip())
	ENDDO

Return aVerbas

/*/{Protheus.doc} RJPct
Função para mudar a picture de campos CPNJ/CPF
@type      	Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@param		cTpInsc, 	characters, 	Ordem para validação do tipo de inscrição
@return		lRet,		logic
/*/
Function RJPct( cTpInsc )
	Local cPicRJ 	:=  "@R 99.999.999/9999-99 "
	Local cTp2		:= "1"

	Default cTpInsc := ""

	If cTpInsc == "1"
		cTp2 := M->RJ3_TPINSC
	ElseIf cTpInsc == "2"
		cTp2 := M->RJ3_TPINCO
	ElseIf cTpInsc == "3"
		cTp2 :=  M->RJ3_TPINPR
	Endif

	If Alltrim(cTp2) == "2" // CPF
		cPicRJ := "@R 999.999.999-99"
	Endif

	cPicRJ := cPicRJ + "%C"

Return cPicRJ

/*/{Protheus.doc} fVldIniRJ
Função para validar o período inicial da tabela RJ3
@type      	Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@return		lRet,		logic
/*/
Function fVldIniRJ()

Local cPerRJ	:= &(ReadVar())
Local nAno		:= 0
Local nMes		:= 0
Local lPerOk	:= .T.

	// Forca o periodo no formato AAAA/MM
	If Valtype(cPerRJ) == "C" .And. !Empty(cPerRJ)
		nAno := Val(SubStr(cPerRJ, 0, 4))
		nMes := Val(SubStr(cPerRJ, 5, 2))
		If (nAno < 1900 .Or. nAno > 3000 ) .Or. (nMes < 1 .Or. nMes > 12 )
			lPerOk:= .F.
		EndIf
	Else
		lPerOk := .F.
	EndIf

	If !lPerOk
		Help( " ", 1, OemToAnsi(STR0045),, OemToAnsi(STR0232), 1, 0 ) //"Atenção"#"Período Inválido! Verifique formato (AAAAMM)."
	Endif

Return lPerOk

/*/{Protheus.doc} fVldObraRJ
Função para validar se o novo controle de Obras/Lotações está em uso
@type      	Function
@author   	Claudinei Soares
@since		19/03/2019
@version	1.0
@param		lParcial	, 	logic		, 	Se utiliza o novo controle de Obras/Lotações para o eSocial, mas somente em partes.
@param		lMsg		, 	logic		, 	Se exibirá mensagem informando que não está utilizando o controle totalmente.
@return		lCompleto	,	logic		,	Se utiliza o novo controle de Obras/Lotações para o eSocial
/*/
Function fVldObraRJ(lParcial, lMsg)
Local lCompleto     := .F.
Local lRJ3          := .F.
Local lRJ5          := .F.
Local aArea 		:= GetArea()

Default lParcial    := .F.
Default lMsg        := .F.

	// Checa a existência das novas tabelas de obras/lotações do eSocial
	If ChkFile("RJ3") .And. ChkFile("RJ5")

		// Verifica se as novas tabelas estão sendo usadas,
		//caso foram criadas na base mas não foram preenchidas.

		DbSelectArea("RJ3")
		RJ3->(DbGoTop())
		If RJ3->(!EOF())
			lRJ3 := .T.
		Endif

		DbSelectArea("RJ5")
		RJ5->(DbGoTop())
		If RJ5->(!EOF())
			lRJ5 := .T.
		Endif

        If lRJ5 .And. lRJ3
            lCompleto := .T.
        ElseIf !lRJ5 .And. !lRJ3
            lCompleto := .F.
        Else
            lParcial := .T.
        Endif

	EndIf

	If lParcial .And. lMsg
		//"Atenção"#"Identificamos que foi iniciada a utilização do novo controle de obras/lotações para o eSocial, entretanto não está completo."
		//"Verifique o preenchimento das tabelas RJ3 e RJ6, Lotações eSocial e Relacionamento CTT x eSocial, respectivamente."
		Help( " ", 1, OemToAnsi(STR0045),, OemToAnsi(STR0233), 2, 0,,,,,, { OemToAnsi(STR0234) } )
	EndIf

	RestArea(aArea)

Return lCompleto

/*/{Protheus.doc} fVldRJ4
Função para validar se o controle da RJ4 está em uso
@type      	Function
@author   	Gisele Nuncherino
@since		21/03/2019
@version	1.0
@return		lret 	Se utiliza o novo controle da RJ4
/*/
Function fVldRJ4(lMsg)

	Local 	lret := .F.
	Default lMsg := .F.

	// Checa a existência da tabela RJ4
	If ChkFile("RJ4")

		// Verifica se as novas tabelas estão sendo usadas,
		//caso foram criadas na base mas não foram preenchidas.
		DbSelectArea("RJ4")
		RJ4->(DbGoTop())
		If RJ4->(!EOF())
			lRet := .T.
		Endif
	Endif

	if lRet
		if IsBlind()
			conout(OemToAnsi(STR0235))
			conout(OemToAnsi(STR0236))
		else
			if lMsg
				MSGINFO( OemToAnsi(STR0235) + " " + OemToAnsi(STR0236), OemToAnsi(STR0045) )
			endif
		endIf
	endif

Return lRet

/*/{Protheus.doc} fBusPerRJ3
Função que verifica se existem registros na tabela de lotações do eSocial de acordo com o período informado
@type      	Function
@author   	Claudinei Soares
@since		27/03/2019
@version	1.0
@param		cMesAno		, 	characters	, 	Período para busca dos registros, formato (MMAAAA).
@param		cTabRJ		, 	characters	, 	Tabela a ser verificada (por padrão será a Rj3).
@param		cMesAnoRJ	, 	characters	, 	Primeiro Período encontrado na tabela, se exixtir, formato (MMAAAA).
@return		lRet		,	logical		,	Retorno da função
/*/
Function fBusPerRJ3(cMesAno, aArrayFilP, cTabRJ, lAntesRJ)

	Local cAnoM			:= ""
	Local aArea			:= GetArea()
	Local aAnoMesRJ		:= {}
	Local lRet			:= .F.

	Default cTabRJ		:= "RJ3"
	Default lAntesRJ	:= .F.

	cAnoM  := SUBSTR(cMesAno,3) + SUBSTR(cMesAno,1,2)

	If cTabRJ == "RJ3"
		DbSelectArea("RJ3")
		DbSetOrder( 1 )
		If RJ3->(dbSeek( Alltrim(FwxFilial("RJ3", aArrayFilP[3,1]) ) ) )
			While RJ3->( !Eof() .And. !lRet )
				Aadd(aAnoMesRJ, {RJ3->RJ3_INI})
				If cAnoM >= RJ3->RJ3_INI
					lRet := .T.
					Exit
				Endif
				RJ3->(dbSkip())
			EndDo
			If !lRet .And. Len(aAnoMesRJ) > 0
				ASort(aAnoMesRJ ,,, { |x,y| x[1]<y[1] })
				lAntesRJ := aAnoMesRJ[1,1] > cAnoM
			Endif
		EndIf
		DbCloseArea("RJ3")
	Else
		DbSelectArea("RJ4")
		DbSetOrder( 1 )
		If RJ4->(dbSeek( Alltrim(FwxFilial("RJ4", aArrayFilP[3,1]) ) ) )
			While RJ4->( !Eof() .And. !lRet )
				Aadd(aAnoMesRJ, {RJ4->RJ4_INI})
				If cAnoM >= RJ4->RJ4_INI
					lRet := .T.
					Exit
				Endif
				RJ4->(dbSkip())
			EndDo
			If !lRet .And. Len(aAnoMesRJ) > 0
				ASort(aAnoMesRJ ,,, { |x,y| x[1]<y[1] })
				lAntesRJ := aAnoMesRJ[1,1] > cAnoM
			Endif
		EndIf
		DbCloseArea("RJ4")
	Endif

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fGetEntEdu
Função que busca o código da Entidade educativa na tabela RJ6, a partir da filial, tipo de inscrição e número de inscrição
@type      	Function
@author   	Claudinei Soares
@since		07/04/2019
@version	1.0
@param		cFilRJ6	, 	characters	, 	Filial a ser procurada.
@param		cTpInRJ6, 	characters	, 	Tipo de Inscrição.
@param		cNinRJ6	, 	characters	, 	Número da Inscrição
@param		aEstEd	, 	array		, 	Array que será retornado com .
@return		Nil		,				,	Retorno da função
/*/
Function fGetEntEdu(cFilRJ6, cTpInRJ6, cNinRJ6, aEstEd )

	Local aArea			:= GetArea()

	Default cFilRJ6 	:= ""
	Default cTpInRJ6	:= ""
	Default cnInRJ6		:= ""
	Default aEstEd		:= {}


	If ChkFile("RJ6")
		DbSelectArea("RJ6")
		DbSetOrder( 2 ) //RJ6_FILIAL+RJ6_TPINSC+RJ6_NINSCR+RJ6_ENTEDU+RJ6_INI

		If RJ6->(dbSeek ( Alltrim( FwxFilial("RJ6", cFilRJ6) + cTpInRJ6 + cNinRJ6 ) ) )
			Aadd(aEstEd, {RJ6->RJ6_NINSCR, RJ6->RJ6_ENTEDU} )
		Endif

	Endif

Return Nil

/*/{Protheus.doc} fVldRJ3
Realiza a validação dos campos envolvidos no e-Social
@type      	Function
@author   	Claudinei Soares
@since		10/05/2019
@version	1.0
@param		nOpcRJ3	, 	numeric		, 	Numero da acao Ativa (CRUD)
@return		lRet	,	logic		,	Retorno da função
/*/
Function fVldRJ3(nOpcRJ3, lRotProc, cMsgRotPrc, oModel)
	Local cStatus		:= "-1"
	Local cFilEnv		:= ""
	Local cCodLot		:= ""
	Local cEFDAviso		:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
	Local cCEI2			:= "RJ3_NINSCR"
	Local cMesAnoP		:= ""
	Local cLotInsc		:= "02|03|04|05|06|07|08|09"
	Local cFPAS
	Local nTerc
	Local cMes			:= SUBSTR(M->RJ3_INI, 5,2)
	Local cAno			:= SUBSTR(M->RJ3_INI, 1,4)
	Local cTpLot
	Local cTp2
	Local cInsEsoc
	Local cTpInsCo
	Local cNrInsCo
	Local cTpInsPr
	Local cNrInsPr
	Local cMsg			:= ""
	Local cChaveTAF

	Local nX			:= 1
	Local nOpcao

	Local lSemFilial	:= .F.
	Local lMsgTAF		:= .F.
	Local lContinua		:= .T.
	Local lRet			:= .T.

	Local aFilInTaf		:= {}
	Local aArrayFil		:= {}
	Local aArrAux		:= {}
	Local aErros		:= {}

	Local cBkpFil	  	:= cFilAnt
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= M->RJ3_INI
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cRetfRJE	 	:= ""
	Local cRetKey	 	:= ""
	Local cOperNew 	 	:= ""
	Local cOperOld		:= "I"
	Local cOperRJE	 	:= "I"
	Local cRetfNew	 	:= ""
	Local cRetfOld		:= "1"
	Local cStatNew	 	:= ""
	Local cStatOld		:= "-1"
	Local lNovoRJE	 	:= .F.
	Local nOpcao 	 	:= 3
	Local nRecOld		:= 0
	Local nRecRJE  	 	:= 0
	Local lS1000 	 	:= .F.
	Local nOpcAx	 	:= nOpcRJ3
	Local aSM0    	 	:= FWLoadSM0(.T.,,.T.)
	Local cTpAmb		:= ""

	Default nOpcRJ3		:= 0
	Default lRotProc	:= .F.
	Default cMsgRotPrc	:= ""
	Default oModel		:= Nil

	//-----------------------------------------------------------
	//| Verifica a existência do Campo importante para o eSocial
	//-----------------------------------------------------------

	If lMiddleware .Or. ( IIF(FindFunction("fChkFMat"),lRet:=fChkFMat("S-1020"),.F.))

		//Se o Tipo de Lotação for 02
		If  M->RJ3_TPLOT == "02"

			If Empty(M->RJ3_TPINCO) .Or. Empty(M->RJ3_NINSCO) .Or. Empty(M->RJ3_TPINPR) .Or. Empty(M->RJ3_NINSPR)
				//"Os campos 'Tp. In. Contr.', 'N.Insc.Contr.', 'Tp.I.Pro.CNO' e 'N.Insc.Prop.' são de preenchimento obrigatório quando o Tipo de Lotação for igual a '02'."
				cMsg += OemToAnsi(STR0238) + CRLF
				lRet:= .F.
			EndIf
		EndIf

		//Se a validação inicial estiver Tudo OK
		If lRet
			cTpLot		:= M->RJ3_TPLOT 	//Tipo Lotacao
			cTp2		:= M->RJ3_TPINSC	//Tipo de Cadastro eSocial
			cInsEsoc	:= M->RJ3_NINSCR 	//Tipo Inscricao eSocial
			cTpInsCo	:= M->RJ3_TPINCO	//Tipo Inscrição Contratante
			cNrInsCo	:= M->RJ3_NINSCO	//Nro Inscricao Contratante
			cTpInsPr	:= M->RJ3_TPINPR	//Tipo Inscricao Proprietario
			cNrInsPr	:= M->RJ3_NINSPR	//Nro Inscricao Proprietario

			IF !Empty( M->RJ3_TPLOT )
				//Tratamento de compartilhamento da tabela RJ3
				lRet:= .T.

				If ( M->RJ3_TPLOT $ "03|04|05|06|07|08|09" )
					If Empty(M->RJ3_COD) .OR. Empty(M->RJ3_TPINSC) .OR. Empty(M->RJ3_NINSCR)
						aArrAux := {"RJ3_COD", "RJ3_TPINSC", "RJ3_NINSCR"}
						For nX := 1 To Len( aArrAux )
							If EMPTY( &("M->" + aArrAux[nX]) )
								//A partir da nova LIB deveremos substituir pela função FWSX3Util()
								SX3->(DBSETORDER(2))
								IF SX3->(DBSeek( aArrAux[nX] ) )
									cMsg += X3Titulo( aArrAux[nX] ) + CRLF
								ENDIF
							EndIf
						Next

						If !IsBlind()
							If !lRotProc
								Aviso(OemtoAnsi(STR0045), OemToAnsi(STR0194) + CRLF + CRLF + cMsg,{"Ok"},3) //"Atenção"##"Existem campos necessários ao eSocial em branco"##Campos##Ok
							Else
								cMsgRotPrc := OemToAnsi(STR0194) + CRLF + CRLF + cMsg//"Existem campos necessários ao eSocial em branco
							EndIf
						Endif
						lRet:= .F.
						cMsg := ""
					Endif

				ElseIf M->RJ3_TPLOT == "02"
					IF Empty(M->RJ3_COD) .OR. Empty(M->RJ3_TPINSC)	.OR. Empty(M->RJ3_NINSCR) .OR. Empty(M->RJ3_TPINCO) .OR. Empty(M->RJ3_NINSCO) .OR. Empty(M->RJ3_TPINPR) .OR. Empty(M->RJ3_NINSPR)
						aArrAux := { "RJ3_COD", "RJ3_TPINSC", "RJ3_NINSCR", "RJ3_TPINCO", "RJ3_NINSCO", "RJ3_TPINPR", "RJ3_NINSPR"}

						For nX := 1 To Len( aArrAux )
							If EMPTY( &("M->" + aArrAux[nX]) )
								SX3->(DBSETORDER(2))
								IF SX3->(DBSeek( aArrAux[nX] ))
									cMsg += X3Titulo( aArrAux[nX] ) + CRLF
								ENDIF
							EndIf
						Next

						If !IsBlind()
							If !lRotProc
								Aviso(OemtoAnsi(STR0045), OemToAnsi(STR0194) + ": " + CRLF + CRLF + cMsg,{"Ok"},3) //"Atenção"##"Existem campos necessários ao eSocial em branco"##Campos##Ok
							Else
								cMsgRotPrc := OemToAnsi(STR0194) + ": " + CRLF + CRLF + cMsg//"Existem campos necessários ao eSocial em branco"
							EndIf
						Endif
						lRet:= .F.
						cMsg := ""
					Endif
				Endif

				//Tratamento de compartilhamento da tabela RJ3
				If Empty(FWXFILIAL("RJ3") )
					lSemFilial := .T.
				EndIf

				//-------------------------------------------------------------
				//| Se não encontrar nenhuma inconsistencia na validacao acima
				//-------------------------------------------------------------
				If lRet
					If !lMiddleware
						fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
					EndIf
					cMesAnoP	:= cMes + cAno

					If Empty(cFilEnv)
						cFilEnv := cFilAnt
					EndIf

					cFPAS	:= M->RJ3_FPAS
					nTerc	:= M->RJ3_TERC

					//----------------------------------------------------
					//| Realiza a integração do registro / Geração do XML
					//----------------------------------------------------
					cCodLot 	:= IIf( lSemFilial, M->RJ3_COD, xFilial("RJ3") + M->RJ3_COD )
					If lMiddleware
						fVersEsoc("S-1020", .F., /*@aRetGPE*/, /*@aRetTAF*/, ,,@cVersMid,, @cTpAmb)
						// verificar os predecessores - evento S1000
						cStatus := "-1"
						fPosFil( cEmpAnt, cFilAnt )
						lS1000 := fVld1000( M->RJ3_INI, @cStatus )
						/*
							* 1 - Não enviado - Gravar por cima do registro encontrado
							* 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e não continuar com o processo
							* 3 - Retorno com Erro - Gravar por cima do registro encontrado
							* 4 - Retorno com Sucesso -?Efetivar a gravação
						*/
						If lS1000 .Or. cEFDAviso $ "0/2"
							aInfos   := fXMLInfos()

							IF Len(aInfos) >= 4
								cTpInsc  := aInfos[1]
								lAdmPubl := aInfos[4]
								cNrInsc  := aInfos[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							EndIf

							If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
								cFilEmp := aSM0[nFilEmp, 2]
							Else
								cFilEmp := cFilAnt
							EndIf

							// verifica se ja existe o evento s1035 na base de dados
							cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1020" + Padr(xFilial( "RJ3", cFilAnt ) + M->RJ3_COD, fTamRJEKey(), " ") + M->RJ3_INI
							cStatus := "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE )
							If nOpcRJ3 == MODEL_OPERATION_UPDATE
								cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1020" + Padr(xFilial( "RJ3", cFilAnt ) + RJ3->RJ3_COD, fTamRJEKey(), " ") + RJ3->RJ3_INI
								GetInfRJE( 2, cChave, @cStatOld, @cOperOld, @cRetfOld, @nRecOld )
								If cStatOld $ "1/3"
									cStatus  := cStatOld
									cOperRJE := cOperRJE
									cRetfRJE := cRetfOld
									nRecRJE  := nRecOld
								EndIf
							EndIf

							//Alteração ou exclusão
							If nOpcAx == 4 .Or. nOpcAx == 5
								//Retorno pendente impede o cadastro
								If cStatus == "2" .Or. cStatOld == "2"
									cMsgRJE 	:= STR0247//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									lRet		:= .F.
								ElseIf cStatOld == "4" .And. (RJ3->RJ3_INI != M->RJ3_INI .Or. RJ3->RJ3_COD != M->RJ3_COD)
									cMsgRJE 	:= STR0263//"Não é permitido alterar a validade ou o código pois o evento já foi transmitido"
									lRet		:= .F.
								//ALTERACAO
								ElseIf nOpcAx == 4 .AND. cStatus <> "2"
									//Evento de exclusão sem transmissão impede o cadastro
									If cOperRJE == "E" .And. cStatus != "4"
										cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
										lRet		:= .F.
									//Não existe na fila, será tratado como inclusão
									ElseIf cStatus == "-1"
										nOpcao 		:= 3
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									//Evento sem transmissão, irá sobrescrever o registro na fila
									ElseIf cStatus $ "1/3"
										If cOperRJE == "A"
											nOpcao 	:= 4
										EndIf
										cOperNew 	:= cOperRJE
										cRetfNew	:= cRetfRJE
										cStatNew	:= "1"
										lNovoRJE	:= .F.
									//Evento diferente de exclusão transmitido, irá gerar uma retificação
									ElseIf cOperRJE != "E" .And. cStatus == "4"
										nOpcao 		:= 4
										cOperNew 	:= "A"
										cRetfNew	:= "2"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									//Evento de exclusão transmitido, será tratado como inclusão
									ElseIf cOperRJE == "E" .And. cStatus == "4"
										nOpcao 		:= 3
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf
								//Exclusão
								ElseIf nOpcAx == 5
									nOpcao 		:= 5
									//Evento de exclusão sem transmissão impede o cadastro
									If cOperRJE == "E" .And. cStatus != "4"
										cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
										lRet		:= .F.
									//Evento diferente de exclusão transmitido irá gerar uma exclusão
									ElseIf cOperRJE != "E" .And. cStatus == "4"
										cOperNew 	:= "E"
										cRetfNew	:= cRetfRJE
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf
								EndIf
							ElseIf nOpcAx == 3
								//Retorno pendente impede o cadastro
								If cStatus == "2"
									cMsgRJE 	:= STR0247//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									lRet		:= .F.
								//Evento de exclusão sem transmissão impede o cadastro
								ElseIf cOperRJE == "E" .And. cStatus != "4"
									cMsgRJE 	:= STR0248//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
									lRet		:= .F.
								//Evento sem transmissão, irá sobrescrever o registro na fila
								ElseIf cStatus $ "1/3"
									nOpcao		:= Iif( cOperRJE == "I", 3, 4 )
									cOperNew 	:= cOperRJE
									cRetfNew	:= cRetfRJE
									cStatNew	:= "1"
									lNovoRJE	:= .F.
								//Evento diferente de exclusão transmitido, irá gerar uma retificação
								ElseIf cOperRJE != "E" .And. cStatus == "4"
									cOperNew 	:= "A"
									cRetfNew	:= "2"
									cStatNew	:=  "1"
									lNovoRJE	:= .T.
								//Será tratado como inclusão
								Else
									cOperNew 	:= "I"
									cRetfNew	:= "1"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								EndIf
							EndIf

							If lRet
								If fCarrLot( cCodLot, cMesAnoP, cTpLot, cLotInsc, cTp2, cInsEsoc, cFPAS, nTerc, cTpInsCo, cNrInsCo, cTpInsPr, cNrInsPr, nOpcao, @aErros, cFilEnv, .F., @cXml, cVersMid, @cRetKey, cTpAmb, oModel)

									aAdd( aDados, { xFilial("RJE", cFilAnt), xFilial("RJ3", cFilAnt), cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1020", cIni, xFilial( "RJ3", cFilAnt ) + M->RJ3_COD, cRetKey, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )

									//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
									If !( nOpcAx == 5 .And. ((cOperRJE == "E" .And. cStatus == "4") .Or. cStatus $ "-1/1/3") )
										If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRecRJE ) )
											cMsgRJE := STR0249//"Ocorreu um erro na gravação do registro na tabela RJE"
										EndIf
									//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
									ElseIf nOpcAx == 5 .And. cStatus != "-1" .And. !(cOperRJE == "E" .And. cStatus == "4")
										If !( lRet := fExcluiRJE( nRecRJE ) )
											cMsgRJE := STR0250//"Ocorreu um erro na exclusão do registro na tabela RJE"
										EndIf
									EndIf
								Else
									lRet := .f.
								EndIf
								If !lRet
									If !lRotProc
										Help(" ", 1, OemToAnsi(STR0045),, cMsgRJE, 1, 0)//"Atenção!"
									Else
										cMsgRotPrc := cMsgRJE
									EndIf
								EndIf
							Else
								If !lRotProc
									Help(" ", 1, OemToAnsi(STR0045),, cMsgRJE, 1, 0)//"Atenção!"
								Else
									cMsgRotPrc := cMsgRJE
								EndIf
							EndIf
						EndIf

						If !lS1000 .And. cEFDAviso != "2"
							lRet := .F.
							cMsgRJE := STR0251//"Problemas com evento S1020"
							Do Case
								Case cStatus == "-1" // nao encontrado na base de dados
									cMsgRJE := STR0252 //"Registro do evento S-1000 não localizado na base de dados"
								Case cStatus == "1" // nao enviado para o governo
									cMsgRJE := STR0253 //"Registro do evento S-1000 não transmitido para o governo"
								Case cStatus == "2" // enviado e aguardando retorno do governo
									cMsgRJE := STR0254 //"Registro do evento S-1000 aguardando retorno do governo"
								Case cStatus == "3" // enviado e retornado com erro
									cMsgRJE := STR0255 //"Registro do evento S-1000 retornado com erro do governo"
							Endcase

							// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
							If cEFDAviso == "0"
								Aviso(OemtoAnsi(STR0045),cMsgRJE,{OemtoAnsi("OK")})//"Atenção!"
							ElseIf cEFDAviso == "1"
								If !lRotProc
									Help(" ", 1, OemToAnsi(STR0045),, cMsgRJE, 1, 0)//"Atenção!"
								Else
									cMsgRotPrc := cMsgRJE
								EndIf
							EndIf
						EndIf
						fPosFil( cEmpAnt, cBkpFil )
					Else
						//------------------------------------------------------------------------------
						//| Realiza a geração do evento S-1020 - Lotações
						//------------------------------------------------------------------------------
						cChaveTAF	:= cCodLot + ";" + cMesAnoP
						nOpcao 	:= fVerExtemp( "S-1020", cChaveTAF, nOpcRJ3, @cStatus, @lContinua)

						If nOpcao == 3 .And. cStatus == "4"
							If !IsBlind()
								Aviso(OemtoAnsi(STR0045),OemtoAnsi(STR0240),{OemtoAnsi("OK")}) //"O registro já existe no TAF, será incluído apenas na tabela do SIGAGPE"
							Endif
							lRet := lContinua
						ElseIf nOpcao > 0
							cFPAS	:= M->RJ3_FPAS
							nTerc	:= M->RJ3_TERC

							If nOpcao == 4 .And. cStatus == "4"
								If !IsBlind()
									Aviso(OemtoAnsi(STR0045),OemtoAnsi(STR0241),{OemtoAnsi("OK")}) //"A Chave dos eventos de tabela é composta pelo código da tabela e a data de início da vigência.  Importante observar que, se informar uma data que já exista fechamento da folha, será necessário reabrir a folha de pagamento (evento S-1298) e retificar os eventos periódicos (S-1200 e S-1210)."
								EndIf
							Endif

							If nOpcao == 5 .And. !(cStatus $ " |0|1|3|4")
								lMsgTaf := .F.
							Else
								lRet := fCarrLot( cCodLot, cMesAnoP, cTpLot, cLotInsc, cTp2, cInsEsoc, cFPAS, nTerc, cTpInsCo, cNrInsCo, cTpInsPr, cNrInsPr, nOpcao, @aErros, cFilEnv, .F., Nil, Nil, Nil, Nil, oModel )
								lMsgTAF := .T.
							Endif
						Else
							lRet := lContinua
						EndIf

						//Exibe mensagem de integração
						If FindFunction("fEFDMsg") .and. lRet .and. lMsgTAF
							fEFDMsg()
						Endif
					EndIf
				EndIf
			Else
				If !IsBlind()
					If !lMiddleware
						Aviso(OemtoAnsi(STR0045),OemtoAnsi(STR0239),{OemtoAnsi("OK")})//"Atencao"##"Para que este registro possa ser integrado com o TAF, você deve informar o campo RJ3_TPLOT e suas respectivas parametrizações. O Registro será salvo mas não integrado."
					Else
						Aviso(OemtoAnsi(STR0045),OemtoAnsi(STR0264),{OemtoAnsi("OK")})//"Atencao"##"Para que este registro possa ser integrado com o Middleware, você deve informar o campo RJ3_TPLOT e suas respectivas parametrizações. O Registro será salvo mas não integrado."
					EndIf
				Endif
			EndIf
		EndIf
		If !lRet
			cMsg:= IIF(LEN(aErros)>0, aErros[1],cMsg)
			//-------------------------------
			//| Cenários:
			//| Se for 0: Ele avisa do erro e segue mesmo assim (Salva RJ3 e Não TAF)
			//| Se for 1, ele avisa do erro e bloqueia o cadastro de tudo (Não RJ3 e Não TAF)
			//| Se for 2, ele não avisa nada (Se tiver erro, salva só RJ3 / Se não tiver, salva RJ3 + TAF)
			//---------------------------------------------------------------------------------------------
			lRet := cEFDAviso $ "0|2"
			If cEFDAviso <> "2"
				If cEFDAviso == "0" .AND. !Empty(cMsg)
					cMsg += CRLF + OemToAnsi(STR0189)//"E de acordo com o valor do parâmetro MV_EFDAVIS"
					If !lMiddleware
						cMsg += CRLF + OemToAnsi(STR0187) //"O Registro será salvo mas não integrado com o TAF. Para corrigir, volte alterando o registro e informe os campos necessários."
					Else
						cMsg += CRLF + OemToAnsi(STR0265) //"O Registro será salvo mas não integrado com o Middleware. Para corrigir, volte alterando o registro e informe os campos necessários."
					EndIf
				ElseIf cEFDAviso == "1" .AND. !Empty(cMsg)
					cMsg += CRLF + OemToAnsi(STR0189) //"E de acordo com o valor do parâmetro MV_EFDAVIS"
					If !lMiddleware
						cMsg += CRLF + OemToAnsi(STR0188) //"O Registro não será salvo e nem integrado com o TAF. Corrija os campos informados para prosseguir com o cadastro."
					Else
						cMsg += CRLF + OemToAnsi(STR0266) //"O Registro não será salvo e nem integrado com o Middleware. Corrija os campos informados para prosseguir com o cadastro."
					EndIf
				EndIf

				If !Empty(cMsg)
					If !lRotProc
						MsgInfo(cMsg,OemToAnsi(STR0045)) //"Atenção!"
					Else
						cMsgRotPrc := cMsg
					EndIf
				EndIf
			EndIf
		EndIf
	Endif

Return lRet

/*/{Protheus.doc} fWhenTSV
Função para ativar o preenchimento dos campos RA_TIPOAFP e RA_DECRLEI
@type      	Function
@author   	Claudinei Soares
@since		23/05/2019
@version	1.0
@return		lRetWhen,	logic,	Retorno da função
/*/
Function fWhenTSV()
Local aArea			:= GetArea()
Local lRetWhen		:= .F.
Local cVersenvio	:= ""
Local cTSV			:= fCatTrabEFD("TSV") //"701|711|712|712|721|722|723|731|734|738|741|751|761|771|781|"

fVersEsoc("S2300", .T.,/**/,/**/,@cVersEnvio)

If cVersEnvio >= "2.6.00"
	lRetWhen := (M->RA_CATEFD $ cTSV)
Endif

RestArea(aArea)

Return lRetWhen


/*/{Protheus.doc} fConsIRRF()
Função para definição de qual consulta padrão ativar para o campo RV_INCIRF
@type      	Function
@author   	Claudinei Soares
@since		28/05/2019
@version	1.0
@return		lRetWhen,	logic,	Retorno da função
/*/
Function fConsIRRF()
Local aArea			:= GetArea()
Local lRet			:= .T.
Local cVersenvio	:= ""

fVersEsoc("S1010", .T.,/**/,/**/,@cVersEnvio)

If cVersEnvio >= "2.6.00"
	GP310SXB('S134','CODINC')
Else
	fRetOpcGPE('RV_INCIRF')
Endif

RestArea(aArea)

Return lRet

/*/{Protheus.doc} fRetTpIRF()
Função que retorna o tipo de incidência IRRF de acordo com o código da incidência através de busca na tabela S134
@type      	Function
@author   	Allyson
@since		29/05/2019
@version	1.0
@return		lRetWhen,	logic,	Retorno da função
/*/
Function fRetTpIRF( cCodIncIrf )
Local aArea			:= GetArea()
Local cTpIRF		:= ""
Local cVersenvio	:= ""
Local nPos134		:= 0

Default cCodIncIrf	:= ""

fVersEsoc("S2300", .T.,/**/,/**/,@cVersEnvio)

If cVersEnvio >= "2.6.00"
	If Empty(aTabS134)
		fCarrTab( @aTabS134, "S134", dDataBase, .T. )
	EndIf
	If !Empty(aTabS134) .And. (( nPos134 := aScan(aTabS134, {|x| x[5] == cCodIncIrf }) ) > 0)
		cTpIRF := aTabS134[nPos134, 7]
	EndIf
Endif

RestArea(aArea)

Return cTpIRF

/*/{Protheus.doc} FVCMU()
Função que trata a chamada do gatilho RA_CODMUNE
Para exibir corretamente o nome do municipio na SRA
@type      	Function
@author   	Wesley Alves Pereira
@since		01/09/2020
@version	1.0
@return		lRetorno (.T. ou .F. Para chamar o gatilho)
/*/

Function FVCMU()

Local lRetorno := .T.

Return (lRetorno)



/*/{Protheus.doc} SRAMOTFUN()
Função que monta uma consulta especifica para ser utilizada no cadastro de funcionários
@type      	Function
@author   	Wesley Alves Pereira
@since		10/09/2020
@version	1.0
@return		lRetorno
/*/

Function SRAMOTFUN()

	Local i,j
	Local nOpca		:= 0
	Local nInd		:= 0
	Local cChave	:= Space(255)
	local oOrdem
	Local oChave
	Local oTmpTbl1
	Local cAreaSRA := SRA->(GetArea())

	Private oLbx,oDlg2
	Private cOrdIx
	Private nOrdem 	 := 1
	Private aIndices := {}
	Private cTRB 	 := GetNextAlias()

	Static cMatFunRet := ""

	aDbf := {{"CODMAT"  , "C", 06, 0},;
			 {"NOME"    , "C", 30, 0}}

	//Instancia classe FWTemporaryTable
	oTmpTbl1 := FWTemporaryTable():New( cTRB, aDbf )
	//Cria indices
	oTmpTbl1:AddIndex( "Ind01" , {"CODMAT"}  )
	oTmpTbl1:AddIndex( "Ind02" , {"NOME"}  )
	//Cria a tabela temporaria
	oTmpTbl1:Create()

	cAliasQry := GetNextAlias()
	cQuery := " SELECT RA_MAT, RA_NOME "
	cQuery += " FROM " + RetSqlName("SRA")
	cQuery += " WHERE RA_DEMISSA = ' ' "
	cQuery += " AND   RA_FILIAL  = '"+xFilial("SRA") +"'"
	cQuery += " AND   D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY RA_MAT "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea((cAliasQry))
	dbGoTop()
	While !Eof()
		DbSelectArea(cTRB)
		RecLock((cTRB),.T.)
		(cTRB)->CODMAT := (cAliasQry)->RA_MAT
		(cTRB)->NOME   := (cAliasQry)->RA_NOME
		MsUnlock(cTRB)
		DbSelectArea((cAliasQry))
		DbSkip()
	EndDo
	(cAliasQry)->(DbCloseArea())

	cLine	:= "{ || { "
	i		:= 0
	aAux	:= {}
	aLbx	:= {}

	// Monta os dados do listbox
	dbSelectArea(cTRB)
	aFields := DbStruct()
	aCabec  := {STR0377,STR0378} //"Matrícula"###"Nome"

	dbGotop()
	While !Eof()
		aAux := Array(Len(aFields))
		For j := 1 to Len(aFields)
			aAux[j] := &(aFields[j][1])
		Next j
		Aadd(aLbx,aAux)
		dbSkip()
	End

	// Define o numero de colunas do listbox
	For i:=1 To Len(aDbf)
		If aDbf[i][2] == "D"
			cLine+= "DtoC(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
		ElseIf aDbf[i][2] == "N"
			cLine+= "Str(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
		Else
			cLine+= "aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"]"
		EndIf
		If i#Len(aDbf)
			cLine+=","
		Else
			cLine+="}"
		EndIf
	Next i

	cLine+= "}"
	nGuarda := 1
	nOrdem  := 1

	aAdd(aIndices,STR0377) //"Matrícula"
	aAdd(aIndices,STR0378) //"Nome"

	Define MsDialog oDlg2 Title STR0379 From 000,000 To 421,522 Pixel //"Funcionários"

	@ 005, 005 combobox oOrdem var cOrdIx items aIndices size 210,08 PIXEL OF oDlg2 ON CHANGE nOrdem := oOrdem:nAt
	@ 020, 005 msget oChave var cChave size 210,08 of oDlg2 pixel
	@ 005, 220 Button STR0380 of oDlg2 Size 40,10 Pixel Action SRAPEQFUN(cChave) //"&Pesquisar"

	oLbx:= TWBrowse():New(3,0,263,149,,aCabec,, oDlg2,,,,,,,,,,,, .F.,, .F.,, .F.,,, )

	oLbx:SetArray(aLbx)
	bLbxLine := { || { Space(Len(SRA->RA_MAT)), Space( 40 ) } }
	IIF(Len(aLbx)>0,oLbx:bLine:= &(cline),oLbx:bLine:= bLbxLine)
	oLbx:nAt   := nGuarda
	oLbx:bLDblClick := {|| (nOpcA := 1,nGuarda:=oLbx:nAt,oDlg2:End()) }

	Define sButton oBtOk  from 195, 05 type 1 action (nOpcA := 1,nGuarda := oLbx:nAt, oDlg2:End()) enable of oDlg2 pixel
	Define sButton oBtCan from 195, 36 type 2 action (nOpcA := 0, oDlg2:End()) enable of oDlg2 pixel

	ACTIVATE MSDIALOG oDlg2 CENTERED

	If nOpca == 1
		If ( Len(aLbx) > 0)
			DbSelectArea("SRA")
			DbSetOrder(1)
			If ( DbSeek(xFilial("SRA")+aLbx[nGuarda][1]))
				cMatFunRet := SRA->RA_MAT
			EndIf
		EndIf
	EndIf

	oTmpTbl1:Delete()//Deleta Arquivo temporario 1

	RestArea(cAreaSRA)

Return .T.

/*/{Protheus.doc} SRARETFUN()
Retorno da consulta especifica para ser utilizada no cadastro de funcionários
@type      	Function
@author   	Wesley Alves Pereira
@since		10/09/2020
@version	1.0
@return		cRetorno
/*/

Function SRARETFUN()
Local cRetorno := ""

If ValType( cMatFunRet ) == "C"
	cRetorno := cMatFunRet
EndIf

Return cRetorno

/*/{Protheus.doc} SRAPEQFUN()
Pesquisa da consulta especifica para ser utilizada no cadastro de funcionários
@type      	Function
@author   	Wesley Alves Pereira
@since		10/09/2020
@version	1.0
@return		.T.
/*/

Static Function SRAPEQFUN(cCHPesq)

	Local cSeek

	dbSelectArea(cTRB)
	dbSetOrder(If(aIndices[1]=cOrdIx,1,2))
	cSeek := If(aIndices[1]=cOrdIx,SubStr(cCHPesq,1,6),Upper(SubStr(cCHPesq,1,30)))
	dbSeek(cSeek,.t.)

	If !Eof()
		nOrdem := Recno()
	ElseIf Eof()
		nOrdem := Len(aLbx)
	Endif

	oLbx:SetFocus(aLbx[nOrdem])

	oLbx:nAt   := nOrdem
	oLbx:bLine := &(cline)

Return .T.

/*/{Protheus.doc} ESocMsgVer
	Realiza a apresentação padronizada das mensagens quando verificada divergência de versões do eSocial
	@type  Function
	@author martins.marcio
	@since 06/05/2021
	@version version
	@param lImpeditiv, logico, informa se a divergência impede o processo (opcional)
	@param cEvento, caracter, evento do eSocial que está sendo gerado (opcional)
	@param cVersGPE, caracter, versão do GPE (opcional)
	@param cVerTaf, caracter, versão do TAF (opcional)
	@return lContinua, logico, indica se o processo deve continuar ou deve ser abortado
	/*/
Function ESocMsgVer(lImpeditiv, cEvento, cVersGPE, cVerTaf)

	Local lContinua := .T. // Retorna se deve continuar ou abortar o processo

	Default lImpeditiv 	:= .F.
	Default cEvento 	:= ""
	Default cVersGPE	:= ""
	Default cVerTaf		:= ""

	If Empty(cVersGPE) .Or. Empty(cVerTaf)
		cVersGPE := GetNewPar("MV_VLESOC", "02_05_00")
		cVerTaf	 := GetNewPar("MV_TAFVLES", "02_05_00")
	Else
		cVersGPE := VersToMsg(cVersGPE)
		cVerTaf	 := VersToMsg(cVerTaf)
	EndIf

	If cVersGPE <> cVerTaf
		If lImpeditiv
			//# "Atenção! # A versão do leiaute GPE é XXX e a do TAF é XXXX, sendo assim, estão divergentes. A rotina será encerrada"
			Help( ,, OemToAnsi(STR0045) ,, OemToAnsi(STR0406 + cVersGPE + STR0407 + cVerTaf + STR0411), 1, 0 )
			lContinua := .F.
		Else
			If !IsBlind()
				//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento xxx não será integrado com o TAF, e consequentemente, não será enviado ao RET.
				//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"
				If MsgNoYes( OemToAnsi(STR0406 + cVersGPE + STR0407 + cVerTaf + STR0408 + cEvento + STR0409 + CRLF + STR0410), OemtoAnsi(STR0045) )
					lContinua := .T.
				Else
					lContinua := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lContinua

/*/{Protheus.doc} VersToMsg
	Função que adapta/padroniza a versão do eSocial para mensagens ao usuário final
	@type  Function
	@author martins.marcio
	@since 06/05/2021
	@version version
	@param cVersEsoc, caracter, versão a ser verificada
	@return cVersEsoc, caracter, versão adaptada para o usuario
	/*/
Function VersToMsg(cVersEsoc)

	Default cVersEsoc := ""

	cVersEsoc := StrTran( cVersEsoc, ".", "_")
	cVersEsoc := StrTran( cVersEsoc, "9_0_00", "S_01_00_00")
	cVersEsoc := StrTran( cVersEsoc, "9_0", "S_01_00_00")

Return cVersEsoc

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDivergTaf
Função genérica que verifica se existe divergencia entre as versões do GPExTAF

@author  martins.marcio
@since   13/05/2021
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fDivergTaf()

Local lDivergTAF := .F.
Local cVersEnvio := ""
Local cVersGPE := ""

If lIntTaf .And. !lMiddleware
	fVersEsoc(/*cEvento*/, .F.,,, @cVersEnvio, @cVersGPE)
	If cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
		lDivergTAF := .T.
	EndIf
EndIf

Return lDivergTAF
