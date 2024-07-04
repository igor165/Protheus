#Include 'Protheus.ch'
#Include "RUP_ATF.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  RUP_ATF( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

Função de compatibilização do release incremental. Esta função é relativa ao módulo ativo fixo

@author TOTVS

@version P12.1.17
@since   18/01/2018
@return  Nil
@obs

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA
*/
//-------------------------------------------------------------------
Function Rup_ATF( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

//--------------------
// Retirar na próxima versão
//--------------------
RUPATFSN0()
If cPaisLoc == "RUS"
	RUPATFSIX()
EndIf

Return

//--------------------------------------------------
/*/{Protheus.doc} RUPATFSN0
Funcao de processamento da gravacao do SN0.

Foi inserida no RUP para não prejudir a abertura do
módulo Ativo Fixo.

Antiga função ATFAtuSN0() - ATFXLOAD.PRX

@author Totvs
@since 23/05/2007
@version P12.1.17

@return nil
/*/
//--------------------------------------------------
Function RUPATFSN0()

Return Nil

//--------------------------------------------------
/*/{Protheus.doc} ATFLOADSN0
Funcao de processamento da gravacao do SN0.

@author Totvs
@since 23/05/2007 - Alterado em 08/12/2021 conforme issue DSERCTR1-26083
@version P12.1.33

@return nil
/*/
//--------------------------------------------------
Function ATFLOADSN0()
Local aAreaAtu	:= GetArea()
Local aSN0			:= {}
Local nI			:= 0
Local aAreaSN0	:= {}

// Criação da tabela de tipos de documentos de despesa
AAdd(aSN0,{"00","10",STR0001} ) //"Motivos de Reavaliação"
If cPaisLoc == "PTG"
	AAdd(aSN0,{"10","PT-77-126",STR0002}) //"Dec. Lei 126/77"
	AAdd(aSN0,{"10","PT-58-202",STR0003}) //"Portaria 202/58"
	AAdd(aSN0,{"10","PT-78-403",STR0004}) //"Dec. Lei 430/78"
	AAdd(aSN0,{"10","PT-82-024",STR0005}) //"Dec. Lei 24/82"
	AAdd(aSN0,{"10","PT-82-219",STR0006}) //"Dec. Lei 219/82"
	AAdd(aSN0,{"10","PT-84-143",STR0007}) //"Dec. Lei 143/84"
	AAdd(aSN0,{"10","PT-84-388",STR0008}) //"Dec. Lei 399-G/84"
	AAdd(aSN0,{"10","PT-85-278",STR0009}) //"Dec. Lei 278/85"
	AAdd(aSN0,{"10","PT-86-118",STR0010}) //"Dec. Lei 118-B/86"
	AAdd(aSN0,{"10","PT-88-111",STR0011}) //"Dec. Lei 111/88"
	AAdd(aSN0,{"10","PT-91-049",STR0012}) //"Dec. Lei 49/91"
	AAdd(aSN0,{"10","PT-92-264",STR0013}) //"Dec. Lei 264/92"
	AAdd(aSN0,{"10","PT-98-031",STR0014}) //"Dec. Lei 31/98"
EndIf

// Criação da tabela de tipos de depreciacao
If cPaisLoc == "PER"
	AAdd(aSN0,{"TD","20",STR0015}) //"Tipo de Depreciação"
	AAdd(aSN0,{"20","1" ,STR0016}) //"Linea reta"
	AAdd(aSN0,{"20","2" ,STR0017}) //"Reduccion de Saldos"
	AAdd(aSN0,{"20","3" ,STR0018}) //Suma de los Años"
	AAdd(aSN0,{"20","4" ,STR0019}) //"Unidades produzidas"
EndIf

AAdd(aSN0,{"10","1",STR0020}) //"Voluntária"
AAdd(aSN0,{"10","2",STR0021}) //"Reorg Sociedades"
AAdd(aSN0,{"10","3",STR0022}) //"Outros"

If cPaisLoc == "RUS"
	cDescN := STR0023 //"Sem depreciação"
	cDescF := STR0024 //"Depreciação total"

	If empty(cDescN)
		cDescN := "Without depreciation"
	Endif
	If empty(cDescF)
		cDescF := "Full depreciation"
	Endif

	AAdd(aSN0,{"00","04",STR0025}) //"Métodos de Depreciação"
	AAdd(aSN0,{"04","1" ,STR0016}) //"Linear"
	AAdd(aSN0,{"04","2" ,STR0017}) //"Redução de Saldos"
	AAdd(aSN0,{"04","N" ,cDescN }) //"Without depreciation"
	AAdd(aSN0,{"04","4" ,STR0019}) //"Unidades Produzidas"
	AAdd(aSN0,{"04","5" ,STR0026}) //"Horas Trabalhadas"
	AAdd(aSN0,{"04","6" ,STR0027}) //"Soma dos Dígitos"
	AAdd(aSN0,{"04","F" ,cDescF }) //"Full depreciation"	

Else
	// Criação da tabela de Métodos de Depreciação
	AAdd(aSN0,{"00","04",STR0025}) //"Métodos de Depreciação"
	AAdd(aSN0,{"04","1" ,STR0016}) //"Linear"
	AAdd(aSN0,{"04","2" ,STR0017}) //"Redução de Saldos"

	If cPaisLoc $ "PER|COS"
		AAdd(aSN0,{"04","3",STR0018}) //"Soma dos Anos(Mensal)"
	EndIf

	AAdd(aSN0,{"04","4",STR0019}) //"Unidades Produzidas"
	AAdd(aSN0,{"04","5",STR0026}) //"Horas Trabalhadas"
	AAdd(aSN0,{"04","6",STR0027}) //"Soma dos Dígitos"
	AAdd(aSN0,{"04","7",STR0028}) //"Linear com Valor Máx. Depreciação"
	AAdd(aSN0,{"04","8",STR0029}) //"Exaustão linear"
	AAdd(aSN0,{"04","9",STR0030}) //"Exaustão por saldo residual"
	AAdd(aSN0,{"04","A",STR0031}) //"Indice de depreciacao"
EndIf

//SPED FISCAL PIS/COFINS
// Criação da tabela de identificacao dos bens
AAdd(aSN0,{"00","11",STR0032}) //"Identificacao dos Bens SPED PIS/COFINS"
AAdd(aSN0,{"11","01",STR0033}) //"Edificacoes e Benfeitorias em Imoveis Proprios"
AAdd(aSN0,{"11","02",STR0034}) //"Edificacoes e Benfeitorias em Imoveis de Terceiros"
AAdd(aSN0,{"11","03",STR0035}) //"Instalacoes"
AAdd(aSN0,{"11","04",STR0036}) //"Maquinas"
AAdd(aSN0,{"11","05",STR0037}) //"Equipamentos"
AAdd(aSN0,{"11","06",STR0038}) //"Veiculos"
AAdd(aSN0,{"11","99",STR0022}) //"Outros"

// Criação da tabela de identificacao dos bens
AAdd(aSN0,{"00","12",STR0039}) //"Identificador Utilizacao dos Bens SPED PIS/COFINS"
AAdd(aSN0,{"12","1" ,STR0040}) //"Producao de Bens Destinados a Venda"
AAdd(aSN0,{"12","2" ,STR0041}) //"Prestacao de Servicos"
AAdd(aSN0,{"12","3" ,STR0042}) //"Locacao a Terceiros"
AAdd(aSN0,{"12","9" ,STR0022}) //"Outros"

//Criação da tabela de ocorrências de apontamentos de produção
AAdd(aSN0,{"00","08",STR0043}) //"Ocorrências de apontamentos de produção"
AAdd(aSN0,{"08","P0",STR0044}) //"Estimativa de produção"
AAdd(aSN0,{"08","P1",STR0045}) //"Revisão de estimativa de produção"
AAdd(aSN0,{"08","P2",STR0046}) //"Produção"
AAdd(aSN0,{"08","P3",STR0047}) //"Encerramento de produção"
AAdd(aSN0,{"08","P4",STR0048}) //"Produção complementar"
AAdd(aSN0,{"08","P5",STR0049}) //"Produção acumulada"
AAdd(aSN0,{"08","P8",STR0050}) //"Estorno de revisão de estim. de produção"
AAdd(aSN0,{"08","P9",STR0051}) //"Estorno de produção"

//Criterio de depreciação
AAdd(aSN0,{"00","05",STR0052}) //"Critério de depreciação"
AAdd(aSN0,{"05","00",STR0053}) //"Mensal - Proporcional no mês de aquisição"
AAdd(aSN0,{"05","01",STR0054}) //"Mensal - Integral no mês de aquisição"
AAdd(aSN0,{"05","02",STR0055}) //"Mensal - Mês posterior a aquisição"
AAdd(aSN0,{"05","03",STR0056}) //"Mensal - Exercício completo"
AAdd(aSN0,{"05","04",STR0057}) //"Mensal - Próximo trimestre"
AAdd(aSN0,{"05","10",STR0058}) //"Anual - Ano proporcional com mês de aquisição proporcional"
AAdd(aSN0,{"05","11",STR0059}) //"Anual - Ano proporcional com mês de aquisição integral"
AAdd(aSN0,{"05","12",STR0060}) //"Anual - Ano posterior a aquisição"

//Calendário de depreciação
AAdd(aSN0,{"00","06"    ,STR0061        }) //"Calendário de depreciação"
AAdd(aSN0,{"06","000001","01/01 | 31/12"})

// Criação da tabela 13 - C0NTROLE DE SALDOS / VIRADA ANUAL
AAdd(aSN0,{"00","13"         ,STR0062   }) //"CONTROLE DE SALDOS/VIRADA ANUAL"
AAdd(aSN0,{"13","VIRADAATIVO","19800101"})

//AVP
AAdd(aSN0,{"00","14",STR0063}) //"Tipos de movimento de AVP"
AAdd(aSN0,{"14","1" ,STR0064}) //"Constituicao"
AAdd(aSN0,{"14","2" ,STR0065}) //"Apropriacao por calculo"
AAdd(aSN0,{"14","3" ,STR0066}) //"Apropriacao por baixa"
AAdd(aSN0,{"14","4" ,STR0067}) //"Baixa"
AAdd(aSN0,{"14","5" ,STR0068}) //"Realizacao por calculo"
AAdd(aSN0,{"14","6" ,STR0069}) //"Realizacao por Baixa"
AAdd(aSN0,{"14","7" ,STR0070}) //"Baixa por revicao"
AAdd(aSN0,{"14","8" ,STR0071}) //"Baixa por transferencia"
AAdd(aSN0,{"14","9" ,STR0072}) //"Ajuste de AVP por revisão (+)"
AAdd(aSN0,{"14","A" ,STR0073}) //"Ajuste de AVP por revisão (-)"

// Criação da tabela 13 - C0NTROLE DE SALDOS / VIRADA ANUAL
AAdd(aSN0,{"00","07",STR0074}) //"Classificacao de Patrimonio"
AAdd(aSN0,{"07","N" ,STR0075}) //"Ativo Imobilizado"
AAdd(aSN0,{"07","S" ,STR0076}) //"Patrimonio Liquido"
AAdd(aSN0,{"07","A" ,STR0077}) //"Amortizacao"
AAdd(aSN0,{"07","C" ,STR0078}) //"Capital Social"
AAdd(aSN0,{"07","P" ,STR0079}) //"Patrimonio Liquido Negativo"
AAdd(aSN0,{"07","I" ,STR0080}) //"Ativo Intangivel"
AAdd(aSN0,{"07","D" ,STR0081}) //"Ativo Diferido"
AAdd(aSN0,{"07","O" ,STR0082}) //"Orçamento de Provisão de Despesa"
AAdd(aSN0,{"07","V" ,STR0083}) //"Provisão de Despesa"
AAdd(aSN0,{"07","T" ,STR0084}) //"Custos de Transação"
AAdd(aSN0,{"07","E" ,STR0085}) //"Custos de Empréstimos"

// Criação da tabela de Funcionalidades do ambiente
AAdd(aSN0,{"00","20"     ,STR0086}) //'Funcionalidades do ambiente'
AAdd(aSN0,{"20","ATFA006",STR0087}) //"Taxas de indices de calculo"
AAdd(aSN0,{"20","ATFA430",STR0088}) //"Cadastro de Projetos de imobilizado"
AAdd(aSN0,{"20","ATFA440",STR0089}) //"Cadastro de AVP de fichas de imobilizado"

// Criação da tabela de ações do ambiente
AAdd(aSN0,{"00","21",STR0090}) //"Ações do ambiente"
AAdd(aSN0,{"21","01",STR0091}) //"PESQUISAR"
AAdd(aSN0,{"21","02",STR0092}) //"VISUALIZAR"
AAdd(aSN0,{"21","03",STR0093}) //"INCLUIR"
AAdd(aSN0,{"21","04",STR0094}) //"ALTERAR"
AAdd(aSN0,{"21","05",STR0095}) //"EXCLUIR"
AAdd(aSN0,{"21","06",STR0096}) //"REVISAR"
AAdd(aSN0,{"21","07",STR0097}) //"BLOQUEAR"
AAdd(aSN0,{"21","08",STR0098}) //"IMPORTAR"
AAdd(aSN0,{"21","09",STR0099}) //"EXPORTAR"
AAdd(aSN0,{"21","10",STR0100}) //"ENCERRAR"
AAdd(aSN0,{"21","11",STR0101}) //"ATUALIZAR"

//PRV
AAdd(aSN0,{"00","15",STR0102}) //"Tipos de movimento de Provisão"
AAdd(aSN0,{"15","01",STR0103}) //"Distribuição"
AAdd(aSN0,{"15","02",STR0104}) //"Provisão"
AAdd(aSN0,{"15","03",STR0105}) //"Realização"
AAdd(aSN0,{"15","04",STR0106}) //"Complemento"
AAdd(aSN0,{"15","05",STR0107}) //"Reversão"
AAdd(aSN0,{"15","06",STR0108}) //"Ajuste a Valor Presente"
AAdd(aSN0,{"15","11",STR0109}) //"Transf.Curto Prazo - Distribuição"
AAdd(aSN0,{"15","12",STR0110}) //"Transf.Curto Prazo - Provisão"
AAdd(aSN0,{"15","13",STR0111}) //"Transf.Curto Prazo - Realização"
AAdd(aSN0,{"15","14",STR0112}) //"Transf.Curto Prazo - Complemento"
AAdd(aSN0,{"15","15",STR0113}) //"Transf.Curto Prazo - Reversão"
AAdd(aSN0,{"15","16",STR0114}) //"Transf.Curto Prazo - AVP"

//PRV
AAdd(aSN0,{"00","16",STR0115}) //"Tipos de cálculo de Provisão"
AAdd(aSN0,{"16","1" ,STR0116}) //"Curva de demanda"

DBSelectArea("SN0")
aAreaSN0 := SN0->(GetArea())
SN0->(DBSetOrder(1))
For nI := 1 To Len(aSN0)
	lGrava := SN0->(!DBSeek( xFilial("SN0")+ aSN0[nI][01]+ aSN0[nI][02] ))
	If aSN0[nI][01] == "13" .And. ! lGrava  //se ja existir tabela 13 nao deve atualizar pois eh chave p/ controle de virada anual
		Loop
	EndIf
	If !SN0->(MsSeek(xFilial("SN0")+aSN0[nI][01]+aSN0[nI][02]))
		RecLock("SN0",lGrava)
		SN0->N0_FILIAL	:= xFilial("SN0")
		SN0->N0_TABELA	:= aSN0[nI][01]
		SN0->N0_CHAVE	:= aSN0[nI][02]
		SN0->N0_DESC01	:= aSN0[nI][03]
		SN0->(MsUnLock())
	EndIf
Next nI

ASize(aSN0,0)
aSN0 := Nil

RestArea(aAreaSN0)
RestArea(aAreaAtu)

Return Nil