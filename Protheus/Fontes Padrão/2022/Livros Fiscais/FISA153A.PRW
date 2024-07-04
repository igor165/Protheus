#INCLUDE "PROTHEUS.CH"

Static lPosCIA	:= AliasIndic("CIA")
Static lPosPerRed := CIA->(FieldPos("CIA_PERRED")) > 0

// ------------------------------
// CLASSE APURACAO
// ------------------------------

CLASS FISA153APURACAO FROM LongNameClass

Data cUF as Character // UF da filial de apuração
Data dDataIni as Date // Data inicial do período de apuração
Data dDataFim as Date // Data final do período de apuração
Data nFS12 as Numeric // Acumulado de gastos c/ folha de pagamento nos últimos 12 meses
Data nFSPA as Numeric // Gastos com folha de pagamento do mês de apuração
Data nRBT12 as Numeric // Receita bruta acumulada dos últimos 12 meses (ou será mercado interno ou mercado externo)
Data nRBT12R as Numeric // Receita bruta acumulada dos últimos 12 meses utilizada no cálculo do fator "R" (mercado interno e externo somadas)
Data nRBA as Numeric // Receita bruta acumulada do ano de apuração
Data nRPA as Numeric // Receita do período de apuração da filial corrente
Data nRPATot as Numeric // Receita TOTAL do período de apuração (todas as filiais, se houver mais de uma)
Data nFatorR as Numeric // Fator "r"
Data nValorDAS as Numeric // Valor "final" a pagar do SIMPLES NACIONAL (Valor do DAS)
Data nLimite as Numeric // Limite para recolhimento dos tributos federais pelo SIMPLES.
Data nSublimite as Numeric // Sublimite para recolhimento dos tributos estaduais/municipais pelo SIMPLES
Data aAtividades as Array // Lista de atividades/subatividades
Data aAnexos as Array // Lista dos anexos da LC123/2006
Data aTributos as Array // Valores "finais" dos tributos calculados
Data nRecSubNaoExced as Numeric // Parcela da receita auferida que não excedeu o sublimite.
Data nRecSubExced as Numeric // Parcela da receita auferida que excedeu o sublimite mas não excedeu o limite
Data nRecLimExced as Numeric // Parcela da receita auferida que excedeu o limite
Data cStatusSub as Character // Status do sublimite
Data cStatusLim as Character // Status do limite
Data dDtIniAtiv as Date // Data de início de atividade
Data nPerRBASubExced as Numeric // Percentual da RBA que excedeu o sublimite ---> Utilizado p/ calcular o status do sublimite
Data nPerRBALimExced as Numeric // Percentual da RBA que excedeu o limite    ---> Utilizado p/ calcular o status do limite
Data nPerSubNaoExced as Numeric // % da RPA que NÃO EXCEDEU o SUBLIMITE                   ---> Utilizado p/ proporcionalizar a RPA
Data nPerSubExced as Numeric // % da RPA que EXCEDEU o SUBLIMITE mas NÃO EXCEDEU o LIMITE ---> Utilizado p/ proporcionalizar a RPA
Data nPerLimExced as Numeric // % da RPA que EXCEDEU o LIMITE                             ---> Utilizado p/ proporcionalizar a RPA
Data nPerRedIC as Numeric // % de redução da base de calculo da CIA

Method new() CONSTRUCTOR
Method clear()
Method destroyObj(oObj)

Method loadAnexos()
Method loadLimites()
Method calcFatorR()
Method addReceita(oReceita)
Method addAnexo(oAnexo)
Method addAtividade(oAtividade)
Method apurar()
Method calcAnexo(cAnexo, cTpCalc)
Method apurarSubatividade(oAtividade, oSubAtiv)
Method execQuery(cIdQuery, aParamQry)
Method calcPerExced()
Method calcRBT12FS12Prop()
Method finalizar()

// getters e setters

Method getUF()
Method setUF(cUF)
Method getDataIni()
Method setDataIni(dDataIni)
Method getDataFim()
Method setDataFim(dDataFim)
Method getFS12()
Method setFS12(nFS12)
Method getFSPA()
Method setFSPA(nFSPA)
Method getRBT12()
Method setRBT12(nRBT12)
Method getRBT12r()
Method setRBT12r(nRBT12R)
Method getRBA()
Method setRBA(nRBA)
Method getRPA()
Method setRPA(nRPA)
Method getRPATot()
Method setRPATot(nRPATot)
Method getFatorR()
Method setFatorR(nFatorR)
Method getValorDAS()
Method setValorDAS(nValorDAS)
Method getLimite()
Method setLimite(nLimite)
Method getSublimite()
Method setSublimite(nSublimite)
Method getAtividades(cCodAtiv)
Method setAtividades(aAtividades)
Method getAnexos(cAnexo)
Method setAnexos(aAnexos)
Method getTributos()
Method setTributos(aTributos)
Method getRecSubNaoExced()
Method setRecSubNaoExced(nRecSubNaoExced)
Method getRecSubExced()
Method setRecSubExced(nRecSubNaoExced)
Method getRecLimExced()
Method setRecLimExced(nRecLimExced)
Method getStatusSublimite()
Method setStatusSublimite(cStatusSub)
Method getStatusLimite()
Method setStatusLimite(cStatusLim)
Method getDtInicioAtiv()
Method setDtInicioAtiv(dIniAtiv)
Method getPerSubNaoExced()
Method setPerSubNaoExced(nPerSubNaoExced)
Method getPerSubExced()
Method setPerSubExced(nPerSubExced)
Method getPerLimExced()
Method setPerLimExced(nPerLimExced)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Método construtor da classe

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new() Class FISA153APURACAO

Self:clear()

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} clear()

Método responsável por reinicializar o componente de apuração.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method clear() Class FISA153APURACAO

Local nX := 0

Self:cUF := ""
Self:dDataIni := cToD("//")
Self:dDataFim := cToD("//")
Self:nFS12 := 0
Self:nFSPA := 0
Self:nRBT12 := 0
Self:nRBT12R := 0
Self:nRBA := 0
Self:nRPA := 0
Self:nRPATot := 0
Self:nFatorR := 0
Self:nValorDAS := 0
Self:nLimite := 0
Self:nSublimite := 0
Self:nRecSubNaoExced := 0
Self:nRecSubExced := 0
Self:nRecLimExced := 0
Self:cStatusSub := "1" // Inicializo o status do sublimite como 01 - Não excedido.
Self:cStatusLim := "1" // Inicializo o status do limite como 01 - Não excedido.
Self:dDtIniAtiv := cToD("//")
Self:nPerRBASubExced := 0
Self:nPerRBALimExced := 0
Self:nPerSubNaoExced := 0
Self:nPerSubExced := 0
Self:nPerLimExced := 0
Self:nPerRedIC := 0

// Limpa da memoria todos os objetos da lista de Atividades
If ValType(Self:aAtividades) == "A" .And. Len(Self:aAtividades) > 0

	For nX := 1 to Len(Self:aAtividades)
		Self:destroyObj(Self:aAtividades[nX])
	Next nX

EndIf

// Reinicializa o array de atividades
Self:aAtividades := {}

// Limpa da memoria todos os objetos da lista de Anexos
If ValType(Self:aAnexos) == "A" .And.  Len(Self:aAnexos) > 0

	For nX := 1 to Len(Self:aAnexos)
		Self:destroyObj(Self:aAnexos[nX])
	Next nX

EndIf

// Reinicializa o array de anexos
Self:aAnexos := {}

// Limpa da memoria todos os objetos da lista de Tributos
If ValType(Self:aTributos) == "A" .And. Len(Self:aTributos) > 0

	For nX := 1 to Len(Self:aTributos)
		Self:destroyObj(Self:aTributos[nX])
	Next nX

EndIf

// Reinicializa o array de tributos
Self:aTributos := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} destroyObj()

Método responsável por destruir o objeto e liberá-lo da memória.

@author joao.pellegrini
@since 27/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method destroyObj(oObj) Class FISA153APURACAO

Local cVersao := GetVersao(.F.)

// Na versão 11 ocorre errorlog ao chamar freeobj.
If cVersao <> "12"
	oObj := NIL
Else
	oObj := NIL
	FreeObj(oObj)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} loadAnexos()

Método de carga dos anexos e faixas de receita.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method loadAnexos() Class FISA153APURACAO

Local cAliasQry := ""
Local cAliasImp := ""
Local aParamQry := ""
Local oAnexo := NIL
Local oFaixa := NIL
Local cAnexo := ""
Local oImpostos := NIL

// Cache dos anexos e faixas de receita - tabelas F10 , F11 e CIA

aParamQry := {Self:dDataIni, Self:dDataFim}
cAliasQry := Self:execQuery("CARGA_ANEXOS", aParamQry)

While !(cAliasQry)->(Eof())

	cAnexo := (cAliasQry)->F10_ANEXO

	oAnexo := FISA153ANEXO():new()

	oAnexo:setNumero((cAliasQry)->F10_ANEXO)
	oAnexo:setDescricao((cAliasQry)->F10_DESCR)
	oAnexo:setPerPIS((cAliasQry)->F10_RIPIS)
	oAnexo:setPerCOF((cAliasQry)->F10_RICOF)
	oAnexo:setPerCSLL((cAliasQry)->F10_RICSLL)
	oAnexo:setPerIRPJ((cAliasQry)->F10_RIIRPJ)
	oAnexo:setPerCPP((cAliasQry)->F10_RICPP)

	// Enquanto for o mesmo anexo adiciono as faixas no objeto.
	While cAnexo == (cAliasQry)->F10_ANEXO

		oFaixa := FISA153FAIXA():new()

		oFaixa:setNumero((cAliasQry)->F11_FAIXA)
		oFaixa:setRecMin((cAliasQry)->F11_RECINI)
		oFaixa:setRecMax((cAliasQry)->F11_RECFIM)
		oFaixa:setAliqNom((cAliasQry)->F11_ALIQSN)
		oFaixa:setParcDed((cAliasQry)->F11_VALDED)
		oFaixa:setPerICMS((cAliasQry)->F11_ICMS)
		oFaixa:setPerISS((cAliasQry)->F11_ISS)
		oFaixa:setPerIPI((cAliasQry)->F11_IPI)
		oFaixa:setPerPIS((cAliasQry)->F11_PIS)
		oFaixa:setPerCOF((cAliasQry)->F11_COFINS)
		oFaixa:setPerCSLL((cAliasQry)->F11_CSLL)
		oFaixa:setPerCPP((cAliasQry)->F11_CPP)
		oFaixa:setPerIRPJ((cAliasQry)->F11_IRPJ)
		
		// Carrega valores da CIA
		oImpostos	:= FISA153IMPOSTOS():New()
		aImpostos	:= {}
		If lPosCIA
			aParamQry	:= { (cAliasQry)->F11_IANEXO , (cAliasQry)->F11_ID }		
			cAliasImp	:= Self:execQuery("CARGA_IMPOSTOS", aParamQry)

			While  !(cAliasImp)->(Eof())
				// Não mudar posição do array
				AADD( aImpostos , { oImpostos:Converter( (cAliasImp)->CIA_TIPO ) , (cAliasImp)->CIA_ALIQ, (cAliasImp)->CIA_VALDED, (cAliasImp)->CIA_LIMITE, (cAliasImp)->CIA_PERRED } )
				(cAliasImp)->(dbSkip())
			End

			(cAliasImp)->(dbCloseArea())			
		EndIf
		oImpostos:setImpostos(aImpostos)

		oFaixa:addImpostos(oImpostos)

		oAnexo:addFaixa(oFaixa)

		// Elimino o objeto da memória
		Self:destroyObj(oFaixa)
		Self:destroyObj(oImpostos)
		
		(cAliasQry)->(dbSkip())

	EndDo

	// Adiciono o anexo na lista
	Self:addAnexo(oAnexo)

	// Elimino o objeto da memória
	Self:destroyObj(oAnexo)

EndDo

dbSelectArea(cAliasQry)
(cAliasQry)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} loadLimites()

Método responsável por efetuar a carga dos limites/sublimites que
serão utilizados no cálculo dos tributos.

@author joao.pellegrini
@since 06/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method loadLimites() Class FISA153APURACAO

Local aParamQry := {}
Local cAliasQry := ""
Local nMesesAtiv := 0
Local nLimite := 0
Local nSublimite := 0

aParamQry := {Self:cUF, Self:dDataIni, Self:dDataFim}
cAliasQry := Self:execQuery("CARGA_LIMITES", aParamQry)

// Esta query deverá retornar sempre somente 1 linha.
// Por isso não faço o laço nos resultados.
If !(cAliasQry)->(Eof())

	// Se o início de atividade se deu o ano calendário de apuração
	// o limite e o sublimite deve ser proporcionais aos meses de atividade,
	// considerando-se as frações de meses como um mês inteiro (por isso somo 1 à diferença)
	If Year(Self:dDtIniAtiv) == Year(Self:dDataFim)
		nMesesAtiv := DateDiffMonth(Self:dDataFim, Self:dDtIniAtiv) + 1
		nLimite := ((cAliasQry)->F14_LFED / 12) * nMesesAtiv
		nSublimite := ((cAliasQry)->F14_LEST / 12) * nMesesAtiv
	Else
		nLimite := (cAliasQry)->F14_LFED
		nSublimite := (cAliasQry)->F14_LEST
	EndIf

	Self:nLimite := nLimite
	Self:nSublimite := nSublimite

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} calcFatorR()

Método responsável por calcular o fator "r" utilizado para definir
o anexo no qual algumas atividades de prestação de serviços são
enquadradas.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method calcFatorR() Class FISA153APURACAO 

// Se for o mês de início de atividade
If Month(Self:dDtIniAtiv) == Month(Self:dDataFim) .And. Year(Self:dDtIniAtiv) == Year(Self:dDataFim)

	/*

	Conforme Res. CGSN Nº 94/2011 Art. 26 § 6º

	§ 6º Para o cálculo do fator “r” referente a período de apuração do mês de início de atividades:
	I - se a FSPA for maior do que 0 (zero) e a RPA for igual a 0 (zero), o fator “r” será igual a 0,28 (vinte e oito centésimos);
	II - se a FSPA for igual a 0 (zero) e a RPA for maior do que 0 (zero), o fator “r” será igual a 0,01 (um centésimo);
	III - se a FSPA e a RPA forem maiores do que 0 (zero), o fator “r” corresponderá à divisão entre a FS12 e a RBT12r;

	*/

	If Self:nFSPA > 0 .And. Self:nRBA == 0
		Self:nFatorR := 0.28
	ElseIf Self:nFSPA == 0 .And. Self:nRBA > 0
		Self:nFatorR := 0.01
	ElseIf Self:nFSPA > 0 .And. Self:nRBA > 0
		Self:nFatorR := (Self:nFS12 / Self:nRBT12r)
	EndIf

Else

	/*

	Conforme Res. CGSN Nº 94/2011 Art. 26 § 7º

	§ 7º Para o cálculo do fator “r” referente a período de apuração posterior ao mês de início de atividades:
	I - se FS12 e RBT12r forem iguais a 0 (zero), o fator “r” será igual a 0,01 (um centésimo);
	II - se a FS12 for maior do que 0 (zero), e a RBT12r for igual a 0 (zero), o fator “r” será igual a 0,28 (vinte e oito centésimos);
	III - se a FS12 e a RBT12r forem maiores do que 0 (zero), o fator “r” corresponderá à divisão entre a FS12 e a RBT12r;
	IV - se a FS12 for igual a 0 (zero) e a RBT12 for maior do que 0 (zero), o fator “r” corresponderá a 0,01 (um centésimo).

	Conforme Res. CGSN Nº 94/2011 Art. 26 § 5º Inciso V

	V - RBT12r, a receita bruta acumulada dos 12 (doze) meses anteriores ao PA, considerando conjuntamente as receitas brutas auferidas no mercado interno e aquelas decorrentes da exportação.

	...por isso não utilizo o RBT12 normal.

	*/

	If Self:nFS12 == 0 .And. Self:nRBT12r == 0
		Self:nFatorR := 0.01
	ElseIf Self:nFS12 > 0 .And. Self:nRBT12r == 0
		Self:nFatorR := 0.28
	ElseIf Self:nFS12 > 0 .And. Self:nRBT12r > 0
		Self:nFatorR := (Self:nFS12 / Self:nRBT12r)
	ElseIf Self:nFS12 == 0 .And. Self:nRBT12r > 0
		Self:nFatorR := 0.01
	EndIf

EndIf

Return Self:nFatorR

//-------------------------------------------------------------------
/*/{Protheus.doc} addReceita()

Método responsável por adicionar uma receita na atividade correspondente
conforme cadastrado na tabela F17

@author joao.pellegrini
@since 01/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method addReceita(oReceita) Class FISA153APURACAO

Local cCodAtiv := oReceita:getCodAtiv()
Local cCodSubAtv := oReceita:getCodSubAtiv()
Local cAnexo := ""
Local oAtividade := NIL
Local oSubAtiv := NIL

dbSelectArea("F12")
F12->(dbSetOrder(1)) // F12_FILIAL+F12_CODATV+F12_ID
dbSelectArea("F17") // F17_FILIAL+F17_SUBATV+F17_ID
F17->(dbSetOrder(1))

// Faço o cálculo do Fator "r" aqui pois preciso saber o valor dele
// para decidir se uso o anexo normal ou o substituto.
If Self:nFatorR == 0
	Self:calcFatorR()
EndIf

// Primeiro verifico se a receita em questão está sujeita ao fator "r" para decidir
// qual anexo deve ser utilizado.
If oReceita:getFatorR() == "1"

	// Se for, verifico se o fator "r" é inferior a 28%.
	// Se for, a receita será tributada no anexo substituto.
	If Self:nFatorR <= 0.28
		cAnexo := oReceita:getAnexoSub()
	Else
		cAnexo := oReceita:getAnexo()
	EndIf

Else

	cAnexo := oReceita:getAnexo()

EndIf

// Carga da atividade.

If F12->(MsSeek(xFilial("F12") + PadR(cCodAtiv, TamSX3("F12_CODATV")[1])))

	oAtividade := FISA153ATIVIDADE():new()
	oAtividade:setCodigo(F12->F12_CODATV)
	oAtividade:setDescricao(F12->F12_DESCR)
	oAtividade:setTipoAtividade(F12->F12_TPATIV)

	// Adiciona atividade na lista de atividades da classe
	Self:addAtividade(oAtividade)

	// Elimino o objeto da memória
	Self:destroyObj(oAtividade)

EndIf

// Carga da subatividade

If F17->(MsSeek(xFilial("F17") + PadR(cCodSubAtv, TamSX3("F17_SUBATV")[1])))

	oSubAtiv := FISA153SUBATIVIDADE():new()
	oSubAtiv:setCodigo(F17->F17_SUBATV)
	oSubAtiv:setDescricao(F17->F17_DESCR)
	oSubAtiv:setReceita(oReceita:getValor())
	oSubAtiv:setRecBruta(oReceita:getValorBruto())
	oSubAtiv:setValorDevolucoes(oReceita:getValorDevolucoes())
	oSubAtiv:setAnexo(cAnexo)
	oSubAtiv:setRegraICMS(F17->F17_ICMS)
	oSubAtiv:setRegraISS(F17->F17_ISS)
	oSubAtiv:setRegraIPI(F17->F17_IPI)
	oSubAtiv:setRegraPIS(F17->F17_PIS)
	oSubAtiv:setRegraCOF(F17->F17_COFINS)
	oSubAtiv:setRegraCSL(F17->F17_CSLL)
	oSubAtiv:setRegraCPP(F17->F17_CPP)
	oSubAtiv:setRegraIRPJ(F17->F17_IRPJ)

	// Adiciona a subatividade na atividade adicionada anteriormente
	Self:getAtividades(cCodAtiv):addSubAtividade(oSubAtiv)

	// Elimino o objeto da memória
	Self:destroyObj(oSubAtiv)

EndIf

// Atualizo a RPA (Receita do Período de Apuração)
Self:nRPA += oReceita:getValor()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addAnexo()

Método responsável por adicionar um anexo na lista de anexos da classe.

@author joao.pellegrini
@since 01/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method addAnexo(oAnexo) Class FISA153APURACAO

aAdd(Self:aAnexos, oAnexo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addAtividade()

Método responsável por adicionar uma atividade na lista de atividades
da classe.

@author joao.pellegrini
@since 01/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method addAtividade(oAtividade) Class FISA153APURACAO

// Se ja houver atividades na lista verifico se a atividade que esta sendo adicionada
// ja existe. Soh adiciono se nao existir.

If Len(Self:aAtividades) > 0
	If aScan(Self:aAtividades, {|x| AllTrim(x:getCodigo()) == AllTrim(oAtividade:getCodigo())}) == 0
		aAdd(Self:aAtividades, oAtividade)
	EndIf
Else
	aAdd(Self:aAtividades, oAtividade)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} apurar()

Método responsável por efetuar a apuração das atividades constantes
na lista de atividades.

@author joao.pellegrini
@since 02/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method apurar() Class FISA153APURACAO

Local nX := 0
Local nY := 0
Local aSubAtivs := {}
Local aExcedentes := {}
Local oSubAtiv := NIL
Local nRecSubExced := 0
Local nRecSubNaoExced := 0
Local nRecLimExced := 0
Local oAnexo := NIL
Local aNewAnexos := {}
Local cCodAnexo := ""
Local cTpCalc := ""

// Verifico se há necessidade de proporcionalizar a RBT12 devido à data de início de atividade
// Devo proporcionalizar se o início de atividade se deu no mesmo ano calendário de apuração
// ou no ano imediatamente anterior conforme regras definidas.
If ((Year(Self:dDtIniAtiv) == Year(Self:dDataFim)) .Or. (Year(Self:dDtIniAtiv) == Year(Self:dDataFim) - 1))
	Self:calcRBT12FS12Prop()
EndIf

// Calcula os percentuais da receita mensal que excederam o sublimite ou o limite.
// Estes percentuais serão utilizados para proporcionalizar as receitas das atividades.
Self:calcPerExced()

// Faço o cálculo do fator "r" aqui novamente pois a filial pode não ter receita
// e não ter chamado o método addreceita.
If Self:nFatorR == 0
	Self:calcFatorR()
EndIf

// Se a RPA total for zero não terei lista de atividades para apurar, pois não
// foi apurada receita para nenhuma delas.
If Self:nRPATot == 0

	If Self:nPerRBALimExced > 0     // Percentual da RBA que excedeu o limite
		cTpCalc := "3"
	ElseIf Self:nPerRBASubExced > 0 // Percentual da RBA que excedeu o sublimite	
		cTpCalc := "2"
	Else
		cTpCalc := "1"
	EndIf

	For nX := 1 to Len(Self:aAnexos)

		cCodAnexo := StrZero(nX, 2)
		oAnexo := Self:calcAnexo(cCodAnexo, cTpCalc)
		aAdd(aNewAnexos, oAnexo)

	Next nX	

	// Atualizo a listagem de anexos da classe.
	Self:aAnexos := aNewAnexos

Else

	// Primeiro faço um laço em todas as atividades...
	For nX := 1 to Len(Self:aAtividades)

		aSubAtivs := Self:aAtividades[nX]:getSubAtividades()

		// Depois um laço nas subatividades apuradas a partir das receitas, calculando os tributos em cada uma...
		For nY := 1 to Len(aSubAtivs)

			nRecSubNaoExced := 0
			nRecSubExced 	:= 0
			nRecLimExced 	:= 0

			oSubAtiv := aSubAtivs[nY]

			// Parcela que NÃO EXCEDEU o SUBLIMITE
			nRecSubNaoExced := Round(oSubAtiv:getReceita() * Self:nPerSubNaoExced, 2)

			// Parcela que EXCEDEU o SUBLIMITE mas NÃO EXCEDEU o LIMITE
			nRecSubExced := Round(oSubAtiv:getReceita() * Self:nPerSubExced, 2)

			// Parcela que EXCEDEU o LIMITE
			nRecLimExced  := Round(oSubAtiv:getReceita() * Self:nPerLimExced, 2)

			// Atualizando a subatividade com as parcelas calculadas.
			oSubAtiv:setRecSubNaoExced(nRecSubNaoExced)
			oSubAtiv:setRecSubExced(nRecSubExced)
			oSubAtiv:setRecLimExced(nRecLimExced)

			Self:apurarSubatividade(Self:aAtividades[nX], aSubAtivs[nY])

		Next nY

	Next nX

EndIf

// Rotina de totalização e finalização da apuração.
Self:finalizar()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} calcAnexo()

Método responsável por efetuar o cálculo das alíquotas efetivas
do anexo passado como parâmetro.

@author joao.pellegrini
@since 23/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method calcAnexo(cAnexo, cTpCalc) Class FISA153APURACAO

Local oAnexo := NIL
Local oFaixa := NIL
Local oFaixaICIS := NIL
Local nRBT12 := IIf(Self:nRBT12 = 0, 1, Self:nRBT12)
Local oFaixaSublimite := NIL
Local nRecICIS := 0

oAnexo := Self:getAnexos(cAnexo)

If oAnexo == NIL
	Return oAnexo
EndIf

Do Case
	
	//------------------------------------------------------------------------
	// RECEITA QUE NÃO EXCEDEU O SUBLIMITE
	//------------------------------------------------------------------------
	Case cTpCalc == "1"
		oFaixa := oAnexo:enquadrar(nRBT12)

		If oFaixa <> NIL
			// Verifico se a faixa enquadrada é a última - getFaixaMax- e se ela não tem
			// percentuais de ICMS e ISS informados. Se for o caso preciso enquadrar a
			// maior faixa possível que contenha os percentuais dos tributos para calculá-los
			// Faço isso utilizando o próprio sublimite para enquadramento.
			// Esta situação está prevista no exemplo 9 do manual do PGDAS-D (2018).

			/*

			Conforme Res. CGSN Nº 94/2011 Art. 20 Inciso III alínea b:

			b) o valor da RBT12, quando for superior ao limite da 5ª faixa de receita bruta anual prevista nos Anexos I a V desta Resolução,
			nas situações em que o sublimite de que trata o § 1º do art. 9º não for excedido, o percentual efetivo do ICMS e do ISS será calculado com a seguinte fórmula:
			{[(RBT12 x alíquota nominal da 5ª faixa) – Parcela a Deduzir da 5ª Faixa]/RBT12} x Percentual de Distribuição do ICMS e do ISS da 5ª faixa.

			Obs: 5ª faixa se for p/ um estado com sublimite de 3.6kk. Se for 1.8kk preciso utilizar a 4ª faixa. Vide exemplo 9 do manual do PGDAS 2018.

			*/

			oFaixaICIS := oAnexo:enquadrar(Self:nSublimite)

			If nRBT12 > oFaixaICIS:getRecMax() .And. oFaixa:getPerISS() == 0 .And. oFaixa:getPerICMS() == 0
				// Efetua o cálculo das alíquotas efetivas passando apenas a faixa específica
				// para cálculo do ICMS e ISS. Neste caso a receita específica é a própria RBT12.
				oAnexo:calcAliqEfetivas(oFaixa, nRBT12, oFaixaICIS, nRBT12)
			Else
				oAnexo:calcAliqEfetivas(oFaixa, nRBT12) // Self:getAtividades("03"):getSubAtividades()
			EndIf

			// Elimino os objetos da memória
			Self:destroyObj(oFaixa)
			Self:destroyObj(oFaixaICIS)
		EndIf
	
	//------------------------------------------------------------------------
	// RECEITA QUE EXCEDEU O SUBLIMITE MAS NÃO EXCEDEU O LIMITE:
	//------------------------------------------------------------------------

	// Tributada normalmente. O ICMS e o ISS serão tributados com seus
	// valores máximos, ou seja, a última faixa (faixa do sublimite) e utilizando
	// a receita máxima desta faixa como base de cálculo.

	/*

	Conforme Res. CGSN Nº 94/2011 Art. 24 Inciso I:

	I - exceder o sublimite, mas não exceder o limite de R$ 4.800.000,00 (quatro milhões e oitocentos mil reais), estará sujeita:
	a) quanto aos tributos federais, aos percentuais efetivos calculados na forma prevista no art. 20; e
	b) quanto ao ICMS ou ISS, ao percentual efetivo calculado da seguinte forma:
	1. quando estiver vigente o sublimite de R$ 1.800.000,00: {[(1.800.000,00 x alíquota nominal da 4ª faixa) - parcela a deduzir da 4ª faixa]/1.800.000,00} x percentual de distribuição do ICMS/ISS da 4ª faixa;
	2. quando estiver vigente o sublimite de R$ 3.600.000,00: {[(3.600.000,00 x alíquota nominal da 5ª faixa) - parcela a deduzir da 5ª faixa]/3.600.000,00} x percentual de distribuição do ICMS/ISS da 5ª faixa

	*/
	Case cTpCalc == "2"
		oFaixa := oAnexo:enquadrar(nRBT12)

		If oFaixa <> NIL
			// Obtenho a faixa "máxima" de tributação enquadrando o sublimite.
			oFaixaICIS := oAnexo:enquadrar(Self:nSublimite)

			// Efetua o cálculo das alíquotas efetivas passando a faixa específica
			// para o cálculo do ICMS e ISS. Além disso a receita "base" para o cálculo
			// das alíquotas dos tributos será a receita máxima da faixa enquadrada
			// anteriormente e não a RBT12.
			oAnexo:calcAliqEfetivas(oFaixa, nRBT12, oFaixaICIS, oFaixaICIS:getRecMax())
			
			// Elimino o objeto da memória
			Self:destroyObj(oFaixaICIS)
		EndIf

	//------------------------------------------------------------------------
	// RECEITA QUE EXCEDEU O LIMITE
	//------------------------------------------------------------------------

	// Toda receita que excede o limite é tributada na faixa máxima (faixa do limite) utilizando como base
	// a receita máxima da faixa (o próprio limite).

	/*

	Conforme Res. CGSN Nº 94/2011 Art. 24 Inciso II:

	II - exceder o limite de R$ 4.800.000,00 (quatro milhões e oitocentos mil reais) estará sujeita:
	a) quanto aos tributos federais, aos percentuais efetivos calculados da seguinte forma:
	{[(4.800.000,00 x alíquota nominal da 6ª faixa) - parcela a deduzir da 6ª faixa]/4.800.000,00} x percentual de distribuição dos tributos federais da 6ª faixa; e
	b) quanto ao ICMS ou ISS, ao percentual efetivo calculado na forma prevista na alínea “b” do inciso I do caput.

	<Alinea b do inciso I do caput>
	1. quando estiver vigente o sublimite de R$ 1.800.000,00: {[(1.800.000,00 x alíquota nominal da 4ª faixa) - parcela a deduzir da 4ª faixa]/1.800.000,00} x percentual de distribuição do ICMS/ISS da 4ª faixa; ou
	2. quando estiver vigente o sublimite de R$ 3.600.000,00: {[(3.600.000,00 x alíquota nominal da 5ª faixa) - parcela a deduzir da 5ª faixa]/3.600.000,00} x percentual de distribuição do ICMS/ISS da 5ª faixa;

	*/
	Case cTpCalc == "3"
		oFaixa := oAnexo:enquadrar(Self:nLimite)

		// ICMS/ISS só ocorrerá se, no mês de apuração, a receita exceder
		// "de uma vez" o sublimite e o limite. Neste caso o status do sublimite
		// ainda seria "1" ou "2". Nesta situação vou tributar o máximo do ICMS/ISS
		//(igual faço quando a receita excede o sublimite).

		// Nas demais situações, quando a receita exceder o limite o sublimite
		// já terá sido excedido no mês anterior e, portanto, não haverá cálculo
		// dos tributos pelo SIMPLES.

		If oFaixa <> NIL
			If Self:cStatusSub $ "1|2"

				// Obtenho a faixa "máxima" de tributação enquadrando o sublimite.
				oFaixaICIS := oAnexo:enquadrar(Self:nSublimite)
				nRecICIS := oFaixaICIS:getRecMax()

			EndIf

			// Efetua o cálculo das alíquotas efetivas passando a faixa específica
			// para o cálculo do ICMS e ISS. Além disso a receita "base" para o cálculo
			// das alíquotas dos tributos será a receita máxima da faixa "máxima" enquadrada
			// anteriormente e não a RBT12.			
			oAnexo:calcAliqEfetivas(oFaixa, Self:nLimite, oFaixaICIS, nRecICIS)

			// Elimino o objeto da memória
			If oFaixaICIS <> NIL
				Self:destroyObj(oFaixaICIS)
			EndIf
		EndIf
EndCase

Return oAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} apurarSubatividade()

Método responsável por efetuar a apuração dos valores devidos da
subatividade passada como parâmetro.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method apurarSubatividade(oAtividade, oSubAtiv) Class FISA153APURACAO

Local oAnexoNaoExced   := NIL
Local oAnexoSubExced   := NIL
Local oAnexoLimExced   := NIL
Local oTributo         := NIL
Local oTribSubNaoExced := NIL
Local oTribSubExced    := NIL
Local oTribLimExced    := NIL
Local nAlqTranspCom    := 0
Local oAnexoTr         := NIL

//------------------------------------------------------------------------
// CÁLCULO DAS ALÍQUOTAS EFETIVAS
//------------------------------------------------------------------------

// Regra de cálculo p/ atividades de serviços de comunicação e transportes.
// Conforme Art. 18 § 5o-E:
//§ 5o-E.  Sem prejuízo do disposto no § 1o do art. 17 desta Lei Complementar, as atividades de prestação de serviços de
//comunicação e de transportes interestadual e intermunicipal de cargas, e de transportes autorizados no inciso VI do caput do art. 17,
//inclusive na modalidade fluvial, serão tributadas na forma do Anexo III, deduzida a parcela correspondente ao ISS e acrescida
//a parcela correspondente ao ICMS prevista no Anexo I.

// Esta alíquota será utilizada em todos os cálculos de ICMS
If oAtividade:getTipoAtividade() == "1"

	oAnexoTr := Self:calcAnexo("01", "1")

	If oAnexoTr <> NIL
		nAlqTranspCom := oAnexoTr:getAliqICMS()
	EndIf

EndIf

// Se houver receita excedente preciso calcular separadamente os tributos de cada
// parcela da receita:
// 1 - Parcela que não excedeu o sublimite
// 2 - Parcela que excedeu o sublimite mas não excedeu o limite.
// 3 - Parcela que excedeu o limite
// Por isso utilizo objetos separados de anexo para que sejam calculadas as alíquotas efetivas conforme cada caso

If oSubAtiv:getRecSubNaoExced() > 0

	oAnexoNaoExced := Self:calcAnexo(oSubAtiv:getAnexo(), "1")

	// Se for atividade de transporte/comunicação atualizo a alíquota de 
	// ICMS com a alíquota do anexo I e com a memória utilizada neste cálculo
	If oAtividade:getTipoAtividade() == "1"
		oAnexoNaoExced:setAliqICMS(nAlqTranspCom)
		oAnexoNaoExced:addMemoria(oAnexoTr:getMemoria("ICMS"))
	EndIf

EndIf

If oAnexoNaoExced <> NIL
	If oSubAtiv:getRecSubExced() > 0

		oAnexoSubExced := Self:calcAnexo(oSubAtiv:getAnexo(), "2")

		// Se for atividade de transporte/comunicação atualizo a alíquota de ICMS com a alíquota
		// do anexo I
		If oAtividade:getTipoAtividade() == "1"
			oAnexoSubExced:setAliqICMS(nAlqTranspCom)
			oAnexoSubExced:addMemoria(oAnexoTr:getMemoria("ICMS"))
		EndIf

	EndIf

	If oSubAtiv:getRecLimExced() > 0

		oAnexoLimExced := Self:calcAnexo(oSubAtiv:getAnexo(), "3")

		If Self:cStatusSub $ "1|2"
			// Se for atividade de transporte/comunicação atualizo a alíquota de ICMS com a alíquota
			// do anexo I
			If oAtividade:getTipoAtividade() == "1"
				oAnexoLimExced:setAliqICMS(nAlqTranspCom)
				oAnexoLimExced:addMemoria(oAnexoTr:getMemoria("ICMS"))
			EndIf
		EndIf

	EndIf

	//-----------------------------------------------------------------------
	// CÁLCULO DOS TRIBUTOS
	//------------------------------------------------------------------------

	// Regras:
	// 1 - Calcula
	// 2 - Não calcula

	// Se houve receita excedente calculo separadamente os tributos, classificando-os em:
	// Tributo referente à parcela da receita não excedente.
	// Tributo referente à parcela da receita excedente.

	//-----------------------------------------------------------------------------------------------------
	// REGRA GERAL PARA CÁLCULO DOS TRIBUTOS
	// Configuração p/ calcular = "1-SIM"
	// TRIBUTOS ESTADUAIS/MUNICIPAIS: Status do sublimite = 1 - Não excedido ou 2 - Excedido em até 20%.
	// TRIBUTOS FEDERAIS: Status do limite = 1 - Não excedido ou 2 - Excedido em até 20%.
	//-----------------------------------------------------------------------------------------------------

	//ICMS
	If oSubAtiv:getRegraICMS() == "1" .And. Self:cStatusSub $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("ICMS","ICMS",oSubAtiv:getRecSubNaoExced(),;
				Iif( oAnexoNaoExced:getRAliqICM() > 0 ,oAnexoNaoExced:getRAliqICM() ,oAnexoNaoExced:getAliqICMS() ),;
				/*valor*/,"1",.T.,/*nPerRedBC*/,/*lPerRedBC*/,oAnexoNaoExced:getISSExced(),IIF( oAnexoNaoExced:getRAliqICM() > 0, oAnexoNaoExced:getPerICMS(), 0 ), oAnexoNaoExced:getPerRedIC("ICMS"))
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("ICMS"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced := FISA153TRIBUTO():new("ICMS", "ICMS", oSubAtiv:getRecSubExced(),;
				IIf(oAnexoSubExced:getRAliqICM() > 0 ,oAnexoSubExced:getRAliqICM() ,oAnexoSubExced:getAliqICMS()),;
				/*valor*/, "2", .T.,/*nPerRedBC*/,/*lPerRedBC*/,oAnexoNaoExced:getISSExced(),IIF( oAnexoNaoExced:getRAliqICM() > 0, oAnexoNaoExced:getPerICMS(), 0 ))
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("ICMS"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("ICMS", "ICMS", oSubAtiv:getRecLimExced(),;
				IIf(oAnexoLimExced:getRAliqICM() > 0 ,oAnexoLimExced:getRAliqICM() ,oAnexoLimExced:getAliqICMS()),;
				/*valor*/, "3", .T.,/*nPerRedBC*/,/*lPerRedBC*/,oAnexoNaoExced:getISSExced(),IIF( oAnexoNaoExced:getRAliqICM() > 0, oAnexoNaoExced:getPerICMS(), 0 ))
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("ICMS"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf

	//ISS
	If oSubAtiv:getRegraISS() == "1" .And. Self:cStatusSub $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("ISS", "ISS", oSubAtiv:getRecSubNaoExced(), oAnexoNaoExced:getAliqISS(), /*valor*/, "1", .T.,,,oAnexoNaoExced:getISSExced())
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("ISS"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced  := FISA153TRIBUTO():new("ISS", "ISS", oSubAtiv:getRecSubExced(), oAnexoSubExced:getAliqISS(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced())
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("ISS"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("ISS", "ISS", oSubAtiv:getRecLimExced(), oAnexoLimExced:getAliqISS(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced())
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("ISS"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf

	//IPI
	If oSubAtiv:getRegraIPI() == "1" .And. Self:cStatusLim $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("IPI", "IPI", oSubAtiv:getRecSubNaoExced(), oAnexoNaoExced:getAliqIPI(), /*valor*/, "1", .T.,,,oAnexoNaoExced:getISSExced())
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("IPI"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced  := FISA153TRIBUTO():new("IPI", "IPI", oSubAtiv:getRecSubExced(), oAnexoSubExced:getAliqIPI(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced())
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("IPI"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("IPI", "IPI", oSubAtiv:getRecLimExced(), oAnexoLimExced:getAliqIPI(), /*valor*/, "3", .T.,,,oAnexoNaoExced:getISSExced())
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("IPI"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf

	//PIS
	If oSubAtiv:getRegraPIS() == "1" .And. Self:cStatusLim $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("PIS", "PIS", oSubAtiv:getRecSubNaoExced(), oAnexoNaoExced:getAliqPIS(), /*valor*/, "1", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerPIS())
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("PIS"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced  := FISA153TRIBUTO():new("PIS", "PIS", oSubAtiv:getRecSubExced(), oAnexoSubExced:getAliqPIS(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerPIS())
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("PIS"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("PIS", "PIS", oSubAtiv:getRecLimExced(), oAnexoLimExced:getAliqPIS(), /*valor*/, "3", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerPIS())
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("PIS"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf

	//COFINS
	If oSubAtiv:getRegraCOF() == "1" .And. Self:cStatusLim $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("COFINS", "COFINS", oSubAtiv:getRecSubNaoExced(), oAnexoNaoExced:getAliqCOF(), /*valor*/, "1", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCOF())
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("COFINS"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced  := FISA153TRIBUTO():new("COFINS", "COFINS", oSubAtiv:getRecSubExced(), oAnexoSubExced:getAliqCOF(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCOF())
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("COFINS"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("COFINS", "COFINS", oSubAtiv:getRecLimExced(), oAnexoLimExced:getAliqCOF(), /*valor*/, "3", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCOF())
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("COFINS"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf

	//CSLL
	If oSubAtiv:getRegraCSL() == "1" .And. Self:cStatusLim $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("CSLL", "CSLL", oSubAtiv:getRecSubNaoExced(), oAnexoNaoExced:getAliqCSLL(), /*valor*/, "1", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCSLL())
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("CSLL"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced  := FISA153TRIBUTO():new("CSLL", "CSLL", oSubAtiv:getRecSubExced(), oAnexoSubExced:getAliqCSLL(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCSLL())
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("CSLL"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("CSLL", "CSLL", oSubAtiv:getRecLimExced(), oAnexoLimExced:getAliqCSLL(), /*valor*/, "3", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCSLL())
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("CSLL"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf

	//CPP
	If oSubAtiv:getRegraCPP() == "1" .And. Self:cStatusLim $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("CPP", "CPP", oSubAtiv:getRecSubNaoExced(), oAnexoNaoExced:getAliqCPP(), /*valor*/, "1", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCPP())
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("CPP"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced  := FISA153TRIBUTO():new("CPP", "CPP", oSubAtiv:getRecSubExced(), oAnexoSubExced:getAliqCPP(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCPP())
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("CPP"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("CPP", "CPP", oSubAtiv:getRecLimExced(), oAnexoLimExced:getAliqCPP(), /*valor*/, "3", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerCPP())
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("CPP"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf

	//IRPJ
	If oSubAtiv:getRegraIRPJ() == "1" .And. Self:cStatusLim $ "1|2"

		// Tributo da parcela que não excedeu o sublimite.
		If oSubAtiv:getRecSubNaoExced() > 0
			oTribSubNaoExced := FISA153TRIBUTO():new("IRPJ", "IRPJ", oSubAtiv:getRecSubNaoExced(), oAnexoNaoExced:getAliqIRPJ(), /*valor*/, "1", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerIRPJ())
			oTribSubNaoExced:setMemoria(oAnexoNaoExced:getMemoria("IRPJ"))
			oSubAtiv:addTributo(oTribSubNaoExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o sublimite e não excedeu o limite.
		If oSubAtiv:getRecSubExced() > 0
			oTribSubExced  := FISA153TRIBUTO():new("IRPJ", "IRPJ", oSubAtiv:getRecSubExced(), oAnexoSubExced:getAliqIRPJ(), /*valor*/, "2", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerIRPJ())
			oTribSubExced:setMemoria(oAnexoSubExced:getMemoria("IRPJ"))
			oSubAtiv:addTributo(oTribSubExced, .T.)
		EndIf

		// Tributo da parcela que excedeu o limite.
		If oSubAtiv:getRecLimExced() > 0
			oTribLimExced := FISA153TRIBUTO():new("IRPJ", "IRPJ", oSubAtiv:getRecLimExced(), oAnexoLimExced:getAliqIRPJ(), /*valor*/, "3", .T.,,,oAnexoNaoExced:getISSExced(),oAnexoNaoExced:getPerIRPJ())
			oTribLimExced:setMemoria(oAnexoLimExced:getMemoria("IRPJ"))
			oSubAtiv:addTributo(oTribLimExced, .T.)
		EndIf

	EndIf
EndIf

//------------------------------------------------------------------------
// LIMPEZA DOS OBJETOS
//------------------------------------------------------------------------

Self:destroyObj(oAnexoNaoExced)
Self:destroyObj(oAnexoSubExced)
Self:destroyObj(oAnexoLimExced)
Self:destroyObj(oAnexoTr)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} execQuery()

Método responsável por executar as queries utilizadas pela apuração.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method execQuery(cIDQuery, aParamQry) Class FISA153APURACAO

Local cAliasQry := ""
Local cSelect 	:= ""
Local cFrom 	:= ""
Local cWhere 	:= ""
Local cOrder 	:= ""
Local cGroupBy	:= ""
Local lUnidNeg 	:= .F.
Local cFilSe5	:= ""
Local cFilSe1	:= ""
Local cTipoTit	:= ""
Local lSe1MsFil	:= .F.
Local lSe5MsFil	:= .F.
Local lNRastDSD	:= .F.
Local cBxSql	:= .F.
Local cBxCanc	:= ""
Local cFilialSE1	:= ""
Local oVal := nil

DEFAULT aParamQry := {}



Do Case

	Case cIDQuery == "CARGA_ANEXOS"

		cSelect += "F10.F10_ANEXO, F10.F10_DESCR, F10.F10_INIVIG, F10.F10_FIMVIG, F10.F10_RIIRPJ, F10.F10_RICSLL, F10.F10_RIPIS, F10.F10_RICOF, F10.F10_RICSLL, F10.F10_RICPP, "
		cSelect += "F11.F11_ID, F11.F11_FAIXA, F11.F11_RECINI, F11.F11_RECFIM, F11.F11_ALIQSN, F11.F11_VALDED, F11.F11_ICMS, F11.F11_ISS, F11.F11_IPI, F11.F11_PIS, F11.F11_COFINS, F11.F11_CSLL, F11.F11_CPP, F11.F11_IRPJ , F11.F11_IANEXO "

		cFrom += RetSQLName("F10") + " F10 "
		cFrom += "JOIN " + RetSQLName("F11") + " F11 " + " ON (F11.F11_FILIAL = " + ValToSQL(xFilial("F11")) + " AND F11.F11_IANEXO = F10.F10_ID AND F11.D_E_L_E_T_ = ' ') "

		cWhere += "F10.F10_FILIAL = " + ValToSQL(xFilial("F10")) + " AND "
		cWhere += "F10.F10_INIVIG <= " + ValToSQL(aParamQry[1])  + " AND "
		cWhere += "(F10.F10_FIMVIG >= " + ValToSQL(aParamQry[2]) + " OR F10.F10_FIMVIG = " + ValToSQL(Space(TamSX3("F10_FIMVIG")[1])) + ") AND "
		cWhere += "F10.D_E_L_E_T_ = ' ' "

		cOrder := "ORDER BY F10.F10_ANEXO, F11.F11_FAIXA"

	Case cIDQuery == "CARGA_ATIVIDADES"

		cSelect += "F12.F12_FILIAL, F12.F12_CODATV, F12.F12_DESCR, F12.F12_TPATIV "

		cFrom += RetSQLName("F12") + " F12 "

		cWhere += "F12.F12_FILIAL = " + ValToSQL(xFilial("F12")) + " AND "
		cWhere += "F12.D_E_L_E_T_ = ' ' "

		cOrder := "ORDER BY F12.F12_CODATV"

	Case cIdQuery == "CARGA_SUBATIVIDADES"

		cSelect += "F17.F17_FILIAL, F17.F17_CODATV, F17.F17_SUBATV, F17.F17_DESCR, F17.F17_ICMS, F17.F17_ISS, F17.F17_IPI, F17.F17_PIS, F17.F17_COFINS, F17.F17_CSLL, F17.F17_CPP, F17.F17_IRPJ "

		cFrom += RetSQLName("F17") + " F17 "

		cWhere += "F17.F17_FILIAL = " + ValToSQL(xFilial("F17")) + " AND "
		cWhere += "F17.D_E_L_E_T_ = ' ' "
		cOrder := "ORDER BY F17.F17_SUBATV"

	Case cIDQuery == "CARGA_LIMITES"

		cSelect += "F14.F14_LEST, F14.F14_LFED "

		cFrom += RetSQLName("F14") + " F14 "

		cWhere += "F14.F14_FILIAL = " + ValToSQL(xFilial("F14")) + " AND "
		cWhere += "F14.F14_UF = " + ValToSQL(aParamQry[1]) + " AND "
		cWhere += "F14.F14_INIVIG <= " + ValToSQL(aParamQry[2])  + " AND "
		cWhere += "(F14.F14_FIMVIG >= " + ValToSQL(aParamQry[3]) + " OR F14.F14_FIMVIG = " + ValToSQL(Space(TamSX3("F14_FIMVIG")[1])) + ") AND "
		cWhere += "F14.D_E_L_E_T_ = ' '"

	Case cIdQuery == "RECEITA_CFOP"

		cSelect += "F12.F12_CODATV, F13.F13_ANEXO , F13.F13_ASUB,  F13.F13_CFOP, SF4.F4_CSOSN, SF4.F4_INCSOL, SD2.D2_VALBRUT AS VALBRUT, SD2.D2_ICMSRET AS NICMSRET, '' AS F13_TPSERV, F13.F13_FATORR, '' AS A1_COD_MUN, '' AS C5_MUNPRES, '' AS C5_ESTPRES, '' AS F2_RECISS, '' AS B1_MEPLES, '' AS A1_EST , D2_VALIPI AS VALIPI"

		cFrom   += RetSQLName("F12") + " F12 "
		cFrom += "JOIN " + RetSQLName("F13") + " F13 " + " ON (F13.F13_FILIAL = " + ValToSQL(xFilial("F13")) + " AND F13.F13_IDATV = F12.F12_ID AND F13.F13_CFOP <> ' ' AND F13.F13_INIVIG <= " + ValToSQL(FirstDay( aParamQry[2] ) )  + " AND (F13.F13_FIMVIG >= " + ValToSQL( lastday(aParamQry[2])) + " OR F13.F13_FIMVIG = " + ValToSQL(Space(TamSX3("F13_FIMVIG")[1])) + ") AND F13.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SD2") + " SD2 " + " ON (SD2.D2_FILIAL = "  + ValToSQL(xFilial("SD2")) + " AND SD2.D2_CF = F13.F13_CFOP AND SD2.D2_EMISSAO >= " + ValToSQL(FirstDay( aParamQry[2] ) )   + " AND SD2.D2_EMISSAO <= " + ValToSQL( lastday(aParamQry[2])) + " AND " + Iif ( aParamQry[1] == "1" , "SD2.D2_EST <> 'EX' "   , "SD2.D2_EST = 'EX' "   ) + " AND SD2.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SF4") + " SF4 ON (SF4.F4_FILIAL  = " + ValToSQL(xFilial("SF4")) + " AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ = ' ') "
		cWhere  += "F12.F12_FILIAL = " + ValToSQL( xFilial("F12") ) + " AND "
		cWhere  += "F12.F12_TPREC = " + ValToSQL( aParamQry[1] )    + " AND "
		cWhere  += "F12.D_E_L_E_T_ = ' '"		

	Case cIdQuery == "RECEITA_GRUPO" 

		cSelect += "F12.F12_CODATV, F13.F13_ANEXO , F13.F13_ASUB, SD2.D2_VALBRUT AS VALBRUT, '' AS F13_CFOP, '' AS F4_CSOSN, 0 AS NICMSRET, '' AS F13_TPSERV, F13.F13_FATORR, '' AS A1_COD_MUN, '' AS C5_MUNPRES, '' AS C5_ESTPRES, '' AS F2_RECISS, '' AS B1_MEPLES, '' AS A1_EST, '' as F4_INCSOL, D2_VALIPI AS VALIPI "
		

		cFrom   += RetSQLName("F12") + " F12 "
		cFrom += "JOIN " + RetSQLName("F13") + " F13 " + " ON (F13.F13_FILIAL = " + ValToSQL(xFilial("F13")) + " AND F13.F13_IDATV = F12.F12_ID AND F13.F13_GRUPO <> ' ' AND F13.F13_INIVIG <= " + ValToSQL(FirstDay( aParamQry[2] ) )  + " AND (F13.F13_FIMVIG >= " + ValToSQL( lastday(aParamQry[2])) + " OR F13.F13_FIMVIG = " + ValToSQL(Space(TamSX3("F13_FIMVIG")[1])) + ") AND F13.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SD2") + " SD2 " + " ON (SD2.D2_FILIAL = "  + ValToSQL(xFilial("SD2")) + " AND SD2.D2_GRUPO = F13.F13_GRUPO AND SD2.D2_EMISSAO >= " +  ValToSQL(FirstDay( aParamQry[2] ) )  + " AND SD2.D2_EMISSAO <= " +  ValToSQL( lastday(aParamQry[2]))  + " AND " + Iif ( aParamQry[1] == "1" , "SD2.D2_EST <> 'EX' "   , "SD2.D2_EST = 'EX' "   ) + " AND SD2.D_E_L_E_T_ = ' ') "

		cWhere  += "F12.F12_FILIAL = " + ValToSQL( xFilial("F12") ) + " AND "
		cWhere  += "F12.F12_TPREC = " + ValToSQL( aParamQry[1] )    + " AND "
		cWhere  += "F12.D_E_L_E_T_ = ' '"		

	Case cIdQuery == "RECEITA_ISS"

		cSelect += "F12.F12_CODATV, F13.F13_ANEXO, F13.F13_ASUB, F13.F13_FATORR, F13.F13_TPSERV, SF2.F2_RECISS, SC5.C5_MUNPRES, SC5.C5_ESTPRES, SF4.F4_CSOSN, SA1.A1_COD_MUN, SD2.D2_VALBRUT AS VALBRUT , '' AS F13_CFOP, 0 AS NICMSRET, SB1.B1_MEPLES, SA1.A1_EST,'' AS F4_INCSOL, D2_VALIPI AS VALIPI "

		cFrom   += RetSQLName("F12") + " F12 "
		cFrom += "JOIN " 	  + RetSQLName("F13") + " F13 ON (F13.F13_FILIAL = " + ValToSQL(xFilial("F13")) + " AND F13.F13_IDATV = F12.F12_ID AND F13.F13_CODISS <> ' ' AND F13.F13_INIVIG <= " + ValToSQL(FirstDay( aParamQry[2] ) )  + " AND (F13.F13_FIMVIG >= " + ValToSQL( lastday(aParamQry[2])) + " OR F13.F13_FIMVIG = " + ValToSQL(Space(TamSX3("F13_FIMVIG")[1])) + ") AND F13.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " 	  + RetSQLName("SD2") + " SD2 ON (SD2.D2_FILIAL  = " + ValToSQL(xFilial("SD2")) + " AND SD2.D2_CODISS = F13.F13_CODISS AND SD2.D2_EMISSAO >= " +  ValToSQL(FirstDay( aParamQry[2] ) )   + " AND SD2.D2_EMISSAO <= " +  ValToSQL( lastday(aParamQry[2]))  + " AND " + Iif ( aParamQry[1] == "1" , "SD2.D2_EST <> 'EX' "   , "SD2.D2_EST = 'EX' "   ) + " AND SD2.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " 	  + RetSQLName("SB1") + " SB1 ON (SB1.B1_FILIAL  = " + ValToSQL(xFilial("SB1")) + " AND SD2.D2_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " 	  + RetSqlName("SF2") + " SF2 ON (SF2.F2_FILIAL  = " + ValToSQL(xFilial("SF2")) + " AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA AND SF2.D_E_L_E_T_=' ') "
		cFrom += "JOIN " 	  + RetSQLName("SA1") + " SA1 ON (SA1.A1_FILIAL  = " + ValToSQL(xFilial("SA1")) + " AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " 	  + RetSQLName("SF4") + " SF4 ON (SF4.F4_FILIAL  = " + ValToSQL(xFilial("SF4")) + " AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ = ' ') "
		cFrom += "LEFT JOIN " + RetSQLName("SC5") + " SC5 ON (SC5.C5_FILIAL  = " + ValToSQL(xFilial("SC5")) + " AND SC5.C5_NUM = SD2.D2_PEDIDO AND SC5.D_E_L_E_T_ = ' ') "

		cWhere  += "F12.F12_FILIAL = " + ValToSQL( xFilial("F12") ) + " AND "
		cWhere  += "F12.F12_TPREC = " + ValToSQL( aParamQry[1] )    + " AND "
		cWhere  += "F12.D_E_L_E_T_ = ' '"

	Case cIdQuery == "RECEITA_CAIXA"

		lUnidNeg 	:= Iif( FindFunction("FWCodFil") , FWSizeFilial() > 2, .F. ) // Verifica se utiliza Gestão Corporativa
		cFilSe5		:= xFilial("SE5")
		cFilSe1		:= xFilial("SE1")
		lSe1MsFil	:= SE1->(FieldPos("E1_MSFIL")) > 0
		lSe5MsFil	:= SE5->(FieldPos("E5_MSFIL")) > 0
		cTipoTit	:= MVTAXA + "|" + MVABATIM + "|" + MV_CRNEG + "|" + MVPROVIS   // Titulos de Impostos
		lNRastDSD	:= SuperGetMV("MV_NRASDSD",.T.,.F.) //Parametro que permite ao usuario utilizar o desdobramento da maneira anterior ao implementado com o rastremaento.
		cBxSql		:= SuperGetMV("MV_MTBXF6",.T.,.F.)

		If lUnidNeg
			cFilSe5	:= SM0->M0_CODFIL
			cFilSe1 := SM0->M0_CODFIL
		EndIF

		cBxCanc		:= "('LIQ'"
		If !Empty(cBxSql)
			cBxCanc += "," + cBxSql
		EndIf
		cBxCanc		+= ")"

		//-------------------------------------------------------------------------------------------------
		//Condição para realizar Join com a SE1, precisa verificar o E1_FILIAL ou E1_MSFIL ou o E1_FILORIG
		//-------------------------------------------------------------------------------------------------
		If !Empty( Iif( lUnidNeg, FWFilial("SE1") , xFilial("SE1") ) )
			cFilialSE1 	:= "SE1.E1_FILIAL = '"  +   xFilial("SE1") + "' AND "
		Else
			If lSe1MsFil
				cFilialSE1 	:= "SE1.E1_MSFIL = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "
			Else
				cFilialSE1 	:= "SE1.E1_FILORIG = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "
			Endif
		EndIf

		//-------------------------------------------
		//Seção dos campos do Select
		//-------------------------------------------
		cSelect += "SE5.E5_FILIAL, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPODOC, SE5.E5_MOTBX, SE5.E5_DATA, "
		cSelect += "SE5.E5_VALOR, SE5.E5_DOCUMEN , SE1.E1_VALOR ,SE1.E1_ORIGEM, SE1.E1_SERIE , SE1.E1_DESDOBR , SE1.E1_EMISSAO ,  SE1.E1_PEDIDO , SE5.E5_VLMULTA , SE5.E5_VLJUROS , SE5.E5_VLDESCO "

		cFrom   += RetSQLName("SE5") + " SE5 "
		cFrom 	+= "JOIN " + RetSQLName("SE1") + " SE1 ON ( " + cFilialSE1  +  " SE5.E5_PREFIXO = SE1.E1_PREFIXO AND SE5.E5_NUMERO = SE1.E1_NUM AND SE5.E5_PARCELA = SE1.E1_PARCELA AND SE5.E5_TIPO = SE1.E1_TIPO AND SE5.E5_CLIFOR = SE1.E1_CLIENTE AND SE5.E5_LOJA = SE1.E1_LOJA AND SE1.D_E_L_E_T_ = ' ') "

		//-------------------------------------------------------------------------------------------------
		//Condição para realizar Join com a SE1, precisa verificar o E5_FILIAL ou E5_MSFIL ou o E5_FILORIG
		//-------------------------------------------------------------------------------------------------
		If !Empty( Iif( lUnidNeg , FWFilial("SE5") , xFilial("SE5") ) )
			cWhere 	+= "SE5.E5_FILIAL = '"  + xFilial("SE5") + "' AND "
		Else
			If lSe5MsFil
				cWhere 	+= "SE5.E5_MSFIL = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "
			Else
				cWhere 	+= "SE5.E5_FILORIG = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "
			Endif
		EndIf

		cWhere 	+= "SE5.E5_DATA >= " + ValToSQL( aParamQry[2] ) + " AND SE5.E5_DATA <= " + ValToSQL( lastDay( aParamQry[2] ) )   + " AND "

		If  !lNRastDSD //Tratamento para desdobramento
			cWhere	+= "( ( SE1.E1_DESDOBR = '1' AND SE1.E1_BAIXA <>'' AND SE1.E1_SITUACA <> '' ) OR SE1.E1_DESDOBR <> '1' ) AND  SE5.D_E_L_E_T_ = ' ' AND "
		Endif

		//-------------------------------------------
		//Exclui os titulos que possuem estorno
		//-------------------------------------------
		cWhere	 	+= "SE5.E5_SEQ NOT IN "
		cWhere 		+= "(SELECT SE5AUX.E5_SEQ FROM "+RetSqlName("SE5")+" SE5AUX WHERE "
		cWhere		+= 		" SE5AUX.E5_FILIAL = SE5.E5_FILIAL AND "
		cWhere		+= 		" SE5AUX.E5_PREFIXO = SE5.E5_PREFIXO AND "
		cWhere		+= 		" SE5AUX.E5_NUMERO = SE5.E5_NUMERO AND  "
		cWhere		+= 		" SE5AUX.E5_PARCELA = SE5.E5_PARCELA AND "
		cWhere		+= 		" SE5AUX.E5_TIPO = SE5.E5_TIPO AND "
		cWhere		+= 		" SE5AUX.E5_CLIFOR = SE5.E5_CLIFOR AND "
		cWhere		+= 		" SE5AUX.E5_LOJA = SE5.E5_LOJA AND "
		cWhere		+= 		" SE5AUX.E5_TIPODOC = 'ES' AND "
		cWhere		+= 		" SE5AUX.D_E_L_E_T_ = '' "
		cWhere 		+= ") AND "
		cWhere 		+= "SE5.E5_TIPO NOT IN " + FormatIn(cTipoTit,If("|"$cTipoTit,"|",","))  + " AND "
		cWhere		+= " ((SE5.E5_MOTBX <> 'FAT' AND SE5.E5_TIPO <> 'RA') OR (SE5.E5_MOTBX = 'CMP' AND SE5.E5_TIPODOC = 'CP' AND SE5.E5_TIPO = 'NF')) AND "
		cWhere		+= "SE5.E5_MOTBX NOT IN " + cBxCanc + " AND "
		cWhere      += "E5_TIPODOC NOT IN ('DC','JR','MT') AND "
		cWhere		+= "SE5.E5_SITUACA <> 'C' AND "
		cWhere	 	+= "SE5.E5_RECPAG = 'R' "		//Somente titulos a receber (tabela SE1).
		cWhere		+= "ORDER BY SE5.E5_FILIAL, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO, SE5.E5_CLIFOR, SE5.E5_LOJA"

	Case cIdQuery == "DEVOLUCOES_CFOP"

		cSelect += "F12.F12_CODATV, F13.F13_ANEXO ,F13.F13_ASUB,  SF4.F4_INCSOL, F13.F13_FATORR, F13.F13_CFOP, SF4.F4_CSOSN, SD1.D1_TOTAL, SD1.D1_ICMSRET AS NICMSRET, D1_VALIPI AS VALIPI, "
		cSelect += "SD1.D1_VALDESC, SD1.D1_VALFRE, SD1.D1_SEGURO, SD1.D1_DESPESA, SD1.D1_VALIPI, '' AS F13_TPSERV, '' AS A1_COD_MUN, '' AS C5_MUNPRES, '' AS C5_ESTPRES, '' AS F2_RECISS, '' AS A1_EST, "
		cSelect += "'' AS B1_MEPLES "

		cFrom  += RetSQLName("SD1") + " SD1 "

		cFrom  += "JOIN " + RetSqlName("SD2") + " SD2 ON (SD2.D2_FILIAL  = " + ValToSQL(xFilial("SD2")) + " AND SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND ((SD2.D2_CLIENTE = SD1.D1_FORNECE AND SD2.D2_LOJA = SD1.D1_LOJA) OR SD1.D1_ORIGLAN = 'LO') AND SD2.D_E_L_E_T_ = ' ') "
		cFrom  += "JOIN " + RetSqlName("SF4") + " SF4 ON (SF4.F4_FILIAL  = " + ValToSQL(xFilial("SF4")) + " AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ = ' ') "
		cFrom  += "JOIN " + RetSqlName("F13") + " F13 ON (F13.F13_FILIAL = " + ValToSQL(xFilial("F13")) + " AND F13.F13_CFOP = SD2.D2_CF AND F13.F13_INIVIG <= " + ValToSQL(FirstDay( aParamQry[2] ) )  + " AND (F13.F13_FIMVIG >= " + ValToSQL( lastday(aParamQry[2])) + " OR F13.F13_FIMVIG = " + ValToSQL(Space(TamSX3("F13_FIMVIG")[1])) + ") AND F13.D_E_L_E_T_ = ' ') "
		cFrom  += "JOIN " + RetSqlName("F12") + " F12 ON (F12.F12_FILIAL = " + ValToSQL(xFilial("F12")) + " AND F12.F12_ID = F13.F13_IDATV AND F12.F12_TPREC = " + ValToSQL( aParamQry[1] ) + " AND F12.D_E_L_E_T_ = ' ') "

		cWhere += "SD1.D1_FILIAL = " + ValToSQL(xFilial("SD1")) + " AND "
    	cWhere += "SD1.D1_DTDIGIT >= " + ValToSQL(FirstDay(aParamQry[2])) + " AND SD1.D1_DTDIGIT <= " + ValToSQL(LastDay(aParamQry[2])) + " AND "
    	cWhere += "SD1.D1_TIPO = 'D' AND "
    	cWhere += "SD1.D_E_L_E_T_ = ' ' "		

	Case cIDQuery == "SALDO_DEVOLUCOES"

		cSelect += "F1D.F1D_FILIAL, F1D.F1D_ID, F1D.F1D_MES, F1D.F1D_ANO, F1D.F1D_MESUTI, F1D.F1D_ANOUTI, F1D.F1D_CODATV, F1D.F1D_SUBATV, F1D.F1D_ANEXO, "
		cSelect += "F1D.F1D_TPREC, F1D.F1D_SLDINI, F1D.F1D_SLDFIN, F1D.F1D_IDAPUR "

		cFrom += RetSqlName("F1D") + " F1D "

		cWhere += "F1D.F1D_FILIAL = " + ValToSQL(xFilial("F1D")) + " AND "
		cWhere += "F1D.F1D_MESUTI = " + ValToSQL(aParamQry[1])   + " AND "
		cWhere += "F1D.F1D_ANOUTI = " + ValToSQL(aParamQry[2])   + " AND "
		cWhere += "F1D.D_E_L_E_T_ = ' ' "

		cWhere += "ORDER BY F1D.F1D_ANO, F1D.F1D_MES"

		//cSelect +=
	Case cIDQuery == "CARGA_IMPOSTOS"

		cSelect += "CIA.CIA_FILIAL, CIA.CIA_TIPO, CIA.CIA_ALIQ, CIA.CIA_VALDED, CIA.CIA_LIMITE "

		If lPosPerRed
			cSelect += " ,CIA.CIA_PERRED "
		Else
			cSelect += " ,0 CIA_PERRED "
		EndIf

		cFrom += RetSqlName("CIA") + " CIA "

		cWhere += "CIA.CIA_FILIAL = " + ValToSQL(xFilial("CIA")) + " AND "
		cWhere += "CIA.CIA_ANEXO = " + ValToSQL(aParamQry[1])   + " AND "
		cWhere += "CIA.CIA_FAIXA = " + ValToSQL(aParamQry[2])   + " AND "
		cWhere += "CIA.D_E_L_E_T_ = ' ' "

		cWhere += "ORDER BY CIA.CIA_TIPO "

		//cSelect +=

EndCase

// Formatando query p/ execução

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom + "%"
cWhere  := "%" + cWhere + cOrder + cGroupBy + "%"

cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

(cAliasQry)->(dbGoTop())

Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} calcPerExced()

Método responsável por calcular os percentuais das receitas mensal (RPA)
e anual (RBA) que excederam ou não o sublimite/limite.

@author joao.pellegrini
@since 06/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method calcPerExced() Class FISA153APURACAO

Local nParcNExcedSub := 0
Local nParcExcedSub := 0
Local nParcExcedLim := 0

Local nPNExcedSub := 0
Local nPExcedSub := 0
Local nPExcedLim := 0

//---------------------------------------------------------------
// CALCULANDO PERCENTUAIS PARA DEFINIÇÃO DAS PARCELAS DA RPA
//---------------------------------------------------------------

/*
	Conforme Res. CGSN Nº 94/2011 Art. 24

	§ 4º Deverá ser calculada a relação entre a parcela da receita bruta total mensal que exceder
	o limite de que trata o § 1º do art. 2º, ou o caput do art. 3º, e a receita bruta total mensal,
	nos termos dos arts. 16 a 19, no que couber.

	§ 9º O valor devido em relação à parcela da receita bruta mensal que exceder o limite de que trata
	o § 1º do art. 2º, observado o disposto no inciso II do § 2º deste artigo, será obtido mediante o
	somatório das expressões formadas pela multiplicação da relação a que se refere o § 4º deste artigo
	pela receita de cada estabelecimento segregada na forma prevista no art. 25-A e, ainda, pela
	respectiva alíquota obtida na forma prevista no inciso II do caput deste artigo.
*/

// Calculo a parcela que excedeu o sublimite...
nParcExcedLim := Max(Self:nRBA - Self:nLimite, 0)

// Relação entre a parcela que excedeu o limite e a receita bruta total mensal (§ 4º)
If nParcExcedLim > 0
	nPExcedLim := nParcExcedLim / Self:nRPATot
EndIf

/*
	Conforme Res. CGSN Nº 94/2011 Art. 24

	§ 3º Deverá ser calculada a relação entre a parcela da receita bruta total mensal que
	exceder o sublimite previsto no caput e no § 1º do art. 9º, ou no § 1º-A do art. 12,
	e a receita bruta total mensal, nos termos dos arts. 16 a 19, no que couber.

	§ 8º O valor devido em relação à parcela da receita bruta mensal que exceder sublimite, mas não o limite de que trata
	o § 1º do art. 2º, observado o disposto nos incisos I e II do § 2º deste artigo, será o somatório das expressões
	formadas pela multiplicação da diferença entre as relações a que se referem os §§ 3º e 4º pela receita de
	cada estabelecimento segregada na forma prevista no art. 25-A e, ainda, pela respectiva alíquota obtida na
	forma prevista no inciso I do caput deste artigo.
*/

// Calculo a parcela que excedeu o sublimite...
nParcExcedSub := Max(Self:nRBA - Self:nSublimite, 0)

If nParcExcedSub > 0
	// Relação entre a parcela que excedeu o sublimite e a receita bruta total mensal (§ 3º)
	nPExcedSub := Min(nParcExcedSub / Self:nRPATot, 1)
	// Neste caso o valor da parcela é obtido pela diferença entre as relações dos §§ 3º e 4º
	nPExcedSub := (nPExcedSub - nPExcedLim)
EndIf

/*
	Conforme Res. CGSN Nº 94/2011 Art. 24

	6º O valor devido em relação à parcela da receita bruta mensal que não exceder sublimite,
	observado o disposto no inciso I do § 2º deste artigo, será obtido mediante o somatório das
	expressões formadas pela multiplicação de 1 (um) inteiro menos a relação a que se refere
	o § 3º pela receita de cada estabelecimento
*/

// Nao utilizei a propria variavel "nPExcedSub" pois o cálculo deve ser feito com a relação
// do § 3º "pura" e esta variável já contém a diferença entre a relação dos §§ 3º e 4º.
// Então refaço o cálculo da relação
If nParcExcedSub > 0
	nPNExcedSub := (1 - Min(nParcExcedSub / Self:nRPATot, 1))
Else
	nPNExcedSub := 1 // Se não tenho parcela excedente a parcela que não excedeu é 1 = 100%.
EndIf

// Garanto que nenhum dos percentuais seja menor que zero (0%), nem maior que 1(100%)
Self:nPerSubNaoExced := IIf(nPNExcedSub < 0, 0, IIf(nPNExcedSub > 1, 1, nPNExcedSub))
Self:nPerSubExced    := IIf(nPExcedSub < 0, 0, IIf(nPExcedSub > 1, 1, nPExcedSub))
Self:nPerLimExced    := IIf(nPExcedLim < 0, 0, IIf(nPExcedLim > 1, 1, nPExcedLim))

//--------------------------------------------------------------------------
// CALCULANDO PERCENTUAIS PARA DEFINIÇÃO DO STATUS DO LIMITE E SUBLIMITE
//--------------------------------------------------------------------------

// Percentual da RBA que excedeu o sublimite ---> Utilizado p/ calcular o status do sublimite
Self:nPerRBASubExced := Iif(nParcExcedSub > 0, ((Self:nRBA / Self:nSublimite) - 1), 0)

// Percentual da RBA que excedeu o limite    ---> Utilizado p/ calcular o status do limite
Self:nPerRBALimExced := IIf(nParcExcedLim > 0, ((Self:nRBA / Self:nLimite) - 1), 0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} finalizar()

Método responsável por finalizar a apuração.

@author joao.pellegrini
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method finalizar() Class FISA153APURACAO

Local nX := 0
Local nY := 0
Local nZ := 0
Local oAtividade := NIL
Local oSubAtiv := NIL
Local oTribSubAt := NIL
Local oTributo := NIL
Local oNewTrib := NIL
Local aTribSubAt := {}
Local aSubAtiv := {}

// Atualizo os STATUS do SUBLIMITE e LIMITE
// Se o sublimite ou limite não for ultrapassado o status é "1".
// Se o sublimite ou limite for ultrapassado em até 20% o status é "2".
// Se o sublimite ou limite for ultrapassado em mais de 20% o status é "3".

If Self:nPerRBASubExced > 0
	If Self:nPerRBASubExced <= 0.2
		Self:cStatusSub := "2"
	Else
		Self:cStatusSub := "3"
	EndIf
Else
	Self:cStatusSub := "1"
EndIf

If Self:nPerRBALimExced > 0
	If Self:nPerRBALimExced <= 0.2
		Self:cStatusLim := "2"
	Else
		Self:cStatusLim := "3"
	EndIf
Else
	Self:cStatusLim := "1"
EndIf

// Percorro a lista de atividades e subatividades apuradas para efetuar as totalizações....
For nX := 1 to Len(Self:aAtividades)

	oAtividade := Self:aAtividades[nX]
	aSubAtiv := oAtividade:getSubAtividades()

	// Percorro a lista de subatividades de cada atividade...
	For nY := 1 to Len(aSubAtiv)

		oSubAtiv   := aSubAtiv[nY]

		// Totalizo as receitas excedentes....
		Self:nRecSubNaoExced += oSubAtiv:getRecSubNaoExced()
		Self:nRecSubExced += oSubAtiv:getRecSubExced()
		Self:nRecLimExced += oSubAtiv:getRecLimExced()

		// Totalizando os tributos calculados...
		aTribSubAt := oSubAtiv:getTributos()
		For nZ := 1 to Len(aTribSubAt)

			oTribSubAt := aTribSubAt[nZ]

			// Verifico se o tributo da subatividade já existe na lista da atividade.
			// Se já existir só atualizo o valor dele. Caso contrário adiciono na lista da atividade.
			// Instancio um novo objeto de tributo pois não quero totalizar a base e a alíquota,
			// então só me interessa o valor calculado.
			If (oTributo := Self:getTributos(oTribSubAt:getCodigo())) <> NIL
				oTributo:setValor(oTributo:getValor() + oTribSubAt:getValor())
			Else
				oNewTrib := FISA153TRIBUTO():new(oTribSubAt:getCodigo(), oTribSubAt:getDescricao(), NIL, NIL, oTribSubAt:getValor(), "", .F.)
				aAdd(Self:aTributos, oNewTrib)

				// Elimino o objeto da memória
				Self:destroyObj(oNewTrib)
			EndIf

			// Totalizo o valor a recolher...
			Self:nValorDAS += oTribSubAt:getValor()

		Next nZ

	Next nY

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} calcRBT12FS12Prop()

Método responsável por calcular a RBT12 e o FS12 proporcionais para os casos
de início de atividade no ano calendário ou no ano imediatamente
anterior ao ano calendário.

@author joao.pellegrini
@since 09/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method calcRBT12FS12Prop() Class FISA153APURACAO

Local nRBT12Prop := 0
Local nFS12Prop := 0
Local nMesesAtiv := 0

// Somo 1 para que o mês de início também seja considerado
nMesesAtiv := DateDiffMonth(Self:dDataFim, Self:dDtIniAtiv) + 1

/*

Conforme Res. CGSN Nº 94/2011 Art. 26 § 4º

§ 4º Na hipótese de a ME ou EPP ter menos de 13 (treze) meses de atividade, adotar-se-ão, para a determinação da folha de salários anualizada,
incluídos encargos, os mesmos critérios para a determinação da receita bruta total acumulada, estabelecidos no art. 21, no que couber.

*/

If Year(Self:dDtIniAtiv) == Year(Self:dDataFim)

	If Month(Self:dDtIniAtiv) == Month(Self:dDataFim)

		/*

		Conforme Res. CGSN Nº 94/2011 Art. 21 § 2º

		§ 2º No caso de início de atividade no próprio ano-calendário da opção pelo Simples Nacional, para efeito de determinação da alíquota no 1º (primeiro)
		mês de atividade, o sujeito passivo utilizará, como receita bruta total acumulada, a receita auferida no próprio mês de apuração multiplicada por 12 (doze).

		*/

		nRBT12Prop := Self:nRPA * 12
		nFS12Prop := Self:nFSPA * 12


	ElseIf nMesesAtiv <= 12 // "<= 12" pois o primeiro mês conta mesmo que seja uma fração. Logo, 1º mês + 11 = 12.

		/*

		Conforme Res. CGSN Nº 94/2011 Art. 21 § 3º

		§ 3º Na hipótese prevista no § 2º, nos 11 (onze) meses posteriores ao do início de atividade, para efeito de determinação da alíquota,
		o sujeito passivo utilizará a média aritmética da receita bruta total auferida nos meses anteriores ao do período de apuração, multiplicada por 12 (doze).

		*/

		// Não preciso somar na diferença dos meses pois não quero considerar o primeiro mês

		nRBT12Prop := ((Self:nRBT12 / DateDiffMonth(Self:dDataFim, Self:dDtIniAtiv)) * 12)
		nFS12Prop := ((Self:nFS12 / DateDiffMonth(Self:dDataFim, Self:dDtIniAtiv)) * 12)

	EndIf

ElseIf Year(Self:dDtIniAtiv) == Year(Self:dDataFim) - 1

	/*

	Conforme Res. CGSN Nº 94/2011 Art. 21 § 4º

	§ 4º Na hipótese de início de atividade em ano-calendário imediatamente anterior ao da opção pelo Simples Nacional, o sujeito passivo utilizará:

	I - a regra prevista no § 3º até alcançar 12 (doze) meses de atividade;
	II - a regra prevista no § 1º a partir de 13 (treze) meses de atividade. --> Aqui já é normal

	*/

	If nMesesAtiv <= 12

		nRBT12Prop := ((Self:nRBT12 / DateDiffMonth(Self:dDataFim, Self:dDtIniAtiv)) * 12)
		nFS12Prop :=  ((Self:nFS12 / DateDiffMonth(Self:dDataFim, Self:dDtIniAtiv)) * 12)

	EndIf

EndIf

If nRBT12Prop > 0
	Self:nRBT12 := nRBT12Prop
EndIf

If nFS12Prop > 0
	Self:nFS12 := nFS12Prop
EndIf

// GETTERS E SETTERS

Method getUF() Class FISA153APURACAO
Return Self:cUF

Method setUF(cUF)  Class FISA153APURACAO
Self:cUF := cUF
Return

Method getDataIni() Class FISA153APURACAO
Return Self:dDataIni

Method setDataIni(dDataIni) Class FISA153APURACAO
Self:dDataIni := dDataIni
Return

Method getDataFim() Class FISA153APURACAO
Return Self:dDataFim

Method setDataFim(dDataFim) Class FISA153APURACAO
Self:dDataFim := dDataFim
Return

Method getFS12() Class FISA153APURACAO
Return Self:nFS12

Method setFS12(nFS12) Class FISA153APURACAO
Self:nFS12 := nFS12
Return

Method getFSPA() Class FISA153APURACAO
Return Self:nFSPA

Method setFSPA(nFSPA) Class FISA153APURACAO
Self:nFSPA := nFSPA
Return

Method getRBT12() Class FISA153APURACAO
Return Self:nRBT12

Method setRBT12(nRBT12) Class FISA153APURACAO
Self:nRBT12 := nRBT12
Return

Method getRBT12r() Class FISA153APURACAO
Return Self:nRBT12R

Method setRBT12r(nRBT12R) Class FISA153APURACAO
Self:nRBT12R := nRBT12R
Return

Method getRBA() Class FISA153APURACAO
Return Self:nRBA

Method setRBA(nRBA) Class FISA153APURACAO
Self:nRBA := nRBA
Return

Method getRPA() Class FISA153APURACAO
Return Self:nRPA

Method setRPA(nRPA) Class FISA153APURACAO
Self:nRPA := nRPA
Return

Method getRPATot()  Class FISA153APURACAO
Return Self:nRPATot

Method setRPATot(nRPATot)  Class FISA153APURACAO
Self:nRPATot := nRPATot
Return

Method getFatorR() Class FISA153APURACAO
Return Self:nFatorR

Method setFatorR(nFatorR) Class FISA153APURACAO
Self:nFatorR := nFatorR
Return

Method getValorDAS() Class FISA153APURACAO
Return Self:nValorDAS

Method setValorDAS(nValorDAS) Class FISA153APURACAO
Self:nValorDAS := nValorDAS
Return

Method getLimite() Class FISA153APURACAO
Return Self:nLimite

Method setLimite(nLimite) Class FISA153APURACAO
Self:nLimite := nLimite
Return

Method getSubLimite() Class FISA153APURACAO
Return Self:nSubLimite

Method setSubLimite(nSubLimite) Class FISA153APURACAO
Self:nSubLimite := nSubLimite

Method getAtividades(cCodAtiv) Class FISA153APURACAO

Local xRet := NIL
Local nPos := 0

DEFAULT cCodAtiv := ""

// Se não passar um código de atividade retorno a lista completa.
If Empty(cCodAtiv)
	xRet := Self:aAtividades
// Caso contrario procuro a atividade na lista. Se encontrar, retorna.
ElseIf Len(Self:aAtividades) > 0
	If (nPos := aScan(Self:aAtividades, {|x| AllTrim(x:getCodigo()) == AllTrim(cCodAtiv)})) > 0
		xRet := Self:aAtividades[nPos]
	EndIf
EndIf

Return xRet

Method setAtividades(aAtividades) Class FISA153APURACAO
Self:aAtividades := aAtividades
Return

Method getAnexos(cAnexo) Class FISA153APURACAO

Local xRet := NIL
Local nPos := 0

DEFAULT cAnexo := ""

// Se não passar um código de anexo retorno a lista completa.
If Empty(cAnexo)
	xRet := aClone(Self:aAnexos)
// Caso contrario procuro o anexo na lista. Se encontrar, retorna.
ElseIf Len(Self:aAnexos) > 0
	If (nPos := aScan(Self:aAnexos, {|x| AllTrim(x:getNumero()) == AllTrim(cAnexo)})) > 0
		xRet := FISA153ANEXO():new(NIL, Self:aAnexos[nPos])
	EndIf
EndIf

Return xRet

Method setAnexos(aAnexos)  Class FISA153APURACAO
Self:aAnexos := aAnexos
Return

Method getTributos(cTributo) Class FISA153APURACAO

Local xRet := NIL
Local nPos := 0

DEFAULT cTributo := ""

// Se não passar um código de tributo retorno a lista completa.
If Empty(cTributo)
	xRet := aClone(Self:aTributos)
ElseIf Len(Self:aTributos) > 0
	If (nPos := aScan(Self:aTributos, {|x| AllTrim(x:getCodigo()) == AllTrim(cTributo)})) > 0
		xRet := Self:aTributos[nPos]
	EndIf
EndIf

Return xRet

Method setTributos(aTributos, cTributo, nValor) Class FISA153APURACAO

Default cTributo := ""
Default nValor   := 0

If Empty(cTributo)
	Self:aTributos := aTributos
ElseIf Len(Self:aTributos) > 0
	If (nPos := aScan(Self:aTributos, {|x| AllTrim(x:getCodigo()) == AllTrim(cTributo)})) > 0
		Self:aTributos[nPos]:nValor := nValor
	EndIf
EndIf

Return

Method getRecSubNaoExced() Class FISA153APURACAO
Return Self:nRecSubNaoExced

Method setRecSubNaoExced(nRecSubNaoExced) Class FISA153APURACAO
Self:nRecSubNaoExced := nRecSubNaoExced
Return

Method getRecSubExced() Class FISA153APURACAO
Return Self:nRecSubExced

Method setRecSubExced(nRecSubExced) Class FISA153APURACAO
Self:nRecSubExced := nRecSubExced
Return

Method getRecLimExced() Class FISA153APURACAO
Return Self:nRecLimExced

Method setRecLimExced(nRecLimExced) Class FISA153APURACAO
Self:nRecLimExced := nRecLimExced
Return

Method getStatusSublimite() Class FISA153APURACAO
Return Self:cStatusSub

Method setStatusSublimite(cStatusSub) Class FISA153APURACAO
Self:cStatusSub := cStatusSub
Return

Method getStatusLimite() Class FISA153APURACAO
Return Self:cStatusLim

Method setStatusLimite(cStatusLim) Class FISA153APURACAO
Self:cStatusLim := cStatusLim
Return

Method getDtInicioAtiv() Class FISA153APURACAO
Return Self:dDtIniAtiv

Method setDtInicioAtiv(dDtIniAtiv) Class FISA153APURACAO
Self:dDtIniAtiv := dDtIniAtiv
Return

Method getPerSubNaoExced() Class FISA153APURACAO
Return Self:nPerSubNaoExced

Method setPerSubNaoExced(nPerSubNaoExced)  Class FISA153APURACAO
Self:nPerSubNaoExced := nPerSubNaoExced
Return

Method getPerSubExced() Class FISA153APURACAO
Return Self:nPerSubExced

Method setPerSubExced(nPerSubExced) Class FISA153APURACAO
Self:nPerSubExced := nPerSubExced
Return

Method getPerLimExced() Class FISA153APURACAO
Return Self:nPerLimExced

Method setPerLimExced(nPerLimExced) Class FISA153APURACAO
Self:nPerLimExced := nPerLimExced
Return

// ------------------------------
// CLASSE TRIBUTO
// ------------------------------

CLASS FISA153TRIBUTO FROM LongNameClass

Data cCodigo as Character // Código identificador
Data cDescricao as Character // Descrição
Data nBase as Numeric // Base de cálculo
Data nAliq as Numeric // Alíquota
Data nValor as Numeric // Valor
Data nPerRedBC as Numeric // Percentual de Redução de Base de Cálculo
Data nISSExced as Numeric // Percentual do ISS excedido
Data nPerc as Numeric // Percentual de repartição do Imposto
Data lPerRedBC as Logical // .T. Redução via "Percentual = PerRedBC" - .F. Redução de base via "Aliquota Efetiva Reduzida - nAliq"
Data nPerRedIC as Numeric // Percentual de redução da base de calculo
// Tipo do tributo:
// 1 - Ref. a parcela que não excedeu o sublimite;
// 2 - Ref. a parcela que excedeu o sublimite e não excedeu o limite;
// 3 - Ref. a parcela que excedeu o limite
Data cTpTributo as Character
Data aMemoria as Array // Memória de cálculo do tributo

Method new(cCodigo, cDescricao, nBase, nAliq, nValor, cTpTributo, lCalcula,nPerRedBC,lPerRedBC, nISSExced, nPerc,nPerRedIC) CONSTRUCTOR
Method calcular()

Method getCodigo()
Method setCodigo(cCodigo)
Method getDescricao()
Method setDescricao(cDescricao)
Method getBase()
Method setBase(nBase)
Method getAliquota()
Method setAliquota(nAliquota)
Method getValor()
Method setValor(nValor)
Method getPerRedBC()
Method setPerRedBC(nPerRedBC)
Method getTipoTributo()
Method setTipoTributo(cTpTributo)
Method getMemoria()
Method setMemoria(aMemoria)
Method getISSExced()
Method setISSExced(nISSExced)
Method getPerc()
Method setPerc(nPerc)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Método construtor da classe

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new(cCodigo, cDescricao, nBase, nAliq, nValor, cTpTributo, lCalcula,nPerRedBC,lPerRedBC, nISSExced, nPerc, nPerRedIC) Class FISA153TRIBUTO

DEFAULT cCodigo := ""
DEFAULT cDescricao := ""
DEFAULT nBase := 0
DEFAULT nAliq := 0
DEFAULT nValor := 0
DEFAULT cTpTributo := "SNE" // Default do tributo é NÃO EXCEDENTE.
DEFAULT lCalcula := .F.
Default nPerRedBC := 0
Default lPerRedBC := .F.
Default nISSExced := 0
Default nPerc := 0
Default nPerRedIC := 0

If !Empty(cCodigo)
	Self:cCodigo := cCodigo
	Self:cDescricao := cDescricao
	Self:nBase := nBase
	Self:nAliq := nAliq
	Self:cTpTributo := cTpTributo
	Self:nValor := nValor
	Self:nPerRedBC := nPerRedBC
	Self:lPerRedBC := lPerRedBC
	Self:aMemoria := {}
	Self:nISSExced := nISSExced
	Self:nPerc := nPerc
	Self:nPerRedIC := nPerRedIC
	If lCalcula
		Self:calcular()
	EndIf
Else
	Self:cCodigo := ""
	Self:cDescricao := ""
	Self:nBase := 0
	Self:nAliq := 0
	Self:nValor := 0
	Self:nPerRedBC := 0
	Self:lPerRedBC := .F.
	Self:cTpTributo := ""
	Self:aMemoria := {}
	Self:nISSExced := nISSExced
	Self:nPerc := nPerc
EndIf

Return Self

Method calcular() Class FISA153TRIBUTO

Local nValor := 0

If Self:nPerRedIC > 0
	Self:nBase := Self:nBase * (1-(Self:nPerRedIC/100))
EndIf

nValor := Self:nValor := Round(Self:nBase * Self:nAliq, 2)

Return nValor

// GETTERS E SETTERS

Method getCodigo() Class FISA153TRIBUTO
Return Self:cCodigo

Method setCodigo(cCodigo) Class FISA153TRIBUTO
Self:cCodigo := cCodigo
Return

Method getDescricao() Class FISA153TRIBUTO
Return Self:cDescricao

Method setDescricao(cDescricao) Class FISA153TRIBUTO
Self:cDescricao := cDescricao
Return

Method getBase() Class FISA153TRIBUTO
Return Self:nBase

Method setBase(nBase) Class FISA153TRIBUTO
Self:nBase := nBase
Return

Method getAliquota() Class FISA153TRIBUTO
Return Self:nAliq

Method setAliquota(nAliquota) Class FISA153TRIBUTO
Self:nAliq := nAliquota
Return

Method getValor() Class FISA153TRIBUTO
Return Self:nValor

Method setValor(nValor) Class FISA153TRIBUTO
Self:nValor := nValor
Return

Method getPerRedBC() Class FISA153TRIBUTO
Return Self:nPerRedBC

Method setPerRedBC(nPerRedBC) Class FISA153TRIBUTO
Self:nPerRedBC := nPerRedBC
Return

Method getTipoTributo() Class FISA153TRIBUTO
Return Self:cTpTributo

Method setTipoTributo(cTpTributo) Class FISA153TRIBUTO
Self:cTpTributo := cTpTributo
Return

Method getMemoria() Class FISA153TRIBUTO
Return aClone(Self:aMemoria)

Method setMemoria(aMemoria) Class FISA153TRIBUTO
Self:aMemoria := aClone(aMemoria)
Return

Method getISSExced() Class FISA153TRIBUTO
Return Self:nISSExced

Method setISSExced(nISSExced) Class FISA153TRIBUTO
Self:nISSExced := nISSExced
Return

Method getPerc() Class FISA153TRIBUTO
Return Self:nPerc

Method setPerc(nPerc) Class FISA153TRIBUTO
Self:nPerc := nPerc
Return

// ------------------------------
// CLASSE FAIXAS DE RECEITA
// ------------------------------

CLASS FISA153FAIXA FROM LongNameClass

Data cNumero as Character // Numero (identificador)
Data nRecMin as Numeric // Receita mínima
Data nRecMax as Numeric // Receita máxima
Data nAliqNom as Numeric // Alíquota nominal
Data nParcDed as Numeric // Parcela dedutível
Data nPerICMS as Numeric // % de repartição do ICMS
Data nPerISS as Numeric // % de repartição do ISS
Data nPerIPI as Numeric // % de repartição do IPI
Data nPerPIS as Numeric // % de repartição do PIS
Data nPerCOF as Numeric // % de repartição do COFINS
Data nPerCSLL as Numeric // % de repartição do CSLL
Data nPerCPP as Numeric // % de repartição do CPP
Data nPerIRPJ as Numeric // % de repartição do IRPJ
Data oImpostos 			 // Objeto que contém os impostos configurados na tabela CIA

Method new() CONSTRUCTOR

//*********************************************************************
// ATENÇÃO!
// SE ADICIONAR UM TRIBUTO NOVO NÃO ESQUECER DE ADICIONA-LO
// NA LISTA DE RETORNO DO MÉTODO GETALLPERC.
//*********************************************************************
Method getAllPerc()

Method getNumero()
Method setNumero(cNumero)
Method getRecMin()
Method setRecMin(nRecMin)
Method getRecMax()
Method setRecMax(nRecMax)
Method getAliqNom()
Method setAliqNom(nAliqNom)
Method getParcDed()
Method setParcDed(nParcDed)
Method getPerICMS()
Method setPerICMS(nPerICMS)
Method getPerISS()
Method setPerISS(nPerISS)
Method getPerIPI()
Method setPerIPI(nPerIPI)
Method getPerPIS()
Method setPerPis(nPerPIS)
Method getPerCOF()
Method setPerCOF(nPerCOF)
Method getPerCSLL()
Method setPerCSLL(nPerCSLL)
Method getPerCPP()
Method setPerCPP(nPerCPP)
Method getPerIRPJ()
Method setPerIRPJ(nPerIRPJ)
Method getImpostos()
Method addImpostos(oImpostos)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Método construtor da classe

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new() Class FISA153FAIXA
	Self:cNumero := ""
	Self:nRecMin := 0
	Self:nRecMax := 0
	Self:nAliqNom := 0
	Self:nParcDed := 0
	Self:nPerICMS := 0
	Self:nPerISS := 0
	Self:nPerIPI := 0
	Self:nPerPIS := 0
	Self:nPerCOF := 0
	Self:nPerCSLL := 0
	Self:nPerCPP := 0
	Self:nPerIRPJ := 0
	Self:oImpostos := NIL
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} getAllPerc()

Método que retorna uma lista com todos os percentuais de repartição
da faixa.

@author joao.pellegrini
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method getAllPerc() Class FISA153FAIXA

Local aRet := {}

aAdd(aRet, {"ICMS", Self:nPerICMS})
aAdd(aRet, {"ISS", Self:nPerISS})
aAdd(aRet, {"IPI", Self:nPerIPI})
aAdd(aRet, {"PIS", Self:nPerPIS})
aAdd(aRet, {"COFINS", Self:nPerCOF})
aAdd(aRet, {"CSLL", Self:nPerCSLL})
aAdd(aRet, {"CPP", Self:nPerCPP})
aAdd(aRet, {"IRPJ", Self:nPerIRPJ})

Return aRet

// GETTERS E SETTERS

Method getNumero() Class FISA153FAIXA
Return Self:cNumero

Method setNumero(cNumero) Class FISA153FAIXA
Self:cNumero := cNumero
Return

Method getRecMin() Class FISA153FAIXA
Return Self:nRecMin

Method setRecMin(nRecMin) Class FISA153FAIXA
Self:nRecMin := nRecMin
Return

Method getRecMax() Class FISA153FAIXA
Return Self:nRecMax

Method setRecMax(nRecMax) Class FISA153FAIXA
Self:nRecMax := nRecMax
Return

Method getAliqNom() Class FISA153FAIXA
Return Self:nAliqNom

Method setAliqNom(nAliqNom) Class FISA153FAIXA
Self:nAliqNom := nAliqNom
Return

Method getParcDed() Class FISA153FAIXA
Return Self:nParcDed

Method setParcDed(nParcDed) Class FISA153FAIXA
Self:nParcDed := nParcDed
Return

Method getPerICMS() Class FISA153FAIXA
Return Self:nPerICMS

Method setPerICMS(nPerICMS) Class FISA153FAIXA
Self:nPerICMS := nPerICMS
Return

Method getPerISS() Class FISA153FAIXA
Return Self:nPerISS

Method setPerISS(nPerISS) Class FISA153FAIXA
Self:nPerISS := nPerISS
Return

Method getPerIPI() Class FISA153FAIXA
Return Self:nPerIPI

Method setPerIPI(nPerIPI) Class FISA153FAIXA
Self:nPerIPI := nPerIPI
Return

Method getPerPIS() Class FISA153FAIXA
Return Self:nPerPIS

Method setPerPis(nPerPIS) Class FISA153FAIXA
Self:nPerPIS := nPerPIS
Return

Method getPerCOF() Class FISA153FAIXA
Return Self:nPerCOF

Method setPerCOF(nPerCOF) Class FISA153FAIXA
Self:nPerCOF := nPerCOF
Return

Method getPerCSLL() Class FISA153FAIXA
Return Self:nPerCSLL

Method setPerCSLL(nPerCSLL) Class FISA153FAIXA
Self:nPerCSLL := nPerCSLL
Return

Method getPerCPP() Class FISA153FAIXA
Return Self:nPerCPP

Method setPerCPP(nPerCPP) Class FISA153FAIXA
Self:nPerCPP := nPerCPP
Return

Method getPerIRPJ() Class FISA153FAIXA
Return Self:nPerIRPJ

Method setPerIRPJ(nPerIRPJ) Class FISA153FAIXA
Self:nPerIRPJ := nPerIRPJ
Return

Method getImpostos() Class FISA153FAIXA
Return Self:oImpostos

Method addImpostos(oImpostos) Class FISA153FAIXA
Self:oImpostos := oImpostos
Return

// ------------------------------
// CLASSE RECEITA
// ------------------------------

CLASS FISA153RECEITA FROM LongNameClass

Data cCodAtiv as Character // Código da atividade à qual a receita pertence
Data cCodSubAti as Character // Código da subatividade à qual a receita pertence
Data cAnexo as Character // Anexo vinculado à receita
Data cFatorR as Character // Indica se a receita é ou não sujeita ao fator R
Data cAnexoSub as Character // Anexo substituto
Data nValor as Numeric // Valor LÍQUIDO da receita
Data nValorBruto as Numeric // Valor BRUTO da receita
Data nValorDev as Numeric // Valor das devoluções.

Method new() CONSTRUCTOR

Method getCodAtiv()
Method setCodAtiv(cCodAtiv)
Method getCodSubAtiv()
Method setCodSubAtiv(cCodSubAti)
Method getAnexo()
Method setAnexo(cAnexo)
Method getFatorR()
Method setFatorR(cFatorR)
Method getAnexoSub()
Method setAnexoSub(cAnexoSub)
Method getValor()
Method setValor(nValor)
Method getValorBruto()
Method setValorBruto(nValorBrut)
Method getValorDevolucoes()
Method setValorDevolucoes(nValorDev)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Método construtor da classe

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new() Class FISA153RECEITA
	Self:cCodAtiv := ""
	Self:cCodSubAti := ""
	Self:cAnexo := ""
	Self:cFatorR := ""
	Self:cAnexoSub := ""
	Self:nValor := 0
	Self:nValorBruto := 0
	Self:nValorDev := 0
Return Self

// GETTERS E SETTERS

Method getCodAtiv() Class FISA153RECEITA
Return Self:cCodAtiv

Method setCodAtiv(cCodAtiv) Class FISA153RECEITA
Self:cCodAtiv := cCodAtiv
Return

Method getCodSubAtiv() Class FISA153RECEITA
Return Self:cCodSubAti

Method setCodSubAtiv(cCodSubAti) Class FISA153RECEITA
Self:cCodSubAti := cCodSubAti
Return

Method getAnexo() Class FISA153RECEITA
Return Self:cAnexo

Method setAnexo(cAnexo) Class FISA153RECEITA
Self:cAnexo := cAnexo
Return

Method getFatorR() Class FISA153RECEITA
Return Self:cFatorR

Method setFatorR(cFatorR) Class FISA153RECEITA
Self:cFatorR := cFatorR
Return

Method getAnexoSub() Class FISA153RECEITA
Return Self:cAnexoSub

Method setAnexoSub(cAnexoSub) Class FISA153RECEITA
Self:cAnexoSub := cAnexoSub
Return

Method getValor() Class FISA153RECEITA
Return Self:nValor

Method setValor(nValor) Class FISA153RECEITA
Self:nValor := nValor
Return

Method getValorBruto() Class FISA153RECEITA
Return Self:nValorBruto

Method setValorBruto(nValorBruto) Class FISA153RECEITA
Self:nValorBruto := nValorBruto
Return

Method getValorDevolucoes() Class FISA153RECEITA
Return Self:nValorDev

Method setValorDevolucoes(nValorDev) Class FISA153RECEITA
Self:nValorDev := nValorDev
Return

// ------------------------------
// CLASSE ANEXO
// ------------------------------

CLASS FISA153ANEXO FROM LongNameClass

Data cNumero as Character // Número identificador do anexo
Data cDescricao as Character // Descrição do anexo
Data nAliqEfet as Numeric // Alíquota efetiva
Data aFaixas as Array // Array de faixas p/ enquadramento
Data nAliqICMS as Numeric // Alíquota efetiva do ICMS
Data nAliqISS as Numeric // Alíquota efetiva do iss
Data nAliqIPI as Numeric // Alíquota efetiva do IPI
Data nAliqPIS as Numeric // Alíquota efetiva do PIS
Data nAliqCOF as Numeric // Alíquota efetiva do COFINS
Data nAliqCSLL as Numeric // Alíquota efetiva do CSLL
Data nAliqCPP as Numeric // Alíquota efetiva do CPP
Data nAliqIRPJ as Numeric // Alíquota efetiva do IRPJ
Data nPerICMS as Numeric // % de repartição do ICMS
Data nPerPIS as Numeric // % de repartição do PIS quando a alíquta efetiva do ISS for superior a 5%.
Data nPerCOF as Numeric // % de repartição do COFINS quando a alíquta efetiva do ISS for superior a 5%.
Data nPerCSLL as Numeric // % de repartição do CSLL quando a alíquta efetiva do ISS for superior a 5%.
Data nPerCPP as Numeric // % de repartição do CPP quando a alíquta efetiva do ISS for superior a 5%.
Data nPerIRPJ as Numeric // % de repartição do IRPJ quando a alíquta efetiva do ISS for superior a 5%.
Data nPerIPI as Numeric // % de repartição do IPI quando
Data nRAliqICMS as Numeric // Alíquota efetiva do ICMS - Redução de base de cálculo
Data nPerRedBCICM as Numeric // % de Redução da BC do ICMS - Fixo ou Cálculado - Redução de base de cálculo
Data nPerRedIC as Numeric // % de Redução da BC do ICMS - via CIA
Data nISSExced as Numeric // % excedente do ISS quando aliquota superior a 5%.
Data aTributos as Array // Parâmetros específicos para cada imposto

// Estrutura: {TRIBUTO, REC. ENQUAD, ANEXO, FAIXA, ALIQ. NOM, ALIQ. EFET, % REPART.}
Data aMemorias as Array // Memorias de calculo

Method new(aFaixas, oAnexoOri) CONSTRUCTOR

Method enquadrar(nReceita)
Method addFaixa(oFaixa)
Method calcAliqEfetivas(oFaixa, nRBT12, oFaixaICMSISS, nRecICMSISS)
Method getFaixaMax()
Method addMemoria(cTributo,nRecEnquad,cAnexo,cFaixa,nAliqNom,nParcDed,nAliqEfet,nPerPart,nPerRedBC)
Method getMemoria(cTributo)

Method getNumero()
Method setNumero(cNumero)
Method getDescricao()
Method setDescricao(cDescricao)
Method getAliqEfet()
Method setAliqEfet(nAliqEfet)
Method getFaixas(cNumero)
Method setFaixas(aFaixas)
Method getAliqICMS()
Method setAliqICMS(nAliqICMS)
Method getAliqISS()
Method setAliqISS(nAliqISS)
Method getAliqIPI()
Method setAliqIPI(nAliqIPI)
Method getAliqPIS()
Method setAliqPIS(nAliqPIS)
Method getAliqCOF()
Method setAliqCOF(nAliqCOF)
Method getAliqCSLL()
Method setAliqCSLL(nAliqCSLL)
Method getAliqCPP()
Method setAliqCPP(nAliqCPP)
Method getAliqIRPJ()
Method setAliqIRPJ(nAliqIRPJ)
Method getPerICMS()
Method setPerICMS(nPerICMS)
Method getPerPIS()
Method setPerPIS(nPerISSPIS)
Method getPerCOF()
Method setPerCOF(nPerISSCOF)
Method getPerCSLL()
Method setPerCSLL(nPerISSCSLL)
Method getPerCPP()
Method setPerCPP(nPerISSCPP)
Method getPerIRPJ()
Method setPerIRPJ(nPerISSIRPJ)
Method getPerRedBCICM()
Method setPerRedBCICM(nPerRedBCICM)
Method getPerRedIC()
Method setPerRedIC(nPerRedIC)
Method getRAliqICM()
Method setRAliqICM(nAliqICMSRed)
Method getISSExced()
Method setISSExced(nISSExced)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Método construtor da classe

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new(aFaixas, oAnexoOri) Class FISA153ANEXO

DEFAULT aFaixas := {}
DEFAULT oAnexoOri := NIL

// Se passar um anexo "origem" crio o objeto espelhando o original.
If oAnexoOri <> NIL

	Self:cNumero := oAnexoOri:getNumero()
	Self:cDescricao := oAnexoOri:getDescricao()
	Self:nAliqEfet := oAnexoOri:getAliqEfet()
	Self:aFaixas := oAnexoOri:getFaixas()
	Self:nAliqICMS := oAnexoOri:getAliqICMS()
	Self:nAliqISS := oAnexoOri:getAliqISS()
	Self:nAliqIPI := oAnexoOri:getAliqIPI()
	Self:nAliqPIS := oAnexoOri:getAliqPIS()
	Self:nAliqCOF := oAnexoOri:getAliqCOF()
	Self:nAliqCSLL := oAnexoOri:getAliqCSLL()
	Self:nAliqCPP := oAnexoOri:getAliqCPP()
	Self:nAliqIRPJ := oAnexoOri:getAliqIRPJ()
	Self:nPerPIS := oAnexoOri:getPerPIS()
	Self:nPerCOF := oAnexoOri:getPerCOF()
	Self:nPerCSLL := oAnexoOri:getPerCSLL()
	Self:nPerCPP := oAnexoOri:getPerCPP()
	Self:nPerIRPJ := oAnexoOri:getPerIRPJ()
	Self:aMemorias := oAnexoOri:getMemoria()
	Self:nRAliqICMS := oAnexoOri:getRaliqICM()
	Self:nPerRedBCICM := oAnexoOri:getPerRedBCICM()
	Self:nPerRedIC := oAnexoOri:getPerRedIC()
	Self:nISSExced := oAnexoOri:getISSExced()


Else

	Self:cNumero := ""
	Self:cDescricao := ""
	Self:nAliqEfet := 0
	Self:aFaixas := {}
	Self:nAliqICMS := 0
	Self:nAliqISS := 0
	Self:nAliqIPI := 0
	Self:nAliqPIS := 0
	Self:nAliqCOF := 0
	Self:nAliqCSLL := 0
	Self:nAliqCPP := 0
	Self:nAliqIRPJ := 0
	Self:nPerPIS :=0
	Self:nPerCOF := 0
	Self:nPerCSLL := 0
	Self:nPerCPP := 0
	Self:nPerIRPJ := 0
	Self:aMemorias := {}
	Self:nRAliqICMS := 0
	Self:nPerRedBCICM := 0
	Self:nPerRedIC	:= 0
	Self:nISSExced := 0

EndIf

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} enquadrar()

Método repsonsável por realizar o enquadramento da receita (RBT12)
em uma faixa do anexo.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method enquadrar(nReceita) Class FISA153ANEXO

Local nX := 0
Local oRet := NIL

For nX := 1 to Len(Self:aFaixas)

	If nReceita >= Self:aFaixas[nX]:getRecMin() .And. nReceita <= Self:aFaixas[nX]:getRecMax()
		oRet := Self:aFaixas[nX]
		Exit
	EndIf

	// Se não enquadrou em nenhuma pq a RBT12 é superior à última faixa retorno a última faixa.
	If nX == Len(Self:aFaixas) .And. nReceita > Self:aFaixas[nX]:getRecMax()
		oRet := Self:aFaixas[nX]
	EndIf

Next nX

Return oRet

//-------------------------------------------------------------------
/*/{Protheus.doc} addFaixa()

Método responsável por adicionar uma faixa no anexo.

@author joao.pellegrini
@since 01/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method addFaixa(oFaixa) Class FISA153ANEXO

	aAdd(Self:aFaixas, oFaixa)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} calcAliqEfetivas()

Método responsável por calcular as alíquotas efetivas do anexo.

@author joao.pellegrini
@since 02/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method calcAliqEfetivas(oFaixa, nRBT12, oFaixaICMSISS, nRecICMSISS) Class FISA153ANEXO

Local nISSExced := 0
Local nSomaAliq := 0
Local nDifAliqs := 0
Local nMaxPer := 0
Local cImpMaxPer := ""
Local aPerc := {}
Local nX := 0
Local nAEfetICIS := 0
Local nAEfetReal := 0
Local nAlqNomICIS := 0
Local nRAliqEfet := 0
Local oImpostos	 := NIL

DEFAULT oFaixaICMSISS := NIL
DEFAULT nRecICMSISS := 0

/*

Conforme Res. CGSN Nº 94/2011 Art. 20, incisos I, II e III do parâgrafo único

I - considera-se alíquota nominal, aquela constante dos Anexos I a V desta Resolução;

II - considera-se alíquota efetiva, o resultado de: (RBT12 x Aliq - PD) / RBT12, em que:
a) RBT12: receita bruta acumulada nos doze meses anteriores ao período de apuração;
b) Aliq: alíquota nominal constante dos Anexos I a V desta Resolução;
c) PD: parcela a deduzir constante dos Anexos I a V desta Resolução;

III - consideram-se percentuais efetivos de cada tributo, aqueles calculados a partir da alíquota efetiva, multiplicada pelo percentual de repartição constante dos Anexos I a V desta Resolução[...]

*/

// Primeiro calculo a alíquota efetiva - cheia - do anexo:
Self:nAliqEfet := (((nRBT12 * (oFaixa:getAliqNom() / 100)) - oFaixa:getParcDed()) / nRBT12)

// Depois faço a repartição da alíquota efetiva encontrada entre os tributos para
// encontrar a alíquota efetiva de cada tributo.

// Se foi enviada a faixa e a receita específicas do ICMS e do ISS significa que os impostos
// devem ser calculados utilizando a alíquota nominal e os percentuais desta faixa, bem como
// utilizando a receita especificada.
If oFaixaICMSISS <> NIL .And. nRecICMSISS <> 0
	nAEfetICIS :=  (((nRecICMSISS * (oFaixaICMSISS:getAliqNom() / 100)) - oFaixaICMSISS:getParcDed()) / nRecICMSISS)
	Self:nAliqICMS := (nAEfetICIS * (oFaixaICMSISS:getPerICMS() / 100))
	Self:nAliqISS := (nAEfetICIS * (oFaixaICMSISS:getPerISS() / 100))
	oImpostos := oFaixaICMSISS:getImpostos()
Else
	Self:nAliqICMS := (Self:nAliqEfet * (oFaixa:getPerICMS() / 100))
	Self:nAliqISS := (Self:nAliqEfet * (oFaixa:getPerISS() / 100))
	oImpostos := oFaixa:getImpostos()
EndIf

Self:nAliqIPI := (Self:nAliqEfet * (oFaixa:getPerIPI() / 100))
Self:nAliqPIS := (Self:nAliqEfet * (oFaixa:getPerPIS() / 100))
Self:nAliqCOF := (Self:nAliqEfet * (oFaixa:getPerCOF() / 100))
Self:nAliqCSLL := (Self:nAliqEfet * (oFaixa:getPerCSLL() / 100))
Self:nAliqCPP := (Self:nAliqEfet * (oFaixa:getPerCPP() / 100))
Self:nAliqIRPJ := (Self:nAliqEfet * (oFaixa:getPerIRPJ() / 100))



If oImpostos:getAliqNom("ICMS") > 0 .And. oImpostos:getValDed("ICMS") > 0
	nRAliqEfet	:= oImpostos:AliqEfetICMS(nRBT12)
	self:nRAliqICMS	:= nRAliqEfet
	self:nPerRedBCICM 	:= ( 1-( (nRAliqEfet*100) / (Self:nAliqICMS *100)) ) * 100	
EndIf

If oImpostos:getPerRedIC("ICMS") > 0
	self:nPerRedIC 	:= oImpostos:getPerRedIC("ICMS")
EndIf

// Se a alíquota efetiva do ISS for superior a 5% ela é fixada em 5% e o excedente
// é distribuído entre os tributos federais conforme os percentuais definidos no anexo em questão.

//JOAO TODO - ATUALIZAR NA MEMÓRIA OS PERCENTUAIS DE RATEIO QUANDO O ISS EXCEDER 5%! !!

If Self:nAliqISS > 0.05

	nISSExced := Self:nAliqISS - 0.05

	Self:nISSExced := nISSExced
	Self:nAliqISS := 0.05
	Self:nAliqPIS += (nISSExced * (Self:nPerPIS / 100))
	Self:nAliqCOF += (nISSExced * (Self:nPerCOF / 100))
	Self:nAliqCSLL += (nISSExced * (Self:nPerCSLL / 100))
	Self:nAliqCPP += (nISSExced * (Self:nPerCPP / 100))
	Self:nAliqIRPJ += (nISSExced * (Self:nPerIRPJ / 100))

EndIf

// Verifico se a soma das aliquotas calculadas corresponde à alíquota efetiva "total"
// Conforme LC 123/2006, Art. 18, § 1o-B, inciso II:
// II - eventual diferença centesimal entre o total dos percentuais e a alíquota efetiva será transferida
// para o tributo com maior percentual de repartição na respectiva faixa de receita bruta.

// Quando passar a faixa específica para calcular o ICMS e o ISS preciso calcular uma "nova"
// alíquota efetiva, pois como foram utilizados percentuais diferentes para os tributos a alíquota
// também mudou. Então, para comparar, preciso somar á alíquota efetiva encontrada os percentuais de
// ICMS e ISS calculados na faixa específica, e subtrair dela os percentuais de ICMS e ISS que teriam sido
// utilizados caso não fosse passada a faixa específica.

If oFaixaICMSISS <> NIL .And. nRecICMSISS <> 0
	nAEfetReal := (Self:nAliqEfet + Self:nAliqICMS + Self:nAliqISS) - ((Self:nAliqEfet * (oFaixa:getPerICMS() / 100)) + (Self:nAliqEfet * (oFaixa:getPerISS() / 100)))
Else
	nAEfetReal := Self:nAliqEfet
EndIf

nSomaAliq := Self:nAliqICMS + Self:nAliqISS + Self:nAliqIPI + Self:nAliqPIS + Self:nAliqCOF + Self:nAliqCSLL + Self:nAliqCPP + Self:nAliqIRPJ

nDifAliqs := nAEfetReal - nSomaAliq

If nDifAliqs > 0

	// Obtenho a lista dos percentuais de todos os tributos da faixa
	// aPerc[1]: Sigla do Tributo
	// aPerc[2]: % de repartição
	aPerc := oFaixa:getAllPerc()
	nMaxPer := 0

	// Determino qual tributo possui o maior percentual de repartição
	For nX := 1 to Len(aPerc)
		If aPerc[nX, 2] > nMaxPer
			cImpMaxPer := aPerc[nX, 1] // Sigla do tributo
			nMaxPer := aPerc[nX, 2]    // % de repartição
		EndIf
	Next nX

	// Atualizo a alíquota efetiva com a diferença conforme o tributo
	// identificado no trecho acima.
	Do Case

		Case cImpMaxPer == "ICMS"
			Self:nAliqICMS += nDifAliqs
		Case cImpMaxPer == "ISS"
			Self:nAliqISS += nDifAliqs
		Case cImpMaxPer == "IPI"
			Self:nAliqIPI += nDifAliqs
		Case cImpMaxPer == "PIS"
			Self:nAliqPIS += nDifAliqs
		Case cImpMaxPer == "COFINS"
			Self:nAliqCOF += nDifAliqs
		Case cImpMaxPer == "CSLL"
			Self:nAliqCSLL += nDifAliqs
		Case cImpMaxPer == "CPP"
			Self:nAliqCPP += nDifAliqs
		Case cImpMaxPer == "IRPJ"
			Self:nAliqIRPJ += nDifAliqs

	EndCase

EndIf

// Adiciona as memórias de cálculo dos tributos...

If oFaixaICMSISS <> NIL .And. nRecICMSISS <> 0
	Self:addMemoria({"ICMS", nRecICMSISS, Self:cNumero, oFaixaICMSISS:getNumero(), oFaixaICMSISS:getAliqNom() / 100, oFaixaICMSISS:getParcDed(), nAEfetICIS, oFaixaICMSISS:getPerICMS() / 100, self:nPerRedBCICM, self:nPerRedIC  })
	Self:addMemoria({"ISS" , nRecICMSISS, Self:cNumero, oFaixaICMSISS:getNumero(), oFaixaICMSISS:getAliqNom() / 100, oFaixaICMSISS:getParcDed(), nAEfetICIS, oFaixaICMSISS:getPerISS()  / 100, 0, 0 })
Else
	Self:addMemoria({"ICMS", nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerICMS() / 100, self:nPerRedBCICM, self:nPerRedIC })
	Self:addMemoria({"ISS" , nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerISS()  / 100, 0, 0})
EndIf

Self:addMemoria({"IPI"   , nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerIPI()  / 100, 0, 0})
Self:addMemoria({"PIS"   , nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerPIS()  / 100, 0, 0})
Self:addMemoria({"COFINS", nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerCOF()  / 100, 0, 0})
Self:addMemoria({"CSLL"  , nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerCSLL() / 100, 0, 0})
Self:addMemoria({"CPP"   , nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerCPP()  / 100, 0, 0})
Self:addMemoria({"IRPJ"  , nRBT12, Self:cNumero, oFaixa:getNumero(), oFaixa:getAliqNom() / 100, oFaixa:getParcDed(), Self:nAliqEfet, oFaixa:getPerIRPJ() / 100, 0, 0})


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getFaixaMax()

Método responsável por retornar o código da última faixa do anexo, ou
seja, a faixa com a maior receita

@author joao.pellegrini
@since 16/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method getFaixaMax() CLASS FISA153ANEXO

Local cRet := ""

cRet := Self:aFaixas[Len(Self:aFaixas)]:getNumero()

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} addMemoria()

Método responsável por adicionar uma memória de cálculo na lista de
memórias.

@author joao.pellegrini
@since 19/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method addMemoria(aMemoria) CLASS FISA153ANEXO

Local nPos        := 0
Local cTributo    := aMemoria[1]
Local nRecEnquad  := aMemoria[2]
Local cAnexo      := aMemoria[3]
Local cFaixa      := aMemoria[4]
Local nAliqNom    := aMemoria[5]
Local nParcDed    := aMemoria[6]
Local nAliqEfet   := aMemoria[7]
Local nPerPart    := aMemoria[8]
Local nPerRedBC   := aMemoria[9]
Local nPerRedIC   := aMemoria[10]

// Se a memória não existir, adiciono. Caso contrário sobrescrevo a existente com a nova.

If (nPos := aScan(Self:aMemorias, {|x| AllTrim(x[1]) == AllTrim(cTributo)})) == 0

	aAdd(Self:aMemorias, {})
	nPos := Len(Self:aMemorias)

	aAdd(Self:aMemorias[nPos], cTributo)
	aAdd(Self:aMemorias[nPos], nRecEnquad)
	aAdd(Self:aMemorias[nPos], cAnexo)
	aAdd(Self:aMemorias[nPos], cFaixa)
	aAdd(Self:aMemorias[nPos], nAliqNom)
	aAdd(Self:aMemorias[nPos], nParcDed)
	aAdd(Self:aMemorias[nPos], nAliqEfet)
	aAdd(Self:aMemorias[nPos], nPerPart)
	aAdd(Self:aMemorias[nPos], nPerRedBC)
	aAdd(Self:aMemorias[nPos], nPerRedIC)

Else

	Self:aMemorias[nPos, 1] := cTributo
	Self:aMemorias[nPos, 2] := nRecEnquad
	Self:aMemorias[nPos, 3] := cAnexo
	Self:aMemorias[nPos, 4] := cFaixa
	Self:aMemorias[nPos, 5] := nAliqNom
	Self:aMemorias[nPos, 6] := nParcDed
	Self:aMemorias[nPos, 7] := nAliqEfet
	Self:aMemorias[nPos, 8] := nPerPart
	Self:aMemorias[nPos, 9] := nPerRedBC
	Self:aMemorias[nPos,10] := nPerRedIC

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getMemoria()

Método responsável por retornar o código da última faixa do anexo, ou
seja, a faixa com a maior receita

@author joao.pellegrini
@since 19/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method getMemoria(cTributo) CLASS FISA153ANEXO

Local nPos := 0
Local aRet := {}

DEFAULT cTributo := ""

// Se for vazio retorno a lista completa.
If Empty(cTributo)
	aRet := aClone(Self:aMemorias)
Else
	If (nPos := aScan(Self:aMemorias, {|x| AllTrim(x[1]) == AllTrim(cTributo)})) > 0
		aRet := aClone(Self:aMemorias[nPos])
	EndIf
EndIf

Return aRet

//GETTERS E SETTERS

Method getNumero() Class FISA153ANEXO
Return Self:cNumero

Method setNumero(cNumero) Class FISA153ANEXO
Self:cNumero := cNumero
Return

Method getDescricao() Class FISA153ANEXO
Return Self:cDescricao

Method setDescricao(cDescricao) Class FISA153ANEXO
Self:cDescricao := cDescricao
Return

Method getAliqEfet() Class FISA153ANEXO
Return Self:nAliqEfet

Method setAliqEfet(nAliqEfet) Class FISA153ANEXO
Self:nAliqEfet := nAliqEfet
Return

Method getFaixas(cNumero) Class FISA153ANEXO

Local xRet := NIL
Local nPos := 0

DEFAULT cNumero := ""

// Se não passar um numero de faixa retorno a lista completa.
If Empty(cNumero)
	xRet := aClone(Self:aFaixas)
// Caso contrario procuro a subatividade na lista. Se encontrar, retorna.
ElseIf Len(Self:aFaixas) > 0
	If (nPos := aScan(Self:aFaixas, {|x| AllTrim(x:getNumero()) == AllTrim(cNumero)})) > 0
		xRet := Self:aFaixas[nPos]
	EndIf
EndIf

Return xRet

Method setFaixas(aFaixas) Class FISA153ANEXO
Self:aFaixas := aFaixas
Return

Method getAliqICMS() Class FISA153ANEXO
Return Self:nAliqICMS

Method setAliqICMS(nAliqICMS) Class FISA153ANEXO
Self:nAliqICMS := nAliqICMS
Return

Method getAliqISS() Class FISA153ANEXO
Return Self:nAliqISS

Method setAliqISS(nAliqISS) Class FISA153ANEXO
Self:nAliqISS := nAliqISS
Return

Method getAliqIPI() Class FISA153ANEXO
Return Self:nAliqIPI

Method setAliqIPI(nAliqIPI) Class FISA153ANEXO
Self:nAliqIPI := nAliqIPI
Return

Method getAliqPIS() Class FISA153ANEXO
Return Self:nAliqPIS

Method setAliqPIS(nAliqPIS) Class FISA153ANEXO
Self:nAliqPIS := nAliqPIS
Return

Method getAliqCOF() Class FISA153ANEXO
Return Self:nAliqCOF

Method setAliqCOF(nAliqCOF) Class FISA153ANEXO
Self:nAliqCOF := nAliqCOF
Return

Method getAliqCSLL() Class FISA153ANEXO
Return Self:nAliqCSLL

Method setAliqCSLL(nAliqCSLL) Class FISA153ANEXO
Self:nAliqCSLL := nAliqCSLL
Return

Method getAliqCPP() Class FISA153ANEXO
Return Self:nAliqCPP

Method setAliqCPP(nAliqCPP) Class FISA153ANEXO
Self:nAliqCPP := nAliqCPP
Return

Method getAliqIRPJ() Class FISA153ANEXO
Return Self:nAliqIRPJ

Method setAliqIRPJ(nAliqIRPJ) Class FISA153ANEXO
Self:nAliqIRPJ := nAliqIRPJ
Return

Method getPerICMS() Class FISA153ANEXO
Return Self:nPerICMS

Method setPerICMS(nPerICMS) Class FISA153ANEXO
Self:nPerICMS := nPerICMS
Return

Method getPerPIS() Class FISA153ANEXO
Return Self:nPerPIS

Method setPerPIS(nPerPIS) Class FISA153ANEXO
Self:nPerPIS := nPerPIS
Return

Method getPerCOF() Class FISA153ANEXO
Return Self:nPerCOF

Method setPerCOF(nPerCOF) Class FISA153ANEXO
Self:nPerCOF := nPerCOF
Return

Method getPerCSLL() Class FISA153ANEXO
Return Self:nPerCSLL

Method setPerCSLL(nPerCSLL) Class FISA153ANEXO
Self:nPerCSLL := nPerCSLL
Return

Method getPerCPP() Class FISA153ANEXO
Return Self:nPerCPP

Method setPerCPP(nPerCPP) Class FISA153ANEXO
Self:nPerCPP := nPerCPP
Return

Method getPerIRPJ() Class FISA153ANEXO
Return Self:nPerIRPJ

Method setPerIRPJ(nPerIRPJ) Class FISA153ANEXO
Self:nPerIRPJ := nPerIRPJ
Return

Method getRAliqICM() Class FISA153ANEXO
Return Self:nRAliqICMS

Method setRAliqICM(nRAliqICMS) Class FISA153ANEXO
Self:nAliqICMSRed := nRAliqICMS
Return

Method getPerRedBCICM() Class FISA153ANEXO
Return Self:nPerRedBCICM

Method setPerRedBCICM(nPerRedBCICM) Class FISA153ANEXO
Return Self:nPerRedBCICM := nPerRedBCICM

Method getPerRedIC() Class FISA153ANEXO
Return Self:nPerRedIC

Method setPerRedIC(nPerRedIC) Class FISA153ANEXO
Self:nPerRedIC := nPerRedIC
Return

Method getISSExced() Class FISA153ANEXO
Return Self:nISSExced

Method setISSExced(nISSExced) Class FISA153ANEXO
Self:nISSExced := nISSExced
Return

// ------------------------------
// CLASSE SUBATIVIDADE
// ------------------------------

CLASS FISA153SUBATIVIDADE FROM LongNameClass

Data cCodigo as Character // Código identificador
Data cDescricao as Character // Descrição da subatividade
Data cAnexo as Character // Anexo no qual a subatividade é enquadrada
Data nReceita as Numeric // Receita LÍQUIDA auferida para a subatividade
Data nRecSubNaoExced as Numeric // Parcela da receita LÍQUIDA auferida que não excedeu o sublimite.
Data nRecSubExced as Numeric // Parcela da receita LÍQUIDA auferida que excedeu o sublimite mas não excedeu o limite
Data nRecLimExced as Numeric // Parcela da receita LÍQUIDA auferida que excedeu o limite
Data cRegraICMS as Character // Regra para cálculo do ICMS
Data cRegraISS as Character // Regra para cálculo do ISS
Data cRegraIPI as Character // Regra para cálculo do IPI
Data cRegraPIS as Character // Regra para cálculo do PIS
Data cRegraCOF as Character // Regra para cálculo do COFINS
Data cRegraCSL as Character // Regra para cálculo do CSLL
Data cRegraCPP as Character // Regra para cálculo da CPP
Data cRegraIRPJ as Character // Regra para cálculo do IRPJ
Data aTributos as Array // Lista de tributos calculados
Data nReceitaBruta as Numeric // Receita BRUTA auferida para a subatividade
Data nValorDev as Numeric // Valor das devoluções.
Data oAnexoNaoExced  // Objeto ANEXO com as alíquotas calculadas para a parcela da receita da subatividade que não excedeu o sublimite
Data oAnexoSubExced // Objeto ANEXO com as alíquotas calculadas para a parcela da receita da subatividade que excedeu o sublimite e não excedeu o limite
Data oAnexoLimExced // Objeto ANEXO com as alíquotas calculadas para a parcela da receita da subatividade que excedeu

Method new() CONSTRUCTOR
Method addTributo(oTributo, lDestroy)



Method getCodigo()
Method setCodigo(cCodigo)
Method getDescricao()
Method setDescricao(cDescricao)
Method getAnexo()
Method setAnexo(cAnexo)
Method getReceita()
Method setReceita(nReceita)
Method getRecSubNaoExced()
Method setRecSubNaoExced(nRecSubNaoExced)
Method getRecSubExced()
Method setRecSubExced(nRecSubNaoExced)
Method getRecLimExced()
Method setRecLimExced(nRecLimExced)
Method getRegraICMS()
Method setRegraICMS(cRegraICMS)
Method getRegraISS()
Method setRegraISS(cRegraISS)
Method getRegraIPI()
Method setRegraIPI(cRegraIPI)
Method getRegraPIS()
Method setRegraPIS(cRegraPIS)
Method getRegraCOF()
Method setRegraCOF(cRegraCOF)
Method getRegraCSL()
Method setRegraCSL(cRegraCSL)
Method getRegraCPP()
Method setRegraCPP(cRegraCPP)
Method getRegraIRPJ()
Method setRegraIRPJ(cRegraIRPJ)
Method getTributos()
Method setTributos(aTributos)
Method getRecBruta()
Method setRecBruta(nReceitaBruta)
Method getValorDevolucoes()
Method setValorDevolucoes(nValorDev)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Método construtor da classe

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new() Class FISA153SUBATIVIDADE

Self:cCodigo := ""
Self:cDescricao := ""
Self:cAnexo := ""
Self:nReceita := 0
Self:nRecSubNaoExced := 0
Self:nRecSubExced := 0
Self:nRecLimExced := 0
Self:cRegraICMS := ""
Self:cRegraISS := ""
Self:cRegraIPI := ""
Self:cRegraPIS := ""
Self:cRegraCOF := ""
Self:cRegraCSL := ""
Self:cRegraCPP := ""
Self:cRegraIRPJ := ""
Self:aTributos := {}
Self:nReceitaBruta := 0
Self:nValorDev := 0
Self:oAnexoNaoExced := NIL
Self:oAnexoSubExced := NIL
Self:oAnexoLimExced := NIL

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} addTributo()

Método responsável por adicionar um tributo calculado na subatividade.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method addTributo(oTributo, lDestroy) Class FISA153SUBATIVIDADE

Local nRet := 0
Local cVersao := GetVersao(.F.)

DEFAULT lDestroy := .F.

// Se o tributo não tem código e valor não adiciona na lista.
If !Empty(oTributo:getCodigo()) .And. !Empty(oTributo:getValor())
	aAdd(Self:aTributos, oTributo)
	nRet := oTributo:getValor()
EndIf

// Elimino o objeto da memória
If lDestroy
	
	// Na versão 11 ocorre errorlog ao chamar freeobj.
	If cVersao <> "12"
		oTributo := NIL
	Else
		oTributo := NIL
		FreeObj(oTributo)
	EndIf
	
EndIf

Return nRet

// GETTERS E SETTERS

Method getCodigo() Class FISA153SUBATIVIDADE
Return Self:cCodigo

Method setCodigo(cCodigo) Class FISA153SUBATIVIDADE
Self:cCodigo := cCodigo
Return

Method getDescricao() Class FISA153SUBATIVIDADE
Return Self:cDescricao

Method setDescricao(cDescricao) Class FISA153SUBATIVIDADE
Self:cDescricao := cDescricao
Return

Method getAnexo() Class FISA153SUBATIVIDADE
Return Self:cAnexo

Method setAnexo(cAnexo) Class FISA153SUBATIVIDADE
Self:cAnexo := cAnexo
Return

Method getReceita() Class FISA153SUBATIVIDADE
Return Self:nReceita

Method setReceita(nReceita) Class FISA153SUBATIVIDADE
Self:nReceita := nReceita
Return

Method getRecSubNaoExced() Class FISA153SUBATIVIDADE
Return Self:nRecSubNaoExced

Method setRecSubNaoExced(nRecSubNaoExced) Class FISA153SUBATIVIDADE
Self:nRecSubNaoExced := nRecSubNaoExced
Return

Method getRecSubExced() Class FISA153SUBATIVIDADE
Return Self:nRecSubExced

Method setRecSubExced(nRecSubExced) Class FISA153SUBATIVIDADE
Self:nRecSubExced := nRecSubExced
Return

Method getRecLimExced() Class FISA153SUBATIVIDADE
Return Self:nRecLimExced

Method setRecLimExced(nRecLimExced) Class FISA153SUBATIVIDADE
Self:nRecLimExced := nRecLimExced
Return

Method getRegraICMS() Class FISA153SUBATIVIDADE
Return Self:cRegraICMS

Method setRegraICMS(cRegraICMS) Class FISA153SUBATIVIDADE
Self:cRegraICMS := cRegraICMS
Return

Method getRegraISS() Class FISA153SUBATIVIDADE
Return Self:cRegraISS

Method setRegraISS(cRegraISS) Class FISA153SUBATIVIDADE
Self:cRegraISS := cRegraISS
Return

Method getRegraIPI() Class FISA153SUBATIVIDADE
Return Self:cRegraIPI

Method setRegraIPI(cRegraIPI) Class FISA153SUBATIVIDADE
Self:cRegraIPI := cRegraIPI
Return

Method getRegraPIS() Class FISA153SUBATIVIDADE
Return Self:cRegraPIS

Method setRegraPIS(cRegraPIS) Class FISA153SUBATIVIDADE
Self:cRegraPIS := cRegraPIS
Return

Method getRegraCOF() Class FISA153SUBATIVIDADE
Return Self:cRegraCOF

Method setRegraCOF(cRegraCOF) Class FISA153SUBATIVIDADE
Self:cRegraCOF := cRegraCOF
Return

Method getRegraCSL() Class FISA153SUBATIVIDADE
Return Self:cRegraCSL

Method setRegraCSL(cRegraCSL) Class FISA153SUBATIVIDADE
Self:cRegraCSL := cRegraCSL
Return

Method getRegraCPP() Class FISA153SUBATIVIDADE
Return Self:cRegraCPP

Method setRegraCPP(cRegraCPP) Class FISA153SUBATIVIDADE
Self:cRegraCPP := cRegraCPP
Return

Method getRegraIRPJ() Class FISA153SUBATIVIDADE
Return Self:cRegraIRPJ

Method setRegraIRPJ(cRegraIRPJ) Class FISA153SUBATIVIDADE
Self:cRegraIRPJ := cRegraIRPJ
Return

Method getTributos() Class FISA153SUBATIVIDADE
Return Self:aTributos

Method setTributos(aTributos) Class FISA153SUBATIVIDADE
Self:aTributos := aTributos
Return

Method getRecBruta() Class FISA153SUBATIVIDADE
Return Self:nReceitaBruta

Method setRecBruta(nReceitaBruta) Class FISA153SUBATIVIDADE
Self:nReceitaBruta := nReceitaBruta
Return

Method getValorDevolucoes() Class FISA153SUBATIVIDADE
Return Self:nValorDev

Method setValorDevolucoes(nValorDev) Class FISA153SUBATIVIDADE
Self:nValorDev := nValorDev
Return

// ------------------------------
// CLASSE ATIVIDADE
// ------------------------------

CLASS FISA153ATIVIDADE FROM LongNameClass

Data cCodigo as Character // Codigo identificador
Data cDescricao as Character // Descrição
Data nReceita as Character // Receita LÍQUIDA da atividade (soma das subatividades)
Data cTpAtiv as Character // Tipo de atividade
Data aSubAtiv as Array // Lista de subatividades
Data nReceitaBruta as Numeric // Receita BRUTA da atividade
Data nValorDev as Numeric // Valor das devoluções

Method new() CONSTRUCTOR
Method addSubAtividade(oSubAtiv)

Method getCodigo()
Method setCodigo(cCodigo)
Method getDescricao()
Method setDescricao(cDescricao)
Method getReceita()
Method setReceita(nReceita)
Method getTipoAtividade()
Method setTipoAtividade(cTpAtiv)
Method getSubAtividades(cCodSubAtv)
Method getRecBruta()
Method setRecBruta(nReceitaBruta)
Method getValorDevolucoes()
Method setValorDevolucoes(nValorDev)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Método construtor da classe

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new() Class FISA153ATIVIDADE

Self:cCodigo := ""
Self:cDescricao := ""
Self:nReceita := 0
Self:cTpAtiv := ""
Self:aSubAtiv := {}
Self:nReceitaBruta := 0
Self:nValorDev := 0

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} addSubAtividade()

Método responsável por adicionar uma subatividade na atividade.

@author joao.pellegrini
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method addSubAtividade(oSubAtiv) Class FISA153ATIVIDADE

Local nRecSubAtv := 0
Local nRecSubNaoExced := 0
Local nRecSubExced := 0
Local nRecLimExced := 0
Local nReceitaBruta := 0
Local nValorDev := 0

// Adiciona a subatividade na lista se já não existir uma subatividade com o mesmo código e anexo.
// Não deveria existir a mesma subatividade c/ anexos diferentes, mas segrego a receita mesmo assim para demonstrar que algo pode estar errado.
// Caso já exista só atualizo a receita da subatividade com a receita de "oSubAtiv"
 If Len(Self:aSubAtiv) > 0
	If aScan(Self:aSubAtiv, {|x| x:getCodigo() == oSubAtiv:getCodigo() .And. x:getAnexo() == oSubAtiv:getAnexo()}) == 0
		aAdd(Self:aSubAtiv, oSubAtiv)
	Else
		// Atualiza as receitas da subatividade
		nRecSubAtv := Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):getReceita()
		nRecSubAtv += oSubAtiv:getReceita()

		nRecSubNaoExced := Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):getRecSubNaoExced()
		nRecSubNaoExced += oSubAtiv:getRecSubNaoExced()

		nRecSubExced := Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):getRecSubExced()
		nRecSubExced += oSubAtiv:getRecSubExced()

		nRecLimExced := Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):getRecLimExced()
		nRecLimExced += oSubAtiv:getRecLimExced()

		nReceitaBruta := Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):getRecBruta()
		nReceitaBruta += oSubAtiv:getRecBruta()

		nValorDev := Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):getValorDevolucoes()
		nValorDev += oSubAtiv:getValorDevolucoes()

		Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):setReceita(nRecSubAtv)
		Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):setRecSubNaoExced(nRecSubNaoExced)
		Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):setRecSubExced(nRecSubExced)
		Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):setRecLimExced(nRecLimExced)
		Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):setRecBruta(nReceitaBruta)
		Self:getSubAtividades(oSubAtiv:getCodigo(), oSubAtiv:getAnexo()):setValorDevolucoes(nValorDev)

	EndIf
Else
	aAdd(Self:aSubAtiv, oSubAtiv)
EndIf

//Atualiza a receita LÍQUIDA da atividade
Self:nReceita += oSubAtiv:getReceita()

//Atualiza a receita BRUTA da atividade
Self:nReceitaBruta += oSubAtiv:getRecBruta()

//Atualiza o total de devoluções da atividade
Self:nValorDev += oSubAtiv:getValorDevolucoes()

Return

// GETTERS E SETTERS

Method getCodigo() Class FISA153ATIVIDADE
Return Self:cCodigo

Method setCodigo(cCodigo) Class FISA153ATIVIDADE
Self:cCodigo := cCodigo
Return

Method getDescricao() Class FISA153ATIVIDADE
Return Self:cDescricao

Method setDescricao(cDescricao) Class FISA153ATIVIDADE
Self:cDescricao := cDescricao
Return

Method getReceita() Class FISA153ATIVIDADE
Return Self:nReceita

Method setReceita(nReceita) Class FISA153ATIVIDADE
Self:nReceita := nReceita
Return

Method getTipoAtividade() Class FISA153ATIVIDADE
Return Self:cTpAtiv

Method setTipoAtividade(cTpAtiv) Class FISA153ATIVIDADE
Self:cTpAtiv := cTpAtiv
Return

Method getSubAtividades(cCodSubAtv, cAnexo) Class FISA153ATIVIDADE

Local xRet := NIL
Local nPos := 0

DEFAULT cCodSubAtv := ""
DEFAULT cAnexo := ""

// Se não passar um código de subatividade retorno a lista completa.
If Empty(cCodSubAtv)
	xRet := Self:aSubAtiv
// Caso contrario procuro a subatividade na lista. Se encontrar, retorna.
ElseIf Len(Self:aSubAtiv) > 0
	// Se nao passar o anexo procuro soh com o código da subatividade.
	If Empty(cAnexo)
		If (nPos := aScan(Self:aSubAtiv, {|x| AllTrim(x:getCodigo()) == AllTrim(cCodSubAtv)})) > 0
			xRet := Self:aSubAtiv[nPos]
		EndIf
	Else
		If (nPos := aScan(Self:aSubAtiv, {|x| AllTrim(x:getCodigo()) == AllTrim(cCodSubAtv) .And. AllTrim(x:getAnexo()) == AllTrim(cAnexo)})) > 0
			xRet := Self:aSubAtiv[nPos]
		EndIf
	EndIf
EndIf

Return xRet

Method getRecBruta() Class FISA153ATIVIDADE
Return Self:nReceitaBruta

Method setRecBruta(nReceitaBruta) Class FISA153ATIVIDADE
Self:nReceitaBruta := nReceitaBruta
Return

Method getValorDevolucoes() Class FISA153ATIVIDADE
Return Self:nValorDev

Method setValorDevolucoes(nValorDev) Class FISA153ATIVIDADE
Self:nValorDev := nValorDev
Return

// ------------------------------
// CLASSE SUBLIMITE
// ------------------------------

CLASS FISA153SUBLIMITE FROM LongNameClass

Data cUF as Character // UF na qual a empresa está localizada
Data nLimiteEst as Numeric // Sublimite para tributos estaduais
Data nLimiteFed as Numeric // Sublimite para tributos federais
Data nLimiteMun as Numeric // SUblimite para tributos municipais

Method new() CONSTRUCTOR

Method getUF()
Method setUF(cUF)
Method getLimiteEst()
Method setLimiteEst(nLimiteEst)
Method getLimiteFed()
Method setLimiteFed(nLimiteFed)
Method getLimiteMun()
Method setLimiteMun(nLimiteMun)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Método construtor da classe

@author joao.pellegrini
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method new() Class FISA153SUBLIMITE

	Self:cUF := ""
	Self:nLimiteEst := 0
	Self:nLimiteFed := 0
	Self:nLimiteMun := 0

Return

// GETTERS E SETTERS

Method getUF() Class FISA153SUBLIMITE
Return Self:cUF

Method setUF(cUF) Class FISA153SUBLIMITE
Self:cUF := cUF
Return

Method getLimiteEst() Class FISA153SUBLIMITE
Return Self:nLimiteEst

Method setLimiteEst(nLimiteEst) Class FISA153SUBLIMITE
Self:nLimiteEst := nLimiteEst
Return

Method getLimiteFed() Class FISA153SUBLIMITE
Return Self:nLimiteFed

Method setLimiteFed(nLimiteFed) Class FISA153SUBLIMITE
Self:nLimiteFed := nLimiteFed
Return

Method getLimiteMun() Class FISA153SUBLIMITE
Return Self:nLimiteMun

Method setLimiteMun(nLimiteMun) Class FISA153SUBLIMITE
Self:nLimiteMun
Return

// ------------------------------
// CLASSE FISA153RECEITANF
// ------------------------------

CLASS FISA153RECEITANF FROM LongNameClass

Data nValBrut	as Numeric
Data nICMSRET 	as Numeric
Data nValorRc 	as Numeric
Data cCodAtv 	as Character
Data cCodSub 	as Character
Data cCSOSN	 	as Character
Data cMumPres 	as Character
Data cCodMun 	as Character
Data cRecIss 	as Character
Data cTpServ 	as Character
Data cAnexo 	as Character
Data cFAtorR 	as Character
Data cCfop 		as Character
Data cAnexoSub	as Character
Data cMepLes	as Character

Method new() CONSTRUCTOR
Method clear()

Method getVALBRUT()
Method getICMSRET()
Method getCodAtv()
Method getCsosn()
Method getMunPres()
Method getCCodMun()
Method getRecIss()
Method getTpServ()
Method getAnexo()
Method getFatorR()
Method getCfop()
Method getSubAtv()
Method getAnexoSub()
Method getMepLes()
Method GetValorRC()

Method setVALBRUT()
Method setICMSRET()
Method setCodAtv()
Method setCsosn()
Method setMunPres()
Method setCCodMun()
Method setRecIss()
Method setTpServ()
Method setAnexo()
Method setFatorR()
Method setCfop()
Method setSubAtv()
Method setAnexoSub()
Method setMepLes()
Method SetValorRC()

ENDCLASS

Method new() Class FISA153RECEITANF

Self:Clear()

Return

Method clear() Class FISA153RECEITANF

Self:nValBrut 	:= 0
Self:nICMSRET 	:= 0
Self:cCodAtv 	:= ""
Self:cCSOSN	 	:= ""
Self:cMumPres 	:= ""
Self:cCodMun 	:= ""
Self:cRecIss 	:= ""
Self:cTpServ 	:= ""
Self:cAnexo 	:= ""
Self:cFAtorR 	:= ""
Self:cCfop 		:= ""
Self:cCodSub	:= ""
Self:cAnexoSub	:= ""
Self:cMepLes	:= ""
Self:nValorRc   := 0 


Return

Method setSubAtv( xValue ) Class FISA153RECEITANF
Self:cCodSub := xValue
Return

Method setVALBRUT( xValue ) Class FISA153RECEITANF
Self:nValBrut := xValue
Return

Method setICMSRET( xValue ) Class FISA153RECEITANF
Self:nICMSRET := xValue
Return

Method setCodAtv( xValue ) Class FISA153RECEITANF
Self:cCodAtv := xValue
Return

Method setCsosn( xValue ) Class FISA153RECEITANF
Self:cCSOSN := xValue
Return

Method setMunPres( xValue ) Class FISA153RECEITANF
Self:cMumPres := xValue
Return

Method setCCodMun( xValue ) Class FISA153RECEITANF
Self:cCodMun := xValue
Return

Method setRecIss( xValue ) Class FISA153RECEITANF
Self:cRecIss := xValue
Return

Method setTpServ( xValue ) Class FISA153RECEITANF
Self:cTpServ := xValue
Return

Method setAnexo( xValue ) Class FISA153RECEITANF
Self:cAnexo := xValue
Return

Method setFatorR( xValue ) Class FISA153RECEITANF
Self:cFAtorR := xValue
Return

Method setCfop( xValue ) Class FISA153RECEITANF
Self:cCfop := xValue
Return

Method setAnexoSub( xValue ) Class FISA153RECEITANF
Self:cAnexoSub := xValue
Return

Method setMepLes( xValue ) Class FISA153RECEITANF
Self:cMepLes := xValue
Return

Method SetValorRC( xValue ) Class FISA153RECEITANF
Self:nValorRc := xValue
Return

Method getVALBRUT() Class FISA153RECEITANF
Return Self:nValBrut

Method getICMSRET() Class FISA153RECEITANF
Return Self:nICMSRET

Method getCodAtv() Class FISA153RECEITANF
Return Self:cCodAtv

Method getCsosn() Class FISA153RECEITANF
Return Self:cCSOSN

Method getMunPres() Class FISA153RECEITANF
Return Self:cMumPres

Method getCCodMun() Class FISA153RECEITANF
Return Self:cCodMun

Method getRecIss() Class FISA153RECEITANF
Return Self:cRecIss

Method getTpServ() Class FISA153RECEITANF
Return Self:cTpServ

Method getAnexo() Class FISA153RECEITANF
Return Self:cAnexo

Method getFatorR() Class FISA153RECEITANF
Return Self:cFAtorR

Method getCfop() Class FISA153RECEITANF
Return Self:cCfop

Method getSubAtv() Class FISA153RECEITANF
Return Self:cCodSub

Method getAnexoSub() Class FISA153RECEITANF
Return Self:cAnexoSub

Method getMepLes() Class FISA153RECEITANF
Return Self:cMepLes

Method GetValorRC() Class FISA153RECEITANF
Return Self:nValorRc

CLASS FISA153IMPOSTOS FROM LongNameClass

Data aImpostos as Array // Retorna os registros da CIA por tipo de imposto
Data aPRICMS17 as Array // Exlusiva - Paraná ICMS - Tabela I do Anexo VIII (RICMS 2012) - Tabela base para utilização do limitador.

Method new() CONSTRUCTOR
Method getImpostos() 			// Retorna o array de impostos 
Method setImpostos(aImpostos) 	// Informar o array com todos os Tributos do Anexo x Faixa
Method getAliqNom(nTipo) 		// Retorna a Aliquota Nominal do imposto - CIA
Method getValDed(nTipo) 		// Retorna o Valor a Deduzir do imposto  - CIA
Method getPerRedIC(nTipo) 		// Percentual de redução da base do imposto  - CIA
Method getLimite(nTipo) 		// Retorna o Limite (Majoração) utilizado nos cálculo de Redução de Base de Cálculo
Method Converter( cTipo ) 				// Converter as opções do campo CIA_TIPO em nome do imposto. Exemplo: 0=ICMS
Method AliqEfetICMS(nRBT12) //  Calcula aliquota efetiva baseado nos dados da CIA

Method setPRICMS()			// Carrega tabela específica do estado do paraná
Method getFaixaPRICMS()			// Majora a tabela específica do estadod o paraná para Redução da Base do ICMS PR

ENDCLASS

Method new() Class FISA153IMPOSTOS
self:aImpostos := {}
Return

Method getImpostos( xValue ) Class FISA153IMPOSTOS
Return Self:aImpostos

Method setImpostos( aImpostos ) Class FISA153IMPOSTOS
Self:aImpostos := aImpostos
Return

Method getAliqNom( nTipo ) Class FISA153IMPOSTOS
Local nPos := 0
Local nRet := 0
If Len(Self:aImpostos) > 0
	nPos := aScan(Self:aImpostos, {|x| x[1] == nTipo })
	If nPos > 0
		nRet := Self:aImpostos[nPos][2]
	EndIf
EndIf
Return nRet

Method getValDed( nTipo ) Class FISA153IMPOSTOS
Local nPos := 0
Local nRet := 0
If Len(Self:aImpostos) > 0
	nPos := aScan(Self:aImpostos, {|x| x[1] == nTipo })
	If nPos > 0
		nRet := Self:aImpostos[nPos][3]
	EndIf
EndIf
Return nRet


Method getLimite( nTipo ) Class FISA153IMPOSTOS
Local nPos := 0
Local nRet := 0
If Len(Self:aImpostos) > 0
	nPos := aScan(Self:aImpostos, {|x| x[1] == nTipo })
	If nPos > 0
		nRet := Self:aImpostos[nPos][4]
	EndIf
EndIf
Return nRet

Method getPerRedIC( nTipo ) Class FISA153IMPOSTOS
Local nPos := 0
Local nRet := 0
If Len(Self:aImpostos) > 0
	nPos := aScan(Self:aImpostos, {|x| x[1] == nTipo })
	If nPos > 0
		nRet := Self:aImpostos[nPos][5]
	EndIf
EndIf
Return nRet

Method Converter( cTipo ) Class FISA153IMPOSTOS
Local cRet := ""
	Do Case
		Case cTipo == "0"
			cRet := "ICMS"
		Case cTipo == "1"
			cRet := "ISS"
		Case cTipo == "2"
			cRet := "IPI"
		Case cTipo == "3"
			cRet := "PIS"
		Case cTipo == "4"
			cRet := "COFINS"
		Case cTipo == "5"
			cRet := "CSLL"
		Case cTipo == "6"
			cRet := "CPP"
		Case cTipo == "7"
			cRet := "IRPJ"
	EndCase
Return cRet

Method AliqEfetICMS( nRBT12) Class FISA153IMPOSTOS
Local nAliqEfet := 0
Local nAliqMajorada := 0
Local cEstado	:= GetMv("MV_ESTADO")
DEFAULT nRBT12	:= 0
	// Genérico
	nAliqEfet :=  (((nRBT12 * (Self:getAliqNom("ICMS") / 100)) - Self:getValDed("ICMS") ) / nRBT12)
	/* 
	Conforme Decreto 8660 publicado no DOE 10110 de 17.01.2018 (Em vigor a partir de 1º de janeiro de 2018
	Em seguida, deve ser apurada as alíquotas efetivas Nacional e a do Paraná, conforme abaixo:
	1 - Apurar a alíquota efetiva (Nacional) com base no Anexo I ou II da LC n. 123/2006, conforme o caso;
	2 - Apurar a alíquota efetiva (Paraná) com base na Tabela I ou II do Anexo XI do RICMS/PR;
	3 - Apurar o percentual de redução entre a alíquota efetiva do Paraná sobre a Nacional.
	Vale lembrar que deve ser observado que a alíquota efetiva do ICMS do Paraná não poderá ser superior a 20% (vinte por cento) acima do percentual previsto para a correspondente 
	faixa de receita bruta da alíquota nominal vigente em 31 de dezembro de 2017, conforme dispõe o art. 39-A da Lei n. 15.562/2007.
	http://www.atendimento.fazenda.pr.gov.br/sacsefa/portal/assuntosReferente/46
	*/	
	If cEstado == "PR"
		nAliqMajorada	:= self:getFaixaPRICMS(nRBT12)[4]
		nAliqEfet	:= Min( nAliqEfet , nAliqMajorada )
	EndIf

Return nAliqEfet

Method setPRICMS() Class FISA153IMPOSTOS
self:aPRICMS17 :=	{	{0				,180000.00		,	0	,	},;
						{180000.01 		, 360000.00		,	0	,	},;
						{360000.01 		, 540000.00		,0.67	,	},;
						{540000.01 		, 720000.00		,1.07	,	},;
						{720000.01 		, 900000.00		,1.33	,	},;
						{900000.01 		, 1080000.00	,1.52	,	},;
						{1080000.01 	, 1260000.00	,1.83	,	},;
						{1260000.01 	, 1440000.00	,2.07	,	},;
						{1440000.01 	, 1620000.00	,2.27	,	},;
						{1620000.01 	, 1800000.00	,2.42	,	},;
						{1800000.01 	, 1980000.00	,2.56	,	},;
						{1980000.01 	, 2160000.00	,2.67	,	},;
						{2160000.01 	, 2340000.00	,2.76	,	},;
						{2340000.01 	, 2520000.00	,2.84	,	},;
						{2520000.01 	, 2700000.00	,2.92	,	},;
						{2700000.01 	, 2880000.00	,3.06	,	},;
						{2880000.01 	, 3060000.00	,3.19	,	},;
						{3060000.01 	, 3240000.00	,3.3	,	},;
						{3240000.01 	, 3420000.00	,3.4	,	},;
						{3420000.01 	, 999999999.00	,3.5	,	}}
						// De[1]		//Até[2]		Aliq.Efetiva.ICMS [3] Aliq.Efetiva.ICMS Majorada[4]
Return 

Method getFaixaPRICMS(nValor) Class FISA153IMPOSTOS
Local cRet		:= {}
Local nPos		:= 0
Local nMajorado	:= 0

Default nValor	:=	0
self:setPRICMS()

nPos := aScan(self:aPRICMS17,{|x| nValor >= x[1] .And. nValor <= x[2]  })
If nPos > 0
	nMajorado	:=  self:aPRICMS17[nPos][3] * ( 1 + ( self:getLimite("ICMS") /100 ) )
	self:aPRICMS17[nPos][4] :=  nMajorado / 100
	cRet	:= self:aPRICMS17[nPos]
EndIf

Return cRet
