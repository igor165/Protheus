#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"

Static __afCatEfd__
Static lParcial		:= .F.
Static lVerRJ5 		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .F.) .And. !lParcial)
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lCposRGEOk	:= (RGE->(ColumnPos("RGE_COD")) > 0 .And. RGE->(ColumnPos("RGE_SALRED")) > 0 .And. RGE->(ColumnPos("RGE_PERC")) > 0)
Static lRGEStat		:= RGE->(ColumnPos("RGE_STATUS")) > 0
Static lRGEDtAlt	:= RGE->(ColumnPos("RGE_DTALT")) > 0
Static cUltFilRGE	:= "cUltFilRGE"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ GPEM026A ≥ Autor ≥ Christiane Vieira                           ≥ Data ≥ 13/11/2015 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Rotina de Envio de Eventos - Relacionados ao funcion·rio                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ GPEM026A()                                                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥                ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista     ≥ Data     ≥ FNC/Requisito  ≥ Chamado ≥  Motivo da Alteracao                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Christiane V.≥01/12/2015|                ≥TTTT69   ≥Integracao do registro S-2190 com o TAF    ≥±±
±±≥Christiane V.≥08/12/2015|                ≥TTTTA0   ≥Integracao do registro S-2200 com o TAF    ≥±±
±±≥Marcia Moura ≥23/06/2016|                ≥TVKVQ0   ≥Integracao registro S2200 com o TAF 2.2.3  ≥±±
±±≥Marcia Moura ≥09/08/2016≥                ≥TVMRZU   ≥Geracao do registro S2205 leiaute 2.2.3    ≥±±
±±≥Marcia Moura  ≥19/08/2016≥               ≥TVMRZU   ≥Utilizacao do codigo unico do SRA para     ≥±±
±±≥              ≥          ≥               ≥         ≥identificacao do funcionario no TAf        ≥±±
±±≥Marcia Moura  ≥26/08/2016≥               ≥TVMRZU   ≥Tratamento para o Novo Status da TafGetStat≥±±
±±≥              ≥          ≥               ≥         ≥-1, que significa registro n„o encontrado  ≥±±
±±≥              ≥          ≥               ≥         ≥apenas para recompilar o fonte             ≥±±
±±≥Marcia Moura  ≥27/09/2016≥               ≥TVUUFA   ≥Inclusao do controle geracao S-2206        ≥±±
±±≥Marcia Moura≥27/04/2017≥DRHESOCP-38     ≥Integracao do TAF - registro s2200					  ≥±±
±±≥Marcia Moura≥08/05/2017≥DRHESOCP-40     ≥Integracao do TAF - registro s2205                    ≥±±
±±≥Marcos Cout ≥09/05/2017≥DRHESOCP-225     ≥          ≥Realizar a geraÁ„o do evento S-2300       ≥±±
±±≥            ≥          ≥                 ≥          ≥CompatibilizaÁ„o do eSocial layout 2.2.01 ≥±±
±±≥Marcia Moura≥10/05/2017≥DRHESOCP-985     ≥          ≥Realizar a geraÁ„o do evento S-2206       ≥±±
±±≥Marcos Cout.|11/05/2017|DRHESOCP-237     |          |Realizar a geraÁ„o do evento S-2300       *±±
±±≥            |          |                 |          |para o Cadastro de Dependentes (GPEA020)  ≥±±
±±≥Marcos Cout.|12/05/2017|DRHESOCP-249     |          |Realizar a geraÁ„o do evento S-2306       *±±
±±≥            |          |                 |          |para o Cad. Funcionario e Cad. Autonomo   ≥±±
±±≥Eduardo Vic |12/05/2017|DRHESOCP-224     |          |Inclus„o de Chamada de FunÁ„o para buscade*±±
±±≥            |          |                 |          |salario                                   ≥±±
±±≥Marcos Cout |29/05/2017|DRHESOCP-308     |          |Realizado ajustes para trazer os dados da *±±
±±≥            |          |                 |          |variavel de memoria do sistema (S-2190)   ≥±±
±±≥Marcos Cout |12/06/2017|DRHESOCP-384	    |          |WAR ROOM (1a Semana) + Merge              ≥±±
±±≥            |          |                 |          |Realizado ajuste no TSV e TCV: Esta envi_ *±±
±±≥            |          |                 |          |ando TAG de estrangeiro mesmo se for BR   ≥±±
±±≥            |          |                 |          |Ajustado pesquisa do nPagoFixo e aPagoFixo≥±±
±±≥Oswaldo L   |13/06/2017|DRHESOCP-400     |          |Evita msg de alerta no loop do GPEM036    ≥±±
±±≥Oswaldo L   |13/06/2017|DRHESOCP-447     |          |Ajuste do teste da funÁ„o na pilha S1200  ≥±±
±±≥Marcos Cout |21/06/2017|DRHESOCP-458     |          |Realizar ajustes diversos na geraÁ„o do   ≥±±
±±≥            |          |                 |          |evento S2300 - Trab Sem Vinculo           ≥±±
±±≥MArcia Moura≥23/06/2017≥DRHESOCP-470     ≥         ≥Inclusao de novos campos para temporario   ≥±±
±±≥Marcos Cout |20/07/2017|DRHESOCP-403     |          |Realizar ajustes diversos na geraÁ„o do   ≥±±
±±≥            |          |                 |          |evento S2300, S2205 e S2306               ≥±±
±±≥Oswaldo L   |19/07/2017|DRHESOCP- 635    |          |Ajuste do DE\PARA da tabela de dependente ≥±±
±±≥            |          |                 |          |do e-Social para o protheus               ≥±±
±±≥Oswaldo L   |19/07/2017|DRHESOCP- 635    |          |CorreÁ„o de convers„o de datas\tipos      ≥±±
±±≥Oswaldo L   |19/07/2017|DRHESOCP- 646    |          |Exclusao de todos ependentes de uma so vez≥±±
±±≥            |          |                 |          |Gerar tipo 08 da tabela de depend do TAF  ≥±±
±±≥Oswaldo L   |27-07-17  |DRHESOCP-699     |          |Unificar opÁıes da Tag undSalFixo         ≥±±
±±≥Oswaldo L   |27-07-17  | DRHESOCP-592    |          |Unificar a lista de opÁıes da Tag         ≥±±
±±≥            |          | SubTask 709     |          |<estCiv>                                  ≥±±
±±≥Eduardo Vic |02/08/2017|DRHESOCP-744     |          |Ajustes na chamada da FunÁ„o fGp23Cons	  ≥±±
±±|Claudinei S.|04/08/2017|DRHESOCP-749 \ DRHESOCP-649 |Ajuste em fIntAdmiss() para levar no XML  |±±
±±|            |          |                 |          |os campos RA_CASADRB E RA_FILHOBR com S/N |±±
±±|            |          |                 |          |e n„o 1 ou 2, conforme o leiaute 2205.    |±±
±±≥Eduardo Vic |07/08/2017|DRHESOCP-773     |          |Ajustes nas condicionais de envio de turno≥±±
±±≥            |          |                 |          |Inclus„o de condiÁ„o para Sindicato       ≥±±
±±≥Oswaldo L   |07/08/2017|DRHESOCP-755     |          |Merge entre vers„o 11.80 e 12.1.17        ≥±±
±±≥Eduardo V   |11/08/2017|DRHESOCP-781     |          |CorreÁıes de erros apontadas a issue 592  ≥±±
±±≥Eduardo V   |15/08/2017|DRHESOCP-878     |          |Inclus„o de tratativa para envio de turno ≥±±
±±≥Eduardo V   |21/08/2017|DRHESOCP-899     |          |Trat. no campo RA_TPCONTR, onde em caso do≥±±
±±≥Eduardo V   |          |                 |          |mesmo esteja vazio,preencher com "1" oxml.≥±±
±±≥Marcos Cout |29/08/2017|DRHESOCP-708     |          |Realizar a tratativa da TAG <estCiv> para ≥±±
±±≥            |          |                 |          |tratar a estado "Uni„o Estavel"           ≥±±
±±≥CecÌlia C.  |04/09/2017|DRHESOCP-1009    |          |Ajuste para layou 2.3 - S-2200, s-2205,   ≥±±
±±≥            |          |                 |          |S-2300.                                   ≥±±
±±≥Eduardo V.  |08/09/2017|DRHESOCP-1061    |          |Tratativa de campos para novo layout 2.3  ≥±±
±±≥Eduardo V.  |08/09/2017|DRHESOCP-1074    |          |Ajuste da Variavel cTurno				  ≥±±
±±≥Eduardo V.  |08/09/2017|DRHESOCP-1075    |          |CriaÁ„o de funÁ„o para tratar Tpde depend.≥±±
±±|Marcos Cout.|08/09/2017|DRHESOCP-887     |          |UnificaÁ„o das rotinas de integraÁ„o dos  |±±
±±|            |          |                 |          |trabalhadores. Ajustada rotina fintAdmiss |±±
±±≥Eduardo V.  |08/09/2017|DRHESOCP-1080    |          |Ajustes de variaveis com problema de decl.≥±±
±±≥Eduardo V.  |08/09/2017|DRHESOCP-1085/1082 |        |Inclus„o de tratativa de campo de salario.≥±±
±±|Claudinei S.|11/09/2017|DRHESOCP-729     |          |Leiaute 2.3, ajuste em fIntAdmiss e       |±±
±±|            |          |                 |          |fInt2206 adequaÁ„o do XML para os funcio- |±±
±±|            |          |                 |          |n·rios tempor·rios, tabelas RBW e SGW.    |±±
±±|Marcos Cout.|14/09/2017|DRHESOCP-1018    |          |Ajustes de consistencias de eventos diver_|±±
±±|            |          |                 |          |sos                                       |±±
±±≥Marcos Cout |15/09/2017|DRHESOCP-1117    |          |Realizar ajustes necess·rios para que o   ≥±±
±±≥            |          |                 |          |cÛdigo unico do trabalhador seja enviado  ≥±±
±±≥            |          |                 |          |para um trabalhador que ja tenha tido o   ≥±±
±±≥            |          |                 |          |evento S-2190 gerado previamente.         ≥±±
±±≥Renan Borges|15/09/2017|DRHESOCP-922     |          |Ajuste para enviar incapacidade do depen- ≥±±
±±≥            |          |                 |          |dente corretamente.                       ≥±±
±±|Claudinei S.|21/09/2017|DRHESOCP-1039    |          |Ajuste na tab codCargo para que envie     |±±
±±|            |          |                 |          |a filial correta no XML.                  |±±
±±|Marcos Cout |29/09/2017| DRHESOCP-1372   |          |Realizando ajustes para o evento S-2306   |±±
±±|            |          |                 |          |CriaÁ„o de variaveis n„o declaradas. Ajus_|±±
±±|            |          |                 |          |tado posiÁ„o de inicializ da var dDataRefP|±±
±±|            |          |                 |          |Ajuste de consistÍncia no prog fIncPreAd  |±±
±±|Cecilia C.  |24/10/2017|DRHESOCP-1592    |          |Ajuste para leiaute 2.4 na geraÁ„o da tag |±±
±±|            |          |                 |          |<tmpPar> dos eventos S-2200 e A-2206.     |±±
±±|Marcos Cout |27/10/2017|DRHESOCP-1728    |          |Realizado ajustes necess·rios para q seja |±±
±±|            |          |                 |          |gerado o XML contendo os dados do estagia_|±±
±±|            |          |                 |          |rio corretamente. Corrigido as chamadas em|±±
±±|            |          |                 |          |diversos pontos da funÁ„o MSGALERT, subs_ |±±
±±|            |          |                 |          |titui por HELP. Ajustes diversos no fote  |±±
±±|            |          |                 |          |Adicionada as regras para geracao do XML  |±±
±±|            |          |                 |          |de apoio baseado no MV_EFD                |±±
±±|Cecilia C.  |30/10/2017|DRHESOCP-1764    |          |Ajuste para gerar as TAG's referentes a   |±±
±±|            |          |                 |          |cargo e remuneraÁ„o somente para as catego|±±
±±|            |          |                 |          |rias 201,202,305,721,722,731,734,738 e 731|±±
±±|            |          |                 |          |dos eventos S-2300 e S-2306.              |±±
±±|Cecilia C.  |01/11/2017|DRHESOCP-1766    |          |Ajuste para leiautes 2.3 e 2.4 na geraÁ„o |±±
±±|            |          |                 |          |da tag <localTrabGeral> dos eventos S-2200|±±
±±|            |          |                 |          |e S-2206.                                 |±±
±±|Cecilia C.  |06/11/2017|DRHESOCP-1802    |          |Ajuste para leiaute 2.4 na geraÁ„o da tag |±±
±±|            |          |                 |          |<sucessaoVinc> do evento S-2200, tag      |±±
±±|            |          |                 |          |<tpRegTrab> do S-2206.                    |±±
±±|Eduardo Vi. |06/11/2017|DRHESOCP-2204    |          |Inclus„o de tags para trabalhador sem vinc|±±
±±|            |          |                 |          |ulo, atÈ ent„o sÛ existiam no evento S2200|±±
±±|Marcos Cout |12/12/2017|DRHESOCP-2201    |          |Realizando ajustes para gerar as TAGS de  |±±
±±|            |          |                 |          |trabalhador estatut·rio no evento S2200 e |±±
±±|            |          |                 |          |S2206 dentro da fIntAdmiss                |±±
±±|Eduardo V.  |13/12/2017≥  DRHESOCP-2213  ≥          |Inclus„o de carga inicial do evento 2300  |±±
±±≥Marcos Cout |28/12/2017| DRHESOCP-2631              |Realizado criaÁ„o da opÁ„o d carga inicial≥±±
±±≥            |          |                            |do evento S-1040 - Cargos/FunÁıes Comissio≥±±
±±≥            |          |                            |nados. Ajustes na funÁ„o para gerar XML.  ≥±±
±±≥            |          |                            |Ajuste no evento S-2200 qnd trabalhador   ≥±±
±±≥            |          |                            |tiver cargo comissionado                  ≥±±
±±|Eduardo K.  |09/01/2018|MPRIMESP-13146   |          |Ajuste nas chamadas da funÁ„o STOD.		  |±±
±±≥Jo„o Balbino|24/01/2018|                            |Ajuste para geraÁ„o informaÁıes de turno do≥±±
±±≥            |          |                            |funcion·rio - evento S-2200 para que respei≥±±
±±≥            |          |                            |te as opÁıs do cadastro de turno.          ≥±±
±±≥CecÌlia Carv|31/01/2018|DRHESOCP-2687    |          |Ajuste na gravaÁ„o das tag's <ideTabRubr>  ≥±±
±±≥            |          |DRHESOCP-2220    |          |(DRHESOCP-2687) e <ideDmDev> (DRHESOCP-    ≥±±
±±≥            |          |                 |          |2220) do evento S-2299.                    ≥±±
±±≥Marcos Cout.|07/02/2018|DRHESOCP-2952               |Realizado ajustes para gerar corretamente ≥±±
±±≥            |          |                            |tag <undSalFixo>. Retirada variaveis lixos≥±±
±±≥            |          |                            |ou sem uso no fonte                       ≥±±
±±≥Marcos Cout.|09/02/2018|DRHESOCP-2924               |Realizado ajustes para geraÁ„o da TAG de  ≥±±
±±≥            |          |                            |dependente incapaz                        ≥±±
±±≥Eduardo Vice|15/02/2018|DRHESOCP-3051			   |Inclus„o de nova funcionalida para envio  ≥±±
±±≥            |          |                            |das observaÁıes contratuais e retificaÁ„o ≥±±
±±≥CecÌlia Carv|15/02/2018|DRHESOCP-2493    |          |ImplementaÁ„o do campo RBW_LOCT para gerar≥±±
±±≥            |          |                 |          |dados na tag <localTrabDom> - eventos     ≥±±
±±≥            |          |                 |          |S-2200/S-2206.                            ≥±±
±±≥Eduardo Vice|02/03/2018|DRHESOCP-3369	  |          |Tratativa do In na query de funcionarios  ≥±±
±±≥CecÌlia Carv|02/03/2018|DRHESOCP-3361    |          |Ajuste na geraÁ„o dos cÛdigos de funÁ„o,  ≥±±
±±≥            |          |                 |          |cargo, carreira p˙blica e turno dos even- ≥±±
±±≥            |          |                 |          |tos S-2200/S-2206.                        ≥±±
±±≥Marcia Moura|05/03/2018|DRHESOCP-3392    |          |Carga Incorreta para os casos de Tab de   ≥±±
±±≥            |          |                 |          |horario e funcao exclusiva                ≥±±
±±≥Eduardo Vice|07/03/2018|DRHESOCP-3441	|          |Inclus„o de tratativa com param MV_DTCGINI≥±±
±±≥Marcos Cout.|09/03/2018|DRHESOCP-3503               |Realizando ajuste na TAG <Aprend> quando o≥±±
±±≥            |          |                            |CATEFD È igual a "103"                    ≥±±
±±≥Marcia Moura|14/03/2018|DRHESOCP-3427               |Gravar corretamente a quantidade de horas ≥±±
±±≥Eduardo Vic.|24/03/2018|DRHESOCP3741				   |CORRE«√O DE GERA«√O DE S-2206			  ≥±±
±±≥Cecilia Car.|17/04/2018|DRHESCOP-4061               |Ajuste ajuste para integrar na filial do  ≥±±
±±≥            |          |                            |funcion·rio e n„o na filail logada, quando≥±±
±±≥            |          |                            | a configuraÁ„o de empresas È 1x1.        ≥±±
±±≥Cecilia Car.|09/05/2018|DRHESCOP-4658               |Ajuste para n„o gerar a tag <vlrBolsa> qdo≥±±
±±≥            |          |                            |for est·gio sem remuneraÁ„o e tratar a tag≥±±
±±≥            |          |                            |<CadIni> do evento S-2300.                ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fIncPreAd   ∫Autor  ≥Christiane Vieira   ∫ Data ≥  02/12/15 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Registro Preliminar de Admiss„o                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEM026-                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fIncPreAd(cCodUnico)

	Local cXml 		:= ""
	Local cFilEnv	:= ""
	Local aErros	:= {}
	Local aFilInTaf := {}
	Local aArrayFil := {}
	Local lGravou	:= .T.
	Local lIntegra	:= .T.
	Local cVersEnvio:= ""

	Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)
	Local cBkpFil	 	:= cFilAnt
	Local cVersMw	 	:= ""
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cChave	 	:= ""
	Local cStatus	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= Space(6)
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cStatRJE	 	:= "-1"
	Local cOper2190	 	:= "I"
	Local cRecib2190 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2190	 	:= "1"
	Local cStat2190	 	:= "-1"
	Local nRec2190   	:= 0
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local cPgtoTrab		:= ""
	Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo (TCV)

	Default cCodUnico	:= (cAliasSRA)->RA_CODUNIC

	lIntegra	:= Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2190", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, Nil, @cVersMw ), .T.)
	cVersEnvio	:= Iif( Empty(cVersEnvio), "2.2",cVersEnvio)
	cPgtoTrab	:= fGetTpPagto(M->RA_TIPOPGT, M->RA_CATFUNC, fGetValCpo( "RA_SALARIO" ) )

	If !lMiddleware .And. !lIntegra
		Aviso(OemToAnsi(STR0001), OemToAnsi(STR0037), {OemToAnsi(STR0038)}) //"Atencao"##"A vers„o do TAF est· desatualizada, n„o ser· possivel efetuar o envio dos eventos."##"Ok"
		Return lIntegra //.F.

	ElseIf lMiddleware .And. !lIntegra
		Aviso(OemToAnsi(STR0001), OemToAnsi(STR0158), {OemToAnsi(STR0038)}) //"Atencao"##"A vers„o do Middleware est· desatualizada, n„o ser· possivel efetuar o envio dos eventos."##"Ok"
		Return lIntegra //.F.
	EndIf

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	EndIf

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	If lMiddleware
		fPosFil( cEmpAnt, cFilAnt )
		lS1000 := fVld1000( AnoMes(M->RA_ADMISSA), @cStatus )
		If !lS1000 .And. cEFDAviso != "2"
			Do Case
				Case cStatus == "-1" // nao encontrado na base de dados
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
						lGravou	:= .F.
					Else
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX n„o localizado na base de dados"
					EndIf
				Case cStatus == "1" // nao enviado para o governo
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
						lGravou	:= .F.
					Else
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX n„o transmitido para o governo"
					EndIf
				Case cStatus == "2" // enviado e aguardando retorno do governo
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
						lGravou	:= .F.
					Else
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
					EndIf
				Case cStatus == "3" // enviado e retornado com erro
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
						lGravou	:= .F.
					Else
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
					EndIf
			EndCase
		EndIf

		aInfos   := fXMLInfos()
		IF Len(aInfos) >= 4
			cTpInsc  := aInfos[1]
			lAdmPubl := aInfos[4]
			cNrInsc  := aInfos[2]
			cId  	 := aInfos[3]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
		EndIf

		cChaveS2190	:= AllTrim( M->RA_CIC ) + DTOS( M->RA_ADMISSA )
		cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2190" + Padr(cChaveS2190, fTamRJEKey(), " ")
		cStat2190 	:= "-1"
		GetInfRJE( 2, cChaveBus, @cStat2190, @cOper2190, @cRetf2190, @nRec2190, @cRecib2190, @cRecibAnt )

		//Retorno pendente impede o cadastro
		If cStat2190 == "2" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
		//Evento de exclus„o sem transmiss„o impede o cadastro
		ElseIf cOper2190 == "E" .And. cStat2190 != "4" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
		//Evento sem transmiss„o, ir· sobrescrever o registro na fila
		ElseIf cStat2190 $ "1/3"
			cOperNew 	:= cOper2190
			cRetfNew	:= cRetf2190
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
		ElseIf cOper2190 != "E" .And. cStat2190 == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:=  "1"
			lNovoRJE	:= .T.
		//Ser· tratado como inclus„o
		Else
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		If !Empty(cMsgRJE)
			Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" n„o enviado(a) ao Middleware. Erro: "
			lGravou := .F.
		EndIf
		If cRetfNew == "2"
			If cStat2190 == "4"
				cRecibXML 	:= cRecib2190
				cRecibAnt	:= cRecib2190
				cRecib2190	:= ""
			Else
				cRecibXML 	:= cRecibAnt
			EndIf
		EndIf
		aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2190", Space(6), cChaveS2190, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2190, cRecibAnt } )

		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtAdmPrelim/v" + cVersMw + "'>"
		cXML += 	"<evtAdmPrelim Id='" + cId + "'>"
		fXMLIdEve( @cXML, { Nil, NIL, Nil, Nil, 1, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		cXml += '<eSocial>'
		cXml += '	<evtAdmPrelim>'
	EndIf
	cXml += '		<infoRegPrelim>'
	cXml += '			<cpfTrab>'    	+ M->RA_CIC				+ '</cpfTrab>'
	If !lMiddleware
		cXml += '			<dtNascto>' 	+ dTOS(M->RA_NASC)		+ '</dtNascto>'
		cXml += '			<dtAdm>'		+ dTOS(M->RA_ADMISSA)		+ '</dtAdm>'
	Else
		cXml += '			<dtNascto>' + SubStr( dToS(M->RA_NASC), 1, 4 ) + "-" + SubStr( dToS(M->RA_NASC), 5, 2 ) + "-" + SubStr( dToS(M->RA_NASC), 7, 2 ) + '</dtNascto>'
		cXml += '			<dtAdm>' + SubStr( dToS(M->RA_ADMISSA), 1, 4 ) + "-" + SubStr( dToS(M->RA_ADMISSA), 5, 2 ) + "-" + SubStr( dToS(M->RA_ADMISSA), 7, 2 ) + '</dtAdm>'
	EndIf

	If cVersEnvio >= "9.0.00"
		cXml += '			<matricula>' 	+ Alltrim(cCodUnico)	+ '</matricula>'
		cXml += '			<codCateg>' 	+ M->RA_CATEFD			+ '</codCateg>'
		cXml += '			<natAtividade>'	+ Iif(M->RA_VIEMRAI $ ('20|25|70|75'),'2','1') + '</natAtividade>'

		If M->RA_CATEFD $ cTrabVincu
			cXml += '			<infoRegCTPS>'

			If !Empty(M->RA_CODCBO)
				cXml += '				<CBOCargo>'		+ M->RA_CODCBO					+ '</CBOCargo>'
			EndIf

			If !Empty(M->RA_SALARIO)
				cXml += '				<vrSalFx>'		+ Iif(cPgtoTrab == "7", "0.00", Transform(M->RA_SALARIO, "@E 999999999.99")) + '</vrSalFx>'
			EndIf

			If !Empty(cPgtoTrab)
				cXml += '				<undSalFixo>'	+ cPgtoTrab 				+ '</undSalFixo>'
			EndIf

			If M->RA_TPCONTR $ "1|2|3"
				cXml += '				<tpContr>' 	+ M->RA_TPCONTR	+ '</tpContr>'
			EndIf

			If M->RA_TPCONTR == "2" .And. !Empty(M->RA_DTFIMCT)
				cXml += '				<dtTerm>'		+ DtoS(M->RA_DTFIMCT)		+ '</dtTerm>'
			EndIf

			cXml += '			</infoRegCTPS>'
		EndIf
	EndIf

	cXml += '		</infoRegPrelim>'
	cXml += '	</evtAdmPrelim>'
	cXml += '</eSocial>'
	If lGravou
		//Realiza geraÁ„o de XML na System
		GrvTxtArq(alltrim(cXml), "S2190", M->RA_CIC)

		If !lMiddleware
			//Enviar como parametro a filial do Protheus na posiÁ„o 1 e o XML na posiÁ„o 2
			aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2190")
		Else
			If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2190 ))
				aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
			EndIf
		EndIf
	EndIf
 	If Len( aErros ) > 0
 		If !lMiddleware
		 	Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )//##"AtenÁ„o"##"Funcion·rio: "##" n„o enviado(a) ao TAF. Erro: "
		Else
		 	Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + aErros[1], 1, 0 )//##"AtenÁ„o"##"Funcion·rio: "##" n„o enviado(a) ao Middleware. Erro: "
		EndIf
 		lGravou := .F.
 	Endif
Return lGravou

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fIntAdmiss  ∫Autor  ≥Christiane Vieira   ∫ Data ≥  02/12/15 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Registro Preliminar de Admiss„o                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEM026-                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fIntAdmiss(cAliasSRA, lAltCad, nOpca, cReg, cTFilial, aDep, cCodUn, oModel, cOrigem, aErros, cVersEnvio, oMdlRFZ, aFilial, oMdlRS9, cFilTrf, dDtAdm, aVinc, cFilDe, lMsgHlp, cCCAte, cArqSR6, cSR6Fil, cEmpP, cArqSRJ, cSRJFil, cArqSQ3, cSQ3Fil, dValRJ5, cSVAObs, lTrfCNPJ, lNovoCPF, cNovoCodUnic, lAjustaDep, lJorSInt)

	Local aArea			:= GetArea()
	Local aAreaRBW		:= RBW->(GetArea())
	Local aAreaSR6 		:= {}
	Local aAreaRS9		:= {}
	Local aAreaSV6      := {}
	Local cFilEnv    	:= ""
	Local cEstCivi		:= GpeEstCivi("2")
	Local aEstCivi		:= GpeEstCivi("1")
	Local nPosEC 		:= 0
	Local aRacaCor		:= {{'2','1'},{'4','2'},{'8','3'},{'6','4'},{'1','5'},{'9','6'}}
	Local cTpAmb		:= "1"
	Local nPosFil		:= 0
	Local lObraParc		:= .F.
	Local aInstrucao	:= {{'10','01'},{'20','02'},{'25','03'},{'30','04'},{'35','05'},{'40','06'},{'45','07'},;
							{'50','08'},{'55','09'},{'65','11'},{'75','12'},{'85','10'},{'95','12'}}
	Local nPosInstr		:= 0
	Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
	Local nTpRegTrab	:= 0
	Local aPagoFixo		:= GpeUndSalFixo ()
	Local nPagoFixo		:= 0
	Local aCatCNH		:= {{'1','A'},{'2','B'},{'3','C'},{'4','D'},{'5','E'},{'6','AB'},{'7','AC'},{'8','AD'},{'9','AE'}}
	Local nPosCCNH		:= 0
	Local aCargo		:= {}
	Local nPosSQ3CC		:= 0
	Local nPosSQ3sCC	:= 0
	Local aDependent	:= {}
	Local aVinculoT		:= {}
	Local aEstagio		:= {}
	Local aInstit		:= {}
	Local aCoord		:= {}
	Local aAgente		:= {}
	Local aAso			:= {}
	Local nI			:= 0
	Local aSind			:= {}
	Local aCC			:= {}
	Local nPosLot		:= 0
	Local nPosSind		:= 0
	Local nTotVinc		:= 0
	Local nVzsTurno		:= 0
	Local lDataDBF		:= .F.
	Local dOpcao
	Local dAdmissao		:= cToD("//")
	Local lGravaOpc		:= .T.
	Local nPosEstb		:= 0
	Local aEstb			:= {}
	Local aRet			:= {}
	Local aFilInTaf		:= {}
	Local aArrayFil		:= {}
	Local lMemo			:= .F.
	Local aTurno		:= {}
	Local nPosTurno		:= 0
	Local cTpInscr		:= ""
	Local cInscr        := ""
	Local cDescCTT      := ""
	Local cNomTrab		:= ""
	Local cNomAux		:= ""
	Local cXml			:= ""
	Local cObsDef		:= ""
	Local cObsVinc		:= ""
	Local cFonePrinc	:= ""
	Local cFoneAltern	:= ""
	Local lFilFuncao 	:= .T.
	Local lFilCargo 	:= .T.
	Local CodUnico		:= ""
	Local cTCVIN        := fCatTrabEFD("TCV")
	Local dDataRefP 	:= CTOD("")
	Local dDtTransf     := CTOD(" / / ")
	Local cDia 			:= ""
	Local cSalario		:= ""
	Local cIntegra		:= ""
	Local aAreaRFS		:= RFS->(GetArea())
	Local aAreaRA0		:= RA0->(GetArea())
	Local aAreaSVA		:= ""
	Local aAreaQuery	:= ""
	Local aAfastam		:= {}
	Local cCatEFD		:= ""
	Local lGravou 		:= .T.
	Local cFilTrab		:= ""
	Local lPriHab		:= SRA->(ColumnPos("RA_DTINCON")) > 0
	Local cTurno		:= ""
	Local cDscJorn		:= ""
	Local cTpJorn		:= ""
	Local lDesRem		:= SRA->(ColumnPos("RA_DESEPS")) > 0
	Local cPgtoTrab		:= ""
	Local lJAchou		:= .T.
	Local lGpa180		:= IsInCallStack("GPEA180MAT") .Or. IsInCallStack("fEnvTaf180")
	Local cTpContSVA	:= ""
	Local cObsSVA		:= ""
	Local cNrPrTrab		:= ""

	//Vari·veis para funcion·rio tempor·rio
	Local cFilRBW		:= ""
	Local cMatRBW		:= ""
	Local cMotSubs		:= ""
	Local cCPFSubs		:= ""
	Local cJustRBW		:= ""
	Local cTpContRBW	:= ""
	Local cTpInscRBW	:= ""
	Local cInscRBW		:= ""
	Local cTpInstRBW	:= ""
	Local cInsctRBW		:= ""
	Local cCPF_2RBW		:= ""
	Local cCPF_3RBW		:= ""
	Local cCPF_4RBW		:= ""
	Local cCPF_5RBW		:= ""
	Local cCPF_6RBW		:= ""
	Local cCPF_7RBW		:= ""
	Local cCPF_8RBW		:= ""
	Local cCPF_9RBW		:= ""
	Local cLoct_RBW     := ""
	Local lRbwLoct		:= RBW->(ColumnPos("RBW_LOCT")) > 0
	Local lSV6          := ChkFile("SV6")
	Local dDtCorte		:= SuperGetMV("MV_DTCGINI",nil,DDATABASE)
	Local aErroTur		:= {}
	Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)

	//Variaveis para funcion·rio Agente P˙blico
	Local lAgntPub		:= .F.
	Local cIndProv		:= ""
	Local cTpProv		:= ""
	Local dDtNome		:= ""
	Local dDtPosse		:= ""
	Local dDtExerc		:= ""
	Local cTpPlanRP		:= ""
	Local nNrPrcJd		:= ""
	Local cCodCarr		:= ""
	Local dDtIngCar		:= ""
	Local cAcumCargo	:= ""
	Local cIndTeto		:= ""
	Local cIndAbono		:= ""
	Local cDtIniAbo		:= ""
	Local cDtIniCess	:= ""
	Local aFil1x1		:= {}

	Local lOC     		:= .T.

	Local cBkpFil	 	:= cFilAnt
	Local cVersMw	 	:= ""
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cChaveS1005 	:= ""
	Local cChaveS1030	:= ""
	Local cChaveS1040	:= ""
	Local cStatus	 	:= "-1"
	Local cStat1030	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= Space(6)
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cStatRJE	 	:= "-1"
	Local cOper2200	 	:= "I"
	Local cRecib2200 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2200	 	:= "1"
	Local cStat2200	 	:= "-1"
	Local nRec2200   	:= 0
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local lS1005 	 	:= .T.
	Local lS1030 	 	:= .T.
	Local lS1035 	 	:= .T.
	Local lS1040 	 	:= .T.
	Local lS1050 	 	:= .T.
	Local lPredess 	 	:= .T.
	Local nOpcAx	 	:= 0
	Local cChaveBus		:= ""
	Local cStat2205	 	:= "-1"
	Local cOper2205	 	:= "I"
	Local nRec2205   	:= 0
	Local cRecib2205 	:= ""
	Local cRetf2205	 	:= "1"
	Local cRJEKey		:= ""
	Local cChaveS2190	:= ""
	Local cRecib2190 	:= ""
	Local cStat2190 	:= ""
	Local lNT15			:= .F.

	Local cTpInsc		:= ''
	Local lAdmPubl 		:= .F.
	Local cNrInsc  		:= ""
	Local cId  	 		:= ""
	Local aInfos		:= {}
	Local lCrgIni		:= IsInCallStack("GPEM023")
	Local cVldPred		:= ""

	//Verifica se o campo RA_NUMCP n„o È obrigatÛrio, se n„o for trata-se da nova CTPS Digital
	Local lNewCTPS		:= !CpoObrigat( "RA_NUMCP" )
	Local lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 ser„o feito pela tabela SQ3 e n„o pela SRJ (Padr„o .F. -> SRJ).
	Local lMTAFCFGE 	:= SuperGetMv("MV_TAFCFGE ",,.F.)

	Local lFilT 	 	:= .F.
	Local aRH5Filt	 	:= {}
	Local cCCRJ5		:= ""

	Local aAreaRFZ      := {}
	Local aAreaSQ3      := {}
	Local aAreaSRJ      := {}
	Local aTreiCap      := {}
	Local nVzsTreiCap   := 0
	Local cDescJrn		:= ""
	Local nPosInt		:= 0
	Local nX			:= 0
	Local cMensagem		:= ""
	Local aJorSeq		:= {}

	Default lNovoCPF	:= .F.
	Default cNovoCodUnic:= ""

	Default oMdlRS9		:= Nil
	Default lAltCad		:= .F.
	Default nOpca		:= 0
	Default cReg		:= "S2200"
	Default cTFilial	:= ""
	Default aDep		:={}
	Default aVinc		:= {}
	Default cCodUn		:= (cAliasSRA)->RA_CODUNIC
	Default cOrigem		:= "ADM"
	Default aErros		:= {}
	Default cVersEnvio	:= "2.2"
	Default oMdlRFZ		:= Nil
	Default aFilial		:= {}
	Default dDtAdm		:= cToD("//")
	Default cFilTrf		:= ""
	Default cFilDe		:= ""
	Default lMsgHlp		:= .T.
	Default cCCAte		:= ""
	Default cArqSR6		:= "SR6"
	Default cSR6Fil		:= xFilial('SR6', cTFilial)
	Default cEmpP		:= Nil
	Default cArqSRJ		:= "SRJ"
	Default cSRJFil		:= xFilial('SRJ', cTFilial)
	Default cArqSQ3		:= "SQ3"
	Default cSQ3Fil		:= xFilial('SQ3', cTFilial)
	Default dValRJ5		:= dDatabase
	Default cSVAObs		:= ""
	Default lTrfCNPJ	:= .F.
	Default lAjustaDep	:= .F.
	Default lJorSInt	:= .F.  // Jornada Sem Intervalo Definido

	If !lMiddleware
		If !Empty(cCodUn)
		   cCodUn := StrTran(cCodUn, "&","&#38;" )
		Endif
		If !Empty(cNovoCodUnic)
		   cNovoCodUnic:= StrTran(cNovoCodUnic, "&","&#38;" )
		Endif
	Endif
	nOpcAx := nOpca

	If !lMiddleware
		If nOpca == 3
			fGp23Cons(@aFil1x1, {cFilAnt})
		EndIf

		If nOpca == 3 .And. ( Len(aFil1x1) > 0 .And. Len(aFil1x1[1,3]) <> 1 .And. FUNNAME() <> "GPEM023" ) //Se vier da carga inicial enviamos filial do funcion·rio quando 1xN
			cFilTrab := cFilAnt
		Else
			cFilTrab:=	If(Empty((cAliasSRA)->RA_FILIAL) , cFilAnt, (cAliasSRA)->RA_FILIAL )
		Endif
	Else
		cFilTrab := If(Empty((cAliasSRA)->RA_FILIAL), cFilAnt, (cAliasSRA)->RA_FILIAL )
	EndIf

	//Responsavel por alimentar a tag <CadIni>
	If ( cOrigem  == "CRG" ) .Or. ( nModulo == 35 .And. Empty(M->RA_CATEFD)) //Carga Inicial ou SIGAMDT
		RegToMemory("SRA",,,.F.)
	EndIf

	//Carrega para memoria o centro de custo definido na rotina de transferencias
	If !Empty(cCCAte)
		SetMemVar( "RA_CC", cCCAte )
	EndIf

	dAdmissao := M->RA_ADMISSA
	dAdmissao := If( Empty(dDtAdm), dAdmissao, dDtAdm )
	aVinculoT   := fGM23Vinc(cFilTrab, M->RA_MAT, cVersEnvio, oMdlRFZ)
	If Len(aVinculoT)   >   0
		If cVersEnvio >= "2.4"
			dDtTransf := aVinculoT[1,8]
		Else
			dDtTransf := aVinculoT[1,6]
		EndIf

		If Len(aVinculoT[1]) > 10
			cNrPrTrab := aVinculoT[1,11]
		EndIf

	EndIf

	If Alltrim(FunName()) == "GPEA180" .And. Len(aVinc) > 0
		dDtTransf := aVinc[1][8]
	EndIf

	dDtTransf := If( Empty(dDtTransf) .And. !Empty(dDtAdm), dDtAdm, dDtTransf)

	If dAdmissao < dDtCorte .And. (dDtTransf < dDtCorte)
		cOrigem := "S" //Vinda da Carga Inicial
		dDataRefP := If( Empty(dValRJ5), dDatabase, dValRJ5 )
	Else
		cOrigem := "N" //Vindo da Admissao
		dDataRefP := Date()
	Endif

	//Data utilizada para validaÁ„o dos predecessores no Middleware
	If lMiddleware
		If cReg == "S2200"
			If Alltrim(FunName()) == "GPEA180" .And. !Empty(dDtTransf)
				cVldPred := AnoMes(dDtTransf)
			Else
				If dAdmissao < dDtCorte
					cVldPred := AnoMes(dDtCorte)
				Else
					cVldPred := AnoMes(dAdmissao)
				EndIf
			Endif
		Else
			cVldPred := AnoMes(dDataBase)
		EndIf
	EndIf

	//-------------------------------------------------------------
	//| Se o layout de trabalho for 2.3 (S2100 e S2200 unificados)
	//-------------------------------------------------------------
	If( cVersEnvio >= "2.3" )
		//--------------------------------------------
		//| Se for um registro vindo da Carga Inicial
		//--------------------------------------------
		If cOrigem == "S" .Or. lGpa180
			//Verificar os dados de afastamento (somente para carga inicial)
			aAfastam 	:= fGM23Afast(cFilTrab, If(lGpa180, SRA->RA_MAT,M->RA_MAT), dDataRefP)
			If !Empty(aAfastam)
				lAfast		:= aScan(aAfastam,{|x| Alltrim(x[2]) <> ""}) == 0
			Else
				lAfast := .F.
			Endif

			If lAfast
				aAdd( aErros, OemToAnsi(STR0088) ) //"N„o ser· possÌvel efetuar a integraÁ„o. O trabalhador possui afastamento sem motivo informado, ou inv·lido para o eSocial."
				lGravou	:= .F.
			EndIf
		EndIf
	EndIf

	//-------------------------------------------------------------
	//| Se o layout de trabalho for 2.5
	//-------------------------------------------------------------
	If cVersEnvio >= "2.5.00"
		If M->RA_TPCONTR == '2'
			aAreaSVA := SVA->(GetArea())
			dbSelectArea("SVA")
			SVA->(DbSetOrder(1))
			If SVA->(dbSeek(cFilTrab+M->RA_MAT+"01")) .Or. !Empty(cSVAObs)
				cTpContSVA := "3"
				If !Empty(cSVAObs)
					cObsSVA := cSVAObs
				Else
					cObsSVA := SVA->VA_OBSERV
				Endif
			EndIf
		EndIf
	EndIf

	If !lMiddleware
		If Len(aFilial) > 0
			aFilInTaf := aFilial[1,1]
			aArrayFil := aFilial[1,2]
			cFilEnv	  := aFilial[1,3]
		Else
			// ENCONTRA A FILIAL DE ENVIO NO CASO DE 1 X N.
			If lGpa180
				cFilEnv := FTafGetFil(AllTrim(cEmpAnt) + cFilDe,,, .T.)
			Else
				cFilEnv := FTafGetFil(AllTrim(cEmpAnt) + AllTrim(SRA->RA_FILIAL),,, .T.)
			EndIf

			If !lGpa180
				fGp23Cons(@aFilInTaf, {cFilAnt}, @cFilEnv)
			Else
				fGp23Cons(@aFilInTaf, {Iif(Empty(cFilEnv), cTFilial, cFilEnv), cFilTrab})
			EndIf
		EndIf
		fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, , , @lNT15 )
	Else
		fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw, @lNT15, @cTpAmb )
		If !lGpa180
			fPosFil( cEmpAnt, cFilTrab )
		EndIf
		lS1000 := fVld1000( cVldPred, @cStatus, Nil, cEmpP )
		If !lS1000 .And. cEFDAviso != "2"
			Do Case
				Case cStatus == "-1" // nao encontrado na base de dados
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
						lGravou	:= .F.
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX n„o localizado na base de dados"
					EndIf
				Case cStatus == "1" // nao enviado para o governo
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
						lGravou	:= .F.
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX n„o transmitido para o governo"
					EndIf
				Case cStatus == "2" // enviado e aguardando retorno do governo
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
						lGravou	:= .F.
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
					EndIf
				Case cStatus == "3" // enviado e retornado com erro
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
						lGravou	:= .F.
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
					EndIf
			EndCase
		EndIf
	EndIf

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	//tratamento para empresa configurada como 1x1 ou 1xN
	If Len(GetAPOInfo("TafTransfTrab.prw")) == 0
		If !lMiddleware .And. !lMTAFCFGE .And. Len(aFilInTaf) > 0 .And. Len(aFilInTaf[1,3]) == 1 .And. !lGpa180 //1X1
			cFilEnv:= cFilTrab
		EndIf
	EndIf

	//Retorna o Tipo de Jornada e a DescriÁ„o dela
	cTurno	:= M->RA_TNOTRAB
	cRegra	:= M->RA_REGRA
	cSeqT	:= M->RA_SEQTURN

	lJorn	:= fTpJorn( cTurno, @cTpJorn, @cDscJorn, cVersEnvio, cFilTrab, @lJAchou, cArqSR6, cSR6Fil, cEmpP )

	If ( !lJorn .AND. !(cReg == "S2205")) //no leiaute S-2205 n„o È utilizada a informaÁ„o do Turno.
		If (cOrigem == "S")
			If !lJAchou .And. IsinCallStack("Gpea180Prc")
				aAdd( aErros, OemToAnsi(STR0089) + cTurno + OemToAnsi(STR0090) )
			Else
				aAdd( aErros, STR0109 ) //"O Tipo de Jornada n„o foi localizado. Favor verificar o cadastro de turno de trabalho (tabela SR6) para que o registro seja integrado corretamente."
			Endif
		Else
			If cVersEnvio < "9.0.00"
				aAdd( aErros, OemToAnsi(STR0062) + CRLF + CRLF + OemToAnsi(STR0063)  ) //"N„o ser· possÌvel efetuar a integraÁ„o. O trabalhador possui um turno de trabalho descontinuado ou inv·lido para o eSocial."
			Else
				aAdd( aErros, OemToAnsi(STR0260) + CRLF + CRLF + OemToAnsi(STR0261)  ) //"N„o ser· possÌvel efetuar a integraÁ„o. O trabalhador possui um turno de trabalho inv·lido para o eSocial."
			Endif
		EndIf
		lGravou	:= .F.
	EndIf

	If (cVersEnvio >= "9.0.00")
		If ((lJorn) .And. (lGravou))
			DbSelectArea("SR6")
			If (FieldPos("R6_ESNOTU") > 0)
				aAreaSR6 := SR6->(GetArea())

				SR6->(DbSetOrder(1))
				If (SR6->(DbSeek(xFilial("SR6") + PadR(M->RA_TNOTRAB, TamSX3("R6_TURNO")[1]))))
					If ((lGravou) .And. (Empty(SR6->R6_ESNOTU)))
						aAdd( aErros, OemToAnsi(STR0062) + CRLF + CRLF + OemToAnsi(STR0247)  ) //"N„o ser· possÌvel efetuar a integraÁ„o. O trabalhador possui um turno de trabalho com o campo obrigatÛrio 'Jorn Sem Not' (R6_ESNOTU) em branco.
						lGravou	:= .F.
					Endif
				Endif

				RestArea(aAreaSR6)
			Endif
		Endif
	Endif

	If lGravou
		lFilFuncao	:= fGM23Func(cArqSRJ)
		lFilCargo	:= fGM23Func(cArqSQ3)
		aSind		:= fGM23Sind()
		aCC			:= fGM23CTT()
		aEstb		:= fGM23SM0(.T., .T., cEmpP)
		lMemo		:= .F.

		nPosFil := aScan(aEstb,{|x| Alltrim(x[1]) == Alltrim(cFilTrab)})

		If nPosFil > 0 .And. Len(aEstb[nPosFil]) > 3 .And. !aEstb[nPosFil,4]
			If !IsBlind()
				//"TOTVS - eSocial"
				//"Funcion·rio est· vinculado a uma filial que È uma obra, porÈm È sub-empreitada, empreitada parcial ou os dados da obra n„o foram encontrados na tabela F0F."
				//"Funcion·rios devem estar vinculados a uma filial ou obra prÛpria da empresa. Verifique Dados da Filial - MÛdulo SIGACFG, ou inclus„o dos dados na tabela F0F"
				//"Deseja prosseguir com a gravaÁ„o do funcion·rio?"
				If !MsgYesNo( OemToAnsi(STR0077) + CRLF + CRLF + OemToAnsi(STR0078) + CRLF + CRLF + OemToAnsi(STR0079), OemToAnsi(STR0080) )
					Return (.F.)
				Endif
			Endif
		Endif

		Begin Transaction

			//CATEGORIA DO FUNCIONARIO
			cCatEFD := M->RA_CATEFD

			//TRABALHADOR
			cNomAux  := IIF(!EMPTY(ALLTRIM(M->RA_NOMECMP)),SUBSTR(M->RA_NOMECMP,1,60),ALLTRIM(M->RA_NOME) )
			cNomTrab := FSubst(cNomAux)
			nPosEC	  := aScan(aEstCivi,{|x| Alltrim(x[1]) == M->RA_ESTCIVI})
			nPosInstr := aScan(aInstrucao,{|x| Alltrim(x[1]) == M->RA_GRINRAI})
			nPosRacaCor	  := aScan(aRacaCor,{|x| Alltrim(x[1]) == M->RA_RACACOR})

			//NASCIMENTO
			cPais	  := fM23Pais(ALLTRIM(M->RA_CPAISOR))

			//DOCUMENTOS
			nPosCCNH  := aScan(aCatCNH,{|x| Alltrim(x[1]) == M->RA_CATCNH})

			//INFO DEFICI NCIA
			If M->RA_DEFIFIS == "1" .And. !fEmptyMemo(M->RA_OBSDEFI)
				lMemo 	:= .T.
				cObsDef	:= ALLTRIM(M->RA_OBSDEFI)
			EndIf

			//DEPENDENTES
			aDependent:= {}

			If(FunName() == "GPEA020")
				If len(aDep) > 0
					aDependent:= aDep
				EndIf
			Else
				if len(aDep) == 0
					aDependent := fGM23Dep(cFilTrab, M->RA_MAT)
				else
					aDependent:= aDep
				Endif
			EndIf

			//CONTATO
			If !Empty(M->RA_DDDFONE)
				cFonePrinc := ALLTRIM(M->RA_DDDFONE) + SUBSTR(M->RA_TELEFON,1,11)
			Else
				If !Empty( M->RA_TELEFON )
					cFonePrinc := SUBSTR(M->RA_TELEFON,1,13)
				EndIf
			EndIf
			cFonePrinc := AllTrim(StrTran(StrTran(cFonePrinc, "-",""), ".",""))

			If !Empty(M->RA_DDDCELU)
				cFoneAltern := ALLTRIM(M->RA_DDDCELU) + SUBSTR(M->RA_NUMCELU,1,11)
			Else
				If !Empty( M->RA_NUMCELU )
					cFoneAltern := SUBSTR(M->RA_NUMCELU,1,13)
				EndIf
			EndIf
			cFoneAltern := AllTrim(StrTran(StrTran(cFoneAltern, "-",""), ".",""))

			//VINCULO
			nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == M->RA_VIEMRAI})//Retorno: 0-CLT | >0-Estatutario
			fGM23Estag(cFilTrab,M->RA_MAT, dDataRefP, @aEstagio, @aInstit, @aAgente, @aCoord )

			If( Len(aVinc) ) > 0
				aVinculoT := aClone( aVinc )
			EndIf
			nTotVinc 	:= LEN(aVinculoT)

			//FGTS
			If !empty(M->RA_OPCAO)
				lGravaOpc := .T.
				dOpcao := M->RA_OPCAO

				If dAdmissao >= STOD('19881004') .AND. (dAdmissao <> dOpcao)
					dOpcao := dAdmissao
					lGravaOpc := .T.
				EndIf

				If M->RA_CATEFD == '105' .AND. dOpcao < STOD('19980122')
					lGravaOpc := .F.
				EndIf

				If M->RA_CATEFD == '104' .AND. dOpcao < STOD('20000301')
					lGravaOpc := .F.
				EndIf

				If M->RA_CATEFD == '103' .AND. dOpcao < STOD('20001220')
					lGravaOpc := .F.
				EndIf

				If dOpcao < STOD('19670101')
					lGravaOpc := .F.
				EndIf

				//para o leiaute S-1.0 o FGTS N√O deve ser gravados quando
				//tpadmissa = 6 (preenchido desta forma somente na quando lNovoCPF = .T.) ou
				//se categoria diferente de 104 e admissao maior ou igual a 1988-10-05 ou
				//categoria igual a 104 e admissao maior que 2015-10-01
				If cVersEnvio >= "9.0.00" .And. (lNovoCPF .Or. ;
				(M->RA_CATEFD <> "104" .And. dAdmissao >= STOD('19881005')) .Or. ;
				(M->RA_CATEFD == "104" .And. dAdmissao >= STOD('20151001')))
					lGravaOpc := .F.
				EndIf

				//Optante pelo FGTS
				If 	dOpcao >= STOD('19881004')
					nOptante:= '1'
				Else
					nOptante := IIf(M->RA_ALTOPC=='S','1','2')
				EndIf
			EndIf

			//--------------
			//| ESTATUTARIO
			//| Monta dados do estatut·rio
			//-----------------------------
			If nTpRegTrab > 0
				//Vindo da tela GPEA931 - Agentes Publicos
				lAgntPub := .T.
				If Funname() == "GPEA931" .AND. oMdlRS9 != Nil

					If cVersEnvio < "9.0"
						cIndProv := AllTrim( oMdlRS9:GetValue("RS9_PROES") )
						cTpProv  := AllTrim( oMdlRS9:GetValue("RS9_TPPROV") )
						dDtNome  := DtoS( oMdlRS9:GetValue("RS9_DTNOM") )
						dDtPosse := DtoS( oMdlRS9:GetValue("RS9_DTPOSS") )
						dDtExerc := DtoS( oMdlRS9:GetValue("RS9_DTEX") )
						cTpPlanRP:= AllTrim( oMdlRS9:GetValue("RS9_SEG") )
						nNrPrcJd := Alltrim( oMdlRS9:GetValue("RS9_PROC") )
						cCodCarr := AllTrim( oMdlRS9:GetValue("RS9_CAR") )
						dDtIngCar:= DtoS( oMdlRS9:GetValue("RS9_DTCAR") )
					elseIf RS9->( ColumnPos( "RS9_TIPPRV" ) > 0 )
						cTpProv		:= AllTrim( oMdlRS9:GetValue("RS9_TIPPRV") )
						dDtExerc	:= DtoS( oMdlRS9:GetValue("RS9_DTEX") )
						cTpPlanRP	:= AllTrim( oMdlRS9:GetValue("RS9_SEGR") )
						cIndTeto	:= AllTrim( oMdlRS9:GetValue("RS9_TETORG") )
						cIndAbono	:= AllTrim( oMdlRS9:GetValue("RS9_ABONPE") )
						cDtIniAbo	:= DtoS( oMdlRS9:GetValue("RS9_INIABO") )
						cAcumCargo	:= AllTrim( oMdlRS9:GetValue("RS9_ACUMCA") )
						cDtIniCess	:= DtoS( oMdlRS9:GetValue("RS9_DTINIC") )
					EndIf

				//Vindo da Carga Inicial ou Outra
				Else
					aAreaRS9 := RS9->(GetArea())
					dbSelectArea("RS9")
					RS9->(dbSetOrder(1))
					If RS9->(dbSeek(cFilTrab+M->RA_MAT))
						If cVersEnvio < "9.0"
							cIndProv := AllTrim( RS9->RS9_PROES )
							cTpProv  := AllTrim( RS9->RS9_TPPROV )
							dDtNome  := DtoS( RS9->RS9_DTNOM )
							dDtPosse := DtoS( RS9->RS9_DTPOSS )
							dDtExerc := DtoS( RS9->RS9_DTEX )
							cTpPlanRP:= AllTrim( RS9->RS9_SEG )
							nNrPrcJd := AllTrim( RS9->RS9_PROC )
							cCodCarr := AllTrim( RS9->RS9_CAR )
							dDtIngCar:= DtoS( RS9->RS9_DTCAR )
						elseIf RS9->( ColumnPos( "RS9_TIPPRV" ) > 0 )
							cTpProv		:= AllTrim( RS9->RS9_TIPPRV )
							dDtExerc	:= DtoS( RS9->RS9_DTEX )
							cTpPlanRP	:= AllTrim( RS9->RS9_SEGR )
							cIndTeto	:= AllTrim( RS9->RS9_TETORG )
							cIndAbono	:= AllTrim( RS9->RS9_ABONPE )
							cDtIniAbo	:= DtoS( RS9->RS9_INIABO )
							cAcumCargo	:= AllTrim( RS9->RS9_ACUMCA )
							cDtIniCess	:= DtoS( RS9->RS9_DTINIC )
						EndIf
					EndIf
					RestArea(aAreaRS9)
				EndIf
			EndIf

			//TRABALHO TEMPORARIO
			If M->RA_TPCONTR == '2'
				aAreaRBW := RBW->(GetArea())
				dbselectArea("RBW")
				RBW->(dbSetOrder(1))
				If Funname() == "GPEA927" .And. oModel <> Nil .And. cVersEnvio >= "2.3"
					cFilRBW := oModel:GetValue("RBWDETAIL","RBW_FILIAL")
					cMatRBW := oModel:GetValue("RBWDETAIL","RBW_MAT")
					If Empty(cFilRBW)
						cFilRBW := cFilTrab
					EndIf

					If cFilRBW + cMatRBW == cFilTrab+M->RA_MAT
						cMotSubs 	:= oModel:GetValue("RBWDETAIL","RBW_MOTIVO")	//RBW_MOTIVO
						cCPFSubs 	:= oModel:GetValue("RBWDETAIL","RBW_CPFSUB")	//RBW_CPFSUB
						cJustRBW 	:= oModel:GetValue("RBWDETAIL","RBW_JUST")		//RBW_JUST
						cTpContRBW	:= oModel:GetValue("RBWDETAIL","RBW_TPCONT")	//RBW_TPCONT
						cTpInscRBW	:= oModel:GetValue("RBWDETAIL","RBW_TPINSC")	//RBW_TPINSC
						cInscRBW	:= oModel:GetValue("RBWDETAIL","RBW_INSC")		//RBW_INSC
						cTpInstRBW	:= oModel:GetValue("RBWDETAIL","RBW_TPINST")	//RBW_TPINST
						cInsctRBW	:= oModel:GetValue("RBWDETAIL","RBW_INSCT")		//RBW_INSCT
						cCPF_2RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF2")		//RBW_CPF2
						cCPF_3RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF3")		//RBW_CPF3
						cCPF_4RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF4")		//RBW_CPF4
						cCPF_5RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF5")		//RBW_CPF5
						cCPF_6RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF6")		//RBW_CPF6
						cCPF_7RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF7")		//RBW_CPF7
						cCPF_8RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF8")		//RBW_CPF8
						cCPF_9RBW	:= oModel:GetValue("RBWDETAIL","RBW_CPF9")		//RBW_CPF9
						If lRbwLoct
							cLoct_RBW := oModel:GetValue("RBWDETAIL","RBW_LOCT")		//RBW_LOCT
						EndIf
					Endif
				ElseIf (MsSeek(cFilTrab+M->RA_MAT))
					cMotSubs 	:= RBW->RBW_MOTIVO
					cJustRBW 	:= RBW->RBW_JUST
					cTpContRBW	:= RBW->RBW_TPCONT
					cCPFSubs 	:= RBW->RBW_CPFSUB
					If cVersEnvio >= '2.3'
						cTpInscRBW	:= RBW->RBW_TPINSC
						cInscRBW	:= RBW->RBW_INSC
						cTpInstRBW	:= RBW->RBW_TPINST
						cInsctRBW	:= RBW->RBW_INSCT
						cCPF_2RBW	:= RBW->RBW_CPF2
						cCPF_3RBW	:= RBW->RBW_CPF3
						cCPF_4RBW	:= RBW->RBW_CPF4
						cCPF_5RBW	:= RBW->RBW_CPF5
						cCPF_6RBW	:= RBW->RBW_CPF6
						cCPF_7RBW	:= RBW->RBW_CPF7
						cCPF_8RBW	:= RBW->RBW_CPF8
						cCPF_9RBW	:= RBW->RBW_CPF9
						If lRbwLoct
							cLoct_RBW := RBW->RBW_LOCT
						EndIf
					EndIf
				EndIf
				RestArea(aAreaRBW)
			EndIf

			//----------------------------
			//| REMUNERACAO
			//| Realizando a lÛgica do C·lculo de Sal·rio
			//--------------------------------------------
			cPgtoTrab := fGetTpPagto(M->RA_TIPOPGT, M->RA_CATFUNC, fGetValCpo( "RA_SALARIO" ) )

			//LOCAL DE TRABALHO - conforme leiaute sempre levar do estabalecimento que esta vinculado
			//por isso retirado o controle por cento vamos sempre gerar pela Filial
			cTpInscr	:= ""
			cInscr		:= ""

			If !lVerRJ5
				If !Empty(M->RA_CC) .AND. LEN(aCC)>0
					nPosLot := aScan(aCC,{|x| x[1] == FWxFilial("CTT") .AND. x[2] == M->RA_CC})
					If nPosLot > 0
						cTpInscr	:= aCC[nPosLot,3]
						cInscr		:= aCC[nPosLot,4]
						cDescCTT   	:= aCC[nPosLot,7]
						cChaveS1005 := FWxFilial("CTT")+cInscr
					EndIf
				EndIf
			Else
				lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0
				If lFilT
					aRH5Filt := fRJ5Filt()
				Endif
				If !lFilT
					RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
					If RJ5->( !dbSeek( xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) + M->RA_CC ) )
						aAdd( aErros, OemToAnsi(STR0111) + CRLF + CRLF + OemToAnsi(STR0112) + M->RA_CC + OemToAnsi(STR0113) ) //"N„o ser· possÌvel efetuar a integraÁ„o. O centro de custo: XXXX (RA_CC) n„o est· cadastrado na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					Else
						While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) .And. RJ5->RJ5_CC == M->RA_CC
							If AnoMes(dValRJ5) >= RJ5->RJ5_INI
								cTpInscr	:= RJ5->RJ5_TPIO
								cInscr  	:= RJ5->RJ5_NIO
								cDescCTT	:= ""
								cChaveS1005 := xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial))+cInscr
							EndIf
							RJ5->( dbSkip() )
						EndDo
					EndIf
				Else
					RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
					RJ5->(dbGotop())
					If Len(aRH5Filt) > 0
						If RJ5->(dbSeek( xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) + M->RA_CC + IIF(Empty(cTFilial), cFilTrab, cTFilial)  ) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) .And.  Alltrim(RJ5->RJ5_CC) == Alltrim(M->RA_CC) .And.;
								IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT ==IIF(Empty(cTFilial), cFilTrab, cTFilial), .T.)
								If AnoMes(dValRJ5) >= RJ5->RJ5_INI
									cTpInscr	:= RJ5->RJ5_TPIO
									cInscr  	:= RJ5->RJ5_NIO
									cDescCTT	:= ""
									cChaveS1005 := xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial))+cInscr
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
					Endif
					If Len(aRH5Filt) == 0 .Or. Empty(cCCRJ5)
						If RJ5->(dbSeek( xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) + M->RA_CC  ) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) .And. Alltrim(RJ5->RJ5_CC) == Alltrim(M->RA_CC) .And.;
								IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT ==IIF(Empty(cTFilial), cFilTrab, cTFilial), .T.)
								If AnoMes(dValRJ5) >= RJ5->RJ5_INI
									cTpInscr	:= RJ5->RJ5_TPIO
									cInscr  	:= RJ5->RJ5_NIO
									cDescCTT	:= ""
									cChaveS1005 := xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial))+cInscr
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
					Endif
					If Empty(cCCRJ5)
						aAdd( aErros, OemToAnsi(STR0111) + CRLF + CRLF + OemToAnsi(STR0112) + M->RA_CC + OemToAnsi(STR0113) ) //"N„o ser· possÌvel efetuar a integraÁ„o. O centro de custo: XXXX (RA_CC) n„o est· cadastrado na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					EndIf
				Endif
			EndIf

			If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
				If fBuscaCAEPF( IIF(Empty(cTFilial), cFilTrab, cTFilial), @cInscr, @cTpInscr )
					cTpInscr 	:= "3"
					cChaveS1005	:= IIF(Empty(cTFilial), cFilTrab, cTFilial)+cInscr
				EndIf
				If Empty(cTpInscr) .Or. Empty(cInscr)
					if empty(cTFilial)
						nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFilTrab)})
					else
						nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cTFilial)})
					Endif
					If nPosEstb > 0
						cTpInscr	:= aEstb[nPosEstb,3]
						cInscr		:= aEstb[nPosEstb,2]
						cDescCTT  	:= ""
						cChaveS1005	:= IIF(Empty(cTFilial), cFilTrab, cTFilial)+cInscr
					EndIf
				EndIf
			EndIf

			//TIPO DE JORNADA - HOR¡RIO CONTRATUAL
			If !Empty(cTurno)
				aTurno    := fGM23Tur("SRA",@cTurno,@cRegra,cSeqT, IIF(Empty(cTFilial), cFilTrab,cTFilial), cVersEnvio)
			Else
				aTurno    := fGM23Tur("SRA",,, , IIF(Empty(cTFilial), cFilTrab,cTFilial), cVersEnvio)
			EndIf
			/*-------------------------------------------------------------------------------------------------
			A TAFGETSTAT nao consegue obter o Status correto do turno porque nao temos como passar uma data de
			inicio da validade. Dessa forma, o sistema sempre tenta incluir um novo turno com mesmo codigo, e
			isso gera uma mensagem de validacao no TAF que impede a conclusao da transferencia. Por isso foi
			retirado o retorno de erros ate que essa questao seja discutida com o TAF.
			---------------------------------------------------------------------------------------------------	*/
			If cReg <> "S2205" .And. Len(aTurno) > 0 .And. cVersEnvio <= "2.5"
				fGrvHorTAF("SRA", If(!Empty(cTFilial), cTFilial, cFilTrab), cTurno, cRegra, cSeqT, Iif(dAdmissao > Date(), Date(), dAdmissao), cEmpP, @aErroTur, cVersMw)

				If Len(aErroTur) > 0
					If cEFDAviso == "1"
						aAdd(aErros, aErroTur[1] )
					ElseIf cEFDAviso == "0"
						Help( ,, OemToAnsi(STR0001) ,, aErroTur[1], 1, 0 )//##"Hor·rio/Turno" ##"N„o enviado ao TAF." ##"Reavaliar o cadastro."
					Endif
				Endif
			EndIf

			//HORARIO CONTRATUAL
			nPosTurno := 0
			If M->RA_TPJORNA $ "1|2|4" .AND. Len(aTurno) > 0 .AND. ;
			(!(EMPTY(M->RA_TNOTRAB)) .AND.  !(EMPTY(M->RA_REGRA)))

				nPosTurno := 1
			EndIf

			//InÌcio da GeraÁ„o do XML
			If !(EMPTY(cFilEnv))
				//GeraÁ„o do registro S-2100 ou S-2200
				If !Empty( cCatEFD )
					If lMiddleware
						aInfos   := fXMLInfos()
						IF Len(aInfos) >= 4
							cTpInsc  := aInfos[1]
							lAdmPubl := aInfos[4]
							cNrInsc  := aInfos[2]
							cId  	 := aInfos[3]
						Else
							cTpInsc  := ""
							lAdmPubl := .F.
							cNrInsc  := "0"
						EndIf

						If cReg == 'S2200'
							cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(cCodUn, fTamRJEKey(), " ")
							cStat2200 	:= "-1"
							GetInfRJE( 2, cChaveBus, @cStat2200, @cOper2200, @cRetf2200, @nRec2200, @cRecib2200, @cRecibAnt )

							//AlteraÁ„o ou exclus„o
							If nOpcAx == 4 .Or. nOpcAx == 5
								//Retorno pendente impede o cadastro
								If cStat2200 == "2" .And. cEFDAviso != "2"
									cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
								EndIf
								//AlteraÁ„o
								If nOpcAx == 4
									//Evento de exclus„o sem transmiss„o impede o cadastro
									If cOper2200 == "E" .And. cStat2200 != "4" .And. cEFDAviso != "2"
										cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
									//N„o existe na fila, ser· tratado como inclus„o
									ElseIf cStat2200 == "-1"
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									//Evento sem transmiss„o, ir· sobrescrever o registro na fila
									ElseIf cStat2200 $ "1/3"
										cOperNew 	:= cOper2200
										cRetfNew	:= cRetf2200
										cStatNew	:= "1"
										lNovoRJE	:= .F.
									//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
									ElseIf cOper2200 != "E" .And. cStat2200 == "4"
										cOperNew 	:= "A"
										cRetfNew	:= "2"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									//Evento de exclus„o transmitido, ser· tratado como inclus„o
									ElseIf cOper2200 == "E" .And. cStat2200 == "4"
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf
									//Exclus„o
									ElseIf nOpcAx == 5
										//Evento de exclus„o sem transmiss„o impede o cadastro
										If cOper2200 == "E" .And. cStat2200 != "4" .And. cEFDAviso != "2"
											cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
										//Evento diferente de exclus„o transmitido ir· gerar uma exclus„o
										ElseIf cOper2200 != "E" .And. cStat2200 == "4"
											cOperNew 	:= "E"
											cRetfNew	:= cRetf2200
											cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf
								EndIf
							ElseIf nOpcAx == 3 .Or. nOpcAx == 7
								//Retorno pendente impede o cadastro
								If cStat2200 == "2" .And. cEFDAviso != "2"
									cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
								//Evento de exclus„o sem transmiss„o impede o cadastro
								ElseIf cOper2200 == "E" .And. cStat2200 != "4" .And. cEFDAviso != "2"
									cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
								//Evento sem transmiss„o, ir· sobrescrever o registro na fila
								ElseIf cStat2200 $ "1/3"
									cOperNew 	:= cOper2200
									cRetfNew	:= cRetf2200
									cStatNew	:= "1"
									lNovoRJE	:= .F.
								//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
								ElseIf cOper2200 != "E" .And. cStat2200 == "4"
									cOperNew 	:= "A"
									cRetfNew	:= "2"
									cStatNew	:=  "1"
									lNovoRJE	:= .T.
								//Ser· tratado como inclus„o
								Else
									cOperNew 	:= "I"
									cRetfNew	:= "1"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								EndIf
							EndIf
							If cRetfNew == "2"
								If cStat2200 == "4"
									cRecibXML 	:= cRecib2200
									cRecibAnt	:= cRecib2200
									cRecib2200	:= ""
								Else
									cRecibXML 	:= cRecibAnt
								EndIf
							EndIf
							aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2200", Space(6), cCodUn, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2200, cRecibAnt } )
						ElseIf cReg == 'S2205'
							If M->RA_CATEFD $ cTCVIN
								cRJEKey	:= cCodUn
							Else
								cRJEKey	:= AllTrim( M->RA_CIC ) + AllTrim( M->RA_CATEFD ) + DTOS( M->RA_ADMISSA )
							EndIf
							cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2205" + Padr(cRJEKey, fTamRJEKey(), " ")+ Padr(cIni,6, " ")+ DTOS(dDtGer)
							cStat2205 	:= "-1"
							GetInfRJE( 2, cChaveBus, @cStat2205, @cOper2205, @cRetf2205, @nRec2205, @cRecib2205, @cRecibAnt )

							//AlteraÁ„o
							If nOpcAx == 3 .Or. nOpcAx == 4
								//Retorno pendente impede o cadastro
								If cStat2205 == "2" .And. cEFDAviso != "2"
									cMsgHlp 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
								Else
									If cStat2205 == "-1"
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
										//Evento sem transmiss„o, ir· sobrescrever o registro na fila
									ElseIf cStat2205 $ "1/3"
										cOperNew 	:= cOper2205
										cRetfNew	:= cRetf2205
										cStatNew	:= "1"
										lNovoRJE	:= .F.
										//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
									ElseIf cOper2205 != "E" .And. cStat2205 == "4"
										cOperNew 	:= "A"
										cRetfNew	:= "2"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf
									If cRetfNew == "2"
										If cStat2205 == "4"
											cRecibXML 	:= cRecib2205
											cRecibAnt	:= cRecib2205
											cRecib2205	:= ""
											Else
											cRecibXML 	:= cRecibAnt
										EndIf
									EndIf
									aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2205", Space(6), cRJEKey, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2205, cRecibAnt } )
								Endif
							Endif
						Endif
						If cReg == 'S2200'
							cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtAdmissao/v" + cVersMw + "'>"
							cXML += 	"<evtAdmissao Id='" + cId + "'>"
						ElseIf cReg == 'S2205'
							cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtAltCadastral/v" + cVersMw + "'>"
							cXML += 	"<evtAltCadastral Id='" + cId + "'>"
						EndIf
						fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cTpAmb, 1, "12" } )
						fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
					Else
						cXml += '<eSocial>'
						if cReg == 'S2200'
							cXml += '	<evtAdmissao>'
						Elseif cReg == 'S2205'
							cXml += '	<evtAltCadastral>'
						Elseif cReg == 'S2100
							cXml += '	<evtCadInicial>'
						Endif
					EndIf

					//TRABALHADOR
					if cReg == 'S2200' .OR. cReg == 'S2100'
						cXml += '<trabalhador>'
					elseif cReg == 'S2205'
						cXml += '<ideTrabalhador>'
					endif

					if lNovoCPF
						cXml += '<cpfTrab>'    	+ ALLTRIM(RJI->RJI_CPF)	+ '</cpfTrab>'
					else
						cXml += '<cpfTrab>'    	+ ALLTRIM(M->RA_CIC)	+ '</cpfTrab>'
					endif

					if cReg == 'S2205'
						cXml += '</ideTrabalhador>'
					Endif

					// Registro de alteracao cadastral
					If cReg == 'S2205'
						cXml += '	<alteracao>'
						If !lMiddleware
							cXml += ' <dtAlteracao>' + DTOS(dDataBase) + '</dtAlteracao>'
						Else
							cXml += ' <dtAlteracao>' + SubStr( dToS(dDataBase), 1, 4 ) + "-" + SubStr( dToS(dDataBase), 5, 2 ) + "-" + SubStr( dToS(dDataBase), 7, 2 ) + '</dtAlteracao>'
						EndIf
						cXml += '<dadosTrabalhador>'
					Endif

					if cReg == 'S2200' .OR. cReg == 'S2205' .OR. cReg == 'S2100'
						If (cVersEnvio < "9.0")
							cXml += '<nisTrab>'+ ALLTRIM(M->RA_PIS)	+ '</nisTrab>'
						Endif
						If !lMiddleware
							cXml += '<nmTrab>'+ cNomTrab   					+ '</nmTrab>'
						Else
							cXml += '<nmTrab>'+ Alltrim(cNomTrab)			+ '</nmTrab>'
						Endif
						cXml += '<sexo>'		  	+ M->RA_SEXO	 		+ '</sexo>'
						cXml += '<racaCor>' 	 	+ IIf(nPosRacaCor> 0, aRacaCor[nPosRacaCor,2], "")    	+ '</racaCor>'

						If ( nPosEC > 0 )
							cXml += '<estCiv>' 		+ aEstCivi[nPosEC,2] + '</estCiv>'
						ElseIf !lMiddleware
							cXml += '<estCiv>' 		+ '' + '</estCiv>'
						EndIf
						cXml += '<grauInstr>'	+ IIf(nPosInstr>0,aInstrucao[nPosInstr,2], "") + '</grauInstr>'
					endif

					if cReg == 'S2200' .or. cReg == 'S2100'  .Or. (cReg == 'S2205' .And. cVersEnvio >= "2.4.02")
						if ((cReg == 'S2200' .And. !lNT15) .Or. (cReg == 'S2200' .And. lNT15 .And. cOrigem <> "S")) .And. (cVersEnvio < "9.0")
							IF substr(M->RA_TIPOADM,2,1) == "A"
								cXml += '<indPriEmpr>'	+ "S" + '</indPriEmpr>'
							ELSE
								cXml += '<indPriEmpr>'	+ "N" + '</indPriEmpr>'
							ENDIF
						Endif
						//Nome Social
						If !lMiddleware .Or. !Empty(M->RA_NSOCIAL)
							cXml += '<nmSoc>'		+ ALLTRIM(M->RA_NSOCIAL) + '</nmSoc>'
						EndIf
						//NASCIMENTO
						If cReg <> 'S2205' .Or. (cVersEnvio < "9.0.00")
							cXml += '<nascimento>'
							If !lMiddleware
								cXml += '<dtNascto>'    	+ DtoS(M->RA_NASC)		+ '</dtNascto>'
							Else
								cXml += '<dtNascto>' + SubStr( dToS(M->RA_NASC), 1, 4 ) + "-" + SubStr( dToS(M->RA_NASC), 5, 2 ) + "-" + SubStr( dToS(M->RA_NASC), 7, 2 ) + '</dtNascto>'
							EndIf

							If (cVersEnvio < "9.0")
								If M->RA_CPAISOR=="01058" .AND. M->RA_NATURAL != "EX"
									If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_CODMUNN)
										cXml += '<codMunic>' + Iif(lMiddleware, fEstIBGE(M->RA_NATURAL), "") + ALLTRIM(M->RA_CODMUNN)+ '</codMunic>'
									EndIf
									If !lMiddleware .Or. !Empty(M->RA_NATURAL)
										cXml += '<uf>' 			+ M->RA_NATURAL		+ '</uf>'
									EndIf
								Endif
							Endif
							cXml += '<paisNascto>' 	+ cPais + '</paisNascto>'
						Endif
						cXml += '<paisNac>'	+ fM23Pais(ALLTRIM(M->RA_NACIONC))+ '</paisNac>'
						If (cVersEnvio < "9.0")
							If lMiddleware .And. !Empty(M->RA_MAE)
								cXml += '<nmMae>' + Alltrim(M->RA_MAE)	+ '</nmMae>'
							ElseIf !lMiddleware .Or. !Empty(M->RA_MAE)
								cXml += '<nmMae>' + M->RA_MAE	+ '</nmMae>'
							Endif
							If lMiddleware .And. !Empty(M->RA_PAI)
								cXml += '<nmPai>' + Alltrim(M->RA_PAI)	+ '</nmPai>'
							ElseIf !lMiddleware .Or. !Empty(M->RA_PAI)
								cXml += '<nmPai>' + M->RA_PAI	+ '</nmPai>'
							EndIf
						Endif
						If cReg <> 'S2205' .Or. (cVersEnvio < "9.0.00")
							cXml += '</nascimento>'
						Endif
					Endif

					if !empty(M->RA_CODIGO) .and. !empty(M->RA_OCEMIS)
						lOC := .T.
					else
						lOC := .F.
					endif

					If cReg == 'S2200' .OR. cReg == 'S2205'.OR. cReg == 'S2100'
						If (cVersEnvio < "9.0")
							//DOCUMENTOS
							cXml += '<documentos>'
							If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_NUMCP) .and. !Empty(M->RA_SERCP) .and. !Empty(M->RA_UFCP)) .Or. lNewCTPS
								cXml += '<CTPS>'
								If lNewCTPS .And. Empty(M->RA_NUMCP)
									cXml += '<nrCtps>'     + M->RA_CIC	+ '</nrCtps>'
									cXml += '<serieCtps>'  + "00000" + '</serieCtps>'
									cXml += '<ufCtps>'     + If(Empty(M->RA_UFCP),SM0->M0_ESTENT,M->RA_UFCP)		+ '</ufCtps>'
								Else
									cXml += '<nrCtps>'     + M->RA_NUMCP		+ '</nrCtps>'
									cXml += '<serieCtps>'  + M->RA_SERCP		+ '</serieCtps>'
									cXml += '<ufCtps>'     + M->RA_UFCP		+ '</ufCtps>'
								EndIf
								cXml += '</CTPS>'
							EndIf
							If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_NUMRIC) .and. !empty(M->RA_EMISRIC))
								cXml += '<RIC>'
								cXml += '<nrRic>'   	  + M->RA_NUMRIC		 + '</nrRic>'
								cXml += '<orgaoEmissor>'  + M->RA_EMISRIC    + '</orgaoEmissor>'
								If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_DEXPRIC)
									If !lMiddleware
										cXml += '<dtExped>'       + DtoS(M->RA_DEXPRIC)+ '</dtExped>'
									Else
										cXml += '<dtExped>' + SubStr( dToS(M->RA_DEXPRIC), 1, 4 ) + "-" + SubStr( dToS(M->RA_DEXPRIC), 5, 2 ) + "-" + SubStr( dToS(M->RA_DEXPRIC), 7, 2 ) + '</dtExped>'
									EndIf
								EndIf
								cXml += '</RIC>'
							EndIf
							If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_RG) .and. !empty(M->RA_RGEXP))
								cXml += '<RG>'
								cXml += '<nrRg>'  	    + Substr(ALLTRIM(M->RA_RG),1,14) + '</nrRg>'
								cXml += '<orgaoEmissor>'+ M->RA_RGEXP		+ '</orgaoEmissor>'
								If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_DTRGEXP)
									If !lMiddleware
										cXml += '<dtExped>'	    + DtoS(M->RA_DTRGEXP)+ '</dtExped>'
									Else
										cXml += '<dtExped>' + SubStr( dToS(M->RA_DTRGEXP), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTRGEXP), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTRGEXP), 7, 2 ) + '</dtExped>'
									EndIf
								EndIf
								cXml += '</RG>'
							EndIf
							If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_RNE) .and. !empty(M->RA_RNEORG))
								cXml += '<RNE>'
								cXml += '<nrRne>'  	    + M->RA_RNE			+ '</nrRne>'
								cXml += '<orgaoEmissor>'+ M->RA_RNEORG		+ '</orgaoEmissor>'
								If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_RNEDEXP)
									If !lMiddleware
										cXml += '<dtExped>'     + DtoS(M->RA_RNEDEXP)+ '</dtExped>'
									Else
										cXml += '<dtExped>' + SubStr( dToS(M->RA_RNEDEXP), 1, 4 ) + "-" + SubStr( dToS(M->RA_RNEDEXP), 5, 2 ) + "-" + SubStr( dToS(M->RA_RNEDEXP), 7, 2 ) + '</dtExped>'
									EndIf
								EndIf
								cXml += '</RNE>'
							EndIf

							If (!lMiddleware .and. !lNT15) .Or. lOC //nao estao em branco
								cXml += '<OC>'
								cXml += '<nrOc>'        + if(lOC, M->RA_CODIGO, "") + '</nrOc>'
								cXml += '<orgaoEmissor>'+ if(lOC, M->RA_OCEMIS, "")	+ '</orgaoEmissor>'
								IF (!lMiddleware .and. !lNT15) .OR. !EMPTY(DtoS(M->RA_OCDTEXP))
									If !lMiddleware
										cXml += '<dtExped>'     + DtoS(M->RA_OCDTEXP) + '</dtExped>'
									Else
										cXml += '<dtExped>' + SubStr( dToS(M->RA_OCDTEXP), 1, 4 ) + "-" + SubStr( dToS(M->RA_OCDTEXP), 5, 2 ) + "-" + SubStr( dToS(M->RA_OCDTEXP), 7, 2 ) + '</dtExped>'
									EndIf
								ENDIF
								IF (!lMiddleware .and. !lNT15) .OR. !EMPTY(DtoS(M->RA_OCDTVAL))
									If !lMiddleware
										cXml += '<dtValid>' 	+ DtoS(M->RA_OCDTVAL) + '</dtValid>'
									Else
										cXml += '<dtValid>' + SubStr( dToS(M->RA_OCDTVAL), 1, 4 ) + "-" + SubStr( dToS(M->RA_OCDTVAL), 5, 2 ) + "-" + SubStr( dToS(M->RA_OCDTVAL), 7, 2 ) + '</dtValid>'
									EndIf
								ENDIF
								cXml += '</OC>'
							EndIf

							If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_HABILIT) .and. !empty(M->RA_UFCNH) .and. !empty(M->RA_DTVCCNH) .and. nPosCCNH > 0)
								cXml += '<CNH>'
								cXml += '<nrRegCnh>'	+ M->RA_HABILIT	+ '</nrRegCnh>'
								If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_DTEMCNH)
									If !lMiddleware
										cXml += '<dtExped>'		+ DtoS(M->RA_DTEMCNH)	+ '</dtExped>'
									Else
										cXml += '<dtExped>' + SubStr( dToS(M->RA_DTEMCNH), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTEMCNH), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTEMCNH), 7, 2 ) + '</dtExped>'
									EndIf
								EndIf
								cXml += '<ufCnh>'		+ M->RA_UFCNH		+ '</ufCnh>'
								If !lMiddleware
									cXml += '<dtValid>'		+ DtoS(M->RA_DTVCCNH) 	+ '</dtValid>'
								Else
									cXml += '<dtValid>' + SubStr( dToS(M->RA_DTVCCNH), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTVCCNH), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTVCCNH), 7, 2 ) + '</dtValid>'
								EndIf
								If cVersEnvio >= "2.3" .And. lPriHab .And. !Empty(DtoS(M->RA_DTINCON))
									If !lMiddleware
										cXml += '<dtPriHab>'	+ DtoS(M->RA_DTINCON)		+ '</dtPriHab>'
									Else
										cXml += '<dtPriHab>' + SubStr( dToS(M->RA_DTINCON), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTINCON), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTINCON), 7, 2 ) + '</dtPriHab>'
									EndIf
								ElseIf (!lMiddleware .and. !lNT15)
									cXml += '<dtPriHab>'	+ ""		+ '</dtPriHab>'
								EndIf
								cXml += '<categoriaCnh>'+ IIf(nPosCCNH>0, aCatCNH[nPosCCNH,2], "")+ '</categoriaCnh>'
								cXml += '</CNH>'
							EndIf
							cXml += '</documentos>'
						Endif
						cXml += '<endereco>'
						//ENDERE«O
						If EMPTY(M->RA_RESEXT) .OR. M->RA_RESEXT=='2'
							cXml += '<brasil>'
							if (lNT15 .and. !empty(M->RA_LOGRTP)) .or. !lNT15
								cXml += '<tpLograd>'	+ Iif(lMiddleware, AllTrim(M->RA_LOGRTP), M->RA_LOGRTP ) + '</tpLograd>'
							endif
							cXml += '<dscLograd>'	+ M->RA_LOGRDSC	+ '</dscLograd>'
							cXml += '<nrLograd>'	+ M->RA_LOGRNUM	+ '</nrLograd>'
							If !lMiddleware .Or. !Empty(M->RA_COMPLEM)
								cXml += '<complemento>'	+ M->RA_COMPLEM 	+ '</complemento>'
							EndIf
							If !lMiddleware .Or. !Empty(M->RA_BAIRRO)
								cXml += '<bairro>'		+ M->RA_BAIRRO	+ '</bairro>'
							EndIf
							cXml += '<cep>'			+ M->RA_CEP		+ '</cep>'
							cXml += '<codMunic>'	+ Iif(lMiddleware, fEstIBGE(M->RA_ESTADO), "") + AllTrim(M->RA_CODMUN)+ '</codMunic>'
							cXml += '<uf>'			+ M->RA_ESTADO 	+ '</uf>'
							cXml += '</brasil>'
						Else
							cXml += '<exterior>'
							cXml += '<paisResid>'	+ fM23Pais(ALLTRIM(M->RA_PAISEXT)) + '</paisResid>'
							cXml += '<dscLograd>'	+ M->RA_LOGRDSC	+ '</dscLograd>'
							cXml += '<nrLograd>'	+ Iif( !Empty( M->RA_LOGRNUM ), M->RA_LOGRNUM, "S/N")	+ '</nrLograd>'
							If !lMiddleware .Or. !Empty(M->RA_COMPLEM)
								cXml += '<complemento>'	+ M->RA_COMPLEM 	+ '</complemento>'
							EndIf
							If !lMiddleware .Or. !Empty(M->RA_BAIRRO)
								cXml += '<bairro>'		+ M->RA_BAIRRO	+ '</bairro>'
							EndIf
							cXml += '<nmCid>'		+ M->RA_MUNICIP	+ '</nmCid>'
							If !lMiddleware .Or. !Empty(M->RA_CPOSTAL)
								cXml += '<codPostal>'	+ M->RA_CPOSTAL 	+ '</codPostal>'
							EndIf
							cXml += '</exterior>'
						Endif
						cXml += '</endereco>'

						//TRABALHADOR ESTRANGEIRO
						If( M->RA_CPAISOR <> "01058" .AND. !Empty( M->RA_CPAISOR ) )
							If  (cVersEnvio >= "9.0.00")
								cXml += '<trabImig>'
								cXml += '<tmpResid>' + M->RA_TIPOVIA + '</tmpResid>'																//Tempo de residÍncia do trabalhador imigrante:
								If Val(M->RA_CLASEST) == 0
									cXml += '<condIng>'+ '' + '</condIng>'
								Else
									cXml += '<condIng>'+Alltrim(Str(Val(M->RA_CLASEST))) + '</condIng>'
								Endif
								cXml += '</trabImig>'
							Else
								cXml += '<trabEstrangeiro>'
								If !lMiddleware .Or. !Empty(M->RA_DATCHEG)
									If !lMiddleware
										cXml += '<dtChegada>'	+ DtoS(M->RA_DATCHEG)   + '</dtChegada>'
									Else
										cXml += '<dtChegada>' + SubStr( dToS(M->RA_DATCHEG), 1, 4 ) + "-" + SubStr( dToS(M->RA_DATCHEG), 5, 2 ) + "-" + SubStr( dToS(M->RA_DATCHEG), 7, 2 ) + '</dtChegada>'
									EndIf
								EndIf
								If Val(M->RA_CLASEST) == 0
									cXml += '<classTrabEstrang>'+ '' + '</classTrabEstrang>'
								Else
									cXml += '<classTrabEstrang>'+Alltrim(Str(Val(M->RA_CLASEST))) + '</classTrabEstrang>'
								Endif

								If( !Empty(M->RA_CASADBR) )
									cXml += '<casadoBr>'		+ If( M->RA_CASADBR == "1", "S", "N")	+ '</casadoBr>'
								EndIf

								If( !Empty(M->RA_FILHOBR) )
									cXml += '<filhosBr>'		+ If( M->RA_FILHOBR == "1", "S", "N") 	+ '</filhosBr>'
								EndIf
								cXml += '</trabEstrangeiro>'
							Endif
						EndIf

						//INFO DEFICI NCIA

						If lMemo .OR. (M->RA_PORTDEF <> "******" .AND. !EMPTY(M->RA_PORTDEF))
							cXml += '<infoDeficiencia>'
							cXml += '<defFisica>'		+ IIf (AT("1",M->RA_PORTDEF) > 0 , "S" , "N")	+ '</defFisica>'
							cXml += '<defVisual>'		+ IIf (AT("3",M->RA_PORTDEF) > 0 , "S" , "N")	+ '</defVisual>'
							cXml += '<defAuditiva>'		+ IIf (AT("2",M->RA_PORTDEF) > 0 , "S" , "N")	+ '</defAuditiva>'
							cXml += '<defMental>'		+ IIf (AT("4",M->RA_PORTDEF) > 0 , "S" , "N")	+ '</defMental>'
							cXml += '<defIntelectual>'	+ IIf (AT("5",M->RA_PORTDEF) > 0 , "S" , "N")	+ '</defIntelectual>'
							cXml += '<reabReadap>'		+ IIf (AT("6",M->RA_PORTDEF) > 0 , "S" , "N")	+ '</reabReadap>'
							If cVersEnvio < "9.0.00" .Or. nTpRegTrab == 0
								cXml += '<infoCota>'        +   IIF(M->RA_CTPCD == '1','S','N')         + '</infoCota>'
							EndIf
							If !lMiddleware .Or. !Empty(cObsDef)
								cXml += '<observacao>'		+ cObsDef										+ '</observacao>'
							EndIf
							cXml += '</infoDeficiencia>'
						Endif

						//DEPENDENTES
						If Len(aDependent) > 0
							For nI:= 1 To Len(aDependent)
								cXml += '<dependente>'
								cXml += fTpDep(aDependent[nI],cVersEnvio)
								cXml += '<nmDep>'		+ aDependent[nI,2]	+ '</nmDep>'
								cDtDep := iif (valtype(aDependent[nI,3]) == "D",DTOS(aDependent[nI,3]),aDependent[nI,3])
								If !lMiddleware
									cXml += '<dtNascto>' + cDtDep 	+ '</dtNascto>'
								Else
									cXml += '<dtNascto>' + SubStr( cDtDep, 1, 4 ) + "-" + SubStr( cDtDep, 5, 2 ) + "-" + SubStr( cDtDep, 7, 2 ) 	+ '</dtNascto>'
								EndIf
								If !lMiddleware .Or. !Empty(aDependent[nI,4])
									cXml += '<cpfDep>'		+ aDependent[nI,4]	+ '</cpfDep>'
								EndIf
								If (cVersEnvio >= "9.0" .And. M->RA_TPPREVI == "2" )
									cXml += '<sexoDep>' + aDependent[nI,10] + '</sexoDep>'
								Endif
								cXml += '<depIRRF>'		+ aDependent[nI,5]	+ '</depIRRF>'
								cXml += '<depSF>'	    + aDependent[nI,6]  + '</depSF>'
								//Dependente Incapaz
								//Se RB_TPDEP for igual a 5 ou 11 = <incTrab> S </incTrab>
								//Se RB_INCT  for igual a 1 = <incTrab> S </incTrab>
								if (aDependent[nI,1] $ "05|11") .OR. (aDependent[nI,9] == "S")
									cXml += '<incTrab>S</incTrab>'
								else
									cXml += '<incTrab>N</incTrab>'
								Endif
								cXml += '</dependente>'
							Next nI

						ElseIf !lMiddleware
							cXml += '<dependente>'
							cXml += '</dependente>'
						Endif
						If !(cVersEnvio >= "2.4")
						//APOSENTADORIA
							cXml += '<aposentadoria>'
							cXml += '<trabAposent>'		+ IIf(M->RA_EAPOSEN=='1','S','N') + '</trabAposent>'
							cXml += '</aposentadoria>'
						EndIf
						//CONTATO
						If !lMiddleware .Or. !Empty(cFonePrinc) .Or. !Empty(cFoneAltern) .Or. !Empty(M->RA_EMAIL) .Or. !Empty(M->RA_EMAIL2)
							cXml += '<contato>'
							If !lMiddleware .Or. !Empty(cFonePrinc)
								cXml += '<fonePrinc>'		+ cFonePrinc				+ '</fonePrinc>'
							EndIf
							If (!lMiddleware .Or. !Empty(cFoneAltern)) .And. (cVersEnvio < "9.0")
								cXml += '<foneAlternat>'		+ cFoneAltern				+ '</foneAlternat>'
							EndIf
							If !lMiddleware .Or. !Empty(M->RA_EMAIL)
								cXml += '<emailPrinc>'		+ M->RA_EMAIL		+ '</emailPrinc>'
							EndIf
							If (!lMiddleware .Or. !Empty(M->RA_EMAIL2)) .And. (cVersEnvio < "9.0")
								cXml += '<emailAlternat>'	+ M->RA_EMAIL2 	+ '</emailAlternat>'
							EndIf
							cXml += '</contato>'
						EndIf
					Endif

					if cReg == 'S2205'
						cXml += '</dadosTrabalhador>'
						cXml += '</alteracao>'
						cXml += '</evtAltCadastral>'
					else
						if cReg == 'S2200' .or. cReg == 'S2100'
							cXml += '</trabalhador>'
						Endif
						//VINCULO
						If cReg == 'S2200' .or. cReg == 'S2100'
							cXml += '<vinculo>'
							if lNovoCPF
								cXml += '<matricula>' + Iif(lMiddleware, Alltrim(cNovoCodUnic), cNovoCodUnic) + '</matricula>'
							else
								cXml += '<matricula>' + Iif(lMiddleware, Alltrim(cCodUn), cCodUn) + '</matricula>'
							endif
						EndIf

						If nTpRegTrab > 0
							cXml += '<tpRegTrab>' + '2' + '</tpRegTrab>'
						Else
							cXml += '<tpRegTrab>' + '1' + '</tpRegTrab>'
						Endif

						cXml += '<tpRegPrev>' + M->RA_TPPREVI + '</tpRegPrev>'
						If cReg == 'S2200'
							If ((cVersEnvio < "9.0"))
								If !lMiddleware
									cXml += '<nrRecInfPrelim>'   + ""							+ '</nrRecInfPrelim>' //chris - verificar
								Else
									cChaveS2190	:= AllTrim( M->RA_CIC ) + DTOS( M->RA_ADMISSA )
									cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2190" + Padr(cChaveS2190, fTamRJEKey(), " ")
									cStat2190 	:= "-1"
									GetInfRJE( 2, cChaveBus, @cStat2190, Nil, Nil, Nil, @cRecib2190, Nil )
									If cStat2190 == "4" .And. !Empty(cRecib2190)
										cXml += '<nrRecInfPrelim>' + cRecib2190 + '</nrRecInfPrelim>'
									EndIf
								EndIf
							Endif
						EndIf

						If cVersEnvio >= "2.3"
							//Define de onde vem o registro: Carga ou Admiss„o
							cXml += '<cadIni>'+ AllTrim( cOrigem ) +'</cadIni>'
						EndIf
						//INFO REGIME TRABALHO
						cXml += '<infoRegimeTrab>'

						//---------------------------
						//| Celetista ou Estatut·rio
						//---------------------------
						If nTpRegTrab == 0
							//INFO CELETISTA
							cXml += '<infoCeletista>'
							if cReg == 'S2200' .or. cReg == 'S2100'
								If !lMiddleware
									cXml += '<dtAdm>' 	  + dTOS(dAdmissao)		+ '</dtAdm>'
								Else
									cXml += '<dtAdm>' + SubStr( dToS(dAdmissao), 1, 4 ) + "-" + SubStr( dToS(dAdmissao), 5, 2 ) + "-" + SubStr( dToS(dAdmissao), 7, 2 ) + '</dtAdm>'
								EndIf
								if lNovoCPF
									cXml += '<tpAdmissao>6</tpAdmissao>'
								else
									cXml += '<tpAdmissao>' + IIf(nTotVinc>0, aVinculoT[1,1],"1") + '</tpAdmissao>'
								endif
								cXml += '<indAdmissao>'+ IIf(nTotVinc>0, aVinculoT[1,2],"1") + '</indAdmissao>'
								If (cVersEnvio >= "9.0") .And. (nTotVinc > 0) .And. !(aVinculoT[1,2] $ "1*2")
									cXml += '<nrProcTrab>'+ AllTrim(aVinculoT[1,11]) +'</nrProcTrab>'
								EndIf
							Endif
							cXml += '<tpRegJor>'	  + M->RA_TPJORNA				+ '</tpRegJor>'
							cXml += '<natAtividade>'+IIf(M->RA_VIEMRAI $ ('20|25|70|75'),'2','1') + '</natAtividade>'
							If !EMPTY(M->RA_SINDICA) .AND. LEN(aSind) > 0
								nPosSind := aScan(aSind,{|x| x[1] == FWxFilial("RCE", cFilTrab) .AND. x[2] ==M->RA_SINDICA})
								If !lMiddleware .Or. nPosSind > 0
									cXml += '<dtBase>'	        + IIf (nPosSind > 0, aSind[nPosSind,4], "")	+ '</dtBase>'
								EndIf
								cXml += '<cnpjSindCategProf>'+ IIf (nPosSind > 0, aSind[nPosSind,3], "")	+ '</cnpjSindCategProf>'
							Endif

							if cReg == 'S2200' .or. cReg == 'S2100'
								//FGTS
								If cVersEnvio >= "9.0" .And. lGravaOpc
									cXml += '<FGTS>'
									cXml += '<dtOpcFGTS>'  + dTOS(dOpcao) + '</dtOpcFGTS>'
									cXml += '</FGTS>'
								ElseIf cVersEnvio < "9.0"
									cXml += '<FGTS>'
									cXml += '<opcFGTS>' 	  + nOptante					+ '</opcFGTS>'
									If !lMiddleware .Or. lGravaOpc
										If !lMiddleware
											cXml += '<dtOpcFGTS>'  + IIF(lGravaOpc, dTOS(dOpcao), "")	+ '</dtOpcFGTS>'
										Else
											cXml += '<dtOpcFGTS>' + SubStr( dToS(dOpcao), 1, 4 ) + "-" + SubStr( dToS(dOpcao), 5, 2 ) + "-" + SubStr( dToS(dOpcao), 7, 2 ) + '</dtOpcFGTS>'
										EndIf
									EndIf
									cXml += '</FGTS>'
								EndIf

								//TRABALHADOR TEMPOR¡RIO
								If M->RA_TPCONTR == '2'
									aAreaRBW := RBW->(GetArea())
									dbSelectArea("RBW")
									RBW->(dbSetOrder(1))

									If RBW->(dbSeek(cFilTrab+M->RA_MAT)) .Or. FunName() == "GPEA927"
										cXml += '					<trabTemporario>'
										cXml += '						<hipLeg>' + cMotSubs				+ '</hipLeg>'
										cXml += '						<justContr>' + cJustRBW 			+ '</justContr>'

										If (cVersEnvio < "9.0")
											if (lNT15 .and. !empty(cTpContRBW)) .or. !lNT15
												cXml += '						<tpInclContr>' + cTpContRBW		+ '</tpInclContr>'
											endif
										Endif

										If (cVersEnvio < "9.0")
											cXml += '						<ideTomadorServ>'
											cXml += '							<tpInsc>' + cTpInscRBW			+ '</tpInsc>'
											cXml += '							<nrInsc>' + cInscRBW				+ '</nrInsc>'
											//Se a inscriÁ„o do tomador foi preenchida e for diferente da insriÁ„o da empresa gera no XML
											If !Empty(cInsctRBW) .And. cInsctRBW <> cInscRBW
												cXml += '						<ideEstabVinc>'
												cXml += '							<tpInsc>' + cTpInstRBW			+ '</tpInsc>'
												cXml += '							<nrInsc>' + cInsctRBW			+ '</nrInsc>'
												cXml += '						</ideEstabVinc>'
											Endif
											cXml += '						</ideTomadorServ>'
										Endif

										If (cVersEnvio >= "9.0")
											cXml += '						<ideEstabVinc>'
											cXml += '							<tpInsc>' + cTpInscRBW			+ '</tpInsc>'
											cXml += '							<nrInsc>' + cInscRBW			+ '</nrInsc>'
											cXml += '						</ideEstabVinc>'
										Endif

										If cMotSubs == "1"
											cXml += '						<ideTrabSubstituido>'
											cXml += '							<cpfTrabSubst>' 	+ cCPFSubs	+ '</cpfTrabSubst>'
											cXml += '						</ideTrabSubstituido>'
											If !Empty(cCPF_2RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_2RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
											If !Empty(cCPF_3RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_3RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
											If !Empty(cCPF_4RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_4RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
											If !Empty(cCPF_5RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_5RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
											If !Empty(cCPF_6RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_6RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
											If !Empty(cCPF_7RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_7RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
											If !Empty(cCPF_8RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_8RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
											If !Empty(cCPF_9RBW)
												cXml += '						<ideTrabSubstituido>'
												cXml += '							<cpfTrabSubst>' 	+ cCPF_9RBW	+ '</cpfTrabSubst>'
												cXml += '						</ideTrabSubstituido>'
											Endif
										Endif

										cXml += '					</trabTemporario>'
									EndIf
									RestArea(aAreaRBW)
								Endif

								//APRENDIZ
								If M->RA_CATEFD == '103' .And. SRA->(ColumnPos("RA_TIPCTA")) > 0 .And. SRA->(ColumnPos("RA_PLAPRE")) > 0 .And. !Empty(M->RA_TIPCTA) .And. !Empty(M->RA_PLAPRE)
									cXml += '					<aprend>'
									cXml += '						<tpInsc>' + M->RA_TIPCTA + '</tpInsc>'
									cXml += '						<nrInsc>' + StrTran(FSubst(M->RA_PLAPRE), " ", "") + '</nrInsc>'
									cXml += '					</aprend>'
								Endif

								If ((cVersEnvio >= "2.6.00" .And. !Empty(cNrPrTrab)) .And. (cVersEnvio < "9.0"))
									cXml += '					<infoProcTrab>'
										cXml += '					<nrProcTrab>' + Alltrim(cNrPrTrab) + '</nrProcTrab>'
									cXml += '					</infoProcTrab>'
								Endif

							Endif
							cXml += '</infoCeletista>'

						//ESTATUTARIO
						Else
							//Se ele conseguiu alimentar as variaveis relacionadas a Agente Publico
							cXml += '<infoEstatutario>'
							If (cVersEnvio < "9.0")
								cXml += '	<indProvim>' + cIndProv + '</indProvim>'
								cXml += '	<tpProv>' + cTpProv + '</tpProv>'
								If !lMiddleware
									cXml += '	<dtNomeacao>' + dDtNome + '</dtNomeacao>'
								Else
									cXml += '	<dtNomeacao>' + SubStr( dDtNome, 1, 4 ) + "-" + SubStr( dDtNome, 5, 2 ) + "-" + SubStr( dDtNome, 7, 2 ) + '</dtNomeacao>'
								EndIf
								If !lMiddleware
									cXml += '	<dtPosse>' + dDtPosse + '</dtPosse>'
								Else
									cXml += '	<dtPosse>' + SubStr( dDtPosse, 1, 4 ) + "-" + SubStr( dDtPosse, 5, 2 ) + "-" + SubStr( dDtPosse, 7, 2 ) + '</dtPosse>'
								EndIf
								If !lMiddleware
									cXml += '	<dtExercicio>' + dDtExerc + '</dtExercicio>'
								Else
									cXml += '	<dtExercicio>' + SubStr( dDtExerc, 1, 4 ) + "-" + SubStr( dDtExerc, 5, 2 ) + "-" + SubStr( dDtExerc, 7, 2 ) + '</dtExercicio>'
								EndIf
								If !lMiddleware .Or. !Empty(cTpPlanRP)
									cXml += '	<tpPlanRP>' + cTpPlanRP + '</tpPlanRP>'
								EndIf
								If !lMiddleware .Or. !Empty(nNrPrcJd)
									cXml += '	<infoDecJud>'
									cXml += '		<nrProcJud>' + nNrPrcJd + '</nrProcJud>'
									cXml += '	</infoDecJud>'
								EndIf
							else
								cXml += '	<tpProv>' + cTpProv + '</tpProv>'
								cXml += '	<dtExercicio>' + dDtExerc + '</dtExercicio>'
								If !Empty(cTpPlanRP)
									cXml += '	<tpPlanRP>' + cTpPlanRP + '</tpPlanRP>'
								EndIf
								If !Empty(cIndTeto)
									cXml += '	<indTetoRGPS>' + If(cIndTeto == "1", "S", "N") + '</indTetoRGPS>'
								EndIf
								If !Empty(cIndAbono)
									cXml += '	<indAbonoPerm>' + If(cIndAbono == "1", "S", "N") + '</indAbonoPerm>'
								EndIf
								If !Empty(cDtIniAbo)
									cXml += '	<dtIniAbono>' + cDtIniAbo + '</dtIniAbono>'
								EndIf
							Endif
							cXml += '</infoEstatutario>'
						EndIf
						cXml += '</infoRegimeTrab>'

						//CONTRATO
						cXml += '<infoContrato>'

						If (cVersEnvio >= "9.0")
							If (!lCargSQ3)
								If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
									DbSelectArea("SRJ")
									aAreaSRJ := SRJ->(GetArea())
									SRJ->(DbSetOrder(1))

									If (SRJ->(DbSeek(xFilial("SRJ") + fGetValCpo( "RA_CODFUNC"))))
										If lAgntPub .And. cTpProv == "2"
											cXml += '<nmFuncao>' + AllTrim(SRJ->RJ_DESC) + '</nmFuncao>'
											cXml += '<CBOFuncao>' + AllTrim(SRJ->RJ_CODCBO) + '</CBOFuncao>'
										Else
											cXml += '<nmCargo>' + IIf(Findfunction("GPENorStrES"), GPENorStrES(AllTrim(SRJ->RJ_DESC)), AllTrim(SRJ->RJ_DESC)) + '</nmCargo>'
											cXml += '<CBOCargo>' + AllTrim(SRJ->RJ_CODCBO) + '</CBOCargo>'
										EndIf

										If Empty(cAcumCargo) .And. !Empty(SRJ->RJ_ACUM)
											cAcumCargo := If( SRJ->RJ_ACUM > "1", "1", "2" )
										EndIf
									Endif

									RestArea(aAreaSRJ)
								Endif
							Else
								If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CARGO"))
									DbSelectArea("SQ3")
									aAreaSQ3 := SQ3->(GetArea())
									SQ3->(DbSetOrder(1))

									If (SQ3->(DbSeek(xFilial("SQ3") + fGetValCpo( "RA_CARGO"))))
										cXml += '<nmCargo>' + AllTrim(SQ3->Q3_DESCSUM) + '</nmCargo>'
										cXml += '<CBOCargo>' + AllTrim(SQ3->Q3_CBO) + '</CBOCargo>'
									Endif

									RestArea(aAreaSQ3)
								Endif
							Endif

							If !Empty(cAcumCargo)
								cXml += '<acumCargo>' + If(cAcumCargo == "1", "S", "N") + '</acumCargo>'
							EndIf
							cXml += '<codCateg>' + AllTrim(M->RA_CATEFD) + '</codCateg>'
						Else
							//AGENTE PUBLICO COMISSIONADO
							//AlimentaÁ„o de TAG (FILIAL + FUNCAO) de acordo com Carga Inicial
							If lCargSQ3
								If lFilCargo
									If !lMiddleware .Or. !Empty(xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" ))
										cXml += '<codCargo>'  		+ xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" ) + '</codCargo>'
									EndIf
								Else
									If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CARGO" ))
										cXml += '<codCargo>'  		+ fGetValCpo( "RA_CARGO" ) + '</codCargo>'
									EndIf
								Endif
								cChaveS1030 := xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" )
								If lFilFuncao
									If !lMiddleware .Or. !Empty(xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ))
										cXml += '<codFuncao>'  		+ xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>'
									EndIf
								Else
									If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
										cXml += '<codFuncao>'  		+ fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>'
									EndIf
								Endif
								cChaveS1040 := xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" )
							Else
								If lAgntPub
									If ( cTpProv == "2" ) //2 - NomeaÁ„o em cargo em comiss„o; //S-1040
										If lFilFuncao
											If !lMiddleware .Or. !Empty(xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ))
												cXml += '<codFuncao>'  		+ xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>'
											EndIf
										Else
											If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
												cXml += '<codFuncao>'  		+ fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>'
											EndIf
										Endif
										cChaveS1040 := xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" )
									Else
										If lFilFuncao
											If !lMiddleware .Or. !Empty(xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ))
												cXml += '<codCargo>'  		+ xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ) + '</codCargo>'
											EndIf
										Else
											If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
												cXml += '<codCargo>'  		+ fGetValCpo( "RA_CODFUNC" ) + '</codCargo>'
											EndIf
										Endif
										cChaveS1030 := xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" )
									EndIf
								Else //S-1030
									If lFilFuncao
										If !lMiddleware .Or. !Empty(xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ))
											cXml += '<codCargo>'  		+ xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" ) + '</codCargo>'
										EndIf
									Else
										If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
											cXml += '<codCargo>'  		+ fGetValCpo( "RA_CODFUNC" ) + '</codCargo>'
										EndIf
									Endif
									cChaveS1030 := xFilial("SRJ", if(!Empty(cSRJFil), cSRJFil, Iif(Empty(cTFilial), cFilTrab, cTFilial))) + fGetValCpo( "RA_CODFUNC" )
								EndIf
							Endif
							cXml += '<codCateg>'  	+ M->RA_CATEFD	+ '</codCateg>'

							If lAgntPub
								If cVersEnvio < "9.0.00" .And. !Empty(cCodCarr)
									cXml += '<codCarreira>' + xFilial("RS9",cFilTrab) + cCodCarr + '</codCarreira>'
								EndIf
								If !lMiddleware .Or. !Empty(dDtIngCar)
									If !lMiddleware
										cXml += '<dtIngrCarr>' + dDtIngCar + '</dtIngrCarr>'
									Else
										cXml += '<dtIngrCarr>' + SubStr( dDtIngCar, 1, 4 ) + "-" + SubStr( dDtIngCar, 5, 2 ) + "-" + SubStr( dDtIngCar, 7, 2 ) + '</dtIngrCarr>'
									EndIf
								EndIf
							EndIf
						Endif

						// Layout 2.5 - Subgrupos ObrigatÛrios para ambos Tipos de Regime
						// SimplificaÁ„o - Subgrupos n„o devem ser gerados para Tipo de Regime Estatut·rio
						If cVersEnvio < "9.0" .Or. (cVersEnvio >= "9.0" .And. nTpRegTrab == 0)
							//REMUNERA«√O
							cXml += '<remuneracao>'
							cSalario	:= fGetValCpo( "RA_SALARIO" )
							If !lMiddleware
								cXml += '<vrSalFx>' 	+ Transform( cSalario, "@E 999999999.99" )	+ '</vrSalFx>'
							Else
								cXml += '<vrSalFx>' 	+ Alltrim(Transform(cSalario, "@R 999999999.99"))	+ '</vrSalFx>'
							EndIf

							cXml += '<undSalFixo>'+ cPgtoTrab + '</undSalFixo>'

							If cVersEnvio >= "2.3" .And. lDesRem .And. !Empty(Alltrim(M->RA_DESEPS))
								cXml += '<dscSalVar>'+ Alltrim(M->RA_DESEPS) + '</dscSalVar>'
							ElseIf !lMiddleware
								cXml += '<dscSalVar>'+ ""						+ '</dscSalVar>'
							EndIf

							cXml += '</remuneracao>'

							//DURA«√O
							cXml += '<duracao>'

							If !Empty(cTpContSVA)
								cXml += '<tpContr>'+ Alltrim(cTpContSVA) + '</tpContr>'
							Else
								cXml += '<tpContr>' 	+ IIF(Empty(M->RA_TPCONTR) .Or. M->RA_TPCONTR == "3" ,"1",M->RA_TPCONTR)	+ '</tpContr>'
							EndIf
							If !lMiddleware .Or. !Empty(M->RA_DTFIMCT)
								If !lMiddleware
									cXml += '<dtTerm>'	+ DtoS(M->RA_DTFIMCT)	+ '</dtTerm>'
								Else
									cXml += '<dtTerm>' + SubStr( dToS(M->RA_DTFIMCT), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTFIMCT), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTFIMCT), 7, 2 ) + '</dtTerm>'
								EndIf
							EndIf
							If( M->RA_TPCONTR $ "2" ) //Tipo de Contrato DETERMINADO
								cXml += '<clauAssec>' + Iif( AllTrim( M->RA_CLAURES ) == "1", "S", "N" ) + '</clauAssec>'
							EndIf

							If !Empty(cObsSVA)
								cXml += '<objDet>' + AllTrim(cObsSVA) + '</objDet>'
							End

							cXml += '</duracao>'
						EndIf

						//LOCAL DE TRABALHO
						If (M->RA_TPCONTR == '2' .And. cVersEnvio < "2.3") .OR. M->RA_TPCONTR <> '2' .Or. (M->RA_TPCONTR == '2' .And. M->RA_CATEFD <> '106' .And. cVersEnvio >= "2.3")//se for tempor·rio, vai gerar somente se vers„o anterior a 2.3
							cXml += '<localTrabalho>'
							cXml += '<localTrabGeral>'
							cXml += '<tpInsc>' 	+ cTpInscr					+ '</tpInsc>'
							cXml += '<nrInsc>'	+ cInscr					+ '</nrInsc>'
							If !lMiddleware .Or. !Empty(cDescCTT)
								cXml += '<descComp>' + cDescCTT               + '</descComp>'
							EndIf
							cXml += '</localTrabGeral>'
							cXml += '</localTrabalho>'
						ElseIf (M->RA_TPCONTR == '2' .And. M->RA_CATEFD == '106' .And. cVersEnvio >= "2.3") .And. lRbwLoct .And. !Empty(cLoct_RBW)
							If lSV6
                                aAreaSV6 := SV6->(GetArea())
								dbSelectArea("SV6")
								SV6->(dbSetOrder(1))
								If SV6->(dbSeek(xFilial("SV6",cFilTrab)+cLoct_RBW))
									cXml += '<localTrabalho>'
									If (cVersEnvio < "9.0")
										cXml += '<localTrabDom>'
										if (lNT15 .and. !empty(SV6->V6_LOGRT)) .or. !lNT15
											cXml += '<tpLograd>' + Alltrim(SV6->V6_LOGRT) + '</tpLograd>'
										endif
										cXml += '<dscLograd>' + Alltrim(SV6->V6_LOGDS) + '</dscLograd>'
										cXml += '<nrLograd>' + SV6->V6_LOGNU + '</nrLograd>'
										If !lMiddleware .Or. !Empty(SV6->V6_LOGC)
											cXml += '<complemento>'	+ Alltrim(SV6->V6_LOGC) + '</complemento>'
										EndIf
										If !lMiddleware .Or. !Empty(SV6->V6_BAIRRO)
											cXml += '<bairro>' + Alltrim(SV6->V6_BAIRRO) + '</bairro>'
										EndIf
										IF (lNT15 .and. !EMPTY(SV6->V6_CEP)) .or. !lNT15
											cXml += '<cep>' + SV6->V6_CEP + '</cep>'
										ENDIF
										cXml += '<codMunic>' + Iif(lMiddleware, fEstIBGE(SV6->V6_ESTAD), "") + SV6->V6_CODMU + '</codMunic>'
										cXml += '<uf>' + SV6->V6_ESTAD + '</uf>'
										cXml += '</localTrabDom>'
                                    Else

                                        cXml += '<localTrabGeral>'
                                        cXml += '<tpInsc>' 	+ cTpInscr					+ '</tpInsc>'
                                        cXml += '<nrInsc>'	+ cInscr					+ '</nrInsc>'
                                        If !lMiddleware .Or. !Empty(cDescCTT)
                                            cXml += '<descComp>' + cDescCTT               + '</descComp>'
                                        EndIf
                                        cXml += '</localTrabGeral>'

										cXml += '<localTempDom>'
										if (lNT15 .and. !empty(SV6->V6_LOGRT)) .or. !lNT15
											cXml += '<tpLograd>' + Alltrim(SV6->V6_LOGRT) + '</tpLograd>'
										endif
										cXml += '<dscLograd>' + Alltrim(SV6->V6_LOGDS) + '</dscLograd>'
										cXml += '<nrLograd>' + SV6->V6_LOGNU + '</nrLograd>'

                                        If !lMiddleware .Or. !Empty(SV6->V6_LOGC)
                                            cXml += '<complemento>'	+ Alltrim(SV6->V6_LOGC) + '</complemento>'
                                        EndIf
                                        If !lMiddleware .Or. !Empty(SV6->V6_BAIRRO)
                                            cXml += '<bairro>' + Alltrim(SV6->V6_BAIRRO) + '</bairro>'
                                        EndIf
                                        
										IF (lNT15 .and. !EMPTY(SV6->V6_CEP)) .or. !lNT15
											cXml += '<cep>' + SV6->V6_CEP + '</cep>'
										ENDIF

										cXml += '<codMunic>' + Iif(lMiddleware, fEstIBGE(SV6->V6_ESTAD), "") + SV6->V6_CODMU + '</codMunic>'
										cXml += '<uf>' + SV6->V6_ESTAD + '</uf>'
										cXml += '</localTempDom>'
									Endif
									cXml += '</localTrabalho>'
								EndIf
								RestArea(aAreaSV6)
							EndIf
						EndIf

						//HOR¡RIO CONTRATUAL
						If M->RA_TPJORNA $ "1|2|4"
							cXml += '<horContratual>'
							cXml += '<qtdHrsSem>'+ Iif( lMiddleware, Alltrim(Str(Int(M->RA_HRSEMAN))), Str(Int(M->RA_HRSEMAN)) ) + '</qtdHrsSem>'
							cXml += '<tpJornada>'+ cTpJorn					+ '</tpJornada>'
							If (cVersEnvio < "9.0")
								IF cTpJorn == "9"
									If lMiddleware .And. !Empty(cDscJorn)
										cXml += '<dscTpJorn>'+ Alltrim(cDscJorn)		+ '</dscTpJorn>'
									ElseIf !lMiddleware .Or. !Empty(cDscJorn)
										cXml += '<dscTpJorn>'+ cDscJorn					+ '</dscTpJorn>'
									Endif
								ENDIF
							Endif
							If cVersEnvio >= '2.4'
								If M->RA_HOPARC == "2"
									cXml += '					<tmpParc>0</tmpParc>'
								Else
									If M->RA_HRSEMAN > 0 .And. M->RA_HRSEMAN <= 25 .And. cCatEFD == "104"
										cXml += '					<tmpParc>1</tmpParc>'
									ElseIf M->RA_HRSEMAN > 0 .And. M->RA_HRSEMAN <= 26  .And. cCatEFD <> "104"
										cXml += '					<tmpParc>3</tmpParc>'
									ElseIf M->RA_HRSEMAN > 26 .And. M->RA_HRSEMAN <= 30 .And. cCatEFD <> "104"
										cXml += '					<tmpParc>2</tmpParc>'
									Else
										cXml += '					<tmpParc>0</tmpParc>'
									EndIf
								Endif
							Else
								If M->RA_HOPARC == "1"
									cXml += '					<tmpParc>S</tmpParc>'
								Else
									cXml += '					<tmpParc>N</tmpParc>'
								Endif
							EndIf

							If (cVersEnvio < "9.0")
								If Len(aTurno) > 99
									nVzsTurno := 99
								Else
									nVzsTurno := Len(aTurno)
								Endif

								For nI := 1 to nVzsTurno
									cXml += '<horario>'
									cDia := AllTrim(Str(Val(aTurno[nI,2])-1))
									cXml += '<dia>' 			+ cDia + '</dia>'
									cXml += '<codHorContrat>'+ aTurno[nI,1] + '</codHorContrat>'
									cXml += '</horario>'
								Next nI
							Else
								DbSelectArea("SR6")
								aAreaSR6 := SR6->(GetArea())
								SR6->(DbSetOrder(1))

								If (SR6->(DbSeek(xFilial("SR6") + fGetValCpo( "RA_TNOTRAB"))))
									cXml += '					<horNoturno>' + Iif(SR6->R6_ESNOTU == "1", "S", "N") + '</horNoturno>'
								Endif

								RestArea(aAreaSR6)

								If Len(aTurno) > 99
									nVzsTurno := 99
								Else
									nVzsTurno := Len(aTurno)
								Endif

								cDescJrn := ""

								If cTpJorn == "9" .And. !Empty(cDscJorn)
									cDescJrn := Left(AllTrim(cDscJorn), 999)
								Else
									For nI := 1 to nVzsTurno
										If Len(cDescJrn + aTurno[nI, 1] + ";") > 999
											EXIT
										Else
											cDescJrn += aTurno[nI, 1] + ";"
											// Acumula sequÍncias sem intervalo para impress„o no log
											nPosInt	:= At("Interv", aTurno[nI, 1])
											If nPosInt == 0
												aAdd(aJorSeq, { Substr(aTurno[nI, 1],1,27) })
											EndIf
										EndIf
									Next nI
									If Len(aJorSeq) > 0
										lJorSInt	:= .T.
									EndIf
								EndIf

								cXml += '					<dscJorn>' + cDescJrn + '</dscJorn>'

							Endif

							cXml += '</horContratual>'
						Endif

						//ALVARA JUDICIAL
						If !EMPTY(M->RA_NJUD14)
							cXml += '				<alvaraJudicial>'
							cXml += '					<nrProcJud>'+ M->RA_NJUD14	+ '</nrProcJud>'
							cXml += '				</alvaraJudicial>'
						Endif
						If IsInCallStack("f933Comm")
							cXml += cXMLS33
						ElseIf FindFunction("GPEA933") .And. Chkfile("SVA")
							cXml+= fVerSVA()
						EndIf

						If (cVersEnvio >= "9.0")
							//TREINAMENTOS, CAPACITA«’ES
							aTreiCap := GPEM017G(SRA->RA_FILIAL, SRA->RA_MAT)

							If Len(aTreiCap) > 99
								nVzsTreiCap := 99
							Else
								nVzsTreiCap := Len(aTreiCap)
							Endif

							For nI := 1 to nVzsTreiCap
								cXml += '				<treiCap>'
								cXml += '					<codTreiCap>'+ AllTrim(aTreiCap[nI, 3])	+ '</codTreiCap>'
								cXml += '				</treiCap>'
							Next nI
						Endif

						cXml += '			</infoContrato>'

						if cReg == 'S2200' .or. cReg == 'S2100'
						//SUCESSAO DE VINCULOS
							If Len(aVinculoT) > 0 .And. aVinculot[1,1] != "1"
								cXml += '<sucessaoVinc>'
								If ( cVersEnvio < "9.0" )
									If Len(aVinculoT[1]) >= 13 .And. !Empty(aVinculoT[1,13])
										cXml += '<tpInscAnt>'+aVinculoT[1,13]+'</tpInscAnt>'
									Else
										If Len(AllTrim(aVinculoT[1,4])) == 11//CPF
											cXml += '<tpInscAnt>2</tpInscAnt>'
										Else
											cXml += '<tpInscAnt>1</tpInscAnt>'
										EndIf
									EndIf
								Else
									If Len(aVinculoT[1]) >= 13 .And. !Empty(aVinculoT[1,13])
										cXml += '<tpInsc>'+aVinculoT[1,13]+'</tpInsc>'
									Else
										If Len(AllTrim(aVinculoT[1,4])) == 11//CPF
											cXml += '<tpInsc>2</tpInsc>'
										Else
											cXml += '<tpInsc>1</tpInsc>'
										EndIf
									EndIf
								EndIf
								If (cVersEnvio < "9.0")
									cXml += '<cnpjEmpregAnt>'+ aVinculoT[1,4]	+ '</cnpjEmpregAnt>'
								Else
									cXml += '<nrInsc>'+ aVinculoT[1,4]	+ '</nrInsc>'
								Endif
								If !lMiddleware .Or. !Empty(aVinculoT[1,5])
									cXml += '<matricAnt>'+ StrTran(aVinculoT[1,5], "&","&#38;" )	+ '</matricAnt>'

								EndIf
								If cVersEnvio >= "2.4"
									If !lMiddleware
										cXml += '<dtTransf>'	+ dtos(aVinculoT[1,8])	+ '</dtTransf>'
									Else
										cXml += '<dtTransf>' + SubStr( dToS(aVinculoT[1,8]), 1, 4 ) + "-" + SubStr( dToS(aVinculoT[1,8]), 5, 2 ) + "-" + SubStr( dToS(aVinculoT[1,8]), 7, 2 ) + '</dtTransf>'
									EndIf
								Else
									cXml += '<dtIniVinculo>'	+ dtos(aVinculoT[1,6])	+ '</dtIniVinculo>'
								EndIf
								cObsVinc := fSubst(aVinculoT[1,7])
								If !lMiddleware .Or. !Empty(cObsVinc)
									cXml += '<observacao>'+ cObsVinc+ '</observacao>'
								EndIf
								cXml += '</sucessaoVinc>'
							Endif
						Endif

						//Utilizado no Layout 2.3 (UnificaÁ„o do S2100 e S2200)
						If ( cVersEnvio >= "2.3" )
							//AFASTAMENTO
							If Len(aAfastam) > 0
								cXml += '			<afastamento>'
								If !lMiddleware
									cXml += '				<dtIniAfast>'	+ aAfastam[1,1]	+ '</dtIniAfast>'
								Else
									cXml += '				<dtIniAfast>' + SubStr( aAfastam[1,1], 1, 4 ) + "-" + SubStr( aAfastam[1,1], 5, 2 ) + "-" + SubStr( aAfastam[1,1], 7, 2 ) + '</dtIniAfast>'
								EndIf
								cXml += '				<codMotAfast>'	+ aAfastam[1,2]	+ '</codMotAfast>'
								cXml += '			</afastamento>'
							Endif

							//DESLIGAMENTO
							If !Empty(M->RA_DEMISSA) .And. !lGpa180 .And. (M->RA_DEMISSA < dDtCorte)
								cXml += '			<desligamento>'
								If !lMiddleware
									cXml += '				<dtDeslig>'	+ DtoS(M->RA_DEMISSA) + '</dtDeslig>'
								Else
									cXml += '				<dtDeslig>'	+ SubStr( dToS(M->RA_DEMISSA), 1, 4 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 5, 2 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 7, 2 ) + '</dtDeslig>'
								EndIf
								cXml += '			</desligamento>'
							EndIf
						EndIf

						if lNovoCPF
							cXml += '			<mudancaCPF>'
							cXml += '				<cpfAnt>'	+ RJI->RJI_CPFA + '</cpfAnt>'
							cXml += '				<matricAnt>'	+ M->RA_CODUNIC + '</matricAnt>'
							If !lMiddleware
								cXml += '				<dtAltCPF>'	+ DtoS(RJI->RJI_DTEF) + '</dtAltCPF>'
							Else
								cXml += '				<dtAltCPF>'	+ SubStr( dToS(RJI->RJI_DTEF), 1, 4 ) + "-" + SubStr( dToS(RJI->RJI_DTEF), 5, 2 ) + "-" + SubStr( dToS(RJI->RJI_DTEF), 7, 2 ) + '</dtAltCPF>'
							EndIf
							IF !EMPTY(RJI->RJI_OBS)
								cXml += '				<observacao>'+ RJI->RJI_OBS+ '</observacao>'
							ENDIF
							cXml += '			</mudancaCPF>'
						endif

						//CESSAO
						If cVersEnvio >= "9.0" .And. !Empty(cDtIniCess)
							cXml += '			<cessao>'
							cXml += '				<dtIniCessao>' + cDtIniCess + '</dtIniCessao>'
							cXml += '			</cessao>'
						EndIf

						If cVersEnvio < "2.3"
							//ASO
							If Len(aASO) > 0
								cXml += '<infoASO>'
								cXml += '<dtAsoAdm>'+ aAso[1,1]	+ '</dtAsoAdm>'
								cXml += '<nrCRM>'	+ aAso[1,3]+ '</nrCRM>'
								cXml += '<ufCRM>'	+ aAso[1,2] + '</ufCRM>'
								cXml += '</infoASO>'
							Endif
						EndIf

						if cReg == 'S2205'
							cXml += '</dadosTrabalhador>'
							cXml += '</alteracao>'
							cXml += '</evtAltCadastral>'
						elseif cReg == 'S2200'
							cXml += '</vinculo>'
							cXml += '</evtAdmissao>'
						elseif cReg == 'S2100'
							cXml += '</vinculo>'
							cXml += '</evtCadInicial>'
						Endif
					endif
					cXml += '</eSocial>'
				Else
					lGravou := .F.
					//##"AtenÁ„o"##"Categoria n„o pode ser branca"
					If lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0064), 1, 0 )
					EndIf
				EndIf
				//Fim do XML

				//Realiza geraÁ„o de XML na System
				GrvTxtArq(alltrim(cXml), cReg)

				If cVersEnvio >= "9.0" .And. lJorSInt .And. !IsBlind() .And. FUNNAME() <> "GPEM023" .And.  FUNNAME() <> "TRMA070"
					//"As seguintes SequÍncias n„o possuem Intervalo Definido - Rever cadastro de Tabela Padr„o"
					//"A falta de Intervalo Definido n„o È impeditivo para geraÁ„o do evento!"
					cMensagem := OemToAnsi(STR0271) + CRLF  + CRLF + OemToAnsi(STR0272) + CRLF  + CRLF
					For nX := 1 to Len(aJorSeq)
						cMensagem += aJorSeq[nX][1] + CRLF
					Next nX
					Help( ,, OemToAnsi(STR0001) ,,cMensagem, 1, 0 )
				EndIf

				//Enviar como parametro a filial do Protheus na posiÁ„o 1 e o XML na posiÁ„o 2
				If ( Len(aErros) > 0 ) .AND. FUNNAME() <> "GPEM023"
					//##atencao##"Funcionario: "##"N„o enviado ao TAF"
					if !IsInCallStack("f927Comm") .And. lMsgHlp
						If !lMiddleware
							Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )//" n„o enviado(a) ao TAF. Erro: "
						Else
							Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + aErros[1], 1, 0 )//" n„o enviado(a) ao Middleware. Erro: "
						EndIf
					EndIf
					lGravou := .F.
				Else
					If !lMiddleware
						If !Empty(cEmpP) .And. lTrfCNPJ
							aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", cReg,,,,,,"GPE",cTFilial,,,cEmpP, , , , , lAjustaDep)
						ElseIf Len(GetAPOInfo("TafTransfTrab.prw")) > 0
							aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", cReg,,,,,,"GPE",If(lGpa180, cTFilial, cFilDe),,,If(lGpa180, cEmpAnt, ""), , , , , lAjustaDep)
						Else
							aErros := TafPrepInt( cEmpAnt, If( lGpa180, cTFilial, cFilEnv), cXml, ,"1", cReg,,,,,,"GPE",cFilDe, , , , , , , , lAjustaDep)
						Endif
					Else
						If cEFDAviso != "2"
							//S-1005
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1005" + Padr(cChaveS1005, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							fVldPred( cVldPred, @cStatus, cChaveMid )
							If cStatus != "4"
								lS1005 := .F.
								Do Case
									Case cStatus == "-1" // nao encontrado na base de dados
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
										ElseIf lMsgHlp
											cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
										EndIf
									Case cStatus == "1" // nao enviado para o governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
										ElseIf lMsgHlp
											cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
										EndIf
									Case cStatus == "2" // enviado e aguardando retorno do governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
										ElseIf lMsgHlp
											cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
										EndIf
									Case cStatus == "3" // enviado e retornado com erro
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
										ElseIf lMsgHlp
											cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
										EndIf
								EndCase
							EndIf
							//S-1030/S-1040
							If lCargSQ3
								If !Empty(cChaveS1030)
									cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
									cStatus 	:= "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									fVldPred( cVldPred, @cStat1030, cChaveMid )
									If cStat1030 != "4"
										lS1030 := .F.
									EndIf
								EndIf
								If !Empty(cChaveS1040)
									cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1040" + Padr(cChaveS1040, 40, " ")
									cStatus 	:= "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									fVldPred( cVldPred, @cStatus, cChaveMid )
									If cStatus != "4"
										lS1040 := .F.
									EndIf
								EndIf
							Else
								If lAgntPub
									If ( cTpProv == "2" ) //2 - NomeaÁ„o em cargo em comiss„o; //S-1040
										If !Empty(cChaveS1040)
											cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1040" + Padr(cChaveS1040, 40, " ")
											cStatus 	:= "-1"
											//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
											fVldPred( cVldPred, @cStatus, cChaveMid )
											If cStatus != "4"
												lS1040 := .F.
											EndIf
										EndIf
									Else
										If !Empty(cChaveS1030)
											cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
											cStatus 	:= "-1"
											//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
											fVldPred( cVldPred, @cStat1030, cChaveMid )
											If cStat1030 != "4"
												lS1030 := .F.
											EndIf
										EndIf
									EndIf
								Else
									If !Empty(cChaveS1030)
										cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
										cStatus 	:= "-1"
										//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
										fVldPred( cVldPred, @cStat1030, cChaveMid )
										If cStat1030 != "4"
											lS1030 := .F.
										EndIf
									EndIf
								EndIf
							EndIf
							If !lS1030
								Do Case
									Case cStat1030 == "-1" // nao encontrado na base de dados
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
										EndIf
									Case cStat1030 == "1" // nao enviado para o governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
										EndIf
									Case cStat1030 == "2" // enviado e aguardando retorno do governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
										EndIf
									Case cStat1030 == "3" // enviado e retornado com erro
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
										EndIf
								EndCase
							EndIf
							If !lS1040
								Do Case
									Case cStatus == "-1" // nao encontrado na base de dados
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
										EndIf
									Case cStatus == "1" // nao enviado para o governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
										EndIf
									Case cStatus == "2" // enviado e aguardando retorno do governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
										EndIf
									Case cStatus == "3" // enviado e retornado com erro
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
										EndIf
								EndCase
							EndIf
							//S-1035
							If lAgntPub .And. !Empty(xFilial("SGY", cFilTrab) + cCodCarr)
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1035" + Padr(xFilial("SGY", cFilTrab) + cCodCarr, 40, " ")
								cStatus 	:= "-1"
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								fVldPred( cVldPred, @cStatus, cChaveMid )
								If cStatus != "4"
									lS1035 := .F.
									Do Case
										Case cStatus == "-1" // nao encontrado na base de dados
											If cEFDAviso == "1"
												aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
											ElseIf lMsgHlp
												cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
											EndIf
										Case cStatus == "1" // nao enviado para o governo
											If cEFDAviso == "1"
												aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
											ElseIf lMsgHlp
												cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
											EndIf
										Case cStatus == "2" // enviado e aguardando retorno do governo
											If cEFDAviso == "1"
												aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
											ElseIf lMsgHlp
												cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
											EndIf
										Case cStatus == "3" // enviado e retornado com erro
											If cEFDAviso == "1"
												aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
											ElseIf lMsgHlp
												cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
											EndIf
									EndCase
								EndIf
							EndIf
							If (cVersEnvio <= "2.5")
								//S-1050
								For nI := 1 to Len(aTurno)
									cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1050" + Padr(aTurno[nI, 1], 40, " ")
									cStatus 	:= "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									fVldPred( cVldPred, @cStatus, cChaveMid )
									If !(cStatus $ "1/4")
										lS1050 := .F.
										Do Case
											Case cStatus == "-1" // nao encontrado na base de dados
												If cEFDAviso == "1"
													aAdd( aErros, OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
												ElseIf lMsgHlp
													cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
												EndIf
											Case cStatus == "2" // enviado e aguardando retorno do governo
												If cEFDAviso == "1"
													aAdd( aErros, OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
												ElseIf lMsgHlp
													cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
												EndIf
											Case cStatus == "3" // enviado e retornado com erro
												If cEFDAviso == "1"
													aAdd( aErros, OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
												ElseIf lMsgHlp
													cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
												EndIf
										EndCase
										Exit
									EndIf
								Next nI
							Endif
							EndIf
						If cEFDAviso $ "0/2" .Or. (lS1005 .And. lS1030 .And. lS1035 .And. lS1040 .And. lS1050)
						 	If !Empty(cMsgHlp)
								Help( ,, OemToAnsi(STR0001) ,, cMsgHlp, 1, 0 )
							EndIf
							If Len(aDados) > 0
								If cReg == 'S2200'
									If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2200 ))
										aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
									EndIf
								ElseIf cReg == 'S2205'
									If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2205 ))
										aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
									EndIf
								Endif
							Else
								lGravou := .F.
							Endif
						ElseIf cEFDAviso == "1"
							If Len(aErros) > 0
								For nI := 1 To Len(aErros)
									cMsgHlp += aErros[nI] + CRLF
								Next
								aErros[1] := cMsgHlp
								aSize(aErros, 1)
							Endif
						EndIf
					EndIf

					If Len( aErros ) > 0
						If !IsInCallStack("GPEM023") .And. !IsInCallStack("f927Comm") .And. !IsInCallStack("f926Comm") .And. lMsgHlp
							If !lMiddleware
								Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )//" n„o enviado(a) ao TAF. Erro: "
							Else
								Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + aErros[1], 1, 0 )//" n„o enviado(a) ao Middleware. Erro: "
							EndIf
						EndIf
						lGravou := .F.
					EndIf
				EndIf
			EndIf
		End Transaction
	Else
		If ( Len(aErros) > 0 ) .And. lMsgHlp
			If !lMiddleware
				Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )//" n„o enviado(a) ao TAF. Erro: "
			Else
				Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + aErros[1], 1, 0 )//" n„o enviado(a) ao Middleware. Erro: "
			EndIf
		Endif
	EndIf

	If lMiddleware .And. !lGpa180
		fPosFil( cEmpAnt, cBkpFil )
	EndIf

	RestArea(aArea)
Return lGravou

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fInt2300 ∫Autor  ≥Marcos Coutinho Araujo ∫ Data ≥  09/05/17 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Registro Admissao Trab sem Vinculo                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEM026-                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fInt2300(cAliasSRA, lAltCad, nOpca, cReg, cTFilial, aDadosXml, cVersEnvio, lCadEst, oMdlRFS, aErros, aFilial, oMdlRFZ, cFilDe, lNovoCpf, lMostraHlp, cEmpP)
Return fInt2300New(cAliasSRA, lAltCad, nOpca, cReg, cTFilial, aDadosXml, cVersEnvio, lCadEst, oMdlRFS, aErros, aFilial, oMdlRFZ, cFilDe, lNovoCpf, lMostraHlp, cEmpP)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fCarg2300 ≥ Autor ≥ Eduardo Vicnete       ≥ Data ≥13/04/2017≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Realiza carga S-2300- Trabalhadores sem Vinculo             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥fCargVI()                                             	  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPEM023						                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fCarg2300(nPar1, aLogProc, nPar2, aDados, aPar3, nPar4, cVersEnvio, nRetifica)
Return fCar2300New(nPar1, aLogProc, nPar2, aDados, aPar3, nPar4, cVersEnvio, nRetifica)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ fGM26ASO      ≥ Autor ≥ Christiane Vieira≥ Data ≥ 08/12/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao que retorna dados do Atestado de Saude Ocupacional  ¥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ fGM26ASO(cFilial, cMatricula)                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ GPEM610                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fGM26ASO(cFil, cMat, cNat)
Local cQuery	:= ""
Local aAso		:= {}

Default cNat := "1"

If !(cNat $ "1*2")
	Return aAso
EndIf

	cQuery := " SELECT TMY_DTEMIS, TMK_ENTCLA, TMK_NUMENT "
	cQuery += " FROM "+	RetSqlName("SRA") + " SRA"
	cQuery += " INNER JOIN " + RetSqlName("TM0") + " ON "
	cQuery += " TM0_FILIAL = RA_FILIAL AND "
	cQuery += " TM0_MAT = RA_MAT "
	cQuery += " INNER JOIN " + RetSqlName("TMY") + " ON "
	cQuery += " TMY_NUMFIC = TM0_NUMFIC "
	cQuery += " INNER JOIN " + RetSqlName("TMK") + " ON "
	cQuery += " TMK_CODUSU = TMY_CODUSU "
	cQuery += " WHERE TM0_MAT = '" + cMat + "' AND "
	cQuery += " TMY_NATEXA = '" + cNat + "' AND "
	cQuery += " SRA.D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QSRA', .F., .T.)
	dbSelectArea("QSRA")
	While !QSRA->(Eof())
		If At("CRM", QSRA->TMK_ENTCLA) > 0
	 	   	Aadd(aASO,{;
	   			QSRA->TMY_DTEMIS,;
	   			Right(AllTrim(QSRA->TMK_ENTCLA),2), ;
	   			QSRA->TMK_NUMENT })
	   	Endif

		QSRA->(dbSkip())
	Enddo

	QSRA->( DbCloseArea() )
Return aASO


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fGM23Func   ∫Autor  ≥Glaucia Messina     ∫ Data ≥  28/03/14 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Carga de Funcao e CBO                                      ∫±±
±±∫          ≥ devolve em formato de Logica                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEM023- fCargVI                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fGM23Func(cAliasTAB)

	Local lTemFilial	:= .T.
	Local aAreaSRJ		:= {}

	Default cAliasTAB	:= "SRJ"

	aAreaSRJ := GetArea()

	IF !EMPTY(xFilial(cAliasTAB))
		lTemFilial := .T.
	ELSE
		lTemFilial := .F.
	ENDIF

	RestArea(aAreaSRJ)
Return(lTemFilial)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fGM23Estag  ∫Autor  ≥Glaucia Messina     ∫ Data ≥  01/04/14 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Verifica se ha cadastro de estagio, para trab sem vinculo  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEM023- fCargTSV                                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fGM23Estag(cFil,cMat, dDataRef, aEstagio, aInstit, aAgente, aCoord, lCadEst, oMdl )
Local aArea 	:= GetArea()
Local lAchou	:= .T.
Local cRFSEntid
Local cRFSAgent
Local cRFSCoord
Local cRFSDtFim
Local cRFSNatur
Local cRFSApoli
Local cRFSNivel
Local cRFSAtuac
Local lNrLogr	:= RA0->(ColumnPos("RA0_NUMEND")) > 0

Default lCadEst	:= .F.
Default oMdl := Nil

	If !lCadEst
		//---------------------------------------------
		//| Se vier da persistÍncia ou carga inicial
		//| Posiciona no banco e da carga para memÛria
		//---------------------------------------------
		DbSelectArea("RFS")
		DbSetOrder(1)
		lAchou := DbSeek( cFil + cMat )

		If lAchou
			RegToMemory("RFS",,,.F.)
			cRFSEntid := M->RFS_ENTIDA
			cRFSAgent := M->RFS_AGENTE
			cRFSCoord := M->RFS_COORD
			cRFSDtFim := M->RFS_DTFIM
			cRFSNatur := M->RFS_NATUR
			cRFSApoli := M->RFS_APOLIC
			cRFSNivel := M->RFS_NIVEL
			cRFSAtuac := M->RFS_ATUA
		EndIf

	Else
		cRFSEntid := oMdl:GetValue("RFS_ENTIDA")
		cRFSAgent := oMdl:GetValue("RFS_AGENTE")
		cRFSCoord := oMdl:GetValue("RFS_COORD")
		cRFSDtFim := oMdl:GetValue("RFS_DTFIM")
		cRFSNatur := oMdl:GetValue("RFS_NATUR")
		cRFSApoli := oMdl:GetValue("RFS_APOLIC")
		cRFSNivel := oMdl:GetValue("RFS_NIVEL")
		cRFSAtuac := oMdl:GetValue("RFS_ATUA")
	EndIf

	If lAchou
		Aadd(aEstagio,{;
			Iif( cRFSNatur == '1','O','N'),;
			AllTrim(cRFSNivel)	,;
			AllTrim(cRFSAtuac)	,;
			AllTrim(cRFSApoli)	,;
			M->RFS_DTFIM	})

		If !Empty(cRFSEntid)
			dbSelectArea("RA0")
			RA0->(DbSetOrder(1))
			If RA0->(DbSeek(FwxFilial("RA0",cFil) + cRFSEntid))
				Aadd(aInstit,{;
					RA0->RA0_CGC,;
					AllTrim(RA0->RA0_DESC),;
					AllTrim(RA0->RA0_ENDERE),;
					AllTrim(RA0->RA0_BAIRRO),;
					RA0->RA0_CEP,;
					RA0->RA0_CODMUN,;
					RA0->RA0_ESTADO,;
					Iif( lNrLogr, RA0->RA0_NUMEND, "" ) })
			EndIf
		EndIf

		If !Empty(cRFSAgent)
			dbSelectArea("RFR")
			RFR->(DbSetOrder(1))
			If RFR->(MsSeek(FwxFilial("RFR",cFil) + cRFSAgent))
				Aadd(aAgente,{;
					RFR->RFR_CNPJ,;
					AllTrim(RFR->RFR_NOME),;
					AllTrim(RFR->RFR_END),;
					AllTrim(RFR->RFR_NREND),;
					AllTrim(RFR->RFR_BAIRRO),;
					RFR->RFR_CEP,;
					RFR->RFR_CODMUN,;
					RFR->RFR_UF})
			EndIf
		EndIf

		If !Empty(cRFSCoord)
			dbSelectArea("RD0")
			RD0->(DbSetOrder(1))
			If RD0->(MsSeek(FwxFilial("RD0",cFil) + cRFSCoord))
				Aadd(aCoord,{RD0->RD0_CIC,RD0->RD0_NOME})
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fInt2206   ∫Autor  ≥Marcia Moura         ∫ Data ≥  10/05/17 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Registro Alteracao Contratal                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEA010                                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fInt2206(cAliasSRA, lAltCad, nOpca, cReg, cTFilial, dtEf, cTurno, cRegra, cSeqT, oModel, cVersEnvio, oMdlRS9, dDtAlt, lTransf, cCTT2206, aErros, lMsgHlp, lDataAlt, cSalario, cSVAObs, lGp010Auto, aRotAuto, cTafKey, cDtRGE, lJorSInt, dDtCalDis)

	Local aArea		 	:= GetArea()
	Local aAreaSR6		:= {}
	Local aAreaRS9		:= {}
	Local aAreaSV6      := {}
	Local cFilEnv    	:= ""
	Local nPosFil		:= 0
	Local nVzsTurno		:= 0
	Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
	Local nTpRegTrab	:= 0
	Local nI			:= 0
	Local aSind			:= {}
	Local aCC			:= {}
	Local nPosLot		:= 0
	Local nPosSind		:= 0
	Local nTotVinc		:= 0
	Local lAlterSal		:= .F.
	Local dAdmissao
	Local cAlsSR3		:= ""
	Local nPosEstb		:= 0
	Local aEstb			:= {}
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}
	Local aTurno		:= {}
	Local nPosTurno		:= 0
	Local cTpInsc		:= ""
	Local cTpInscr		:= ""
	Local cInscr		:= ""
	Local cDescCTT       := ""
	Local cXml			:= ""
	Local cTpJorn		:= ""
	Local lFilFuncao 	:= .T.
	Local lFilCargo 	:= .T.
	Local dDataRefP 	:= CTOD("")
	Local cDia 			:= ""
	Local aAreaSVA		:= ""
	Local cCatEFD		:= ""
	Local lGravou 		:= .T.
	Local lPpeAtiv		:= .F.
	Local lRedMP936		:= .F.
	Local dDtCorte 		:= SuperGetMV("MV_DTCGINI",nil,DDATABASE)
	Local dIniRed		:= cToD("//")
	Local cFilTrab		:= If(Empty((cAliasSRA)->RA_FILIAL) , cFilAnt, (cAliasSRA)->RA_FILIAL )
	Local lDesRem		:= SRA->(ColumnPos("RA_DESEPS")) > 0
	Local lTpJorn		:= .F.
	Local cFilSGW		:= ""
	Local cMatSRA		:= ""
	Local cMotivoSGW	:= ""
	Local cDescJorn		:= ""
	Local cPgtoTrab		:= ""
	Local cDataAlt		:= ""
	Local cTpContSVA	:= ""
	Local cObsSVA		:= ""
	Local aErroTur		:= {}
	Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)
	Local nPerRed		:= 0
	Local dFimRed		:= cToD("//")
	Local dAltRed		:= cToD("//")
	Local cSitRGE		:= ""
	Local nPosInt		:= 0
	Local nX			:= 0
	Local cMensagem		:= ""
	Local aJorSeq		:= {}
    Local cNrInsc		:= ""
	//Variavel para funcion·rio Agente P˙blico
	Local lAgntPub		:= .F.
	Local cIndProv		:= ""
	Local cTpProv		:= ""
	Local dDtNome		:= ""
	Local dDtPosse		:= ""
	Local dDtExerc		:= ""
	Local cTpPlanRP		:= ""
	Local nNrPrcJd		:= ""
	Local cCodCarr		:= ""
	Local dDtIngCar		:= ""
	Local cIndTetoRG	:= ""
	Local cIndAbonoP	:= ""

	//Vari·veis para funcion·rio tempor·rio
	Local cFilRBW		:= ""
	Local cMatRBW		:= ""
	Local cLoct_RBW     := ""
	Local lRbwLoct		:= RBW->(ColumnPos("RBW_LOCT")) > 0
	Local lSV6          := ChkFile("SV6")
	Local cMsgErro		:= ""
	Local dValRJ5		:= cToD("//")

	Local cVersMw	 	:= ""
	Local cChaveS1030	:= ""
	Local cChaveS1040	:= ""
	Local cStatus	 	:= "-1"
	Local cStat1030	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cHrGer	 	:= Time()
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cOper2206	 	:= "I"
	Local cRecib2206 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2206	 	:= "1"
	Local cStat2206	 	:= "-1"
	Local nRec2206   	:= 0
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local lS1005 	 	:= .T.
	Local lS1030 	 	:= .T.
	Local lS1035 	 	:= .T.
	Local lS1040 	 	:= .T.
	Local lS1050 	 	:= .T.
	Local lNT15			:= .F.
	Local nOpcAx	 	:= 0
	Local lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 ser„o feito pela tabela SQ3 e n„o pela SRJ (Padr„o .F. -> SRJ).
	Local lSalRedRGE	:= If(Empty(cDtRGE), .F.,.T.)
	Local lFilT 	 	:= .F.
	Local aRH5Filt	 	:= {}
	Local cCCRJ5		:= ""
	Local cMatric		:= ""
	Local aAreaSRJ      := {}
	Local aAreaSQ3      := {}
	Local aTreiCap      := {}
	Local nVzsTreiCap   := 0
	Local lTurnoOk		:= .T.
	Local lRetif2206	:= .F.
	Local aInfoCargo	:= {}
	Local cChaveSR7		:= ""
	Local cFilCg		:= ""
	Local cCodCargo		:= ""
	Local cNomeCargo	:= ""
	Local cCBOCargo		:= ""
	Local cDescJrn		:= ""
	Local cAcumCargo	:= ""
	Local lMvDtAltSa	:= SuperGetMv("MV_DTALTSA",,.T.) // .T. Integra com dDatabase(padr„o) - .F. Integra com a data do histÛrico (R3_DATA)
	Local lAltDiss		:= .T.
	Local lOpenSR3		:= .F.
	Local lGetTurn		:= .F.

	Default oMdlRS9		:= Nil
	Default cVersEnvio	:= "2.2"
	Default lAltCad		:= .F.
	Default nOpca		:= 0
	Default cReg		:= "S2206"
	Default cTFilial	:= ""
	Default cTurno		:=""
	Default cRegra		:=""
	Default cSeqT		:=""
	Default dDtAlt		:= NIL
	Default lTransf		:= .F.
	Default cCTT2206	:= "" //Se a transferÍncia for por centro de custo e este for uma obra Total, informar o centro de custo de destino
	Default aErros 		:= {}
	Default lMsgHlp		:= .T.
	Default lDataAlt	:= .F.
	DEFAULT cSalario	:= ""
	Default cSVAObs		:= ""
	Default lGp010Auto	:= .F.
	Default aRotAuto	:= {}
	Default cTafKey		:= ""
	Default cDtRGE		:= dTos(dDataBase)
	Default lJorSInt	:= .F.  // Jornada Sem Intervalo Definido
	Default dDtCalDis	:= CTOD("//")

	Private cIndRetif   := ""

	//Se a geraÁ„o  do evento S-2206 for pelo mÛdulo SIGAMDT carrega os campos em memÛria
	If ( nModulo == 35 )
		RegToMemory("SRA",,,.F.)
	EndIf

	If dDtAlt <> Nil .And. IsInCallStack("GPEM047")
		lRetif2206 := .T.
		If Empty(cSalario)
			cSalario:= fBuscaSal1(dDtAlt, cFilTrab, M->RA_MAT) //buscar o salario da epoca da alteraÁ?o
		Endif
	Endif

	// RECEBE O VALOR VINDO COMO PARAMETRO.
	nOpcAx	:= nOpca

	cDataAlt := DTOS( IIF(dDtAlt != NIL .And. lDataAlt, dDtAlt, IIF(M->RA_SITFOLH == "D" .And. dDataBase > (cAliasSRA)->RA_DEMISSA, (cAliasSRA)->RA_DEMISSA, dDataBase )))
	dValRJ5	 := IIF(dDtAlt != NIL, dDtAlt, dDataBase)

	If !lMiddleware
		If !lTransf
			fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
		Else
			fGp23Cons(@aFilInTaf, {cTFilial}, @cFilEnv)
		EndIf
	EndIf

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	If lMiddleware
		fVersEsoc( "S2206", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw, @lNT15 )
		fPosFil( cEmpAnt, cFilEnv )
		lS1000 := fVld1000( SubStr(cDataAlt, 1, 6), @cStatus )
		If !lS1000 .And. cEFDAviso != "2"
			Do Case
				Case cStatus == "-1" // nao encontrado na base de dados
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX n„o localizado na base de dados"
					EndIf
				Case cStatus == "1" // nao enviado para o governo
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX n„o transmitido para o governo"
					EndIf
				Case cStatus == "2" // enviado e aguardando retorno do governo
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
					EndIf
				Case cStatus == "3" // enviado e retornado com erro
					If cEFDAviso == "1"
						aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
					ElseIf lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
					EndIf
			EndCase
		EndIf
	Else
		fVersEsoc( "S2206", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, , , @lNT15 )
	EndIf

	dDataRefP := Date()

	lFilFuncao	:= fGM23Func()
	lFilCargo	:= fGM23Func("SQ3")
	aSind		:= fGM23Sind()
	aCC			:= fGM23CTT()
	aEstb		:= fGM23SM0(.T.,.T.)

	lMemo		:= .F.

	nPosFil := aScan(aEstb,{|x| Alltrim(x[1]) == Alltrim(cFilTrab)})

	If nPosFil > 0 .And. Len(aEstb[nPosFil]) > 3 .And. !aEstb[nPosFil,4]
		If !IsBlind()
			//"TOTVS - eSocial"
			//"Funcion·rio est· vinculado a uma filial que È uma obra, porÈm È sub-empreitada ou empreitada parcial."
			//"Funcion·rios devem estar vinculados a uma filial ou obra prÛpria da empresa. verifique Dados da Filial - MÛdulo SIGACFG"
			//"Deseja prosseguir com a gravaÁ„o do funcion·rio?"
			If !MsgYesNo( OemToAnsi(STR0077) + CRLF + CRLF + OemToAnsi(STR0078) + CRLF + CRLF + OemToAnsi(STR0079), OemToAnsi(STR0080) )
				Return (.F.)
			Endif
		Endif
	Endif

	RCA->( dbSetOrder(1) )

	If RCA->( dbSeek( xFilial("RCA", cFilTrab) + "P_LPPEATIV" ) )
		lPpeAtiv := (AllTrim(RCA->RCA_CONTEU) == ".T.")
	EndIf

	If lPpeAtiv .And. lCposRGEOk
		lRedMP936 := .T.
	EndIf

	Begin Transaction

		//CATEGORIA DO FUNCIONARIO
		cCatEFD := M->RA_CATEFD

		//VINCULO
		dAdmissao   := M->RA_ADMISSA
		nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == M->RA_VIEMRAI})//Retorno: 0-CLT | >0-Estatutario
		aVinculoT 	:= fGM23Vinc(cFilTrab, M->RA_MAT, cVersEnvio)
		nTotVinc 	:= LEN(aVinculoT)

		//--------------
		//| ESTATUTARIO
		//| Monta dados do estatut·rio
		//-----------------------------
		If nTpRegTrab > 0
			//Vindo da tela GPEA931 - Agentes Publicos
			lAgntPub := .T.
			If Funname() == "GPEA931" .AND. oMdlRS9 != Nil
				If cVersEnvio < "9.0"
					cIndProv := AllTrim( oMdlRS9:GetValue("RS9_PROES") )
					cTpProv  := AllTrim( oMdlRS9:GetValue("RS9_TPPROV") )
					dDtNome  := DtoS( oMdlRS9:GetValue("RS9_DTNOM") )
					dDtPosse := DtoS( oMdlRS9:GetValue("RS9_DTPOSS") )
					dDtExerc := DtoS( oMdlRS9:GetValue("RS9_DTEX") )
					cTpPlanRP:= AllTrim( oMdlRS9:GetValue("RS9_SEG") )
					nNrPrcJd := Alltrim( oMdlRS9:GetValue("RS9_PROC") )
					cCodCarr := AllTrim( oMdlRS9:GetValue("RS9_CAR") )
					dDtIngCar:= DtoS( oMdlRS9:GetValue("RS9_DTCAR") )
				ElseIf RS9->(ColumnPos("RS9_SEGR")) > 0
					cTpPlanRP	:= AllTrim( oMdlRS9:GetValue("RS9_SEGR") )
					cIndTetoRG	:= AllTrim( oMdlRS9:GetValue("RS9_TETORG") )
					cIndAbonoP	:= AllTrim( oMdlRS9:GetValue("RS9_ABONPE") )
					cAcumCargo	:= AllTrim( oMdlRS9:GetValue("RS9_ACUMCA") )
					cTpProv		:= AllTrim( oMdlRS9:GetValue("RS9_TIPPRV") )
				EndIf

			//Vindo do gpea010 ou Outra
			Else
				aAreaRS9 := RS9->(GetArea())
				dbSelectArea("RS9")
				RS9->(dbSetOrder(1))
				If RS9->(dbSeek(cFilTrab+M->RA_MAT))
					If cVersEnvio < "9.0"
						cIndProv := AllTrim( RS9->RS9_PROES )
						cTpProv  := AllTrim( RS9->RS9_TPPROV )
						dDtNome  := DtoS( RS9->RS9_DTNOM )
						dDtPosse := DtoS( RS9->RS9_DTPOSS )
						dDtExerc := DtoS( RS9->RS9_DTEX )
						cTpPlanRP:= AllTrim( RS9->RS9_SEG )
						nNrPrcJd := AllTrim( RS9->RS9_PROC )
						cCodCarr := AllTrim( RS9->RS9_CAR )
						dDtIngCar:= DtoS( RS9->RS9_DTCAR )
					ElseIf RS9->(ColumnPos("RS9_SEGR")) > 0
						cTpPlanRP	:= AllTrim( RS9->RS9_SEGR )
						cIndTetoRG	:= AllTrim( RS9->RS9_TETORG )
						cIndAbonoP	:= AllTrim( RS9->RS9_ABONPE )
						cAcumCargo	:= AllTrim( RS9->RS9_ACUMCA )
						cTpProv		:= AllTrim( RS9->RS9_TIPPRV )
					EndIf
				EndIf
				RestArea(aAreaRS9)
			EndIf
		EndIf

		If Empty(cSalario) .Or. IsInCallStack("IntAltSal")
			cAlsSR3:= GPR3SAL(dDTCorte, cFilTrab , M->RA_MAT, lSalRedRGE )
			lOpenSR3 := .T.
		EndIf

		//Para os cen·rios de geraÁ„o do evento S-2206 pela GPEM047 preenche data efeito em caso de dissÌdio
		If IsInCallStack("GPEM047") .And. !Empty((cAlsSR3)->R3_DTCDISS) 
			dtEf := (cAlsSR3)->R3_DATA
		EndIf

		//PRORROGA«√O DO CONTRATO DE TRABALHO TEMPORARIO
		If M->RA_TPCONTR == '2'
			If Funname() == "GPEA927" .And. oModel <> Nil .And. cVersEnvio >= "2.3"
				If oModel:GetModel("SGWDETAIL") <> Nil
					cFilSGW := oModel:GetValue("SGWDETAIL","GW_FILIAL")
					cMatSRA := oModel:GetValue("SRAMASTER","RA_MAT")
					If cFilSGW + cMatSRA == cFilTrab+M->RA_MAT
						cMotivoSGW	:= oModel:GetValue("SGWDETAIL","GW_MOTIVO")	//GW_MOTIVO
					Endif
				EndIf
			EndIf

			//TRABALHO TEMPORARIO
			aAreaRBW := RBW->(GetArea())
			dbselectArea("RBW")
			RBW->(dbSetOrder(1))

			If M->RA_CATEFD == "106"
				If Funname() == "GPEA927" .And. oModel <> Nil .And. cVersEnvio >= "2.3"
					If oModel:Getmodel("RBWDETAIL") <> Nil
						cFilRBW := oModel:GetValue("RBWDETAIL","RBW_FILIAL")
						cMatRBW := oModel:GetValue("RBWDETAIL","RBW_MAT")
						If Empty(cFilRBW)
							cFilRBW := cFilTrab
						EndIf

						If cFilRBW + cMatRBW == cFilTrab+M->RA_MAT
							If lRbwLoct
								cLoct_RBW := oModel:GetValue("RBWDETAIL","RBW_LOCT")		//RBW_LOCT
							EndIf
						Endif
					EndIf
				ElseIf (MsSeek(cFilTrab+M->RA_MAT)) .And. cVersEnvio >= "2.3"
				   If lRbwLoct
					   cLoct_RBW := RBW->RBW_LOCT
				   EndIf
				EndIf
			Endif
			RestArea(aAreaRBW)
		EndIf

		//----------------------------
		//| REMUNERACAO
		//| Realizando a lÛgica do C·lculo de Sal·rio
		//--------------------------------------------
		cPgtoTrab := fGetTpPagto(M->RA_TIPOPGT, M->RA_CATFUNC, fGetValCpo( "RA_SALARIO" ) )

		//LOCAL DE TRABALHO - conforme leiaute sempre levar do estabalecimento que esta vinculado
		//por isso retirado o controle por cento vamos sempre gerar pela Filial
		cTpInscr	:= ""
		cInscr		:= ""

		If !lVerRJ5
			If !Empty(M->RA_CC) .AND. LEN(aCC)>0
				nPosLot := aScan(aCC,{|x| x[1] == FWxFilial("CTT", IIF(Empty(cTFilial), cFilTrab, cTFilial) ) .AND. x[2] == If( Empty(cCTT2206), M->RA_CC, cCTT2206 )})
				If nPosLot > 0
					cTpInscr	:= aCC[nPosLot,3]
					cInscr		:= aCC[nPosLot,4]
					cDescCTT   := aCC[nPosLot,7]
				EndIf
			EndIf
		Else
			lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0
			If !lFilT
				RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
				If RJ5->( dbSeek( xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) + If( Empty(cCTT2206), M->RA_CC, cCTT2206 ) ) )
					While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) .And. RJ5->RJ5_CC == If( Empty(cCTT2206), M->RA_CC, cCTT2206 )
						If AnoMes(dValRJ5) >= RJ5->RJ5_INI
							cTpInscr	:= RJ5->RJ5_TPIO
							cInscr  	:= RJ5->RJ5_NIO
							cDescCTT	:= ""
						EndIf
						RJ5->( dbSkip() )
					EndDo
				EndIf
			Else
				aRH5Filt := fRJ5Filt()
				RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
				RJ5->(dbGotop())
				If Len(aRH5Filt) > 0
					If RJ5->( dbSeek( xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) + If( Empty(cCTT2206), M->RA_CC, cCTT2206 ) + IIF(Empty(cTFilial), cFilTrab, cTFilial))  )
						While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) .And. RJ5->RJ5_CC == If( Empty(cCTT2206), M->RA_CC, cCTT2206 ) .And.;
							IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == IIF(Empty(cTFilial), cFilTrab, cTFilial), .T.)
							If AnoMes(dValRJ5) >= RJ5->RJ5_INI
								cTpInscr	:= RJ5->RJ5_TPIO
								cInscr  	:= RJ5->RJ5_NIO
								cDescCTT	:= ""
								cCCRJ5 := RJ5->RJ5_COD
							EndIf
							RJ5->( dbSkip() )
						EndDo
					EndIf
				Endif
				If Len(aRH5Filt) == 0 .Or. Empty(cCCRJ5)
					If RJ5->( dbSeek( xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) + If( Empty(cCTT2206), M->RA_CC, cCTT2206 ) ) )
						While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", IIF(Empty(cTFilial), cFilTrab, cTFilial)) .And. RJ5->RJ5_CC == If( Empty(cCTT2206), M->RA_CC, cCTT2206 ) .And.;
							IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT ==IIF(Empty(cTFilial), cFilTrab, cTFilial), .T.)
							If AnoMes(dValRJ5) >= RJ5->RJ5_INI
								cTpInscr	:= RJ5->RJ5_TPIO
								cInscr  	:= RJ5->RJ5_NIO
								cDescCTT	:= ""
							EndIf
							RJ5->( dbSkip() )
						EndDo
					EndIf
				Endif
			Endif
		EndIf

		If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
			If fBuscaCAEPF( IIF(Empty(cTFilial), cFilTrab, cTFilial), @cInscr, @cTpInscr )
				cTpInscr := "3"
			EndIf
			If Empty(cTpInscr) .Or. Empty(cInscr)
				if empty(cTFilial)
					nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFilTrab)})
				else
					nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cTFilial)})
				Endif
				If nPosEstb > 0
					cTpInscr	:= aEstb[nPosEstb,3]
					cInscr		:= aEstb[nPosEstb,2]
					cDescCTT  := ""
				EndIf
			EndIf
		EndIf

		//Verifica se a linha do histÛrico salarial È devido c·lculo de dissÌdio
		lAltDiss  := !Empty(dDtCalDis) .Or. (lOpenSR3 .And. !Empty((cAlsSR3)->R3_DTCDISS))		

		//Pesquisa o Turno do Funcion·rio conforme data de alteraÁ„o quando n„o for dissÌdio:
		If !lAltDiss .And. (IsInCallStack("IntAltSal") .Or. IsInCallStack("GPEM047"))
			//Utiliza o campo R3_DATA como data de alteraÁ„o quando n„o for dissÌdio:
			If !lMvDtAltSa .And. lOpenSR3 .And. !(cAlsSR3)->(Eof())
				cDataAlt := (cAlsSR3)->R3_DATA
			EndIf
			//Pesquisa o turno conforme a data de alteraÁ„o, se usou o histÛrico guarda em lGetTurn
			//para que a funÁ„o fGM23Tur n„o busque o ˙ltimo turno na SPF
			lGetTurn := fGetTurno(SRA->RA_FILIAL, SRA->RA_MAT, cDataAlt, @cTurno, @cSeqT, @cRegra)
		EndIf
		//TIPO DE JORNADA - HOR¡RIO CONTRATUAL
			//Procura Turno
		if empty(cTurno)
			cTurno := M->RA_TNOTRAB
		endif
		if empty(cRegra)
			cRegra:=M->RA_REGRA
		Endif
		if empty(cSeqT)
			cSeqT:=(cAliasSRA)->RA_SEQTURN
		Endif

		lTurnoOk := fTurnoOk(cTurno,cRegra,cSeqT)

		aTurno	:= fGM23Tur("SRA",cTurno,cRegra,cSeqT,IIF(Empty(cTFilial), cFilTrab,cTFilial), cVersEnvio, lGetTurn)
		If Len(aTurno) > 0 .And. cVersEnvio <= "2.5"
			fGrvHorTAF("SRA", IIF(Empty(cTFilial), cFilTrab, cTFilial), cTurno, cRegra, cSeqT, If(lMiddleware, STOD(cDataAlt), dDtAlt),, @aErroTur, cVersMw)

			If Len(aErroTur) > 0
				If cEFDAviso == "1"'
					aAdd(aErros, aErroTur[1] )
				ElseIf cEFDAviso == "0"
						Help( ,, OemToAnsi(STR0001) ,, aErroTur[1], 1, 0 )//##"Hor·rio/Turno" ##"N„o enviado ao TAF." ##"Reavaliar o cadastro."
				Endif
			Endif
		EndIf

		cTpJorn := ""
		cDescJorn := ""

		lTpJorn:= fTpJorn(cTurno,@cTpJorn,@cDescJorn,cVersEnvio,IIF(Empty(cTFilial), cFilTrab,cTFilial))

		//HORARIO CONTRATUAL
		nPosTurno := 0
		If M->RA_TPJORNA $ "1|2|4" .AND. Len(aTurno) > 0 .AND. ;
			(!(EMPTY(cTurno)) .AND.  !(EMPTY(cRegra)))

			nPosTurno := 1
		EndIf

		//-------------------------------------------------------------
		//| Se o layout de trabalho for 2.5
		//-------------------------------------------------------------
		If cVersEnvio >= "2.5.00"
			If M->RA_TPCONTR == '2'
				aAreaSVA := SVA->(GetArea())
				dbSelectArea("SVA")
				SVA->(DbSetOrder(1))
				If SVA->(dbSeek(cFilTrab+M->RA_MAT+"01")) .Or. !Empty(cSVAObs)
					cTpContSVA := "3"
					If !Empty(cSVAObs)
						cObsSVA := cSVAObs
					Else
						cObsSVA := SVA->VA_OBSERV
					Endif
				EndIf
			EndIf
		EndIf

	//InÌcio da GeraÁ„o do XML
		If !(EMPTY(cFilEnv))

			If (cEFDAviso == "1" .And. Len(aErros) == 0) .Or. (cEFDAviso == "0" .And. Len(aErroTur) == 0) .Or. cEFDAviso == "2"
				//GeraÁ„o do registro S-2100 ou S-2200
				If (cCatEFD $ '101*102*103*104*105*106*107*108*111*301*302*303*306*307*309') .And. lTpJorn
					If lMiddleware
						aInfos   := fXMLInfos()
						IF Len(aInfos) >= 4
							cTpInsc  := aInfos[1]
							lAdmPubl := aInfos[4]
							cNrInsc  := aInfos[2]
							cId  	 := aInfos[3]
						Else
							cTpInsc  := ""
							lAdmPubl := .F.
							cNrInsc  := "0"
						EndIf

						cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2206" + Padr((cAliasSRA)->RA_CODUNIC, fTamRJEKey(), " ") + Space(6) + cDataAlt
						cStat2206 	:= "-1"
						GetInfRJE( 2, cChaveBus, @cStat2206, @cOper2206, @cRetf2206, @nRec2206, @cRecib2206, @cRecibAnt )

						//AlteraÁ„o ou exclus„o
						If nOpcAx == 4 .Or. nOpcAx == 5
							//Retorno pendente impede o cadastro
							If cStat2206 == "2" .And. cEFDAviso != "2"
								cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
							EndIf
							//AlteraÁ„o
							If nOpcAx == 4
								//Evento de exclus„o sem transmiss„o impede o cadastro
								If cOper2206 == "E" .And. cStat2206 != "4" .And. cEFDAviso != "2"
									cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
								//N„o existe na fila, ser· tratado como inclus„o
								ElseIf cStat2206 == "-1"
									cOperNew 	:= "I"
									cRetfNew	:= "1"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								//Evento sem transmiss„o, ir· sobrescrever o registro na fila
								ElseIf cStat2206 $ "1/3"
									cOperNew 	:= cOper2206
									cRetfNew	:= cRetf2206
									cStatNew	:= "1"
									lNovoRJE	:= .F.
								//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
								ElseIf cOper2206 != "E" .And. cStat2206 == "4"
									cOperNew 	:= "A"
									cRetfNew	:= "2"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								//Evento de exclus„o transmitido, ser· tratado como inclus„o
								ElseIf cOper2206 == "E" .And. cStat2206 == "4"
									cOperNew 	:= "I"
									cRetfNew	:= "1"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								EndIf
							//Exclus„o
							ElseIf nOpcAx == 5
								//Evento de exclus„o sem transmiss„o impede o cadastro
								If cOper2206 == "E" .And. cStat2206 != "4" .And. cEFDAviso != "2"
									cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
								//Evento diferente de exclus„o transmitido ir· gerar uma exclus„o
								ElseIf cOper2206 != "E" .And. cStat2206 == "4"
									cOperNew 	:= "E"
									cRetfNew	:= cRetf2206
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								EndIf
							EndIf
						ElseIf nOpcAx == 3 .Or. nOpcAx == 7
							//Retorno pendente impede o cadastro
							If cStat2206 == "2" .And. cEFDAviso != "2"
								cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
							//Evento de exclus„o sem transmiss„o impede o cadastro
							ElseIf cOper2206 == "E" .And. cStat2206 != "4" .And. cEFDAviso != "2"
								cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
							//Evento sem transmiss„o, ir· sobrescrever o registro na fila
							ElseIf cStat2206 $ "1/3"
								cOperNew 	:= cOper2206
								cRetfNew	:= cRetf2206
								cStatNew	:= "1"
								lNovoRJE	:= .F.
							//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
							ElseIf cOper2206 != "E" .And. cStat2206 == "4"
								cOperNew 	:= "A"
								cRetfNew	:= "2"
								cStatNew	:=  "1"
								lNovoRJE	:= .T.
							//Ser· tratado como inclus„o
							Else
								cOperNew 	:= "I"
								cRetfNew	:= "1"
								cStatNew	:= "1"
								lNovoRJE	:= .T.
							EndIf
						EndIf
						If !Empty(cMsgRJE)
							If lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" n„o enviado(a) ao Middleware. Erro: "
							Else
								aAdd( aErros, cMsgRJE )
							EndIf
							DisarmTransaction()
							Return .F.
						EndIf
						If cRetfNew == "2"
							If cStat2206 == "4"
								cRecibXML 	:= cRecib2206
								cRecibAnt	:= cRecib2206
								cRecib2206	:= ""
							Else
								cRecibXML 	:= cRecibAnt
							EndIf
						EndIf
						aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2206", Space(6), (cAliasSRA)->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, sToD(cDataAlt), cHrGer, cOperNew, cRecib2206, cRecibAnt } )
						cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtAltContratual/v" + cVersMw + "'>"
						cXML += 	"<evtAltContratual Id='" + cId + "'>"
						fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" } )
						fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
					Else
						If !Empty((cAliasSRA)->RA_CODUNIC)
							cMatric := StrTran( (cAliasSRA)->RA_CODUNIC, "&", "&#38;" )
						EndIf

						cXml += '<eSocial>'
						cXml += '	<evtAltContratual>'
					EndIf
					If FindFunction("GPEA933") .And. Chkfile("SVA")
						aErros:= fCheckStat(M->RA_CIC+";"+(cAliasSRA)->RA_CODUNIC,cFilEnv,IIF(dDtAlt == NIL,dDataBase,dDtAlt))
						cXml+= cIndRetif
					EndIf
					//TRABALHADOR
					cXml += '<ideVinculo>'
					cXml += '<cpfTrab>'    	+ ALLTRIM(M->RA_CIC)	+ '</cpfTrab>'
					// Registro de alteracao contratual
					If (cVersEnvio < "9.0")
						cXml += '<nisTrab>'    	+ ALLTRIM(M->RA_PIS)	+ '</nisTrab>'
					Endif
					cXml += '<matricula>' + Iif(lMiddleware, Alltrim((cAliasSRA)->RA_CODUNIC), cMatric)	+ '</matricula>'
					cXml += '</ideVinculo>'
					cXml += '<altContratual>'

					If ValType(cSalario) == "C"
                        cSalario := Val(StrTran(cSalario, ",", "."))
                    EndIf

					If Empty(cSalario) .Or. IsInCallStack("IntAltSal")
						if !(cAlsSR3)->(eof()) .AND. FunName() != "GPEA010"
                            If lRedMp936 .And. lSalRedRGE .And. IsInCallStack("GPEM047")
								cSalario:= fBuscaSal1(RGE->RGE_DATAIN, cFilTrab, M->RA_MAT) //buscar o salario da epoca da alteraÁ?o
							Endif

							IF cSalario == 0
								cSalario := (cAlsSR3)->R3_VALOR
							Endif
							//Se N√O FOR DISSÕDIO pesquisa os dados de cargo da Època:
							iF !lAltDiss
								cChaveSR7 := (cAlsSR3)->R3_FILIAL + (cAlsSR3)->R3_MAT + (cAlsSR3)->R3_DATA + (cAlsSR3)->R3_TIPO
								aInfoCargo := getInfCarg(lCargSQ3, "SR7", cChaveSR7)
							EndIf
							//Atualiza a data de integraÁ„o na SR3 quando n„o for executado pelo JOB
							If !IsInCallStack("IntAltSal")
								GPR3INT((cAlsSR3)->R3_FILIAL+(cAlsSR3)->R3_MAT+(cAlsSR3)->R3_DATA+(cAlsSR3)->R3_TIPO+(cAlsSR3)->R3_PD)
							EndIf
						Else
							cSalario := fGetValCpo("RA_SALARIO")
						EndIf

						If Select(cAlsSR3) > 0
							(cAlsSR3)->(dbCloseArea())
						EndIf
					EndIf

					If lRedMp936 .And. (lSalRedRGE .Or. !( IsInCallStack("IntAltSal") .Or. cSalario != SRA->RA_SALARIO .Or. lAlterSal ) )
						If IsInCallStack("GPEM047")
							fSalRed(sToD(cDtRGE), @cSalario, @dIniRed, IIf(Empty(cTFilial), cFilTrab,cTFilial), @nPerRed, @dFimRed, @dAltRed, @cSitRGE)
						Else
							fSalRed(sToD(cDataAlt), @cSalario, @dIniRed, IIf(Empty(cTFilial), cFilTrab,cTFilial), @nPerRed, @dFimRed, @dAltRed, @cSitRGE)
						EndIf
					EndIf

					If !lMiddleware
						cXml += '<dtAlteracao>' + cDataAlt  + '</dtAlteracao>'
					Else
						cXml += '<dtAlteracao>' + SubStr( cDataAlt, 1, 4 ) + "-" + SubStr( cDataAlt, 5, 2 ) + "-" + SubStr( cDataAlt, 7, 2 )  + '</dtAlteracao>'
					EndIf

					if !empty(dtEf) .And. lAltDiss
						If !lMiddleware
							cXml += ' <dtEf>' + dtEf  + '</dtEf>'
						Else
							cXml += ' <dtEf>' + SubStr( dtEf, 1, 4 ) + "-" + SubStr( dtEf, 5, 2 ) + "-" + SubStr( dtEf, 7, 2 )  + '</dtEf>'
						EndIf
					Endif

					If lGp010Auto
						If aScan( aRotAuto, { |x| x[1] == "RA_SALARIO" } ) > 0
							lAlterSal	:= .T.
						EndIf
					EndIf

					If IsInCallStack("PONA160")
						cXml += ' <dscAlt>' + If(lMiddleware,FSubst(STR0170),STR0170)  + '</dscAlt>'//"AlteraÁ„o no hor·rio contratual"
					ElseIf IsInCallStack("IntAltSal") .Or. M->RA_SALARIO != SRA->RA_SALARIO .Or. lAlterSal
						cXml += ' <dscAlt>' + If(lMiddleware,FSubst(STR0171),STR0171)  + '</dscAlt>'//"AlteraÁ„o salarial"
					Else
						cXml += ' <dscAlt>' + If(lMiddleware,FSubst(STR0172),STR0172)  + '</dscAlt>'//"AlteraÁ„o no contrato de trabalho"
					EndIf

					//VINCULO
					cXml += '<vinculo>'
					If cVersEnvio <= "2.3"
						If nTpRegTrab > 0
							cXml += '<tpRegTrab>' + '2' + '</tpRegTrab>'
						Else
							cXml += '<tpRegTrab>' + '1' + '</tpRegTrab>'
						Endif
					EndIf

					cXml += '<tpRegPrev>'     	+ M->RA_TPPREVI		+ '</tpRegPrev>'
					If (cVersEnvio < "9.0")
						cXml += '</vinculo>'
					Endif

					//INFO REGIME TRABALHO
					If cVersEnvio < "9.0" .Or. !(lAgntPub .And. M->RA_TPPREVI == "1")
						cXml += '<infoRegimeTrab>'
						//---------------------------
						//| Celetista ou Estatut·rio
						//---------------------------
						If nTpRegTrab == 0
							cXml += '<infoCeletista>'
							cXml += '<tpRegJor>'	  + M->RA_TPJORNA				+ '</tpRegJor>'
							cXml += '<natAtividade>'+IIf(M->RA_VIEMRAI $ ('20|25|70|75'),'2','1') + '</natAtividade>'
							If !EMPTY(M->RA_SINDICA) .AND. LEN(aSind) > 0
								nPosSind := aScan(aSind,{|x| x[1] == FWxFilial("RCE",cFilTrab) .AND. x[2] ==M->RA_SINDICA})
								If !lMiddleware .Or. nPosSind > 0
									cXml += '<dtBase>'	        + IIf (nPosSind > 0, aSind[nPosSind,4], "")	+ '</dtBase>'
								EndIf
								cXml += '<cnpjSindCategProf>'+ IIf (nPosSind > 0, aSind[nPosSind,3], "")	+ '</cnpjSindCategProf>'
							Endif

							//TRABALHADOR TEMPOR¡RIO
							If M->RA_TPCONTR == '2' .And. cVersEnvio >= "2.3" .And. !Empty(cMotivoSGW)
								cXml += '					<trabTemp>'
								cXml += '						<justProrr>' + Alltrim(cMotivoSGW) + '</justProrr>'
								cXml += '					</trabTemp>'
							Endif

							//APRENDIZ
							If M->RA_CATEFD == '103' .And. SRA->(ColumnPos("RA_TIPCTA")) > 0 .And. SRA->(ColumnPos("RA_PLAPRE")) > 0 .And. !Empty(M->RA_TIPCTA) .And. !Empty(M->RA_PLAPRE)
								cXml += '					<aprend>'
								cXml += '						<tpInsc>' + M->RA_TIPCTA + '</tpInsc>'
								cXml += '						<nrInsc>' + StrTran(FSubst(M->RA_PLAPRE), " ", "") + '</nrInsc>'
								cXml += '					</aprend>'
							Endif
							cXml += '</infoCeletista>'

						//ESTATUTARIO
						Else
							//Se ele conseguiu alimentar as variaveis relacionadas a Agente Publico
							If (cVersEnvio < "9.0")
								cXml += '<infoEstatutario>'
								cXml += '	<tpPlanRP>' + cTpPlanRP + '</tpPlanRP>'
								cXml += '</infoEstatutario>'
							elseIf M->RA_TPPREVI == "2"
								cXml += '<infoEstatutario>'
								cXml += '	<tpPlanRP>' + cTpPlanRP + '</tpPlanRP>'
								cXml += '	<indTetoRGPS>' + If(cIndTetoRG == "1", "S", "N") + '</indTetoRGPS>'
								cXml += '	<indAbonoPerm>' + If(cIndAbonoP == "1", "S", "N") + '</indAbonoPerm>'
								cXml += '</infoEstatutario>'
							Endif

						EndIf
						cXml += '</infoRegimeTrab>'
					EndIf

					//CONTRATO
					cXml += '<infoContrato>'

					If (cVersEnvio >= "9.0")
						If !Empty(aInfoCargo)
							cCodCargo	:= IIf(lCargSQ3, aInfoCargo[4], aInfoCargo[1])
							cNomeCargo	:= IIf(lCargSQ3, aInfoCargo[5], aInfoCargo[2])
							cCBOCargo	:= IIf(lCargSQ3, aInfoCargo[6], aInfoCargo[3])
							If !lMiddleware .Or. !Empty(cCodCargo)
								If lAgntPub .And. cTpProv == "2"
									cXml += '<nmFuncao>' + cNomeCargo + '</nmFuncao>'
									cXml += '<CBOFuncao>' + cCBOCargo + '</CBOFuncao>'
								Else
									cXml += '<nmCargo>' + cNomeCargo + '</nmCargo>'
									cXml += '<CBOCargo>' + cCBOCargo + '</CBOCargo>'
								Endif	
							EndIf
							If Empty(cAcumCargo) .And. !Empty(aInfoCargo[7])
								cAcumCargo := If( aInfoCargo[7] > "1", "1", "2")
							EndIf

						ElseIf (!lCargSQ3)
							If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
								DbSelectArea("SRJ")
								aAreaSRJ := SRJ->(GetArea())
								SRJ->(DbSetOrder(1))

								If (SRJ->(DbSeek(xFilial("SRJ") + fGetValCpo( "RA_CODFUNC"))))
									If lAgntPub .And. cTpProv == "2"
											cXml += '<nmFuncao>' + AllTrim(SRJ->RJ_DESC) + '</nmFuncao>'
											cXml += '<CBOFuncao>' + AllTrim(SRJ->RJ_CODCBO) + '</CBOFuncao>'
									Else
										cXml += '<nmCargo>' + IIf(Findfunction("GPENorStrES"), GPENorStrES(AllTrim(SRJ->RJ_DESC)), AllTrim(SRJ->RJ_DESC)) + '</nmCargo>'
										cXml += '<CBOCargo>' + AllTrim(SRJ->RJ_CODCBO) + '</CBOCargo>'
									Endif	
									If Empty(cAcumCargo) .And. !Empty(SRJ->RJ_ACUM)
										cAcumCargo := If( SRJ->RJ_ACUM > "1", "1", "2" )
									EndIf
								Endif

								RestArea(aAreaSRJ)
							Endif
						Else
							If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CARGO"))
								DbSelectArea("SQ3")
								aAreaSQ3 := SQ3->(GetArea())
								SQ3->(DbSetOrder(1))

								If (SQ3->(DbSeek(xFilial("SQ3") + fGetValCpo( "RA_CARGO"))))
									If lAgntPub .And. cTpProv == "2"
										cXml += '<nmFuncao>' + AllTrim(SQ3->Q3_DESCSUM) + '</nmFuncao>'
										cXml += '<CBOFuncao>' +AllTrim(SQ3->Q3_CBO) + '</CBOFuncao>'
									Else
										cXml += '<nmCargo>' + AllTrim(SQ3->Q3_DESCSUM) + '</nmCargo>'
										cXml += '<CBOCargo>' + AllTrim(SQ3->Q3_CBO) + '</CBOCargo>'
									Endif	
								Endif

								RestArea(aAreaSQ3)
							Endif
						Endif

						If !Empty(cAcumCargo)
							cXml += '<acumCargo>' + If(cAcumCargo == "1", "S", "N") + '</acumCargo>'
						EndIf
						cXml += '<codCateg>' + AllTrim(M->RA_CATEFD) + '</codCateg>'
					Else
						//AGENTE PUBLICO COMISSIONADO
						//AlimentaÁ„o de TAG (FILIAL + FUNCAO) de acordo com Carga Inicial
						cFilCg := IIF(Empty(cTFilial), cFilTrab, cTFilial)
						If !Empty(aInfoCargo)
							cCodFuncao	:= aInfoCargo[1]
							cCodCargo	:= aInfoCargo[4]
						Else
							cCodCargo	:= fGetValCpo( "RA_CARGO" )
							cCodFuncao	:= fGetValCpo( "RA_CODFUNC" )
						EndIf
						If lCargSQ3
							If lFilCargo
								If !lMiddleware .Or. !Empty(xFilial("SQ3", cFilCg) + cCodCargo)
									cXml += '<codCargo>' + xFilial("SQ3", cFilCg) + cCodCargo + '</codCargo>'
								EndIf
							Else
								If !lMiddleware .Or. !Empty(cCodCargo)
									cXml += '<codCargo>' + cCodCargo + '</codCargo>'
								EndIf
							Endif
							cChaveS1030 := xFilial("SQ3", cFilCg) + cCodCargo

							If lFilFuncao
								If !lMiddleware .Or. !Empty(xFilial("SRJ", cFilCg) + cCodFuncao)
									cXml += '<codFuncao>' + xFilial("SRJ", cFilCg) + cCodFuncao + '</codFuncao>'
								EndIf
							Else
								If !lMiddleware .Or. !Empty(cCodFuncao)
									cXml += '<codFuncao>' + cCodFuncao + '</codFuncao>'
								EndIf
							Endif
							cChaveS1040 := xFilial("SRJ", cFilCg) + cCodFuncao
						Else
							If lAgntPub
								If ( cTpProv == "2" ) //2 - NomeaÁ„o em cargo em comiss„o; //S-1040
									If lFilFuncao
										If !lMiddleware .Or. !Empty(xFilial("SRJ", cFilCg) + cCodFuncao)
											cXml += '<codFuncao>' + xFilial("SRJ", cFilCg) + cCodFuncao + '</codFuncao>'
										EndIf
									Else
										If !lMiddleware .Or. !Empty(cCodFuncao)
											cXml += '<codFuncao>' + cCodFuncao + '</codFuncao>'
										EndIf
									Endif
									cChaveS1040 := xFilial("SRJ", cFilCg) + cCodFuncao

								Else
									If lFilFuncao
										If !lMiddleware .Or. !Empty(xFilial("SRJ", cFilCg) + cCodFuncao)
											cXml += '<codCargo>' + xFilial("SRJ", cFilCg) + cCodFuncao + '</codCargo>'
										EndIf
									Else
										If !lMiddleware .Or. !Empty(cCodFuncao)
											cXml += '<codCargo>' + cCodFuncao + '</codCargo>'
										EndIf
									Endif
									cChaveS1030 := xFilial("SRJ", cFilCg) + cCodFuncao
								EndIf
							Else //S-1030
								If lFilFuncao
									If !lMiddleware .Or. !Empty(xFilial("SRJ", cFilCg) + cCodFuncao)
										cXml += '<codCargo>' + xFilial("SRJ", cFilCg) + cCodFuncao + '</codCargo>'
									EndIf
								Else
									If !lMiddleware .Or. !Empty(cCodFuncao)
										cXml += '<codCargo>' + cCodFuncao + '</codCargo>'
									EndIf
								Endif
								cChaveS1030 := xFilial("SRJ", cFilCg) + cCodFuncao
							EndIf
						Endif
						cXml += '<codCateg>'  	+ M->RA_CATEFD	+ '</codCateg>'

						If lAgntPub
							If !Empty(cCodCarr)
								cXml += '<codCarreira>' + xFilial("RS9",cFilTrab) + cCodCarr + '</codCarreira>'
							EndIf
							If !lMiddleware .Or. !Empty(dDtIngCar)
								If !lMiddleware
									cXml += '<dtIngrCarr>' + dDtIngCar + '</dtIngrCarr>'
								Else
									cXml += '<dtIngrCarr>' + SubStr( dDtIngCar, 1, 4 ) + "-" + SubStr( dDtIngCar, 5, 2 ) + "-" + SubStr( dDtIngCar, 7, 2 ) + '</dtIngrCarr>'
								EndIf
							EndIf
						EndIf
					Endif

					// Layout 2.5 - Subgrupos ObrigatÛrios para ambos Tipos de Regime
					// SimplificaÁ„o - Subgrupos n„o devem ser gerados para Tipo de Regime Estatut·rio
					If cVersEnvio < "9.0" .Or. (cVersEnvio >= "9.0" .And. nTpRegTrab == 0)
						//REMUNERA«√O
						cXml += '<remuneracao>'

						If !lMiddleware
							cXml += '<vrSalFx>' + Transform(cSalario, "@E 999999999.99") + '</vrSalFx>'
						Else
							cXml += '<vrSalFx>' 	+ Alltrim(Transform(cSalario, "@R 999999999.99"))	+ '</vrSalFx>'
						EndIf

						cXml += '<undSalFixo>'+ cPgtoTrab + '</undSalFixo>'

						If cVersEnvio >= '2.3' .And. lDesRem .And. !Empty(Alltrim(M->RA_DESEPS))
							cXml += '<dscSalVar>'+ Alltrim(M->RA_DESEPS) + '</dscSalVar>'
						ElseIf !lMiddleware
							cXml += '<dscSalVar>'+ ""	+ '</dscSalVar>'
						EndIf

						cXml += '</remuneracao>'

						//DURA«√O
						cXml += '<duracao>'

						If !Empty(cTpContSVA)
							cXml += '<tpContr>'+ Alltrim(cTpContSVA) + '</tpContr>'
						Else
							cXml += '<tpContr>' 	+ IIF(Empty(M->RA_TPCONTR) .Or. M->RA_TPCONTR == "3" ,"1",M->RA_TPCONTR)	+ '</tpContr>'
						EndIf

						If !lMiddleware .Or. !Empty(M->RA_DTFIMCT)
							If !lMiddleware
								cXml += '<dtTerm>'	+ DtoS(M->RA_DTFIMCT)	+ '</dtTerm>'
							Else
								cXml += '<dtTerm>'	+ SubStr( dToS(M->RA_DTFIMCT), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTFIMCT), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTFIMCT), 7, 2 )	+ '</dtTerm>'
							EndIf
						EndIf

						If !Empty(cObsSVA)
							cXml += '<objDet>' + AllTrim(cObsSVA) + '</objDet>'
						EndIf

						cXml += '</duracao>'
					EndIf

					//LOCAL DE TRABALHO
					If (M->RA_TPCONTR == '2' .And. cVersEnvio < "2.3") .OR. M->RA_TPCONTR <> '2' .Or. (M->RA_TPCONTR == '2' .And. M->RA_CATEFD <> '106' .And. cVersEnvio >= "2.3")//se for tempor·rio, vai gerar somente se vers„o anterior a 2.3
						cXml += '<localTrabalho>'
						cXml += '<localTrabGeral>'
						cXml += '<tpInsc>' 	+ cTpInscr					+ '</tpInsc>'
						cXml += '<nrInsc>'	+ cInscr					+ '</nrInsc>'
						If !lMiddleware .Or. !Empty(cDescCTT)
							cXml += '<descComp>' + cDescCTT               + '</descComp>'
						EndIf
						cXml += '</localTrabGeral>'
						cXml += '</localTrabalho>'
					ElseIf (M->RA_TPCONTR == '2' .And. M->RA_CATEFD == '106' .And. cVersEnvio >= "2.3") .And. lRbwLoct .And. !Empty(cLoct_RBW)
						If lSV6
							aAreaSV6 := SV6->(GetArea())
							dbSelectArea("SV6")
							SV6->(dbSetOrder(1))
							If SV6->(dbSeek(xFilial("SV6",cFilTrab)+cLoct_RBW))

								cXml += '<localTrabalho>'
								If (cVersEnvio < "9.0")
									cXml += '<localTrabDom>'
									if (lNT15 .and. !empty(SV6->V6_LOGRT)) .or. !lNT15
										cXml += '<tpLograd>' + Alltrim(SV6->V6_LOGRT) + '</tpLograd>'
									ENDIF
									cXml += '<dscLograd>' + Alltrim(SV6->V6_LOGDS) + '</dscLograd>'
									cXml += '<nrLograd>' + SV6->V6_LOGNU + '</nrLograd>'
									If !lMiddleware .Or. !Empty(SV6->V6_LOGC)
										cXml += '<complemento>'	+ Alltrim(SV6->V6_LOGC) + '</complemento>'
									EndIf
									If !lMiddleware .Or. !Empty(SV6->V6_BAIRRO)
										cXml += '<bairro>' + Alltrim(SV6->V6_BAIRRO) + '</bairro>'
									EndIf
									IF (lNT15 .and. !EMPTY(SV6->V6_CEP)) .or. !lNT15
										cXml += '<cep>' + SV6->V6_CEP + '</cep>'
									ENDIF
									cXml += '<codMunic>' + SV6->V6_CODMU	 + '</codMunic>'
									cXml += '<uf>' + SV6->V6_ESTAD + '</uf>'
									cXml += '</localTrabDom>'
                                Else

                                    cXml += '<localTrabGeral>'
                                    cXml += '<tpInsc>' 	+ cTpInscr					+ '</tpInsc>'
                                    cXml += '<nrInsc>'	+ cInscr					+ '</nrInsc>'
                                    If !lMiddleware .Or. !Empty(cDescCTT)
                                        cXml += '<descComp>' + cDescCTT               + '</descComp>'
                                    EndIf
                                    cXml += '</localTrabGeral>'

                                    cXml += '<localTempDom>'
                                    if (lNT15 .and. !empty(SV6->V6_LOGRT)) .or. !lNT15
                                        cXml += '<tpLograd>' + Alltrim(SV6->V6_LOGRT) + '</tpLograd>'
                                    endif
                                    cXml += '<dscLograd>' + Alltrim(SV6->V6_LOGDS) + '</dscLograd>'
                                    cXml += '<nrLograd>' + SV6->V6_LOGNU + '</nrLograd>'

									If !lMiddleware .Or. !Empty(SV6->V6_LOGC)
										cXml += '<complemento>'	+ Alltrim(SV6->V6_LOGC) + '</complemento>'
									EndIf
									If !lMiddleware .Or. !Empty(SV6->V6_BAIRRO)
										cXml += '<bairro>' + Alltrim(SV6->V6_BAIRRO) + '</bairro>'
									EndIf
                                    
                                    IF (lNT15 .and. !EMPTY(SV6->V6_CEP)) .or. !lNT15
                                        cXml += '<cep>' + SV6->V6_CEP + '</cep>'
                                    ENDIF

                                    cXml += '<codMunic>' + Iif(lMiddleware, fEstIBGE(SV6->V6_ESTAD), "") + SV6->V6_CODMU + '</codMunic>'
                                    cXml += '<uf>' + SV6->V6_ESTAD + '</uf>'
                                    cXml += '</localTempDom>'
								Endif
								cXml += '</localTrabalho>'
							EndIf
							RestArea(aAreaSV6)
						EndIf
					EndIf

					//HOR¡RIO CONTRATUAL
					If M->RA_TPJORNA $ "1|2|4"
						cXml += '<horContratual>'
						nQtdHrsSem := M->RA_HRSEMAN
						If !Empty(dIniRed)
							nQtdHrsSem := Round( ( M->RA_HRSEMAN - ( M->RA_HRSEMAN * (nPerRed/100) ) ), 2)
						EndIf
						cXml += '<qtdHrsSem>'+ Iif( lMiddleware, Alltrim(Str(nQtdHrsSem)), Str(nQtdHrsSem) ) + '</qtdHrsSem>'
						cXml += '<tpJornada>'+ cTpJorn					+ '</tpJornada>'
						If (cVersEnvio < "9.0")
							IF cTpJorn == "9" .And. (!lMiddleware .Or. !Empty(cDescJorn))
								cXml += '<dscTpJorn>'+ cDescJorn					+ '</dscTpJorn>'
							ENDIF
						Endif
						If cVersEnvio >= '2.4'
							If M->RA_HOPARC == "2"
								cXml += '					<tmpParc>0</tmpParc>'
							Else
								If M->RA_HRSEMAN > 0 .And. M->RA_HRSEMAN <= 25 .And. cCatEFD == "104"
									cXml += '					<tmpParc>1</tmpParc>'
								ElseIf M->RA_HRSEMAN > 0 .And. M->RA_HRSEMAN <= 26 .And. cCatEFD <> "104"
									cXml += '					<tmpParc>3</tmpParc>'
								ElseIf M->RA_HRSEMAN > 26 .And. M->RA_HRSEMAN <= 30 .And. cCatEFD <> "104"
									cXml += '					<tmpParc>2</tmpParc>'
								Else
									cXml += '					<tmpParc>0</tmpParc>'
								EndIf
							Endif
						Else
							If M->RA_HOPARC == "1"
								cXml += '					<tmpParc>S</tmpParc>'
							Else
								cXml += '					<tmpParc>N</tmpParc>'
							Endif
						EndIf

						If (cVersEnvio < "9.0")
							If Len(aTurno) > 99
								nVzsTurno := 99
							Else
								nVzsTurno := Len(aTurno)
							Endif

							If Empty(aTurno) .And. !lTurnoOk
								Aadd(aErros, OemToAnsi(STR0251)) //"Evento S-2206 n„o foi integrado. Motivo: Turno, Regra de Apontamento e/ou Sequencia do funcion·rio n„o foram encontrados nas respectivas tabelas impossibilitando a geraÁ„o da tag codHorContrat."
							EndIf

							For nI := 1 to nVzsTurno
								cXml += '<horario>'
								cDia := AllTrim(Str(Val(aTurno[nI,2])-1))
								cXml += '<dia>' 			+ cDia + '</dia>'
								cXml += '<codHorContrat>'+ aTurno[nI,1] + '</codHorContrat>'
								cXml += '</horario>'
							Next NI
						Else
							DbSelectArea("SR6")
							aAreaSR6 := SR6->(GetArea())
							SR6->(DbSetOrder(1))

							If (SR6->(DbSeek(xFilial("SR6") + fGetValCpo( "RA_TNOTRAB"))))
								cXml += '					<horNoturno>' + Iif(SR6->R6_ESNOTU == "1", "S", "N") + '</horNoturno>'
							Endif

							RestArea(aAreaSR6)

							If Len(aTurno) > 99
								nVzsTurno := 99
							Else
								nVzsTurno := Len(aTurno)
							Endif

							cDescJrn := ""

							If cTpJorn == "9" .And. !Empty(cDescJorn)
								cDescJrn := Left(AllTrim(cDescJorn), 999)
							Else
								For nI := 1 to nVzsTurno
									If Len(cDescJrn + aTurno[nI, 1] + ";") > 999
										EXIT
									Else
										cDescJrn += aTurno[nI, 1] + ";"
										// Acumula sequÍncias sem intervalo para impress„o no log
										nPosInt	:= At("Interv", aTurno[nI, 1])
										If nPosInt == 0
											aAdd(aJorSeq, { Substr(aTurno[nI, 1],1,27) })
										EndIf
									EndIf
								Next nI
								If Len(aJorSeq) > 0
									lJorSInt	:= .T.
								EndIf
							EndIf

							cXml += '					<dscJorn>' + cDescJrn + '</dscJorn>'

						Endif

						cXml += '</horContratual>'
					Endif

					//ALVARA JUDICIAL
					If !EMPTY(M->RA_NJUD14)
						cXml += '				<alvaraJudicial>'
						cXml += '					<nrProcJud>'+ M->RA_NJUD14	+ '</nrProcJud>'
						cXml += '				</alvaraJudicial>'
					Endif
					If FindFunction("GPEA933") .And. Chkfile("SVA")
						If IsInCallStack("f933Comm")
							cXml += cXMLS33
						Else
							cXml+= fVerSVA(Nil, !Empty(dIniRed), dIniRed, If(Empty(dAltRed) .Or. If(IsInCallStack("GPEM047"), stod(cDtRGE) <= dFimRed .And. cSitRGE != "4", stod(cDataAlt) <= dFimRed .And. cSitRGE != "4"), dFimRed, dAltRed))
						EndIf
					EndIf

					If (cVersEnvio >= "9.0")
						//TREINAMENTOS, CAPACITA«’ES
						aTreiCap := GPEM017G(SRA->RA_FILIAL, SRA->RA_MAT)

						If Len(aTreiCap) > 99
							nVzsTreiCap := 99
						Else
							nVzsTreiCap := Len(aTreiCap)
						Endif

						For nI := 1 to nVzsTreiCap
							cXml += '				<treiCap>'
							cXml += '					<codTreiCap>'+ AllTrim(aTreiCap[nI, 3])	+ '</codTreiCap>'
							cXml += '				</treiCap>'
						Next nI
					Endif

					cXml += '			</infoContrato>'
					If (cVersEnvio >= "9.0")
						cXml += '</vinculo>'
					Endif
					cXml += '	</altContratual>'
					cXml += '</evtAltContratual>'
					cXml += '</eSocial>'

					//Realiza geraÁ„o de XML na System
					GrvTxtArq(alltrim(cXml), cReg)
				Else
					If !lTpJorn							//"Tipo de Jornada no Turno de Horas escolhido est· descontinuada, favor verificar o campo R6_TPJORN."
						cDescJrn := If(cVersEnvio < "9.0", OemToAnsi(STR0063), OemToAnsi(STR0261))	//"Tipo de Jornada no Turno de Horas escolhido È invalido, favor verificar o campo R6_TPJOR1."
					Else
						cDescJrn := OemToAnsi(STR0064)	//"Categoria n„o pode ser branca"
					EndIf
					If lMsgHlp
						Help( ,, OemToAnsi(STR0001),, cDescJrn, 1, 0 ) //  "Atencao"##
					else
						aAdd(aErros, cDescJrn)
					EndIf

					lGravou := .F.
				EndIf
			EndIf
			//Fim do XML

			If lGravou .And. (cEFDAviso == "1" .And. Len(aErros) == 0) .Or. (cEFDAviso == "0" .And. Len(aErroTur) == 0) .Or. cEFDAviso == "2"
				If !lMiddleware
					//Enviar como parametro a filial do Protheus na posiÁ„o 1 e o XML na posiÁ„o 2
					If Empty(cTafKey)
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", cReg)
					Else
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, Alltrim(cTafKey) , "3", "S2206", , /*cTicket*/, , , , "GPE", , /*cPredeces*/ )
					EndIf
				Else
					If cEFDAviso != "2"
						//S-1005
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1005" + Padr(cFilAnt+cInscr, 40, " ")
						cStatus 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						fVldPred( SubStr(cDataAlt, 1, 6), @cStatus, cChaveMid )
						If cStatus != "4"
							lS1005 := .F.
							Do Case
								Case cStatus == "-1" // nao encontrado na base de dados
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
									ElseIf lMsgHlp
										cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
									EndIf
								Case cStatus == "1" // nao enviado para o governo
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
									ElseIf lMsgHlp
										cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
									EndIf
								Case cStatus == "2" // enviado e aguardando retorno do governo
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
									ElseIf lMsgHlp
										cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
									EndIf
								Case cStatus == "3" // enviado e retornado com erro
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
									ElseIf lMsgHlp
										cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
									EndIf
							EndCase
						EndIf
						//S-1030/S-1040
						If lCargSQ3
							If !Empty(cChaveS1030)
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
								cStatus 	:= "-1"
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								fVldPred( SubStr(cDataAlt, 1, 6), @cStat1030, cChaveMid )
								If cStat1030 != "4"
									lS1030 := .F.
								EndIf
							EndIf
							If !Empty(cChaveS1040)
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1040" + Padr(cChaveS1040, 40, " ")
								cStatus 	:= "-1"
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								fVldPred( SubStr(cDataAlt, 1, 6), @cStatus, cChaveMid )
								If cStatus != "4"
									lS1040 := .F.
								EndIf
							EndIf
						Else
							If lAgntPub
								If ( cTpProv == "2" ) //2 - NomeaÁ„o em cargo em comiss„o; //S-1040
									If !Empty(cChaveS1040)
										cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1040" + Padr(cChaveS1040, 40, " ")
										cStatus 	:= "-1"
										//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
										fVldPred( SubStr(cDataAlt, 1, 6), @cStatus, cChaveMid )
										If cStatus != "4"
											lS1040 := .F.
										EndIf
									EndIf
								Else
									If !Empty(cChaveS1030)
										cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
										cStatus 	:= "-1"
										//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
										fVldPred( SubStr(cDataAlt, 1, 6), @cStat1030, cChaveMid )
										If cStat1030 != "4"
											lS1030 := .F.
										EndIf
									EndIf
								EndIf
							Else
								If !Empty(cChaveS1030)
									cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
									cStatus 	:= "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									fVldPred( SubStr(cDataAlt, 1, 6), @cStat1030, cChaveMid )
									If cStat1030 != "4"
										lS1030 := .F.
									EndIf
								EndIf
							EndIf
						EndIf
						If !lS1030
							Do Case
								Case cStat1030 == "-1" // nao encontrado na base de dados
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
									EndIf
								Case cStat1030 == "1" // nao enviado para o governo
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
									EndIf
								Case cStat1030 == "2" // enviado e aguardando retorno do governo
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
									EndIf
								Case cStat1030 == "3" // enviado e retornado com erro
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
									EndIf
							EndCase
						EndIf
						If !lS1040
							Do Case
								Case cStatus == "-1" // nao encontrado na base de dados
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
									EndIf
								Case cStatus == "1" // nao enviado para o governo
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
									EndIf
								Case cStatus == "2" // enviado e aguardando retorno do governo
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
									EndIf
								Case cStatus == "3" // enviado e retornado com erro
									If cEFDAviso == "1"
										aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
									ElseIf lMsgHlp
										cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
									EndIf
							EndCase
						EndIf
						//S-1035
						If lAgntPub .And. !Empty(xFilial("SGY", cFilTrab) + cCodCarr)
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1035" + Padr(xFilial("SGY", cFilTrab) + cCodCarr, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							fVldPred( SubStr(cDataAlt, 1, 6), @cStatus, cChaveMid )
							If cStatus != "4"
								lS1035 := .F.
								Do Case
									Case cStatus == "-1" // nao encontrado na base de dados
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
										EndIf
									Case cStatus == "1" // nao enviado para o governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
										EndIf
									Case cStatus == "2" // enviado e aguardando retorno do governo
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
										EndIf
									Case cStatus == "3" // enviado e retornado com erro
										If cEFDAviso == "1"
											aAdd( aErros, OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
										ElseIf lMsgHlp
											cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1035" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
										EndIf
								EndCase
							EndIf
						EndIf
						If (cVersEnvio <= "2.5")
							//S-1050
							For nI := 1 to Len(aTurno)
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1050" + Padr(aTurno[nI, 1], 40, " ")
								cStatus 	:= "-1"
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								fVldPred( SubStr(cDataAlt, 1, 6), @cStatus, cChaveMid )
								If !(cStatus $ "1/4")
									lS1050 := .F.
									Do Case
										Case cStatus == "-1" // nao encontrado na base de dados
											If cEFDAviso == "1"
												aAdd( aErros, OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
											ElseIf lMsgHlp
												cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
											EndIf
										Case cStatus == "2" // enviado e aguardando retorno do governo
											If cEFDAviso == "1"
												aAdd( aErros, OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
											ElseIf lMsgHlp
												cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
											EndIf
										Case cStatus == "3" // enviado e retornado com erro
											If cEFDAviso == "1"
												aAdd( aErros, OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
											ElseIf lMsgHlp
												cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1050" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
											EndIf
									EndCase
									Exit
								EndIf
							Next nI
						Endif
					EndIf
					If cEFDAviso $ "0/2" .Or. (lS1005 .And. lS1030 .And. lS1035 .And. lS1040 .And. lS1050)
						If !Empty(cMsgHlp)
							Help( ,, OemToAnsi(STR0001) ,, cMsgHlp, 1, 0 )
						EndIf
						If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2206 ))
							aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
						EndIf
					ElseIf cEFDAviso == "1"
						If Len(aErros) > 0
							For nI := 1 To Len(aErros)
								cMsgHlp += aErros[nI] + CRLF
							Next
							aErros[1] := cMsgHlp
							aSize(aErros, 1)
						EndIf
					EndIf
				EndIf
			EndIf

			If Len( aErros ) > 0 .Or. Len( aErroTur ) > 0 .Or.  lJorSInt
				//##"AtenÁ„o" ##Funcionario: "##"N„o integrado"
				If lMsgHlp
					If !lMiddleware
						If Len( aErros ) > 0 .Or. Len( aErroTur ) > 0
							FeSoc2Err(Iif(Len(aErros) > 0, aErros[1], aErroTur[1]), @cMsgErro, Iif(Iif(Len(aErros) > 0, aErros[1], aErroTur[1]) != '000026', 1, 2))
							Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + M->RA_MAT + OemToAnsi(STR0036) + cMsgErro , 1, 0 )//" n„o enviado(a) ao TAF. Erro: "
						EndIf
					Else
						If Len( aErros ) > 0 .Or. Len( aErroTur ) > 0
							If cEFDAviso == "1"
								Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + M->RA_MAT + OemToAnsi(STR0137) + If( Len( aErros ) > 0, aErros[1], aErroTur[1]) , 1, 0 )//" n„o enviado(a) ao Middleware."
							ElseIf cEFDAviso == "0"
								Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + M->RA_MAT + OemToAnsi(STR0147), 1, 0 )//" Registro gravado no GPE, mas n„o enviado(a) ao Middleware"
							EndIf
						EndIf
					EndIf
				EndIf
				If lJorSInt
					If cVersEnvio >= "9.0" .And.  lJorSInt .And. !IsBlind()
						//"As seguintes SequÍncias n„o possuem Intervalo Definido - Rever cadastro de Tabela de Hor·rio Padr„o"
						//"A falta de Intervalo Definido n„o È impeditivo para geraÁ„o do evento!"
						cMensagem := OemToAnsi(STR0271) + CRLF  + CRLF + OemToAnsi(STR0272) + CRLF  + CRLF
						For nX := 1 to Len(aJorSeq)
							cMensagem += aJorSeq[nX][1] + CRLF
						Next nX
						Help( ,, OemToAnsi(STR0001) ,,cMensagem, 1, 0 )
					EndIf
				EndIf
				If Len( aErros ) > 0 .Or. Len( aErroTur ) > 0
					lGravou := .F.
				EndIf
   			EndIf
		EndIf
	End Transaction

	RestArea(aArea)
Return lGravou

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fInt2306   ∫Autor  ≥Marcos Coutinho      ∫ Data ≥  12/05/17 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Registro Alteracao Contratal do evento S-2306              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEA010                                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fInt2306(cAliasSRA, lAltCad, nOpca,cReg,cTFilial,dtEf,cVersEnvio,lCadEst, oMdlRFS, lTransf, dDtAlt, lDataAlt, aErros, lMsgHlp)
Return fInt2306New(cAliasSRA, lAltCad, nOpca,cReg,cTFilial,dtEf,cVersEnvio,lCadEst, oMdlRFS, lTransf, dDtAlt, lDataAlt, aErros, lMsgHlp)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fInt2399  ∫Autor  ≥Marcos Coutinho Araujo ∫ Data ≥ 27/06/17 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Registro Admissao Trab sem Vinculo                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥GPEM026-                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fInt2399( oModel, aErros, cReg, cCodDslg, cTpRes, aPd, dDataRes, cDiaInde, cVersEnvio, nOpc, lResComp, lRetif )
Return fInt2399New( oModel, aErros, cReg, cCodDslg, cTpRes, aPd, dDataRes, cDiaInde, cVersEnvio, nOpc, lResComp, lRetif )

/*/{Protheus.doc} fTrf2399
Funcao responsavel por realizar a integracao com o TAF na transferencia entre Grupo/Empresas diferentes
@author Guilherme Bertelli
@since 23/10/2018
@version 12.1.17
/*/
Function fTrf2399( cCodDslg, cFilEnv, cCgcPara, dDataTRF, cVersaoEnv, cMsgRet )
Return fTrf2399New( cCodDslg, cFilEnv, cCgcPara, dDataTRF, cVersaoEnv, cMsgRet )

/*/{Protheus.doc} fTpJorn(cTurno,cTpJorn,cDescJorn,cVersEnvio)
FunÁ„o para preenchimento das informaÁıes de jornada
@type  Function
@author Eduardo
@since 06/09/2017
@version 1.0
@param cTurno, param_type, cÛdigo do Turno
@param cTpJorn, param_type, Tipo da Jornada
@param cDscJorn, param_type, DescriÁ„o da jornada
@param cVersEnvio, string, Informa qual vers„o esocial esta sendo tratadol
@return lRet,boolean, Retorno se o Tipo de Jornada est· preenchido(Esse retorno È tratado na funÁ„o solicitante apenas se o layout for 2.3)
/*/
Function fTpJorn(cTurno, cTpJorn, cDscJorn, cVersEnvio, cFilTrab, lAchou, cArqSR6, cSR6Fil, cSR6Emp)
Local nTpJorn		:= 0
Local aAreaSR6		:= GetArea()
Local aTpJorn       := RetSx3Box( Posicione("SX3", 2, "R6_TPJORN", "X3CBox()" ),,, 1 )
Local lRet          := .T.

Local cAuxEmp		:= cEmpAnt
Local cAuxFil		:= cFilAnt

Default cTurno      := ""
Default cTpJorn     := ""
Default cDscJorn    := ""
Default cVersEnvio  := "2.2"
Default cFilTrab 	:= ""
Default cSR6Fil		:= ""
Default cArqSR6 	:= "SR6"
Default lAchou		:= .T.
Default cSR6Emp		:= ""

IF valtype(cSR6Emp) <> "U" .and. !EMPTY(cSR6Emp) .And. cSR6Emp != cEmpAnt
	dbSelectArea("SX2")
	dbSetOrder(1)
	If MsSeek("SR6",.F.)
		cModoFil := FWModeAccess(cArqSR6,3,cSR6Emp) + FWModeAccess(cArqSR6,2,cSR6Emp) + FWModeAccess(cArqSR6,1,cSR6Emp)
		cModo := IIF( "E" $ cModoFil   , "E", "C" )
	Else
		cModo := "E"
	Endif
	IF EmpOpenFile(cArqSR6,cArqSR6,1,.T.,cSR6Emp,@cModo)
		dbSelectArea("SX2")
		dbSetOrder(1)
		If MsSeek("SPA",.F.)
			cModoFil := FWModeAccess("SPA",3,cSR6Emp) + FWModeAccess("SPA",2,cSR6Emp) + FWModeAccess("SPA",1,cSR6Emp)
			cModo := IIF( "E" $ cModoFil   , "E", "C" )
		Else
			cModo := "E"
		Endif
		IF !EmpOpenFile("SPA","SPA",1,.T.,cSR6Emp,@cModo)
			lRet := .F.
		ENDIF
	ELSE
		lRet := .f.
	ENDIF
ENDIF

IF lRet

	If !Empty( cSR6Fil )
		cChaveSR6 := cSR6Fil + cTurno
	Else
		cChaveSR6 := xFilial((cArqSR6), cFilTrab) + cTurno
	EndIf

	dbSelectArea(cArqSR6)
	(cArqSR6)->(dbGoTop()) //Posiciona no inicio da tabela de regras
	(cArqSR6)->(dbSetOrder(1))//R6_FILIAL+R6_TURNO


	if (cArqSR6)->(dbseek(cChaveSR6)) // so gera se o turno for encontrado
		If cVersEnvio < "2.3"
			if val((cArqSR6)->R6_TPJORN) >= 1
				cTpJorn := "9"
			else
				cTpJorn := IIF((cArqSR6)->R6_TPJORN == "00", "1", "2")
			endif
			if (cArqSR6)->R6_TPJORN == "02"
				cDscJorn := "ESCALA 12 X 36"
			endif
			if (cArqSR6)->R6_TPJORN == "99"
				cDscJorn := (cArqSR6)->R6_DTPJOR
			endif
		Else
			//--------------------------------------------------------------------------
			//BLOCO A SER EXECUTADO QUANDO A VERSAO 2.3 DO ESOCIAL ESTIVER ATIVA
			//--------------------------------------------------------------------------
			If cVersEnvio < "9.0.00"
				nTpJorn:= Val((cArqSR6)->R6_TPJORN)
				If nTpJorn >= 1 .And. nTpJorn < 99
					cTpJorn :=  cvaltochar(val((cArqSR6)->R6_TPJORN))
					cDscJorn:=  (cArqSR6)->R6_DTPJOR
				EndIf
			Else
				If SR6->(ColumnPos("R6_TPJOR1")) > 0
					nTpJorn:= Val((cArqSR6)->R6_TPJOR1)
					If nTpJorn >= 1 .And. nTpJorn < 99
						cTpJorn :=  cvaltochar(val((cArqSR6)->R6_TPJOR1))
						cDscJorn:=  (cArqSR6)->R6_DTPJOR
					EndIf
				Endif
			Endif
		EndIf
	Endif
ENDIF

If Empty(cTpJorn) .And. cVersEnvio >= "2.3"
    lRet:= .F.
EndIf

Return lRet

/*/{Protheus.doc} fTpDep(aDependent,lVer23)
FunÁ„o que retorna a string xml do tipo de dependente
@type  Function
@author Eduardo
@since 08/09/2017
@version 1.0
@param aDependent, array, array com o dependente
@param lVer23, boolean, Checagem da vers„o do esocial
@return cXml,String, retorno do tipo de dependente tratando as duas versıes do eSocial.
/*/
function fTpDep(aDependent,cVersEnvio)
Local cXml:= ""

Default cVersEnvio := "2.2"
If cVersEnvio >= "2.3"
	if val(aDependent[1])<03
		cXml += '<tpDep>'+aDependent[1]+'</tpDep>'
	elseif val(aDependent[1])==03 .or. val(aDependent[1]) ==05
		cXml += '<tpDep>03</tpDep>'
	elseif val(aDependent[1])==04
		cXml += '<tpDep>04</tpDep>'
	elseif val(aDependent[1])>=06 .and. val(aDependent[1]) <=08
		cXml += '<tpDep>06</tpDep>'
	elseif val(aDependent[1])==09
		cXml += '<tpDep>09</tpDep>'
	elseif val(aDependent[1])==10
		cXml += '<tpDep>10</tpDep>'
	elseif val(aDependent[1])==11
		cXml += '<tpDep>11</tpDep>'
	elseif val(aDependent[1])==12
		cXml += '<tpDep>12</tpDep>'
	elseif val(aDependent[1])==13
		cXml += '<tpDep>99</tpDep>'
	Endif
Else
	if val(aDependent[1])<03
		cXml += '<tpDep>'+aDependent[1]+'</tpDep>'
	elseif val(aDependent[1])==03 .or. val(aDependent[1]) ==05
		cXml += '<tpDep>03</tpDep>'
	elseif val(aDependent[1])==04
		cXml += '<tpDep>08</tpDep>'
	elseif val(aDependent[1])>=06 .and. val(aDependent[1]) <=08
		cXml += '<tpDep>04</tpDep>'
	elseif val(aDependent[1])==09
		cXml += '<tpDep>05</tpDep>'
	elseif val(aDependent[1])==10
		cXml += '<tpDep>06</tpDep>'
	elseif val(aDependent[1])==11
		cXml += '<tpDep>07</tpDep>'
	elseif val(aDependent[1])==12
		cXml += '<tpDep>15</tpDep>'
	elseif val(aDependent[1])==13
		cXml += '<tpDep>99</tpDep>'
	Endif
EndIF
Return cXml

/*/{Protheus.doc} fCatEfd
Consulta FopÁıes para catefd
@type function
@author Eduardo
@since 13/12/2017
@version 1.0
@param l1Elem, ${param_type}, (DescriÁ„o do par‚metro)
@param cPreSelect, character, (DescriÁ„o do par‚metro)
@param nMaxSel, numÈrico, (DescriÁ„o do par‚metro)
@param cCpoFiltro, character, (DescriÁ„o do par‚metro)
@return lRet, lÛgico,
/*/Function fCatEfd( l1Elem , cPreSelect,nMaxSel, cCpoFiltro )

Local aNewSelect		:= {}
Local aPreSelect		:= {}
Local aArea			:= {}
Local cFilSRV			:= xFilial("RCC")
Local cTitulo			:= ""
Local MvParDef		:= ""
Local MvRetor			:= ""
Local MvParam			:= ""
Local lRet			:= .T.
Local nFor			:= 0
Local nAuxFor			:= 1
Local MvPar     		:= NIL

DEFAULT cPreSelect		:= ""
DEFAULT l1Elem			:= .F.
DEFAULT nMaxSel			:= 10
DEFAULT cCpoFiltro		:= ""
Begin Sequence

	For nFor := 1 To Len( cPreSelect ) Step 3
		aAdd( aPreSelect , SubStr( cPreSelect , nFor , 3 ) )
	Next nFor

	cAlias 	:= Alias()
	MvPar	:= &(Alltrim(ReadVar()))
	mvRet	:= Alltrim(ReadVar())

	If !( l1Elem )
		For nFor := 1 TO Len(alltrim(MvPar))
			Mvparam += Subs(MvPar,nAuxFor,3)
			MvParam += Replicate("*",3)
			nAuxFor := (nFor * 3) + 1
		Next
	Endif
	mvPar 	:= MvParam

	IF Empty( __afCatEfd__ )
		__afCatEfd__	:= BldafCatEfd( cFilSRV )
	EndIF

	IF !( lRet := !Empty( __afCatEfd__ ) )
		Help(" ",1,"GPENFILIAL")	//Cadastro de verbas nao existe para a filial
		Break
	EndIF

	For nFor := 1 To Len( __afCatEfd__ )
		IF ( aScan( aPreSelect , SubStr( __afCatEfd__[ nFor ] , 1 , 3 ) ) == 0.00 )
			If !Empty(cCpoFiltro)
				aArea:= getArea()
				dbSelectArea("RCC")
				//POSICIONA O SRV
				PosSRV(Left(__afCatEfd__[ nFor ],3), cFilSRV)
				RestArea(aArea)
				If &cCpoFiltro $ "1/S"
					MvParDef+=Left(__afCatEfd__[ nFor ],3)
					aAdd(aNewSelect , __afCatEfd__[nFor])
				EndIf
			Else
				MvParDef+=Left(__afCatEfd__[ nFor ],3)
				aAdd( aNewSelect , __afCatEfd__[ nFor ] )
			EndIf
		EndIF
	Next nFor

	IF f_Opcoes(@MvPar,cTitulo,aNewSelect,MvParDef,12,49,l1Elem,3,nMaxSel)
		For nFor := 1 To Len( mVpar ) Step 3
			IF ( SubStr( mVpar , nFor , 3 ) # "***" )
				mvRetor += SubStr( mVpar , nFor , 3 )
			Endif
		Next nFor
		&MvRet := Alltrim(Mvretor)
	EndIF

End Sequence

dbSelectArea(cAlias)

Return( lRet )

/*/{Protheus.doc} BldafCatEfd
Respons·vel por montagem do array para apresentar no fpÁıes
@type function
@author Eduardo
@since 13/12/2017
@version 1.0
@param cFilRCC, character, Filial da tabela RCC
@return aCateg, array, Vetor para montagem do FOpÁıes
/*/Static Function BldafCatEfd( cFilRCC )

Local aArea		:= GetArea()
Local aQuery	:= {}
Local aCateg	:= {}
Local cCateg	:=  '201*202*305*308*401*410*701*711*712*721*722*723*731*734*738*741*751*761*771*781*901*902*903*904*905*906'
Local bSkip		:= { || IIF( SUBSTR(RCC->RCC_CONTEU,1,3) $ cCateg , aAdd( aCateg , ( SUBSTR(RCC->RCC_CONTEU,1,3)   + " - " + SUBSTR(RCC->RCC_CONTEU,6,245) ) ),) , .F. }

#IFDEF TOP
	aQuery		:= Array( 03 )
	aQuery[01]	:= "RCC_FILIAL='"+cFilRCC+"'"
	aQuery[02]	:= " AND  RCC_CODIGO = 'S049'"
	aQuery[03]	:= " AND D_E_L_E_T_=' ' "
#ENDIF

RCC->( GdMontaCols(	NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					{				 ;
						"RCC_FILIAL"	,;
						"RCC_CODIGO"	,;
						"RCC_CONTEU"	 ;
					}				,;
					NIL				,;
					"RCC"			,;
					cFilRCC			,;
					NIL				,;
					bSkip			,;
					.F.				,;
					.F.				,;
					.F.				,;
					NIL				,;
					.F.				,;
					.F.				,;
					aQuery			,;
					.F.				,;
					.T.				,;
					.F.				,;
					.T.				,;
					.F.				,;
					.F.				,;
					.F.				 ;
				   );
	  )

RestArea( aArea )

Return( aClone( aCateg ) )

/*/{Protheus.doc} fGetTpPagto
FunÁ„o respons·vel por devolver os Tipo de Pagamento para cada trabalhador
Esta funÁ„o ser· respons·vel pela montagem das TAGs <undSalFixo>
Desenvolvido com base no roteiro de folha
@type class
@author marcos.coutinho
@since 06/02/2018
@version 1.0
@param cTpPagto (c) RA_TIPOPGT (M ou S)
@param cCatFunc (c) RA_CATFUNC (A, C, D, E, G, H, I, J, M, P, S, T)
@param cSalario
@see OpÁıes disponiveis para a tag <undSalFixo>
#1 - Por hora
#2 - Por dia
#3 - Por semana
#4 - Por quizena
#5 - Por mÍs
#6 - Por tarefa
#7 - N„o aplic·vel
/*/
Function fGetTpPagto( cTpPagto, cCatFunc, cSalario )
Local cPagamento	:= ""
Default cTpPagto	:= ""
Default cCatFunc	:= ""
Default cSalario	:= 0

// Autonomo, Comissionado, Pro-Labore, Estag Mensal, Tarefeiro, Professor Aulista
If cCatFunc $ "A|C|E|P|T|J"

	// Sem Salario (zerado)
	If cSalario == 0
		//AutÙnomo, Comissionado, Tarefeiro ou Professor sem sal·rio
		If cCatFunc $ "A|C|J"
			cPagamento := "7"
		ElseIf cCatFunc $ "T"
			cPagamento := "6"
		EndIf
	// Com Salario
	Else
		If cTpPagto == "S"
			cPagamento := "3"
		Else
			cPagamento := "5"
		EndIf
	EndIf

// Estag Horista, Horista
ElseIf cCatFunc $ "H|G"
	cPagamento := "1"

// Diarista
ElseIf cCatFunc == "D"
	cPagamento := "2"

// Semanalista
ElseIf cCatFunc == "S"
	cPagamento := "1"

// Mensalista
ElseIf cCatFunc == "M"
	cPagamento := "5"

//Professor Mensalista
Elseif cCatFunc == "I"
	cPagamento := "5"

EndIf


Return cPagamento

/*/{Protheus.doc} fGetValCpo
FunÁ„o respons·vel por retornar o conte˙do do campo
vari·vel de memÛria ou banco.
Caso o usu·rio n„o tenha acesso ao campo conforme o NÕVEL o campo n„o estar· na memÛria,
ent„o pegaremos o valor da tabela.
@type Function
@author claudinei.soares
@since 15/03/2018
@version 1.0
@param cCampo
/*/
Function fGetValCpo( cCampo )

	Local aArea		:= GetArea()
	Local xRet

	Default cCampo	:= ""

	If IsMemVar( cCampo )
		xRet := "M->" + cCampo
	Else
		xRet := "SRA->" + cCampo
	Endif

	RestArea(aArea)

Return &xRet

/*/{Protheus.doc} fInt2260
FunÁ„o respons·vel pela montagem XML e envio do evento S-2260 - ConvocaÁ„o trabalho intermitente
@type function
@author Allyson Mesashi
@since 06/08/2018
@version 1.0
@param cMsgErro	  	- Array com os erros gerados na integraÁ„o
@param cVersEnvio   - Indica a vers„o do leiaute
@param lRetif  		- Indica se dever· ser efetuada retificaÁ„o
@return lRet 		- Retorna se a integraÁ„o foi efetuada corretamente
/*/
Function fInt2260( cMsgErro, cVersEnvio, lRetif )
	Local aLocal		:= {}
	Local aTurno		:= {}
	Local cBkpFil		:= cFilAnt
	Local cDescCTT		:= ""
	Local cFilEnv		:= FTafGetFil( AllTrim( cEmpAnt ) + AllTrim( SRA->RA_FILIAL ), , , .T. )
	Local cInscr		:= ""
	Local cTpInscr		:= ""
	Local lRet			:= .T.
	Local nCont			:= 0
	Local nPosLot		:= 0

	Default cMsgErro	:= ""
	Default cVersEnvio	:= "2.4"
	Default lRetif		:= .F.

	If !Empty(cFilEnv)
		cFilAnt	:= cFilEnv
	EndIf

	If !Empty(SRA->RA_CC) .AND. Len(aCC) > 0
		nPosLot := aScan(aCC, { |x| x[1] == xFilial("CTT") .AND. x[2] == SRA->RA_CC })
		If nPosLot > 0
			//CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
			If aCC[nPosLot,6] == "01" .And. aCC[nPosLot,3] == "4" .And. aCC[nPosLot,8] == "2"
				cTpInscr	:= aCC[nPosLot,3]
				cInscr		:= aCC[nPosLot,4]
				cDescCTT   	:= aCC[nPosLot,7]
			EndIf
		EndIf
	EndIf

	If Empty(cTpInscr) .OR. Empty(cInscr)
		If fBuscaCAEPF( cFilEnv, @cInscr, @cTpInscr )
			cTpInscr := "3"
		EndIf
		If Empty(cTpInscr) .Or. Empty(cInscr)
			nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFilEnv)})
			If nPosEstb > 0
				cTpInscr	:= aEstb[nPosEstb,3]
				cInscr		:= aEstb[nPosEstb,2]
				cDescCTT  	:= ""
			EndIf
		EndIf
	EndIf

	//TIPO DE JORNADA - HOR¡RIO CONTRATUAL
	If SV7->(ColumnPos( "V7_REGRA" )) > 0 .AND. SV7->(ColumnPos( "V7_SEQTURN" )) > 0
		If !Empty(SV7->V7_TURNO) .And. !Empty(SV7->V7_REGRA) .And. !Empty(SV7->V7_SEQTURN)
			aTurno    := fGM23Tur("SRA", SV7->V7_TURNO, SV7->V7_REGRA, SV7->V7_SEQTURN, cFilEnv )
			fGrvHorTAF("SRA", cFilEnv, SV7->V7_TURNO, SV7->V7_REGRA, SV7->V7_SEQTURN)
		EndIf
	Endif

	//Efetua a integracao do evento S-2260 com TAF
	If !Empty(cFilEnv)
		cXml := ''
		cXml += '<eSocial>'
			cXml += '<evtConvInterm>'
				cXml += '<ideEvento>'
					cXml += '<indRetif>' + Iif( lRetif, "2", "1" ) + '</indRetif>'
				cXml += '</ideEvento>'
				cXml += '<ideEmpregador>'
					cXml += '<tpInsc>' + cTpInscr + '</tpInsc>'
					cXml += '<nrInsc>' + cInscr + '</nrInsc>'
				cXml += '</ideEmpregador>'
				cXml += '<ideVinculo>'
					cXml += '<cpfTrab>' + SRA->RA_CIC + '</cpfTrab>'
					cXml += '<nisTrab>' + SRA->RA_PIS + '</nisTrab>'
					cXml += '<matricula>' + Iif(lMiddleware, Alltrim(SRA->RA_CODUNIC), SRA->RA_CODUNIC) + '</matricula>'
				cXml += '</ideVinculo>'
				cXml += '<infoConvInterm>'
					cXml += '<codConv>' + SV7->V7_CONVC + '</codConv>'
					cXml += '<dtInicio>' + dToS(SV7->V7_DTINI) + '</dtInicio>'
					cXml += '<dtFim>' + dToS(SV7->V7_DTFIM) + '</dtFim>'
					cXml += '<dtPrevPgto>' + dToS(SV7->V7_DPREVPG) + '</dtPrevPgto>'
					cXml += '<jornada>'
					If Len(aTurno) > 0
						cXml += '<codHorContrat>' + aTurno[1,1] + '</codHorContrat>'
					Else
						cXml += '<dscJornada>' + fDesc("SR6",SV7->V7_TURNO,"R6_DESC",,cFilEnv) + '</dscJornada>'
					EndIf
					cXml += '</jornada>'
					cXml += '<localTrab>'
						cXml += '<indLocal>' + SV7->V7_TPLOC + '</indLocal>'
						If SV7->V7_TPLOC == "1"
							aLocal := fLocalTrab(SV7->V7_FILIAL, SV7->V7_LOCAL)
							cXml += '<localTrabInterm>'
							For nCont := 1 To Len(aLocal)
								cXml += '<tpLograd>' + aLocal[nCont, 1] + '</tpLograd>'
								cXml += '<dscLograd>' + aLocal[nCont, 2] + '</dscLograd>'
								cXml += '<nrLograd>' + aLocal[nCont, 3] + '</nrLograd>'
								cXml += '<complem>' + aLocal[nCont, 4] + '</complem>'
								cXml += '<bairro>' + aLocal[nCont, 5] + '</bairro>'
								cXml += '<cep>' + aLocal[nCont, 6] + '</cep>'
								cXml += '<codMunic>' + aLocal[nCont, 7] + '</codMunic>'
								cXml += '<uf>' + aLocal[nCont,8 ] + '</uf>'
							Next
							cXml += '</localTrabInterm>'
						EndIf
					cXml += '</localTrab>'
				cXml += '</infoConvInterm>'
			cXml += '</evtConvInterm>'
		cXml += '</eSocial>'

		//Realiza geraÁ„o de XML na System
		GrvTxtArq(alltrim(cXml), "S2260")

		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2260")
		If Len(aErros) > 0
			FeSoc2Err( aErros[1], @cMsgErro, IIF(aErros[1] != '000026', 1, 2) )
			If aErros[1] == '000026'
			    lRet := .T.
			Else
			    lRet := .F.
			EndIf
		Else
			fEFDMsg()
		EndIf
    EndIf

cFilAnt := cBkpFil

Return lRet

/*/{Protheus.doc} fLocalTrab
FunÁ„o respons·vel pela montagem do local de trabalho - SV6
@type function
@author Allyson Mesashi
@since 06/08/2018
@version 1.0
@param cFilSV6 	  - CÛdigo da filial da tabela SV7
@param cCodLocal  - CÛdigo do local da tabela SV7
@return aLocalSV6 - Array com as informaÁıes do local
/*/
Static Function fLocalTrab( cFilSV6, cCodLocal )

Local aAreaSV6  := SV6->(GetArea())
Local aLocalSV6 := {}

dbselectArea("SV6")
SV6->(dbSetOrder(1))
If dbSeek( xFilial("SV6", cFilSV6) + cCodLocal )
	aAdd(aLocalSV6, {	AllTrim(SV6->V6_LOGRT)  ,; //tipo do logradouro
						AllTrim(SV6->V6_LOGDS)  ,; //descriÁ„o do logradouro
						AllTrim(SV6->V6_LOGNU)  ,; //n˙mero do logradouro
						AllTrim(SV6->V6_LOGC)   ,; //complemento
						AllTrim(SV6->V6_BAIRRO) ,; //bairro
						AllTrim(SV6->V6_CEP)    ,; //cep
						AllTrim(SV6->V6_CODMU)  ,; //cÛdigo do municÌpio
						AllTrim(SV6->V6_ESTAD)  }) //estado
EndIf

RestArea(aAreaSV6)

Return aLocalSV6

/*/{Protheus.doc} fExc2260
FunÁ„o respons·vel pela montagem XML e envio da exclus„o do evento S-2260 - ConvocaÁ„o trabalho intermitente
@type function
@author Allyson Mesashi
@since 06/08/2018
@version 1.0
@param aErros 	  	- Array com os erros gerados na integraÁ„o
@param cVersEnvio   - Indica a vers„o do leiaute
@return lRet 		- Retorna se a integraÁ„o foi efetuada corretamente
/*/
Function fExc2260( aErros, cVersEnvio )
	Local cBkpFil		:= cFilAnt
	Local cFilEnv		:= FTafGetFil( AllTrim( cEmpAnt ) + AllTrim( SRA->RA_FILIAL ), , , .T. )
	Local cMsgErro		:= ""
	Local lRet			:= .T.

	Default aErros 		:= {}
	Default cVersEnvio	:= "2.4"

	If !Empty(cFilEnv)
		cFilAnt	:= cFilEnv
	EndIf

	//Efetua a integracao do evento S-2260 com TAF
	If !Empty(cFilEnv)
		cXml := ''
		cXml +='<eSocial>'
			cXml +='<evtExclusao>'
				cXml +='<infoExclusao>'
					cXml +='<tpEvento>' + "S-2260" + '</tpEvento>'
					cXml +='<nrRecEvt >' + AllTrim(SRA->RA_CIC) + ALLTRIM(SRA->RA_CODUNIC) + SV7->V7_CONVC + '</nrRecEvt>'
					cXml +='<ideTrabalhador>'
						cXml +='<cpfTrab>' + SRA->RA_CIC + '</cpfTrab>'
					cXml +='</ideTrabalhador>'
			cXml +='</infoExclusao>'
			cXml +='</evtExclusao>'
		cXml +='</eSocial>'

		//Realiza geraÁ„o de XML na System
		GrvTxtArq(alltrim(cXml), "S3000")

		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
		If Len(aErros) > 0
			FeSoc2Err( aErros[1], @cMsgErro, IIF(aErros[1] != '000026', 1, 2) )
			fEFDMsgErro(cMsgErro)
			If aErros[1] == '000026'
			    lRet := .T.
			Else
			    lRet := .F.
			EndIf
		EndIf
    EndIf

cFilAnt := cBkpFil

Return lRet

/*/{Protheus.doc} fEstagCBO
FunÁ„o para verificar se o cargo e/ou a funÁ„o do estagi·rio possuem cÛdigo de CBO informados
@author Claudinei Soares
@since 10/06/2019
@version 1.0
@param cFilEstag, Caracter, Filial do estagi·rio
@param cCargo, Caracter, CÛdigo do cargo na tabela SRA
@param cFuncao, Caracter, CÛdigo da funÁ„o na tabela SRA
@param lCBOCargo, Logic, se o cargo tem CBO informado
@param lCBOFuncao, Logic, se a funÁ„o tem CBO informado
@return Nil
/*/
Function fEstagCBO(cFilEstag, cCargo, cFuncao, lCBOCargo, lCBOFuncao)

Local aArea			:= GetArea()

Default cFilEstag	:= ""
Default cCargo		:= ""
Default cFuncao		:= ""
Default lCBOCargo 	:= .F.
Default lCBOFuncao	:= .F.

If !Empty(cCargo)
	DbSelectArea("SQ3")
	DbSetOrder(1)
	If SQ3->(DbSeek(xFilial("SQ3", cFilEstag)+cCargo)) .And. ( SQ3->(ColumnPos("Q3_CBO")) > 0 .And. !Empty(SQ3->Q3_CBO))
		lCBOCargo := .T.
	Else
		lCBOCargo := .F.
	Endif
Endif

If !Empty (cFuncao)
	DbSelectArea("SRJ")
	DbSetOrder(1)
	If SRJ->(DbSeek(xFilial("SRJ", cFilEstag)+cFuncao)) .And. !Empty(SRJ->RJ_CODCBO)
		lCBOFuncao := .T.
	Else
		lCBOFuncao := .F.
	Endif
Endif

RestArea(aArea)

Return

/*/{Protheus.doc} fEstIBGE
Retorna cÛdigo do estado conforme tabela do IBGE (Middleware)
@author	isabel.noguti
@since	03/12/2019
@version 1.0
@param	cSigla,		Caracter, sigla do estado
@return cCodigo,	Caracter, cÛdigo do estado na tabela IBGE
/*/
function fEstIBGE(cSigla)
	Local aEstados	:= {}
	Local cCodigo	:= ""
	Local nPosEst	:= 0
	Default cSigla	:= ""

	aAdd( aEstados, {"AC", "12"} )
	aAdd( aEstados, {"AL", "27"} )
	aAdd( aEstados, {"AP", "16"} )
	aAdd( aEstados, {"AM", "13"} )
	aAdd( aEstados, {"BA", "29"} )
	aAdd( aEstados, {"CE", "23"} )
	aAdd( aEstados, {"DF", "53"} )
	aAdd( aEstados, {"ES", "32"} )
	aAdd( aEstados, {"GO", "52"} )
	aAdd( aEstados, {"MA", "21"} )
	aAdd( aEstados, {"MT", "51"} )
	aAdd( aEstados, {"MS", "50"} )
	aAdd( aEstados, {"MG", "31"} )
	aAdd( aEstados, {"PA", "15"} )
	aAdd( aEstados, {"PB", "25"} )
	aAdd( aEstados, {"PR", "41"} )
	aAdd( aEstados, {"PE", "26"} )
	aAdd( aEstados, {"PI", "22"} )
	aAdd( aEstados, {"RN", "24"} )
	aAdd( aEstados, {"RS", "43"} )
	aAdd( aEstados, {"RJ", "33"} )
	aAdd( aEstados, {"RO", "11"} )
	aAdd( aEstados, {"RR", "14"} )
	aAdd( aEstados, {"SC", "42"} )
	aAdd( aEstados, {"SP", "35"} )
	aAdd( aEstados, {"SE", "28"} )
	aAdd( aEstados, {"TO", "17"} )

	If ( nPosEst := aScan(aEstados, {|x| x[1] == cSigla}) ) > 0
		cCodigo := aEstados[nPosEst][2]
	EndIf

Return cCodigo

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ FSubst        ≥ Autor ≥ Cristina Ogura   ≥ Data ≥ 17/09/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao que substitui os caracteres especiais por espacos   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ FSubst()                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ GPEM610                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function FSubst(cTexto)

Local aAcentos	:={}
Local aAcSubst	:={}
Local cImpCar	:= Space(01)
Local cImpLin	:=""
Local cAux		:=""
Local cAux1		:=""
Local nTamTxt	:= Len(cTexto)
Local j
Local nPos

// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
// maximo possivel para visualizacao dos mesmos.
// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

aAcentos :=	{;
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252),Chr(045),Chr(047),Chr(061),Chr(060),Chr(062);
			}

aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u","","","","","";
			}

For j:=1 TO Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)
	//-- Nao pode sair com 2 espacos em branco.
	cAux	:=Space(01)
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar

Next j

//--Volta o texto no tamanho original
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin

/*/{Protheus.doc} fSalRed
Retorna o sal·rio reduzido conforme MP 936/2020
@author allyson.mesashi
@since 15/04/2020
@version 1.0
/*/
Static Function fSalRed(dDataAlt, cSalario, dIniRed, cFilRA, nPerRed, dFimRed, dDtAlt, cStatus)

	Local aAreaRGE	:= RGE->(GetArea())
	Local aAreaSVA	:= SVA->(GetArea())
	Local aArea		:= GetArea()
	Local cItemSVA	:= "01"
	Local dFimRed	:= cToD("//")
	Local lExcRCC	:= !Empty(xFilial("RCC"))
	Local lGravaSVA	:= .F.
	Local lTemRGE	:= .F.
	Local nPosTab	:= 0
	Local nSalRed	:= Iif(ValType(cSalario) == "N", cSalario, Val(cSalario))
	Local cStatus	:= " "
	Local dDtAlt	:= cToD("//") //Conte˙do do campo RGE_DTALT
	Local lRobo		:= IsBlind()

	RGE->( dbSetOrder(2) )//RGE_FILIAL+RGE_MAT+DTOS(RGE_DATAIN)+RGE_TIPOCO
	If RGE->( dbSeek( cFilRA+M->RA_MAT ) )
		While RGE->( !EoF() ) .And. RGE->RGE_FILIAL+RGE->RGE_MAT == cFilRA+M->RA_MAT
			//Se o status na tabela RGE for 1 - Inativo ou 2 - Cancelado n„o ser· considerado
			//Se o status na tabela RGE for igual vazio, 0 (zero) ou 3 - Prorrogada considera os campos RGE_DATAFI e RGE_DTALT na pesquisa
			//Se o status na tabela RGE for igual 4 - ReduÁ„o/AntecipaÁ„o considera apenas a data de alteraÁ„o
			If dDataAlt >= RGE->RGE_DATAIN .And. (dDataAlt <= RGE->RGE_DATAFI .And. lRGEStat .And. RGE->RGE_STATUS != '4' .Or. (lRGEDtAlt .And. dDataAlt <= RGE->RGE_DTALT)) .And. RGE->RGE_PPE == "1" .And. !Empty(RGE->RGE_COD) .And. (!lRGEStat .Or. !(RGE->RGE_STATUS $ "1*2"))
				lTemRGE	:= .T.
				If !Empty(RGE->RGE_SALRED)
					dIniRed		:= RGE->RGE_DATAIN
					dFimRed		:= RGE->RGE_DATAFI
					nPerRed		:= RGE->RGE_PERC
					cSalario	:= RGE->RGE_SALRED
					If lRGEDtAlt .And. lRGEStat
						cStatus		:= RGE->RGE_STATUS
						dDtAlt		:= RGE->RGE_DTALT
					EndIf
					Exit
				Else
					dIniRed	:= RGE->RGE_DATAIN
					dFimRed	:= RGE->RGE_DATAFI
					If lExcRCC .And. cUltFilRGE != cFilRA
						cUltFilRGE 	:= cFilRA
						RstGpexIni()
					EndIf
					nPosTab	:= fPosTab("S061", RGE->RGE_COD, "==", 4)
					nPerRed	:= Iif(nPosTab == 0, 0, fTabela("S061", nPosTab, 8))//Percentual de reducao
					If nPerRed > 0
						If !(M->RA_CATFUNC $ "H|G")
							cSalario := (nSalRed - Round((nSalRed * (nPerRed / 100)), 2))
						EndIf

						If RGE->( RecLock("RGE", .F.) )
							RGE->RGE_PERC	:= nPerRed
							RGE->RGE_SALRED	:= cSalario
							RGE->(MsUnlock())
						EndIf
					Else
						lTemRGE	:= .F.
					EndIf
					Exit
				EndIf
			EndIf
			RGE->( dbSkip() )
		EndDo
	EndIf

	If lTemRGE
		SVA->( dbSetOrder(2) )//VA_FILIAL+VA_MATRIC+VA_TP+VA_ITEM
		If SVA->( dbSeek( cFilRA+M->RA_MAT ) )
			lGravaSVA	:= .T.
			While SVA->( !EoF() ) .And. SVA->VA_FILIAL+SVA->VA_MATRIC == cFilRA+M->RA_MAT
				If SVA->VA_TP == "1"
					cItemSVA := Soma1(SVA->VA_ITEM)

					If cStatus $ " *0" .And. STR0167 $ AllTrim(SVA->VA_OBSERV) .And. dToC(dIniRed) $ AllTrim(SVA->VA_OBSERV) //"Data de inÌcio da reduÁ„o: "
						lGravaSVA	:= .F.
						Exit

					ElseIf cStatus == "3" .And. (STR0167 $ AllTrim(SVA->VA_OBSERV) .And. STR0244 $ AllTrim(SVA->VA_OBSERV) .And. Iif(lRobo, dToC(dIniRed), dToC(dDtAlt)) $ AllTrim(SVA->VA_OBSERV) .Or. dDataAlt <= dFimRed) //"Data de inÌcio da reduÁ„o: e Data de tÈrmino prorrogada atÈ"
						lGravaSVA	:= .F.
						Exit

					ElseIf cStatus == "4" .And. STR0167 $ AllTrim(SVA->VA_OBSERV) .And. STR0245 $ AllTrim(SVA->VA_OBSERV) .And. Iif(lRobo, dToC(dIniRed), dToC(dDtAlt)) $ AllTrim(SVA->VA_OBSERV) //"Data de inÌcio da reduÁ„o: e Data de tÈrmino reduzida para"
						lGravaSVA	:= .F.
						Exit
					EndIf
				EndIf
				SVA->( dbSkip() )
			EndDo
		Else
			lGravaSVA	:= .T.
		EndIf

		If lGravaSVA .And. SVA->( RecLock("SVA", .T.) )

			SVA->VA_FILIAL 	:= cFilRA
			SVA->VA_MATRIC 	:= M->RA_MAT
			SVA->VA_TP 		:= "1"
			SVA->VA_ITEM	:= cItemSVA

			If cStatus $ " *0"
				SVA->VA_OBSERV	:= STR0167 + dToC(dIniRed) + STR0168 + dToC(dFimRed) + STR0169 + cValToChar(nPerRed) + "%"//"Data de inÌcio da reduÁ„o: "##" - Data de tÈrmino da reduÁ„o: "##" | Percentual de reduÁ„o da jornada: "## | Prorrogado atÈ: "##"

			ElseIf cStatus == "3"
				SVA->VA_OBSERV	:= STR0167 + dToC(dIniRed) + STR0244 + dToC(dDtAlt) + STR0169 + cValToChar(nPerRed) + "%" //"Data de inÌcio da reduÁ„o: "##" - Data de tÈrmino prorrogada atÈ: "##" | Percentual de reduÁ„o da jornada: "##

			ElseIf cStatus == "4"
				SVA->VA_OBSERV	:= STR0167 + dToC(dIniRed) + STR0245 + dToC(dDtAlt) + STR0169 + cValToChar(nPerRed) + "%" //"Data de inÌcio da reduÁ„o: "##" - Data de tÈrmino reduzida para: "##" | Percentual de reduÁ„o da jornada: "##

			EndIf

			SVA->( MsUnlock() )
		EndIf
	EndIf

	RestArea(aAreaRGE)
	RestArea(aAreaSVA)
	RestArea(aArea)

Return

/*/{Protheus.doc} fRJ5Filt
Pesquisa as lotaÁıes com campo da filial do trabalhador preenchidos
@type      	Static Function
@author Silvia Taguti
@since 04/11/2020
@version	1.0
@return aRJ5Fil
/*/

Static Function fRJ5Filt()
Local aAreaRJ5   	:= RJ5->(GetArea())
Local aRJ5Fil   := {}
Local lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0

RJ5->(dbSetOrder(7))
RJ5->(dbGotop())

	While RJ5->(!Eof()) .AND. RJ5->RJ5_FILIAL == XFILIAL('RJ5')
		If lFilT .And. !Empty(RJ5->RJ5_FILT)
			AADD(aRJ5Fil,{RJ5->RJ5_FILIAL, RJ5->RJ5_CC, RJ5->RJ5_FILT, RJ5->RJ5_COD, RJ5->RJ5_INI})
		Endif
		RJ5->(dbSkip())
	EndDo

RJ5->(dbGotop())

RestArea(aAreaRJ5)

Return aRJ5Fil

/*/{Protheus.doc} fTurnoOk
Verifica se as informaÁıes de turno, regra e sequencia de turno est„o consistentes
@type      	Static Function
@author Marcio Felipe
@since 15/04/2021
@version	1.0
@return lTurnoOk
/*/
Static Function fTurnoOk(cTurno,cRegra,cSeqT)
	Local aArea		:= GetArea()
	Local lTurnoOk := .T.

	If !SR6->(DbSeek(xFilial("SR6") + cTurno)) .Or.	!SPA->(DbSeek(xFilial("SPA") + cRegra)) .Or.;
		 !SPJ->(DbSeek(xFilial("SPJ") + cTurno + cSeqT))

		lTurnoOk := .F.
	EndIf
	RestArea(aArea)

Return lTurnoOk

/*/{Protheus.doc} fEmptyMemo
Verifica se um campo memo È vazio, descartando as quebras de linha
@type      	Static Function
@author Marcio Felipe
@since 07/07/2021
@version	1.0
@return lRet
/*/
Static Function fEmptyMemo(cCpoMemo)

Local lRet := .F.
Local cQuebra := CHR(13) + CHR(10)
Default cCpoMemo := ""

cCpoMemo := STRTRAN(cCpoMemo,cQuebra,"")

If Empty(cCpoMemo)
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} getInfCarg
Retorna array com as informaÁıes do cargo/funÁ„o
@type      	Static Function
@author Marcio Felipe
@since 23/09/2021
@version	1.0
@return aRet
aRet[1] => Codigo do cargo/funÁ„o
aRet[2] => <nmCargo> Nome do Cargo
aRet[3] => <CBOCargo> CBO do Cargo
/*/
Static Function getInfCarg(lCargSQ3, cTabInfo, cChaveSR7)
	Local aArea		:= GetArea()
	Local aRet		:= ""
	Local cAcum		:= ""
	Local cCodSRJ	:= ""
	Local cNomeSRJ	:= ""
	Local cCBOSRJ	:= ""

	Local cCodSQ3	:= ""
	Local cNomeSQ3	:= ""
	Local cCBOSQ3	:= ""

	Default lCargSQ3 	:= SuperGetMv("MV_CARGSQ3",,.F.)
	Default cTabInfo 	:= "SRA"
	Default cChaveSR7	:= ""

	// aRet[1] Codigo do Cargo/FunÁ„o que pode vir da SR7 ou SRA
	If cTabInfo == "SR7" .And. !Empty(cChaveSR7)
		DbSelectArea("SR7")
		DbSetOrder(1) // R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_TIPO
		If SR7->(DbSeek(cChaveSR7))
			cCodSRJ	:= SR7->R7_FUNCAO
			cCodSQ3	:= SR7->R7_CARGO
		EndIf
	Else
		cCodSRJ	:= fGetValCpo("RA_CODFUNC")
		cCodSQ3	:= fGetValCpo("RA_CARGO")
	EndIf

	If !Empty(cCodSRJ)
		DbSelectArea("SRJ")
		SRJ->(DbSetOrder(1))
		If SRJ->(DbSeek(xFilial("SRJ") + AllTrim(cCodSRJ)))
			cNomeSRJ := AllTrim(SRJ->RJ_DESC)
			cCBOSRJ	:= AllTrim(SRJ->RJ_CODCBO)
			cAcum	:= SRJ->RJ_ACUM
		Endif
	EndIf

	If !Empty(cCodSQ3)
		DbSelectArea("SQ3")
		SQ3->(DbSetOrder(1))
		If SQ3->(DbSeek(xFilial("SQ3") + AllTrim(cCodSQ3)))
			cNomeSQ3 := AllTrim(SQ3->Q3_DESCSUM)
			cCBOSQ3	:= AllTrim(SQ3->Q3_CBO)

		Endif
	EndIf

	aRet := {cCodSRJ, cNomeSRJ, cCBOSRJ, cCodSQ3, cNomeSQ3, cCBOSQ3, cAcum}

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetTurno
ObtÈm os dados de turno na SPF conforme a data
@author  lidio.oliveira
@since   19/08/2022
@version 0.1
/*/
//-------------------------------------------------------------------
Function fGetTurno(cFil, cMat, cData, cTurno, cSeq, cRegra)

	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local lRet		:= .F.

	Default	cTurno	:= ""
	Default	cSeq	:= ""
	Default	cRegra	:= ""

	BeginSql Alias cAliasQry
		SELECT PF_FILIAL, PF_MAT, PF_TURNOPA, PF_SEQUEPA, PF_REGRAPA
		FROM %table:SPF% SPF
		WHERE PF_FILIAL=%exp:cFil% AND PF_MAT=%exp:cMat% AND PF_DATA <= %exp:cData% AND %notDel%
		ORDER BY PF_DATA DESC
	EndSql

	If !(cAliasQry)->(Eof())
		cTurno	:= (cAliasQry)->PF_TURNOPA
		cSeq	:= (cAliasQry)->PF_SEQUEPA
		cRegra	:= (cAliasQry)->PF_REGRAPA
		lRet 	:= .T.
	EndIf
	
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)

Return lRet
