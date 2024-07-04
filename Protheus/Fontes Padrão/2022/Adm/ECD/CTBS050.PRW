#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECD.CH"

//Compatibilização de fontes 30/05/2018

Static lDefTopCtb := IfDefTopCTB()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTBS040    ³ Autor ³Microsiga	        ³ Data ³20/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função utilizada para criar as tabela de prevalidação do	  ³±±
±±³          ³SPED, baseando se no manual do mesmo.               		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBS050()  
Local aArea		:= GetArea()
Local cFilCSH	:= xFilial( "CSH" )
Local cCSHCount := "CSH"
Local aSpedCdpo := {}
Local nX		:= 0
Local cRet		:= "Tabela CSH carregada com sucesso"
                                                    
If lDefTopCtb 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query -Verifica se existe registro na tabela    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuerCount := "SELECT COUNT(*) CSHCOUNT";
			+ " FROM " + RetSqlName( "CSH" ) + " CSH ";
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera um novo alias  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCSHCount := GetNextAlias()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a query     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuerCount) , cCSHCount,.T.,.T.)
Else
	dbSelectArea("CSH")
	dbSetOrder(1)
	MsSeek( cFilCSH )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cCSHCount)->CSHCOUNT <= 0
	
	aSpedCdpo := SpedCamposValid()
	
	DbSelectArea("CSH")
	For nX := 1 To Len(aSpedCdpo)
		RecLock( "CSH" , .T. )
		CSH->CSH_MODELO	:= 	aSpedCdpo[nX][1]
		CSH->CSH_ITEM  	:=	aSpedCdpo[nX][2]
		CSH->CSH_RGRVLD 	:=	aSpedCdpo[nX][3]
		CSH->CSH_DESCRI	:=	aSpedCdpo[nX][4]
		CSH->CSH_TIPO	:=	aSpedCdpo[nX][5]
		MsUnLock()
	Next
	
EndIf


If lDefTopCtb
	(cCSHCount)->( dbCloseArea() )
	dbSelectArea("CSH")
EndIf
RestArea( aArea )
Return cRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SpedCamposValid³ Autor ³Microsiga	        ³ Data ³20/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Campos de validação do SPED Contabil 							  ³±±
±±³          ³	  															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array com os campos do SPED                                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                  	  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SpedCamposValid()

Local aSpedCpo := {}

//Regra 1
//{modelo,item, regra, descrição, tipo }
aAdd(aSpedCpo,{"ECD",1,"REGRA_REGISTRO_DUPLICADO","Verifica se o registro não é duplicado, considerando o campo chave especificados para o registro.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",2,"REGRA_COD_CCUS_DT_ALT_DUPLICADO","Verifica se o registro não é duplicado considerando a chave COD_CCUS+DT_ALT.","1-	ERRO"})
aAdd(aSpedCpo,{"ECD",3,"REGRA_COD_CTA_DT_ALT_DUPLICADO","Verifica se o registro não é duplicado considerando a chave COD_CTA+DT_ALT.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",4,"REGRA_DETALHE_BALANCETE_DUPLICADO","Verifica se, para cada data (Registro I300), o registro não é duplicado considerando a chave COD_CTA+COD_CCUS.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",5,"REGRA_DATA_BALANCETE_DUPLICADO","Verifica se o registro não é duplicado considerando a chave DT_BCTE.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",6,"REGRA_CODIGO_CONTA_NIVEL_SUPERIOR_INVALIDO","Verifica se COD_CTA_SUP existe no plano de contas (Registro I050).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",7,"REGRA_CONTA_NO_PLANO_CONTAS","Verifica se conta COD_CTA existe no  plano de contas (Registro I050).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",8,"REGRA_COD_HIS_PAD_NO_HISTÓRICO_PADRAO","Verifica se Código do histórico padrão COD_HIS_PAD existe no Tabela de Histórico Padronizado (registro I075).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",9,"REGRA_CCUS_NO_CENTRO_CUSTOS","Verifica se Código do centro de custos COD_CCUS existe no registro I100 Centro de Custos.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",10,"REGRA_CODIGO_PARTICIPANTE ","Verifica se o Código do participante COD_PART existe no registro tabela de cadastro de participante (Registro 0150), considerando-se a DT_INI_REL e DT_FIN_REL.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",11,"REGRA_COD_CTA_DT_RES_DUPLICIDADE ","Verificar se, para uma mesma data (Registro I350), se o registro não é duplicado considerando a chave   COD_CTA+COD_CCUS.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",12,"REGRA_DT_RES_DUPLICIDADE","Verifica se o registro não é duplicado considerando a chave  DT_RES.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",13,"REGRA_DUPLICIDADE_CONTA_SALDO_PERIODICO","Verificar se, para o mesmo período (Registro I150), o registro não é duplicado considerando a chave a chave  CÓD_CTA + COD_CCUS.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",14,"REGRA_DUPLICIDADE_PERIODO_SALDO_PERIODICO","Verifica se o registro não é duplicado considerando a chave  DT_INI + DT_FIN.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",15,"REGRA_OCORRENCIA_UNITARIA_ARQ","Verifica se registro ocorreu apenas uma vez por arquivo, considerando a chave REG.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",16,"REGRA_OCORRÊNCIA_0020_ARQ","Verifica se o Campo IND_DEC do Registro 0020 é igual a 1 (um) e Registro 0020 ocorreu mais de uma vez no arquivo.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",17,"REGRA_VALIDA_CNPJ","Verifica se a regra de formação do Código é válida.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",18,"REGRA_VALIDA_CPF","Verifica se a regra de formação do Código é válida.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",19,"REGRA_VALIDA_ID_SUSEP","Verifica se a regra de formação do Código é válida.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",20,"REGRA_VALIDA_ID_BACEN","Verifica se a regra de formação do Código é válida.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",21,"REGRA_VALIDA_ID_CVM","Verifica se a regra de formação do Código é válida.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",22,"REGRA_VALIDA_INSCRICAO","Verifica qual regra de formação do Código deve ser aplicada, a partir do preenchimento do campo COD_END_REF: para o Código “01”, executa REGRA_VALIDA_ID_BACEN;  para o “03”, REGRA_VALIDA_ID_CVM; e, para o “02”, REGRA_VALIDA_ID_SUSEP.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",23,"REGRA_TODOS_CAMPOS_VAZIOS","Verifica se pelo menos um dos campos informados (no registro I510) para os registros I550 e I555 foi preenchido. ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",24,"REGRA_COD_CCUS_COD_CTA_REF_DUPLICIDADE","Verifica se o registro não é duplicado considerando a chave  COD_ENT+COD_CCUS + COD_CTA_REF.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",25,"REGRA_COD_AGL_DUPLICIDADE","   Verifica se o registro não é duplicado considerando a chave COD_AGL (quando o campo tiver algum conteúdo). ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",26,"REGRA_VALIDA_NIRE","Verifica se a regra de formação do Código é válida. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",27,"REGRA_COD_CCUS_COD_AGL_DUPLICIDADE","Verifica se o registro não é duplicado considerando a chave  COD_CCUS+COD_AGL.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",28,"REGRA_IDENT_CPF_COD_ASSIN_DUPLICIDADE","Verifica se o registro não é duplicado considerando a chave  IDENT_CPF + COD_ASSIN.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",29,"REGRA_REG_BLC_DUPLICIDADE","Verifica se o registro não é duplicado considerando a chave  REG_BLC.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",30,"REGRA_NIRE_UF","Verifica se os dois primeiros dígitos do NIRE correspondem à Unidade da Federação informada no campo UF do Registro 0000. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",31,"REGRA_REG_COD_NUM_AD_DUPLICADO","Verifica se o registro não é duplicado considerando a chave REG_COD + NUM_AD.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",32,"REGRA_VERIFICA_CNPJ_REG_0000_REG_0020","Verifica se os oito primeiros dígitos do campo CNPJ do Registro 0000 é igual aos oito primeiros dígitos do campo CNPJ do Registro 0020. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",33,"REGRA_CAMPO_ CÓD_HASH_AUX _OBRIGATORIO","Verifica o campo  COD_HASH_AUX do Registro I012 foi preenchido quando o campo IND_ESC do Registro I010 for igual a “R” ou “B” (para escrituração Resumida e Balancete) e o campo TIPO do registro I012 igual a “0”.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",34,"REGRA_QTD_LIN_BLOCO0","Verifica se numero de linhas do bloco 0 é igual ao valor informado no campo QTD_LIN (Registro 0990).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",35,"REGRA_QTD_LIN_BLOCOI","Verifica se número de linhas do bloco I é igual ao valor informado no campo QTD_LIN (Registro I990).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",36,"REGRA_QTD_LIN_BLOCOJ","Verifica se número de linhas do bloco J é igual ao valor informado no campo QTD_LIN (Registro J990).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",37,"REGRA_QTD_LIN_ARQUIVO","Verifica se número de linhas do arquivo é igual ao valor informado no campo QTD_LIN (Registro 9999).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",38,"REGRA_CAMPO_OBRIGATORIO","Verifica se o campo foi preenchido com algum valor diferente de vazio e do caractere “espaço”. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",39,"REGRA_COD_CTA_SUP_OBRIGATORIO","Verifica se NIVEL>1, se afirmativo executa  REGRA_CAMPO_OBRIGATORIO.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",40,"REGRA_IND_DC_INI_OBRIGATORIO","Verifica se o campo VL_SLD_INI do registro saldos periódicos (Registro I155) foi informado ou é diferente de 0(zero), nesse caso o campo se torna obrigatório. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",41,"REGRA_IND_DC_FIN_OBRIGATORIO","Verifica se o campo VL_SLD_FIN do registro saldos periódicos (Registro I155) foi informado ou é diferente de 0(zero), nesse caso o campo se torna obrigatório. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",42,"REGRA_HISTORICO_OBRIGATORIO","Verifica se campo HIST ou campo COD_HIST_PAD estão preenchidos (um dos dois campos deve estar preenchido).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",43,"REGRA_COD_AGL_OBRIGATORIO","Verifica se IND_VL = “D” ou “R” quando COD_AGL foi informado. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",44,"REGRA_CAB_DEM_OBRIGATORIO","Campo obrigatório quando o campo ID_DEM  for igual a 2. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",45,"REGRA_REGISTRO_PARA_CONTA_ANALITICA","O registro somente poderá existir quando o valor do campo  IND_CTA do Registro I050 = “A” ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",46,"REGRA_OBRIGATORIO_CONTADOR","Campo obrigatório quando COD_ASSIN for igual a 900 (Contador) ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",47,"REGRA_NAO_EXISTE_COD_CTA_PAD","Verifica se a conta informada existe no plano de contas referencial","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",48,"REGRA_TABELA_RELACIONAMENTO","Verifica se o Código informado no Campo COD_REL do Registro 0180 existe na Tabela de Relacionamento, conforme tabelas divulgadas pelo Sped. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",49,"REGRA_TABELA_NATUREZA","Verifica se o Código informado no Campo COD_NAT do Registro I050 existe na Tabela de Naturezas das Contas/Grupo de Contas, conforme tabelas divulgadas pelo Sped.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",50,"REGRA_TABELA_ENTIDADES","Verifica se o Código informado no Campo COD_ENT_REF do Registro I051 existe na Tabela de Entidades Responsáveis pela Manutenção do Plano de Contas Referencial, conforme tabelas divulgadas pelo Sped.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",51,"REGRA_TABELA_INSTITUICOES_CADASTRO","Verifica se o Código informado no Campo COD_ENT_REF do Registro 0007 existe na Tabela de Instituições Responsáveis pela Administração do Cadastro das Entidades, conforme tabelas divulgadas pelo Sped.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",52,"REGRA_TABELA_SITUACAO","Verifica se o Código informado no Campo IND_SIT_ESP do Registro 0000 existe na Tabela de Indicador de situação especial, conforme tabelas divulgadas pelo Sped. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",53,"REGRA_TABELA_ASSINANTE","Verifica o Código valor informado no Campo COD_ASSIN existe na Tabela de Qualificação do Assinante, conforme tabelas divulgadas pelo Sped. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",54,"REGRA_TABELA_ASSINANTE_DESC","Se COD_ASSIN=900 verifica se a descrição informada no Campo IDENT_QUALIF existe na Tabela de Qualificação do Assinante, conforme tabelas divulgadas pelo Sped e corresponde ao campo COD_ASSIN informado.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",55,"REGRA_TABELA_UF","Verifica se Código informado no Campo UF existe na Tabela de Unidades da Federação, conforme tabelas divulgadas pelo Sped.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",56,"REGRA_IGUAL_CNPJ_REG0000","Verifica se o conteúdo do campo é igual ao do campo CNPJ do Registro 0000.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",57,"REGRA_REGISTRO_OBRIGATORIO_I051","Verifica se existe ao menos um registro I051 na escrituração . ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",58,"REGRA_IGUAL_NOME_REG0000","Verifica se o conteúdo do campo é igual ao do campo NOME do Registro 0000.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",59,"REGRA_REGISTRO_OBRIGATÓRIO_I151","Nas escriturações tipo “B”, de período inicial igual ou posterior a 01.01.2010, verifica se foi informado, pelo menos, um registro I151 para cada registro I150.","2-ADVERTENCIA"})

//Regra 2
aAdd(aSpedCpo,{"ECD",60,"REGRA_DATA_INI_MAIOR","Verifica se o campo foi preenchido com a data igual ou anterior a data do campo (DT_FIM) do registro 0000.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",61,"REGRA_DATA_INTERVALO_DO_ARQUIVO","Verifica se campo (Data) pertence ao intervalo do arquivo: campo  (DT_INI) do registro 0000 <= campo (Data) <= campo  (DT_FIM) do registro 0000.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",62,"REGRA_DT_ALT_DATA_MAIOR","Verifica se DT_ALT<=DT_FIN do Registro 0000","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",63,"REGRA_CTA_DE_NIVEL_SUPERIOR_INVALIDA","Verifica se NIVEL > 1, se afirmativo verifica regras:+REGRA_CODIGO_CONTA_NIVEL_SUPERIOR_INVALIDO+REGRA_CONTA_NIVEL_SUPERIOR_NAO_SINTETICA+REGRA_NIVEL_DE_CONTA_NIVEL_SUPERIOR_INVALIDO+Verifica se NIVEL > 2, se afirmativo verifica a regra: REGRA_NATUREZA_CONTA","1-ERRO"})
aAdd(aSpedCpo,{"ECD",64,"REGRA_CONTA_NIVEL_SUPERIOR_NAO_SINTETICA","Verifica se NIVEL > 1, se afirmativo localizar o registro em que o campo  (COD_CTA) tenha o mesmo valor do campo  (COD_CTA_SUP). Neste registro, o campo (IND_CTA) deve ser igual a S. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",65,"REGRA_NIVEL_DE_CONTA_NIVEL_SUPERIOR_INVALIDO","Verifica se NÍVEL > 1, se afirmativo localizar o registro em que o campo (COD_CTA) tenha o mesmo valor do campo (COD_CTA_SUP). Neste registro, o campo NIVEL deve ser menor que o NIVEL ATUAL","1-ERRO"})
aAdd(aSpedCpo,{"ECD",66,"REGRA_CONTA_ANALITICA","Localiza COD_CTA no plano de contas (Registro I050) e verifica se IND_CTA=[”A” ou ”a”] ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",67,"REGRA_VALIDACAO_SOMA_SALDO_INICIAL","Nas escriturações G e R, verifica se a soma de VL_SLD_INI (Registro I155) igual a zero para cada período informado no registro de período do saldo periódico (Registro I150) (considerados os indicadores de Débito e Crédito) .","1-ERRO"})
aAdd(aSpedCpo,{"ECD",68,"REGRA_VALIDACAO_SOMA_SALDO_FINAL","Nas escriturações G e R, verifica se a soma de VL_SLD_FIN (Registro I155) é igual a zero para cada período informado no registro de período do saldo periódico (Registro I150). (considerados os indicadores de Débito e Crédito) ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",69,"REGRA_VALIDACAO_DEB_DIF_CRED","Nas escriturações G e R , verifica se a soma de VL_DEB (Registro I155) é igual à soma de VL_CRED (Registro I155) para cada período informado no registro de período do saldo periódico (Registro I150). ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",70,"REGRA_VALIDACAO_SALDO_FINAL","Verifica se o valor do campo VL_SLD_FIN é igual a: valor do campo VL_SLD_INI mais o valor do campo VL_DEB mais o valor do campo VL_CRED, considerando os indicadores de débito e crédito (DC) do saldo inicial e do saldo final (IND_DC_INI , IND_DC_FIN).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",71,"REGRA_VALIDACAO_VALOR_DEB","Verifica se a soma dos débitos (por mês e conta) de lançamentos é igual o valor do campo VL_DEB no mês de saldos; (para as escriturações do tipo A, R, G).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",72,"REGRA_VALIDACAO_VALOR_CRED","Verifica se a soma dos créditos (por mês e conta) de lançamentos é igual do valor do campo VL_CRED no mês de saldos; (para as escriturações do tipo A, R, G).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",73,"REGRA_VALIDACAO_SALDO_INI_DIF_FIN","Verifica se, a partir do 2o. mês do período (Registro I150),  o valor do campo VL_SLD_INI (Registro I155) é diferente do valor do campo VL_SLD_FIN (Registro I155) do mês imediatamente anterior.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",74,"REGRA_VALIDACAO_VL_LCTO_DEB","Se IND_ESC do registro I010 for diferente de “A” (Livro Diário Auxiliar ao Diário), verifica se a soma dos débitos do Registro I250 (Partidas do Lançamento) é igual ao VL_LCTO.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",75,"REGRA_VALIDACAO_VL_LCTO_CRED","Se IND_ESC do registro I010 for diferente de “A” (Livro Diário Auxiliar ao Diário), verifica se a soma dos créditos do Registro I250 (Partidas do Lançamento) é igual ao VL_LCTO. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",76,"REGRA_VALIDACAO_VALOR_DEB_BALANCETE","Verifica se a soma dos débitos (mês, conta e centro de custo) no balancete diário (Registro I300/I310) é igual ao valor do campo VL_DEB no mês de saldos (para as escriturações do tipo B).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",77,"REGRA_VALIDACAO_VALOR_CRED_BALANCETE","Verifica se a soma dos créditos (mês, conta e centro de custo) no balancete diário (Registro I300/I310) é igual ao valor do campo VL_CRED no mês de saldos (para as escriturações do tipo B). ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",78,"REGRA_CONTINUIDADE_SALDOS_PERIODICOS","Verifica se existe detalhe do saldo periódico para todos os meses informados no intervalo do arquivo de acordo com o registro 0000 .","1-ERRO"})
aAdd(aSpedCpo,{"ECD",79,"REGRA_CONTA_RESULTADO","Verifica se a natureza da conta (COD_NAT) do registro plano de contas (Registro I050) é de conta de resultado. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",80,"REGRA_VALIDACAO_SALDO_CONTA","Verifica se a soma de todos os lançamentos do tipo encerramento de conta de resultado (campo IND_LCTO do Registro I200) para cada data (DT_RES) e conta (considerando se é crédito ou débito) é igual ao valor do saldo final antes do lançamento de encerramento (VL_CTA) para escriturações do tipo R,G, (com o indicador de débito ou crédito invertido).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",81,"REGRA_VALIDACAO_CONTA_RESULTADO","Verifica se, na data de encerramento, a soma do saldo de cada conta de resultado (o campo VL_SLD_FIN  do Registro I155) é igual a 0.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",82,"REGRA_DATA_MES","Verifica se datas inicial e final (campos DT_INI e DT_FIN) estão contidas no mesmo mês. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",83,"REGRA_VALIDACAO_DC_BALANCETE","Verifica se soma de VAL_DEB (Registro I310) = Soma VAL_CRED (Registro I310) na mesma data DT_BCTE (Registro I300).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",84,"REGRA_CAMPOS_SALDOS_PERIODICOS_DIFERENTE_ZERO","Verifica se, pelo menos, um dos campos VL_SLD_INI, VL_DEB, VL_CRED e VL_SLD_FIN do Registro I155 têm valor diferente de zero. ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",85,"REGRA_VALIDADE_COD_CTA_PAD","Verifica se o período de validade da conta no plano de contas referencial está dentro do período da escrituração (ou do arquivo - Campos DT_INI e DT_FIN do registro 0000) ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",86,"REGRA_PERIODO_MINIMO_ESCRITURACAO","Verifica se campo IND_SIT_ESP do Registro 0000 é não foi informado e campos DT_INI e DT_FIN do registro 0000 abrangem,  no mínimo, um mês. Devem ser informados meses completos, ou seja, a DT_INI é o primeiro dia do mês e a DT_FIN é o último dia do mês.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",87,"REGRA_PERÍODO_MAXIMO_ESCRITURACAO","Verifica se Campos DT_INI e DT_FIN do registro 0000 estão contidos no mesmo ano.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",88,"REGRA_CONTA_PARA_LANCAMENTO","Verifica se REGRA_CONTA_ANALITICA e+REGRA_CONTA_NO_PLANO_CONTAS foram atendidas.  ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",89,"REGRA_DT_INI_MAIOR_DT_FIN_REL","Verifica se o campo DT_INI_REL é menor ou igual ao campo DT_FIN_REL.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",90,"REGRA_MAIOR_QUE_UM","Verifica se o valor informado para o campo é maior ou igual a 1.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",91,"REGRA_CONTA_SUPERIOR_NAO_SE_APLICA","Verifica se, para contas cujo nível é igual a 1 não foi informada a conta de nível superior (COD_CTA_SUP).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",92,"REGRA_VERSAO_LC","Verifica se a versão informada é válida.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",93,"REGRA_TAM_FONTE","O valor informado no campo deverá ser  maior que 3 e menor que 13.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",94,"REGRA_COLUNAS_PAGINA","O somatório dos campos COL_CAMPO do Registro I510 + número de registros I510 que aparecem no arquivo – 1 deverá ser igual ao número máximo de caracteres que cabem em uma linha do livro que será impresso/visualizado, considerar que o livro será impresso/visualizado em papel A-4,  com a orientação paisagem, margens de 1,5 cm e com fonte Courier. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",95,"REGRA_NUM_CAMPOS_RELATORIO","O número de campos informados no registro (desconsiderando o campo REG) deverá ser igual ao número de registros I510 informados no arquivo.  ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",96,"REGRA_SOMA_DAS_PARCELAS_BALANCO","Verifica se a soma dos valores do campo VL_CTA, considerando o indicador da situação do saldo (IND_DC_BAL), das contas de mesmo nível consecutivas ou intercaladas por contas de nível inferior  é igual ao valor do campo VL_CTA da conta de nível superior imediatamente anterior. ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",97,"REGRA_SOMA_DAS_PARCELAS_DRE","Verifica se a soma dos valores do campo VL_CTA, considerando o indicador da situação do saldo (IND_VL), das contas de mesmo nível consecutivas ou intercaladas por contas de nível inferior é igual ao valor do campo VL_CTA da conta de nível superior imediatamente anterior. ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",98,"REGRA_VALIDA_ATIVO_PASSIVO","Verifica se o ATIVO é igual ao PASSIVO.","1-ERRO"})
aAdd(aSpedCpo,{"ECD",99,"REGRA_VALIDA_BALANCO_COM_SALDO"," (campo ID_DEM (J005) = 1), o valor informado para as linhas de maior detalhamento do balanço patrimonial é igual a soma dos valores do campo VL_SLD_FIN dos registros de saldos periódicos.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",100,"REGRA_VALIDA_DRE_COM_SALDO"," (campo ID_DEM (J005) = 1), o valor informado para as linhas de maior detalhamento da Demonstração de Resultado é igual a soma dos valores do campo VL_SLD_FIN dos registros de saldos das contas de resultado antes do encerramento.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",101,"REGRA_VALIDACAO_VL_LCTO_ESC_AUXILIAR","Se IND_ESC do registro I010 for igual a “A” (Livro Diário Auxiliar ao Diário), verifica se a soma dos débitos ou dos créditos do Registro I250 (Partidas do Lançamento) é igual ao VL_LCTO. ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",102,"REGRA_EXISTE_AGLUTINACAO","Verifica se pelo menos um registro I052 foi informado para a linha de maior detalhamento do Balanço Patrimonial.","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",103,"REGRA_IGUAL_QTD_LIN_REG9999","Verifica se o valor do campo é igual ao valor do campo QTD_LIN do Registro 9999. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",104,"REGRA_IGUAL_NUM_ORD_REGI030","Verifica se o valor informado no campo é igual ao valor do campo NUM_ORD do Registro I030. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",105,"REGRA_IGUAL_DT_INI_REG0000","Verifica se o valor informado no campo é igual ao valor do campo DT_INI do Registro 0000. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",106,"REGRA_IGUAL_DT_FIN_REG0000","Verifica se o valor informado no campo é igual ao valor do campo DT_FIN do Registro 0000. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",107,"REGRA_DT_INI_MAIOR_DT_FIN","Verifica se a data inicial é igual ou anterior que a data final informada no registro. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",108,"REGRA_NATUREZA_CONTA","Verifica se a conta de nível superior tem a mesma natureza (campo COD_NAT) da subconta. ","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",109,"REGRA_QTD_REG_BLC_OBRIGATORIO","Verifica se todos os tipos de registros existentes no arquivo foram totalizados no registro 9900. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",110,"REGRA_REGISTRO_OBRIGATORIO_I350","Verifica se existe lançamento de encerramento (nas escriturações G e R).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",111,"REGRA_OBRIGATORIO_ASSIN_CONTADOR","É obrigatória a existência de no mínimo um registro J930 cujo COD_ASSIN seja igual a 900 (contador) e no mínimo um registro J930 cujo COD_ASSIN seja diferente de 900. ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",112,"REGRA_QTD_LIN_BLOCO9","Verifica se número de linhas do bloco 9 é igual ao valor informado no campo QTD_LIN_9 (Registro 9990). ","1-ERRO"})
aAdd(aSpedCpo,{"ECD",113,"REGRA_QTD_REG_BLC","Verifica se o número de linhas do arquivo, por tipo de registro (campo REG_BLC do Registro 9900), é igual ao valor informado no campo QTD_REG_BLC (Registro 9900).","1-ERRO"})
aAdd(aSpedCpo,{"ECD",114,"REGRA_REGISTRO_OBRIGATORIO_J005","Verifica se existem demonstrações contábeis (J005) na mesma data das informações relativas a saldo das contas de resultado antes do encerramento (campo DT_RES do registro I350).","2-ADVERTENCIA"})
aAdd(aSpedCpo,{"ECD",115,"REGRA_MAIOR_QUE_ZERO","Verifica se o conteúdo do campo NUM_ORD é maior que zero","1-ERRO"})


Return aSpedCpo
