#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCOM();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCOM()
@description Classe que terá as informações específicas para geração dos 
			   registros do bloco M no SPED Contribuições, o bloco dos registros 
			   de apuração de PIS e COFINS. Esta classe nã herda propriedades de outras
			   classes.Aqui teremos a formatação de todos os registros deste bloco,
			   levando em consideração que existem registros duplicados, ou seja,
			   exsite um registro para PIS, e existe outro registro igual porém com
			   informações da COFINS, aqui iremos unificar e tratar em um único
			   método, diferenciando apenas os valores dos tributos.
			   

@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCOM FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS DA CLASSE
//-----------------------------------------------------
Data cCodCrd		as String		READONLY		//Código do crédito conforme tabela 4.3.6 da RFB
Data cCodCon		as String		READONLY		//Código da contribuição conforme tabela 4.3.5 da RFB
Data nAlq			as String		READONLY		//Alíquota de PIS e COFINS em percentual
Data nAlqR			as String		READONLY		//Alíquota de PIS e COFINS em reais
Data nBasCalc		as Integer		READONLY		//Base de cálculo 
Data nBasCalcQ		as Integer		READONLY		//Base de cálculo em quantidade
Data cCodCtb		as String		READONLY		//Código da conta contábil
Data cDescr			as String		READONLY		//Descrição complementar
Data cInfComp		as String		READONLY		//Informação complementar
Data cCST			as String		READONLY		//Código da Situação Tributária de PIS e COFINS conforme tabela 433 e 434.
Data nAjuAcr		as Integer		READONLY		//Valor de ajuste de acréscimo, de crédito ou da contribuição.
Data nAjuRed		as Integer		READONLY		//Valor de ajuste de redução, de crédito ou da contribuição.
Data cDtOper		as String		READONLY		//Data da operação
Data nConDif		as Integer		READONLY		//Valor da contribuição diferida no período
Data nCrdDif		as Integer		READONLY		//Valor do crédito diferido no período
Data nConDifA		as Integer		READONLY		//Valor da contribuição apurada e diferida em períodos anteriores
Data lPauta 		as Boolean		READONLY		//Indica se valores são referente pauta de PIS e COFINS

//M100/M500
Data nCrdApur		as Integer		READONLY		//Valor do crédito apurado no período
Data cOriCrd		as String		READONLY		//Indicador da Origem do crédito
Data nCrdDisp		as Integer		READONLY		//Valor total do crédito disponível
Data cIndUti		as String		READONLY		//Indicador de utilização dos créditos
Data nCrdDesc		as String		READONLY		//Valor do crédito descontado/utilizado
Data nSldCrd		as String		READONLY		//Saldo de crédito a ser utilizado em período futuro

//M105/M505
Data cCodBcc		as String		READONLY		//Código da base do cálculo do crédito conforme tabela 4.3.7
Data nBasACDF		as Integer		READONLY		//Valor total da base de cálculo escriturada no registros A, C, D e F.
Data nBasCum		as Integer		READONLY		//Parcela da base vinculada a receita cumulativa
Data nBasNCum		as Integer		READONLY		//Parcela da base vinculada a receita Não cumulativa
Data nBasQACDF		as Integer		READONLY		//Quantidade total da base de cálculo escriturada nos blocos A, C, D e F

//M110/M510/M220/M620
Data cIndAju		as String		READONLY		//Indicador do tipo de ajuste, se redução ou acréscimo
Data nValAju		as integer		READONLY		//Valor do Ajuste
Data cCodAju		as String		READONLY		//Código do ajuste, conforme tabela 4.3.8 
Data cNumDoc		as String		READONLY		//CNúmero do processo/documento/ação

//M200/M600
Data nVlNCum		as Integer		READONLY		//Valor total da contribuição Não Cumulativa
Data nCrduTiP		as Integer		READONLY		//Valor total do crédito utilizado do período
Data nCrduTiA		as Integer		READONLY		//Valor total do crédito utilizado do anterior
Data nTotConN		as Integer		READONLY		//Valor total da contribuição Não Cumulativa
Data nVlRetN		as Integer		READONLY		//Valor retido na fonte deduzido - Não Cumulativo
Data nOutNCum		as Integer		READONLY		//Outras deduções no período - Não Cumulativo
Data nNCumRec		as Integer		READONLY		//Valor da contribuição Não Cumulativa a recolher
Data nVlCum			as Integer		READONLY		//Valor total da contribuição Cumulativa
Data nVlRetC		as Integer		READONLY		//Valor retido na fonte deduzido - Cumulativo
Data nOutCum		as Integer		READONLY		//Outras deduções no período - Cumulativoo
Data nCumRec		as Integer		READONLY		//Valor da contribuição Cumulativa a recolher
Data nTotPag		as Integer		READONLY		//Valor total a pagar

//M205/M605
Data cNumCpo		as String		READONLY		//Número do campo do registro pai M200/M600
Data cCodRec		as String		READONLY		//Código da receita do pagamento

//M210/M610
Data nVlBrut		as Integer		READONLY		//Valor da receita bruta
Data nVlConPer		as Integer		READONLY		//Valor total da contribuição no período
Data nVlConApu		as Integer		READONLY		//Valor total da contribuição apuradao no período, antes dos ajustes e diferimento
Data nAcreBC		as Integer		//Acréscimo de base de cálculo
Data nReduBC		as Integer		//Redução de base de cálculo
Data nBCAJus		as Integer		//Base de cálculo ajustada

//M211/M611
Data cIndSoc		as String		READONLY		//Indicador do tipo de sociedadecooperativa
Data nExcES			as Integer		READONLY		//Valor de exclusão especifica da sociedade
Data nExcET			as Integer		READONLY		//Valor de exclusão específica do tipo de sociedade
Data nSocACDF		as Integer		READONLY		//Valor da base de cálculo escriturada nos blocos A, C, D e F
Data nBasSoc		as Integer		READONLY		//Valor da base de cálculo após exclusões

//M230/M630
Data CNPJ			as String		READONLY		//CNPJ da pessoa jurídica de direito público
Data nTotVend		as Integer		READONLY		//Valor total das vendas no período
Data nNReceb		as INteger		READONLY		//Valor total não recebido

//M300/M700
Data cNatCrd		as String		READONLY		//Natureza do crédito diferido
Data cPer			as String		READONLY		//Período da apuração MM/AAAA

//M350
Data nTotFol		as Integer		READONLY		//Valor total da folha de salário
Data nExcFol		as Integer		READONLY		//Valor total das exclusões

//M410/M810
Data cCNatRec		as String		READONLY		//Código da natureza da receita

Data lAjuBase		as Boolean  //Indica se o bloco M será gerado com registros e campos de ajuste de base de cálculo



//-------------------------------------------------------------
//ARRAY DOS REGISTROS DO BLOCO M 
//-------------------------------------------------------------
//-------------------------------------------------------------
//INFORMAÇÕES DE PIS
//-------------------------------------------------------------
Data aRegM100		as Array		READONLY		
Data aRegM105		as Array		READONLY
Data aRegM110		as Array		READONLY
Data aRegM115		as Array		READONLY
Data aRegM200		as Array		READONLY
Data aRegM205		as Array		READONLY
Data aRegM210		as Array		READONLY
Data aRegM215		as Array		READONLY
Data aRegM220		as Array		READONLY
Data aRegM225		as Array		READONLY
Data aRegM211		as Array		READONLY
Data aRegM230		as Array		READONLY
Data aRegM300		as Array		READONLY
Data aRegM350		as Array		READONLY
Data aRegM400		as Array		READONLY
Data aRegM410		as Array		READONLY

//-------------------------------------------------------------
//INFORMAÇÕES DE COFINS
//-------------------------------------------------------------
Data aRegM500		as Array		READONLY		
Data aRegM505		as Array		READONLY
Data aRegM510		as Array		READONLY
Data aRegM515		as Array		READONLY
Data aRegM600		as Array		READONLY
Data aRegM605		as Array		READONLY
Data aRegM610		as Array		READONLY
Data aRegM611		as Array		READONLY
Data aRegM615		as Array		READONLY
Data aRegM620		as Array		READONLY
Data aRegM625		as Array		READONLY
Data aRegM630		as Array		READONLY
Data aRegM700		as Array		READONLY
Data aRegM800		as Array		READONLY
Data aRegM810		as Array		READONLY
Data aRegM001		as Array		READONLY
Data aRegM990		as Array		READONLY
		
	//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()
Method AddM100500()
Method AddM100()
Method AddM500()
Method AddM105505()
Method AddM105()
Method AddM505()
Method AddAjuste()
Method AddM110()
Method AddM510()
Method AddM220()
Method AddM620()
Method AddDetAjus()
Method AddM115()
Method AddM515()
Method AddM225()
Method AddM625()
Method AddM200600()
Method AddM200()
Method AddM600()
Method AddM205605()
Method AddM205()
Method AddM605()
Method AddM210610()
Method AddM215615()
Method AddM210()
Method AddM610()
Method AddM211()
Method AddM215()
Method AddM611()
Method AddM615()
Method AddM211611()
Method AddM230()
Method AddM630()
Method AddM230630()
Method AddM300700()
Method AddM300()
Method AddM700()
Method AddM350()
Method AddM400800()
Method AddM400()
Method AddM800()
Method AddM410810()
Method AddM410()
Method AddM810()
Method AddM001(cIndMovto)
Method AddM990(nQtde)

Method setCodCrd( cCodCrd) 
Method setCodCon( cCodCon) 
Method setAlq( nAlq)
Method setAlqR( nAlqR)
Method setBasCalc( nBasCalc) 
Method setBaCalcQ( nBasCalcQ)
Method setCodCtb( cCodCtb)
Method setDescr( cDescr) 
Method setInfComp( cInfComp)
Method setCST( cCST) 
Method setAjuAcr( nAjuAcr)
Method setAjuRed( nAjuRed) 
Method setDtOper( cDtOper) 
Method setConDif( nConDif) 
Method setCrdDif( nCrdDif) 
Method setConDifA( nConDifA) 
Method setPauta( lPauta) 
Method setCrdApur( nCrdApur)
Method setOriCrd( cOriCrd) 
Method setCrdDisp( nCrdDisp) 
Method setIndUti( cIndUti) 
Method setCrdDesc( nCrdDesc) 
Method setSldCrd( nSldCrd) 
Method setCodBcc( cCodBcc)
Method setBasACDF( nBasACDF)
Method setBasCum( nBasCum) 
Method setBasNCum( nBasNCum)
Method setBsQACDF( nBasQACDF)
Method setIndAju( cIndAju) 
Method setValAju( nValAju) 
Method setCodAju( cCodAju) 
Method setNumDoc( cNumDoc) 
Method setVlNCum( nVlNCum) 
Method setCrduTiP( nCrduTiP)
Method setCrduTiA( nCrduTiA)
Method setTotConN( nTotConN) 
Method setVlRetN( nVlRetN) 
Method setOutNCum( nOutNCum)
Method setNCumRec( nNCumRec)
Method setVlCum( nVlCum)
Method setVlRetC( nVlRetC)
Method setOutCum( nOutCum) 
Method setCumRec( nCumRec) 
Method setTotPag( nTotPag)
Method setNumCpo( cNumCpo)
Method setCodRec( cCodRec) 
Method setVlBrut( nVlBrut) 
Method setVlConPe( nVlConPer)
Method setVlConAp( nVlConApu)
Method setAcreBC( nAcreBC)
Method setReduBC( nReduBC)
Method setBCAJus( nBCAJus)
Method setIndSoc( cIndSoc) 
Method setExcES( nExcES) 
Method setExcET( nExcET) 
Method setSocACDF( nSocACDF)
Method setBasSoc( nBasSoc) 
Method setCNPJ( cNPJ)
Method setTotVend( nTotVend)
Method setNReceb( nNReceb) 
Method setNatCrd( cNatCrd) 
Method setPer( cPer) 
Method setTotFol( nTotFol) 
Method setExcFol( nExcFol) 
Method setCNatRec( cCNatRec)
Method setAjuBase( lAjuBase)

Method getM350()
Method getM210()
Method getM211()
Method getM215()
Method getM610()
Method getM611()
Method getM615()
Method getM100()
Method getM500()
Method getM105()
Method getM505()
Method getM400()
Method getM410()
Method getM800()
Method getM810()

Method getM110()
Method getM115()
Method getM220()
Method getM225()

Method getM510()
Method getM515()
Method getM620()
Method getM625()

Method getM300()
Method getM700()
Method getM230()
Method getM630()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCOM
Self:cJob	:= '00'
Self:Clear()

Return

Method setCodCrd( cCodCrd) Class EFDCBLOCOM
	Self:cCodCrd := cCodCrd
Return

Method setCodCon( cCodCon) Class EFDCBLOCOM
	Self:cCodCon := cCodCon
Return

Method setAlq( nAlq) Class EFDCBLOCOM
	Self:nAlq := nAlq
Return

Method setAlqR( nAlqR) Class EFDCBLOCOM
	Self:nAlqR := nAlqR
Return

Method setBasCalc( nBasCalc) Class EFDCBLOCOM
	Self:nBasCalc := nBasCalc
Return

Method setBaCalcQ( nBasCalcQ) Class EFDCBLOCOM
	Self:nBasCalcQ := nBasCalcQ
Return

Method setCodCtb( cCodCtb) Class EFDCBLOCOM
	Self:cCodCtb := cCodCtb
Return

Method setDescr( cDescr) Class EFDCBLOCOM
	Self:cDescr := cDescr
Return

Method setInfComp( cInfComp) Class EFDCBLOCOM
	Self:cInfComp := cInfComp
Return

Method setCST( cCST) Class EFDCBLOCOM
	Self:cCST := cCST
Return

Method setAjuAcr( nAjuAcr) Class EFDCBLOCOM
	Self:nAjuAcr := nAjuAcr
Return

Method setAjuRed( nAjuRed) Class EFDCBLOCOM
	Self:nAjuRed := nAjuRed
Return

Method setDtOper( cDtOper) Class EFDCBLOCOM
	Self:cDtOper := cDtOper
Return

Method setConDif( nConDif) Class EFDCBLOCOM
	Self:nConDif := nConDif
Return

Method setCrdDif( nCrdDif) Class EFDCBLOCOM
	Self:nCrdDif := nCrdDif
Return

Method setConDifA( nConDifA) Class EFDCBLOCOM
	Self:nConDifA := nConDifA
Return

Method setPauta( lPauta) Class EFDCBLOCOM
	Self:lPauta := lPauta
Return

Method setCrdApur( nCrdApur) Class EFDCBLOCOM
	Self:nCrdApur := nCrdApur
Return

Method setOriCrd( cOriCrd) Class EFDCBLOCOM
	Self:cOriCrd := cOriCrd
Return

Method setCrdDisp( nCrdDisp) Class EFDCBLOCOM
	Self:nCrdDisp := nCrdDisp
Return

Method setIndUti( cIndUti) Class EFDCBLOCOM
	Self:cIndUti := cIndUti
Return

Method setCrdDesc( nCrdDesc) Class EFDCBLOCOM
	Self:nCrdDesc := nCrdDesc
Return

Method setSldCrd( nSldCrd) Class EFDCBLOCOM
	Self:nSldCrd := nSldCrd
Return

Method setCodBcc( cCodBcc) Class EFDCBLOCOM
	Self:cCodBcc := cCodBcc
Return

Method setBasACDF( nBasACDF) Class EFDCBLOCOM
	Self:nBasACDF := nBasACDF
Return

Method setBasCum( nBasCum) Class EFDCBLOCOM
	Self:nBasCum := nBasCum
Return

Method setBasNCum( nBasNCum) Class EFDCBLOCOM
	Self:nBasNCum := nBasNCum
Return

Method setBsQACDF( nBasQACDF) Class EFDCBLOCOM
	Self:nBasQACDF := nBasQACDF
Return

Method setIndAju( cIndAju) Class EFDCBLOCOM
	Self:cIndAju := cIndAju
Return

Method setValAju( nValAju) Class EFDCBLOCOM
	Self:nValAju := nValAju
Return

Method setCodAju( cCodAju) Class EFDCBLOCOM
	Self:cCodAju := cCodAju
Return

Method setNumDoc( cNumDoc) Class EFDCBLOCOM
	Self:cNumDoc := cNumDoc
Return

Method setVlNCum( nVlNCum) Class EFDCBLOCOM
	Self:nVlNCum := nVlNCum
Return

Method setCrduTiP( nCrduTiP) Class EFDCBLOCOM
	Self:nCrduTiP := nCrduTiP
Return

Method setCrduTiA( nCrduTiA) Class EFDCBLOCOM
	Self:nCrduTiA := nCrduTiA
Return

Method setTotConN( nTotConN) Class EFDCBLOCOM
	Self:nTotConN := nTotConN
Return

Method setVlRetN( nVlRetN) Class EFDCBLOCOM
	Self:nVlRetN := nVlRetN
Return

Method setOutNCum( nOutNCum) Class EFDCBLOCOM
	Self:nOutNCum := nOutNCum
Return

Method setNCumRec( nNCumRec) Class EFDCBLOCOM
	Self:nNCumRec := nNCumRec
Return

Method setVlCum( nVlCum) Class EFDCBLOCOM
	Self:nVlCum := nVlCum
Return

Method setVlRetC( nVlRetC) Class EFDCBLOCOM
	Self:nVlRetC := nVlRetC
Return

Method setOutCum( nOutCum) Class EFDCBLOCOM
	Self:nOutCum := nOutCum
Return

Method setCumRec( nCumRec) Class EFDCBLOCOM
	Self:nCumRec := nCumRec
Return

Method setTotPag( nTotPag) Class EFDCBLOCOM
	Self:nTotPag := nTotPag
Return

Method setNumCpo( cNumCpo) Class EFDCBLOCOM
	Self:cNumCpo := cNumCpo
Return

Method setCodRec( cCodRec) Class EFDCBLOCOM
	Self:cCodRec := cCodRec
Return

Method setVlBrut( nVlBrut) Class EFDCBLOCOM
	Self:nVlBrut := nVlBrut
Return

Method setVlConPe( nVlConPer) Class EFDCBLOCOM
	Self:nVlConPer := nVlConPer
Return

Method setVlConAp( nVlConApu) Class EFDCBLOCOM
	Self:nVlConApu := nVlConApu
Return

Method setAcreBC( nAcreBC) Class EFDCBLOCOM
	Self:nAcreBC := nAcreBC
Return

Method setReduBC( nReduBC) Class EFDCBLOCOM
	Self:nReduBC := nReduBC
Return

Method setBCAJus( nBCAJus) Class EFDCBLOCOM
	Self:nBCAJus := nBCAJus
Return

Method setIndSoc( cIndSoc) Class EFDCBLOCOM
	Self:cIndSoc := cIndSoc
Return

Method setExcES( nExcES) Class EFDCBLOCOM
	Self:nExcES := nExcES
Return

Method setExcET( nExcET) Class EFDCBLOCOM
	Self:nExcET := nExcET
Return

Method setSocACDF( nSocACDF) Class EFDCBLOCOM
	Self:nSocACDF := nSocACDF
Return

Method setBasSoc( nBasSoc) Class EFDCBLOCOM
	Self:nBasSoc := nBasSoc
Return

Method setCNPJ( cNPJ) Class EFDCBLOCOM
	Self:CNPJ:= cNPJ
Return

Method setTotVend( nTotVend) Class EFDCBLOCOM
	Self:nTotVend := nTotVend
Return

Method setNReceb( nNReceb) Class EFDCBLOCOM
	Self:nNReceb := nNReceb
Return

Method setNatCrd( cNatCrd) Class EFDCBLOCOM
	Self:cNatCrd := cNatCrd
Return

Method setPer( cPer) Class EFDCBLOCOM
	Self:cPer := cPer
Return

Method setTotFol( nTotFol) Class EFDCBLOCOM
	Self:nTotFol := nTotFol
Return

Method setExcFol( nExcFol) Class EFDCBLOCOM
	Self:nExcFol := nExcFol
Return

Method setCNatRec( cCNatRec) Class EFDCBLOCOM
	Self:cCNatRec := cCNatRec
Return

Method setAjuBase(lAjuBase) Class EFDCBLOCOM
	Self:lAjuBase := lAjuBase
Return

Method getM350() Class EFDCBLOCOM
Return Self:aRegM350

Method getM210() Class EFDCBLOCOM
Return Self:aRegM210

Method getM211() Class EFDCBLOCOM
Return Self:aRegM211

Method getM215() Class EFDCBLOCOM
Return Self:aRegM215

Method getM610() Class EFDCBLOCOM
Return Self:aRegM610

Method getM611() Class EFDCBLOCOM
Return Self:aRegM611

Method getM615() Class EFDCBLOCOM
Return Self:aRegM615

Method getM100() Class EFDCBLOCOM
Return Self:aRegM100

Method getM500() Class EFDCBLOCOM
Return Self:aRegM500

Method getM105() Class EFDCBLOCOM
Return Self:aRegM105

Method getM505() Class EFDCBLOCOM
Return Self:aRegM505

Method getM400() Class EFDCBLOCOM
Return Self:aRegM400

Method getM410() Class EFDCBLOCOM
Return Self:aRegM410

Method getM800() Class EFDCBLOCOM
Return Self:aRegM800

Method getM810() Class EFDCBLOCOM
Return Self:aRegM810


Method getM110() Class EFDCBLOCOM
Return Self:aRegM110

Method getM115() Class EFDCBLOCOM
Return Self:aRegM115

Method getM220() Class EFDCBLOCOM 
Return Self:aRegM220

Method getM225() Class EFDCBLOCOM
Return Self:aRegM225

Method getM510() Class EFDCBLOCOM
Return Self:aRegM510

Method getM515() Class EFDCBLOCOM
Return Self:aRegM515

Method getM620() Class EFDCBLOCOM 
Return Self:aRegM620

Method getM625() Class EFDCBLOCOM
Return Self:aRegM625

Method getM300() Class EFDCBLOCOM
Return Self:aRegM300

Method getM700() Class EFDCBLOCOM
Return Self:aRegM700

Method getM230() Class EFDCBLOCOM
Return Self:aRegM230

Method getM630() Class EFDCBLOCOM
Return Self:aRegM630


//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
@description Método que inicializa as propriedades da classe

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method Clear() Class EFDCBLOCOM

Self:cCodCrd		:= ''		//Código do crédito conforme tabela 4.3.6 da RFB
Self:cCodCon		:= ''		//Código da contribuição conforme tabela 4.3.5 da RFB
Self:nAlq			:= ''		//Alíquota de PIS e COFINS em percentual
Self:nAlqR			:= ''		//Alíquota de PIS e COFINS em reais
Self:nBasCalc		:= 0		//Base de cálculo 
Self:nBasCalcQ	:= 0		//Base de cálculo em quantidade
Self:cCodCtb		:= ''		//Código da conta contábil
Self:cDescr		:= ''		//Descrição complementar
Self:cInfComp		:= ''		//Informação complementar
Self:cCST			:= ''		//Código da Situação Tributária de PIS e COFINS conforme tabela 433 e 434.
Self:nAjuAcr		:= 0		//Valor de ajuste de acréscimo, de crédito ou da contribuição.
Self:nAjuRed		:= 0		//Valor de ajuste de redução, de crédito ou da contribuição.
Self:cDtOper		:= ''		//Self:da operação
Self:nConDif		:= 0		//Valor da contribuição diferida no período
Self:nCrdDif		:= 0		//Valor do crédito diferido no período
Self:nConDifA		:= 0		//Valor da contribuição apurada e diferida em períodos anteriores
Self:lPauta 		:= .F.		//Indica se valores são referente pauta de PIS e COFINS
Self:nCrdApur		:= 0		//Valor do crédito apurado no período
Self:cOriCrd		:= ''		//Indicador da Origem do crédito
Self:nCrdDisp		:= 0		//Valor total do crédito disponível
Self:cIndUti		:= ''		//Indicador de utilização dos créditos
Self:nCrdDesc		:= ''		//Valor do crédito descontado/utilizado
Self:nSldCrd		:= ''		//Saldo de crédito a ser utilizado em período futuro
Self:cCodBcc		:= ''		//Código da base do cálculo do crédito conforme tabela 4.3.7
Self:nBasACDF		:= 0		//Valor total da base de cálculo escriturada no registros A, C, D e F.
Self:nBasCum		:= 0		//Parcela da base vinculada a receita cumulativa
Self:nBasNCum		:= 0		//Parcela da base vinculada a receita Não cumulativa
Self:nBasQACDF	:= 0		//Quantidade total da base de cálculo escriturada nos blocos A, C, D e F
Self:cIndAju		:= ''		//Indicador do tipo de ajuste, se redução ou acréscimo
Self:nValAju		:= 0		//Valor do Ajuste
Self:cCodAju		:= ''		//Código do ajuste, conforme tabela 4.3.8 
Self:cNumDoc		:= ''		//CNúmero do processo/documento/ação
Self:nVlNCum		:= 0		//Valor total da contribuição Não Cumulativa
Self:nCrduTiP		:= 0		//Valor total do crédito utilizado do período
Self:nCrduTiA		:= 0		//Valor total do crédito utilizado do anterior
Self:nTotConN		:= 0		//Valor total da contribuição Não Cumulativa
Self:nVlRetN		:= 0		//Valor retido na fonte deduzido - Não Cumulativo
Self:nOutNCum		:= 0		//Outras deduções no período - Não Cumulativo
Self:nNCumRec		:= 0		//Valor da contribuição Não Cumulativa a recolher
Self:nVlCum		:= 0		//Valor total da contribuição Cumulativa
Self:nVlRetC		:= 0		//Valor retido na fonte deduzido - Cumulativo
Self:nOutCum		:= 0		//Outras deduções no período - Cumulativoo
Self:nCumRec		:= 0		//Valor da contribuição Cumulativa a recolher
Self:nTotPag		:= 0		//Valor total a pagar
Self:cNumCpo		:= ''		//Número do campo do registro pai M200/M600
Self:cCodRec		:= ''		//Código da receita do pagamento
Self:nVlBrut		:= 0		//Valor da receita bruta
Self:nVlConPer	:= 0		//Valor total da contribuição no período
Self:nVlConApu	:= 0		//Valor total da contribuição apuradao no período, antes dos ajustes e diferimento
Self:nAcreBC	:= 0	//Acréscimo de base de cálculo
Self:nReduBC	:= 0	//Redução de base de cálculo
Self:nBCAJus    := 0	//Base de cálculo ajustada
Self:cIndSoc		:= ''		//Indicador do tipo de sociedadecooperativa
Self:nExcES		:= 0		//Valor de exclusão especifica da sociedade
Self:nExcET		:= 0		//Valor de exclusão específica do tipo de sociedade
Self:nSocACDF		:= 0		//Valor da base de cálculo escriturada nos blocos A, C, D e F
Self:nBasSoc		:= 0		//Valor da base de cálculo após exclusões
Self:CNPJ			:= ''		//CNPJ da pessoa jurídica de direito público
Self:nTotVend		:= 0		//Valor total das vendas no período
Self:nNReceb		:= 0		//Valor total não recebido
Self:cNatCrd		:= ''		//Natureza do crédito diferido
Self:cPer			:= ''		//Período da apuração MM/AAAA
Self:nTotFol		:= 0		//Valor total da folha de salário
Self:nExcFol		:= 0		//Valor total das exclusões
Self:cCNatRec		:= ''		//Código da natureza da receita
Self:lAjuBase		:= .F.		//Indica se o bloco M terá registros e campos de ajuste de base de cálculo
Self:aRegM100		:= {}		
Self:aRegM105		:= {}
Self:aRegM110		:= {}
Self:aRegM115		:= {}
Self:aRegM200		:= {}
Self:aRegM205		:= {}
Self:aRegM210		:= {}
Self:aRegM215		:= {}
Self:aRegM220		:= {}
Self:aRegM225		:= {}
Self:aRegM211		:= {}
Self:aRegM230		:= {}
Self:aRegM300		:= {}
Self:aRegM350		:= {}
Self:aRegM400		:= {}
Self:aRegM410		:= {}
Self:aRegM500		:= {}		
Self:aRegM505		:= {}
Self:aRegM510		:= {}
Self:aRegM515		:= {}
Self:aRegM600		:= {}
Self:aRegM605		:= {}
Self:aRegM610		:= {}
Self:aRegM611		:= {}
Self:aRegM615		:= {}
Self:aRegM620		:= {}
Self:aRegM625		:= {}
Self:aRegM630		:= {}
Self:aRegM700		:= {}
Self:aRegM800		:= {}
Self:aRegM810		:= {}
Self:aRegM001		:= {}
Self:aRegM990		:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM100()
@description Método que irá chamar AddM100500 para adiconar informações de
			   crédito de PIS no registro M100	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM100() Class EFDCBLOCOM

Self:AddM100500('M100',Self:aRegM100)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM500()
@description Método que irá chamar AddM100500 para adiconar informações de
			   crédito de COFINS no registro M500	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM500() Class EFDCBLOCOM

Self:AddM100500('M500',Self:aRegM500)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM100500()
@description Método para gravação das informações dos registros M100 e M500.
			   Ambos registros possuem mesma estrutura, por este motivo a utilização
			   do mesmo método.
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Registro M100 ou M500 para ter as informações incluídas	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM100500(cReg, aReg) Class EFDCBLOCOM

Local nPos			:= 0

nPos := aScan (aReg,{|aX|SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ; 
							   aX[3]==Self:cCodCrd .AND. ;
								Iif(Self:lPauta,cvaltochar(aX[8][1])==cvaltochar(Self:nAlqR),cvaltochar(aX[6][1])==cvaltochar(Self:nAlq))})		
IF nPos == 0			
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cGrupoReg)			//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)			   	   	//01 - REG
	aAdd (aReg[nPos], Self:cCodCrd)			//02 - COD_CRED
	aAdd (aReg[nPos], Self:cOriCrd)			//03 - IND_CRED_ORI 			
	aAdd (aReg[nPos], Self:nBasCalc)  		//04 - VL_BC_PIS
	aAdd (aReg[nPos], {Self:nAlq,4})			//05 - ALIQ_PIS
	aAdd (aReg[nPos], Self:nBasCalcQ)		//06 - QUANT_BC_PIS
	aAdd (aReg[nPos], {Self:nAlqR,4})			//07 - ALIQ_PIS_QUANT			
	aAdd (aReg[nPos], Self:nCrdApur)		//08 - VL_CRED
	aAdd (aReg[nPos], Self:nAjuAcr)			//09 - VL_AJUST_ACRED
	aAdd (aReg[nPos], Self:nAjuRed)			//10 - VL_AJUS_REDUC		
	aAdd (aReg[nPos], Self:nCrdDif)			//11 - VL_CRED_DIF
	aAdd (aReg[nPos], Self:nCrdDisp)		//12 - VL_CRED_DISP		
	aAdd (aReg[nPos], Self:cIndUti)			//13 - IND_DESC_CRED
	aAdd (aReg[nPos], Self:nCrdDesc)		//14 - VL_CRED_DESC					
	aAdd (aReg[nPos], Self:nSldCrd)			//15 - SLD_CRED	
Else
	Self:cGrupoReg	:= aReg[nPos][1]
	aReg[nPos][7]		+= Self:nBasCalcQ			//06 - QUANT_BC_PIS			   			   		
	aReg[nPos][5]		+= Self:nBasCalc			//04 - VL_BC_PIS			   		
	aReg[nPos][9]		+=Self:nCrdApur			//08 - VL_CRED	
	aReg[nPos][10]		+=Self:nAjuAcr		//09 - VL_AJUST_ACRED	
	aReg[nPos][11]		+=Self:nAjuRed		//10 - VL_AJUS_REDUC
	aReg[nPos][12]		+=Self:nCrdDif		//11 - VL_CRED_DIF
	aReg[nPos][13]	+= Self:nCrdDisp			//12 - VL_CRED_DISP
	aReg[nPos][14]	:= Self:cIndUti			//13 - IND_DESC_CRED
   	aReg[nPos][15]	+= Self:nCrdDesc			//14 - VL_CRED_DESC	
	aReg[nPos][16]	+= Self:nSldCrd			//15 - SLD_CRED  			
EndIf		

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM105()
@description Método que irá chamar AddM105505 para adiconar informações de
			   crédito de PIS no registro M105	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM105() Class EFDCBLOCOM

Self:AddM105505('M105',Self:aRegM105)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM505()
@description Método que irá chamar AddM105505 para adiconar informações de
			   crédito de COFINS no registro M505	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM505() Class EFDCBLOCOM

Self:AddM105505('M505',Self:aRegM505)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM105505()
@description Método para gravação das informações dos registros M105 e M505.
			   Ambos registros possuem mesma estrutura, por este motivo a utilização
			   do mesmo método. Estes registros são filhos dos registros M100/M500
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Registro M105 ou M505 para ter as informações incluídas	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM105505(cReg, aReg) Class EFDCBLOCOM

Local nPos	:= 0

nPos := aScan (aReg,{|aX|SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ;  
							   aX[3]== Self:cCodBcc .AND.  ;
							   aX[4]== Self:cCST  })		
If nPos ==0	
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)	
	aAdd (aReg[nPos], Self:cGrupoReg)				//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)			   	 		//01 - REG
	aAdd (aReg[nPos], Self:cCodBcc)		 		//02 - NAT_BC_CRED
	aAdd (aReg[nPos], Self:cCST)				//03 - CST_PIS
	aAdd (aReg[nPos], Self:nBasACDF)			//04 - VL_BC_PIS_TOT
	aAdd (aReg[nPos], Self:nBasCum)				//05 - VL_BC_PIS_CUM
	aAdd (aReg[nPos], Self:nBasNCum)			//06 - VL_BC_PIS_NC	
	aAdd (aReg[nPos], Self:nBasCalc)			//07 - VL_BC_PIS	
	aAdd (aReg[nPos], {Self:nBasQACDF,3})			//08 - QUANT_BC_PIS_TOT
	aAdd (aReg[nPos], {Self:nBasCalcQ,3})			//09 - QUANT_BC_PIS
	aAdd (aReg[nPos],Self:cDescr)			   	//10 - DESC_CRED
Else
	Self:cGrupoReg	:= aReg[nPos][1]
	aReg[nPos][5]+=Self:nBasACDF				//04 - VL_BC_PIS_TOT
	aReg[nPos][6]+=Self:nBasCum    				//05 - VL_BC_PIS_CUM
	aReg[nPos][7]+=Self:nBasNCum 				//06 - VL_BC_PIS_NC
	aReg[nPos][8]+= Self:nBasCalc				//07 - VL_BC_PIS
	aReg[nPos][9][1]+= Self:nBasQACDF    			//08 - QUANT_BC_PIS_TOT
	aReg[nPos][10][1]+= Self:nBasCalcQ				//09 - QUANT_BC_PIS
EndIF	


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM110()
@description Método que irá chamar AddAjuste para adiconar informações de
			   crédito de PIS no registro M110	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM110() Class EFDCBLOCOM

Self:AddAjuste('M110',Self:aRegM110)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM510()
@description Método que irá chamar AddAjuste para adiconar informações de
			   crédito de COFINS no registro M510	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM510() Class EFDCBLOCOM

Self:AddAjuste('M510',Self:aRegM510)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM220()
@description Método que irá chamar AddAjuste para adiconar informações de
			   DÉBITO de PIS no registro M220	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM220() Class EFDCBLOCOM

Self:AddAjuste('M220',Self:aRegM220)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM620()
@description Método que irá chamar AddAjuste para adiconar informações de
			   DÉBITO de COFINS no registro M620	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM620() Class EFDCBLOCOM

Self:AddAjuste('M620',Self:aRegM620)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddAjuste()
@description Método para gravação das informações de ajustes de créditos
			   M110 e M510, e também para os ajustes de débitos M220 e M620.
			   Os quatro registros possuem a mesma estrutura, desta forma 
			   serão tratados no mesmo método.
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Registro M110, M510, M220 ou M620	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddAjuste(cReg, aReg) Class EFDCBLOCOM

Local nPos	:= 0

nPos := aScan (aReg,{|aX|SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ;     
								aX[3]==Self:cIndAju .AND. ;
							   aX[5]==Self:cCodAju  .AND. ;
							   aX[6]==Self:cNumDoc  .AND. ;
							   aX[7]==Self:cDescr 	.AND. ;
							   aX[8]==Self:cDtOper })
If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)			   		
	aAdd (aReg[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)			   	//01 - REG
	aAdd (aReg[nPos], Self:cIndAju)		//02 - IND_AJ
	aAdd (aReg[nPos], Self:nValAju)		//03 - VL_AJ
	aAdd (aReg[nPos], Self:cCodAju)		//04 - COD_AJ
	aAdd (aReg[nPos], Self:cNumDoc)		//05 - NUM_DOC           
	aAdd (aReg[nPos], Self:cDescr) 		//06 - DESCR_AJ 	
	aAdd (aReg[nPos], Self:cDtOper) 	//07 - DT_REF
Else
	Self:cGrupoReg	:= aReg[nPos][1]
	aReg[nPos][4] += Self:nValAju		//03 - VL_AJ	
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM115()
@description Método que irá chamar AddDetAjus para adiconar informações de
			   detalhamento do ajuste de crédito de PIS	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM115() Class EFDCBLOCOM

Self:AddDetAjus('M115',Self:aRegM115)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM515()
@description Método que irá chamar AddDetAjus para adiconar informações de
			   detalhamento do ajuste de crédito de COFINS	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM515() Class EFDCBLOCOM

Self:AddDetAjus('M515',Self:aRegM515)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM225()
@description Método que irá chamar AddDetAjus para adiconar informações de
			   detalhamento do ajuste de DÉBITO de PIS	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM225() Class EFDCBLOCOM

Self:AddDetAjus('M225',Self:aRegM225)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM625()
@description Método que irá chamar AddDetAjus para adiconar informações de
			   detalhamento do ajuste de DÉBITO de COFINS	
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM625() Class EFDCBLOCOM

Self:AddDetAjus('M625',Self:aRegM625)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddDetAjus()
@description Método para gravação das informações dos detalhamentos de ajustes de créditos
			   M115 e M515, e também para os ajustes de débitos M225 e M625.
			   Os quatro registros possuem a mesma estrutura, desta forma 
			   serão tratados no mesmo método.
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Registro M115, M5105, M225 ou M625	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddDetAjus(cReg, aReg) Class EFDCBLOCOM

Local nPos	:= 0
	
nPos := aScan(aReg, {|x| SubStr(x[1], 1, Len(Self:cRelac)) == Self:cRelac .And.;
 						 x[4] == Self:cCST    .And.;
						 cValToChar(x[6][1]) == cValToChar(Self:nAlq) .And.;
						 x[8] == Self:cDescr  .And.;
						 x[9] == Self:cCodCtb .And.;
						 x[10] == Self:cInfComp})

If nPos == 0

	Self:cGrupoReg := FSA008SReg(@Self:aNumeracao,Self:cRelac,cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)	
	aAdd (aReg[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)					//01 - REG
	aAdd (aReg[nPos], Self:nValAju)			//02 - DET_VALOR_AJ
	aAdd (aReg[nPos],	Self:cCST)	   		//03 - CST_PIS
	aAdd (aReg[nPos], {Self:nBasCalc,3})	//04 - DET_BC_CRED                                     		
	aAdd (aReg[nPos], {Self:nAlq,4})		//05 - DET_ALIQ           
	aAdd (aReg[nPos], Self:cDtOper)			//06 - DT_OPER_AJ           
	aAdd (aReg[nPos], Self:cDescr)			//07 - DESC_AJ          
	aAdd (aReg[nPos], Self:cCodCtb)			//08 - COD_CTA          
	aAdd (aReg[nPos], Self:cInfComp)		//09 - INFO_COMPL

Else

	aReg[nPos, 3]    += Self:nValAju           //02 - DET_VALOR_AJ
	aReg[nPos, 5][1] += Self:nBasCalc       //04 - DET_BC_CRED

EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM200()
@description Método que irá chamar método AddM200600 para geração do 
			   registro M200.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM200() Class EFDCBLOCOM

Self:AddM200600('M200',Self:aRegM200)

Return (Self:aRegM200)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM600()
@description Método que irá chamar método AddM200600 para geração do 
			   registro M600.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM600() Class EFDCBLOCOM

Self:AddM200600('M600',Self:aRegM600)

Return (Self:aRegM600)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM200600()
@description Método para adicionar informações nos registros M200 e M600
			   com o resumo da apuração e valores a recolher. Somente existirão
			   um registro por arquivo.
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M200 ou M600	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM200600(cReg, aReg) Class EFDCBLOCOM

Local 				:= 0
aReg				:= {}

Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
aAdd(aReg, {})
nPos := Len(aReg)	
aAdd (aReg[nPos], Self:cGrupoReg)			//RELACIONAMENTO
aAdd (aReg[nPos], cReg)					//01 - REG
aAdd (aReg[nPos], Self:nVlNCum)			//02 - VL_TOT_CONT_NC_PER
aAdd (aReg[nPos],	 Self:nCrduTiP)		//03 -VL_TOT_CRED_DESC
aAdd (aReg[nPos], Self:nCrduTiA)		//04 - VL_TOT_CRED_DESC_ANT                                     		
aAdd (aReg[nPos], Self:nTotConN)		//05 - VL_TOT_CONT_NC_DEV           
aAdd (aReg[nPos], Self:nVlRetN)			//06 - VL_RET_NC           
aAdd (aReg[nPos], Self:nOutNCum)		//07 - VL_OUT_DED_NC          
aAdd (aReg[nPos], Self:nNCumRec)		//08 - VL_CONT_NC_REC          
aAdd (aReg[nPos], Self:nVlCum)			//09 - VL_TOT_CONT_CUM_PER
aAdd (aReg[nPos], Self:nVlRetC)			//10 - VL_RET_CUM
aAdd (aReg[nPos], Self:nOutCum)			//11 - VL_OUT_DED_CUM
aAdd (aReg[nPos], Self:nCumRec)			//12 - VL_CONT_CUM_REC
aAdd (aReg[nPos], Self:nTotPag)			//13 - VL_TOT_CONT_REC

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM205()
@description Método que irá chamar método AddM205605 para geração do 
			   registro M205.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM205() Class EFDCBLOCOM

Self:AddM205605('M205',Self:aRegM205)

Return Self:aRegM205

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM605()
@description Método que irá chamar método AddM205605 para geração do 
			   registro M605.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM605() Class EFDCBLOCOM

Self:AddM205605('M605',Self:aRegM605)

Return Self:aRegM605


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM205605()
@description Método para adicionar informações nos registros M205 e M605
			   com informações do valor a recolher e o código da receita
			   vinculada
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M205 ou M605	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM205605(cReg, aReg) Class EFDCBLOCOM
Local nPos	:= 0

aReg				:= {}
Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
aAdd (aReg, {})
nPos :=	Len (aReg)
aAdd (aReg[nPos], Self:cGrupoReg)	//RELACIONAMENTO
aAdd (aReg[nPos], cReg)				//01 - REG
aAdd (aReg[nPos], Self:cNumCpo)		//02 - NUM_CAMPO
aAdd (aReg[nPos], Self:cCodRec) 	//03 - COD_REC
aAdd (aReg[nPos], Self:nTotPag)	  	//04 - VL_DEBITO

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM210()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M210.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM210() Class EFDCBLOCOM

Self:AddM210610('M210',Self:aRegM210)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM610()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M610.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM610() Class EFDCBLOCOM

Self:AddM210610('M610',Self:aRegM610)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM210610()
@description Método para adicionar informações nos registros M210 e M610
			   estes registros são filhos dos registros M200 e M600
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M210 ou M610	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM210610(cReg, aReg) Class EFDCBLOCOM

Local nPos			:= 0
local lPauta		:= Self:cCodCon $ '03/53'


If Self:lAjuBase
	//---------------------------------------------------------------------------------------------------------------------------------
	//Trecho de geração do bloco M a partir do momento que o layout foi alterado e novos campos foram adicionados no registro M210/M610
	//---------------------------------------------------------------------------------------------------------------------------------
	nPos := aScan (aReg, {|aX|	SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ;   
									aX[3]==Self:cCodCon .AND. ;
								Iif(lPauta ,cvaltochar(aX[11][1])==cvaltochar(Self:nAlqR),cvaltochar(aX[9][1])==cvaltochar(Self:nAlq))})
	If nPos == 0
		//Busca próxima chave para registro
		Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
		aAdd(aReg, {})
		nPos := Len(aReg)
		aAdd (aReg[nPos], Self:cGrupoReg)		//RELACIONAMENTO
		aAdd (aReg[nPos], cReg)			   	//01 - REG
		aAdd (aReg[nPos], Self:cCodCon)		//02 - COD_CONT
		aAdd (aReg[nPos], Self:nVlBrut)		//03 - VL_REC_BRT
		aAdd (aReg[nPos], Iif(lPauta,0,Self:nBasCalc))	//04 - VL_BC_CONT
		aAdd (aReg[nPos], Self:nAcreBC)		//05 - VL_AJUS_ACRES_BC
		aAdd (aReg[nPos], Self:nReduBC)		//06 - VL_AJUS_REDUC_BC
		aAdd (aReg[nPos], Self:nBCAJus)		//07 - VL_BC_CONT_AJUS	
		aAdd (aReg[nPos], {Iif(lPauta,'',Self:nAlq),4})		//08 - ALIQ_PIS
		aAdd (aReg[nPos], {Iif(lPauta,Self:nBasCalcQ,''),3})	//09 - QUANT_BC_PIS 
		aAdd (aReg[nPos], {Iif(lPauta,Self:nAlqR,''),4})		//10 - ALIQ_PIS_QUANT
		aAdd (aReg[nPos], Self:nVlConApu)	//11 - VL_CONT_APUR
		aAdd (aReg[nPos], Self:nAjuAcr)		//12 - VL_AJUS_ACRES	
		aAdd (aReg[nPos], Self:nAjuRed)		//13 - VL_AJUS_REDUC
		aAdd (aReg[nPos], Self:nConDif)		//14 - VL_CONT_DIFER
		aAdd (aReg[nPos], Self:nConDifA)	//15 - VL_CONT_DIFER_ANT
		aAdd (aReg[nPos], Self:nVlConPer)	//16 - VL_CONT_PER
	Else
		Self:cGrupoReg	:= aReg[nPos][1]
		aReg[nPos][4]+= Self:nVlBrut		//03 - VL_REC_BRT
		IF lPauta
			aReg[nPos][10][1]+= Self:nBasCalcQ	//09 - QUANT_BC_PIS
		Else
			aReg[nPos][5]+= Self:nBasCalc	//04 - VL_BC_CONT	
		EndIF
		aReg[nPos][06]+= Self:nAcreBC	//05 - VL_AJUS_ACRES_BC
		aReg[nPos][07]+= Self:nReduBC	//06 - VL_AJUS_REDUC_BC
		aReg[nPos][08]+= Self:nBCAJus	//07 - VL_BC_CONT_AJUS
		aReg[nPos][12]+= Self:nVlConApu	//11 - VL_CONT_APUR
		aReg[nPos][13]+= Self:nAjuAcr	//12 - VL_AJUS_ACRES
		aReg[nPos][14]+= Self:nAjuRed	//13 - VL_AJUS_REDUC
		aReg[nPos][15]+= Self:nConDif	//14 - VL_CONT_DIFER
		aReg[nPos][16]+= Self:nConDifA	//15 - VL_CONT_DIFER_ANT
		aReg[nPos][17]+= Self:nVlConPer	//16 - VL_CONT_PER

	EndIF

Else
	//---------------------------------------------------------------------------------------------------------
	//Trecho de geração do bloco M quando ainda não existiam os campos referente aos ajustes da base de cálculo
	//---------------------------------------------------------------------------------------------------------
	nPos := aScan (aReg, {|aX|	SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ;   
									aX[3]==Self:cCodCon .AND. ;
								Iif(lPauta ,cvaltochar(aX[8][1])==cvaltochar(Self:nAlqR),cvaltochar(aX[6][1])==cvaltochar(Self:nAlq))})
	If nPos == 0
		//Busca próxima chave para registro
		Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
		aAdd(aReg, {})
		nPos := Len(aReg)
		aAdd (aReg[nPos], Self:cGrupoReg)		//RELACIONAMENTO
		aAdd (aReg[nPos], cReg)			   	//01 - REG
		aAdd (aReg[nPos], Self:cCodCon)		//02 - COD_CONT
		aAdd (aReg[nPos], Self:nVlBrut)		//03 - VL_REC_BRT
		aAdd (aReg[nPos], Iif(lPauta,0,Self:nBasCalc))	//04 - VL_BC_CONT
		aAdd (aReg[nPos], {Iif(lPauta,'',Self:nAlq),4})		//05 - ALIQ_PIS
		aAdd (aReg[nPos], {Iif(lPauta,Self:nBasCalcQ,''),3})	//06 - QUANT_BC_PIS 
		aAdd (aReg[nPos], {Iif(lPauta,Self:nAlqR,''),4})		//07 - ALIQ_PIS_QUANT
		aAdd (aReg[nPos], Self:nVlConApu)	//08 - VL_CONT_APUR
		aAdd (aReg[nPos], Self:nAjuAcr)		//09 - VL_AJUS_ACRES	
		aAdd (aReg[nPos], Self:nAjuRed)		//10 - VL_AJUS_REDUC
		aAdd (aReg[nPos], Self:nConDif)		//11 - VL_CONT_DIFER
		aAdd (aReg[nPos], Self:nConDifA)	//12 - VL_CONT_DIFER_ANT
		aAdd (aReg[nPos], Self:nVlConPer)	//13 - VL_CONT_PER
	Else
		Self:cGrupoReg	:= aReg[nPos][1]
		aReg[nPos][4]+= Self:nVlBrut		//03 - VL_ITEM
		IF lPauta
			aReg[nPos][7][1]+= Self:nBasCalcQ	//06 - QUANT_BC_PIS
		Else
			aReg[nPos][5]+= Self:nBasCalc	//04 - VL_BC_CONT	
		EndIF
		aReg[nPos][9]+= Self:nVlConApu	//08 - VL_CONT_APUR
		aReg[nPos][10]+= Self:nAjuAcr	//09 - VL_AJUS_ACRES
		aReg[nPos][11]+= Self:nAjuRed	//10 - VL_AJUS_REDUC
		aReg[nPos][12]+= Self:nConDif	//11 - VL_CONT_DIFER
		aReg[nPos][13]+= Self:nConDifA	//12 - VL_CONT_DIFER_ANT
		aReg[nPos][14]+= Self:nVlConPer	//13 - VL_CONT_PER

	EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM215()
@description Método que irá chamar método AddM215615 para geração do 
			   registro M215.
@author Erick G. Dias
@since 01/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
METHOD AddM215() Class EFDCBLOCOM

Self:AddM215615('M215',Self:aRegM215)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM615()
@description Método que irá chamar método AddM215615 para geração do 
			   registro M615.
@author Erick G. Dias
@since 01/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
METHOD AddM615() Class EFDCBLOCOM

Self:AddM215615('M615',Self:aRegM615)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM215615()
@description Método que fará geração dos registros M215 e M615
             referentes aos ajutes de base de cálculo de PIS e COFINS
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M210 ou M610	
@author Erick G. Dias
@since 02/11/2018
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM215615(cReg, aReg) Class EFDCBLOCOM

Local nPos			:= 0

nPos :=  aScan (aReg, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
								aX[3]== Self:cIndAju .AND. ;
								aX[5]== Self:cCodAju .AND. ;
								aX[6]== Self:cNumDoc .AND. ;
								aX[8]== Self:cDtOper .AND. ;
								aX[9]== Self:cCodCtb .AND. ;
								aX[10]== Self:cNPJ .AND. ;
								aX[11] == Self:cInfComp })
//DSERFIS1-15920 - Retirado aX[7]== Self:cDescr .AND. ; da chava de quebra.								


If nPos == 0
	//Busca próxima chave para registro
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)				//01 - REG
	aAdd (aReg[nPos], Self:cIndAju)		//02 - IND_AJ_BC
	aAdd (aReg[nPos], Self:nValAju)		//03 - VL_AJ_BC
	aAdd (aReg[nPos], Self:cCodAju)		//04 - COD_AJ_BC
	aAdd (aReg[nPos], Self:cNumDoc)		//05 - NUM_DOC
	aAdd (aReg[nPos], Self:cDescr)		//06 - DESCR_AJ_BC
	aAdd (aReg[nPos], Self:cDtOper)		//07 - DT_REF
	aAdd (aReg[nPos], Self:cCodCtb)		//08 - COD_CTA
	aAdd (aReg[nPos], Self:cNPJ)		//09 - CNPJ
	aAdd (aReg[nPos], Self:cInfComp)	//10 - INFO_COMPL	
Else
	Self:cGrupoReg	:= aReg[nPos][1]
	aReg[nPos][4]+= Self:nValAju		//03 - VL_AJ_BC	
EndIF			

/*
setIndAju
setValAju
setCodAju
setNumDoc
setDescr
setDtOper
setCodCtb
setCNPJ
setInfComp
*/

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM211()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M610.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM211() Class EFDCBLOCOM

Self:AddM211611('M211',Self:aRegM211)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM611()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M610.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM611() Class EFDCBLOCOM

Self:AddM211611('M611',Self:aRegM611)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM211611()
@description Método para adicionar informações nos registros M211 e M611
			   estes registros são filhos dos registros M210 e M610.
			   Estes registros posseum infotrmações das exclusões da Sociedade
			   cooperativa. Somente poderá ter um registro M211/M611 por arquivo
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M211 ou M611	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM211611(cReg, aReg) Class EFDCBLOCOM

Local nBaseCont := 0

If Self:nSocACDF > 0
	nBaseCont := (Self:nSocACDF - (Self:nExcES + Self:nExcET))
EndIf 

Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac,cReg)
aAdd(aReg, {})
nPos := Len(aReg)
aAdd (aReg[nPos], Self:cGrupoReg)	//RELACIONAMENTO
aAdd (aReg[nPos], cReg)				//01 - REG
aAdd (aReg[nPos],Self:cIndSoc )		//02 - IND_TIP_COOP
aAdd (aReg[nPos],Self:nSocACDF)		//03 - VL_BC_CONT_ANT_EXC_COOP            				
aAdd (aReg[nPos],Self:nExcES )		//04 - VL_EXC_COOP_GER		
aAdd (aReg[nPos],Self:nExcET )		//05 - VL_EXC_ESP_COOP
aAdd (aReg[nPos],nBaseCont)			//06 - VL_BC_CONT

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM230()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M210.
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM230() Class EFDCBLOCOM

Self:AddM230630('M230',Self:aRegM230)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM630()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M210.
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM630() Class EFDCBLOCOM

Self:AddM230630('M630',Self:aRegM630)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM230630()
@description Método para adicionar as informações de diferimento
			   que ocorreram no período. Os valores demosntrados aqui
			   serão postergados, até o momento do recebimnto por parte
			   do cliente de direito público. Os registros gerados são 
			   M230 e M630
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M230 ou M630	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM230630(cReg, aReg) Class EFDCBLOCOM

Local nPos	:= 0

nPos :=  aScan (aReg, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac  	.AND. ;   
								aX[3]== Self:CNPJ .AND. ;
								aX[8] == Self:cCodCrd })
If nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)				   		
	aAdd (aReg[nPos], Self:cGrupoReg)			//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)			   	  	//01 - REG
	aAdd (aReg[nPos], Self:CNPJ)			//02 - CNPJ
	aAdd (aReg[nPos], Self:nTotVend)		//03 - VL_VENDA
	aAdd (aReg[nPos], Self:nNReceb)			//04 - VL_NAO_RECEB
	aAdd (aReg[nPos], Self:nConDif)			//05 - VL_CONT_DIF
	aAdd (aReg[nPos], Self:nCrdDif)			//06 - VL_CRED_DIF
	aAdd (aReg[nPos], Self:cCodCrd)			//07 - COD_CRED	
Else
	aReg[nPos][4] += Self:nTotVend			//03 - VL_VENDA
	aReg[nPos][5] += Self:nNReceb			//04 - VL_NAO_RECEB
	aReg[nPos][6] += Self:nConDif			//05 - VL_CONT_DIF
	aReg[nPos][7] += Self:nCrdDif			//06 - VL_CRED_DIF
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddM300()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M210.
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM300() Class EFDCBLOCOM

Self:AddM300700('M300',Self:aRegM300)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM700()
@description Método que irá chamar método AddM210610 para geração do 
			   registro M210.
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM700() Class EFDCBLOCOM

Self:AddM300700('M700',Self:aRegM700)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM300700()
@description Método para demonstrar os valores dferidos em períodos anteriores,
			   onde no período houve o recebimento por parte do cliente de direito
			   públco, devendo ser adicionado o valor para que seja tributado no
			   período. Os registros gerados serão os M300 e M700.
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M300 ou M700	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM300700(cReg, aReg) Class EFDCBLOCOM

Local nPos	:= 0

nPos :=  aScan (aReg, {|aX|	aX[1]== Self:cRelac 	.AND. ;   
								aX[3]== Self:cCodCon .AND.;
								aX[9] == Self:cDtOper  .AND. ;
								aX[5] == Self:cNatCrd .And. ;
								aX[8] == Self:cPer})	

If nPos == 0 
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cGrupoReg)			//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)			   		//01 - REG
	aAdd (aReg[nPos],Self:cCodCon)			//02 - COD. CONTRIBUICAO
	aAdd (aReg[nPos],Self:nConDifA)			//03 - VL_CONT_APUR_DIFER
	aAdd (aReg[nPos],Self:cNatCrd)	       //04 - NAT. CREDITO DIFERIDO
	aAdd (aReg[nPos],Self:nCrdDesc)	   		//05 - VALRO CRED. DESCONTAR
	aAdd (aReg[nPos],Self:nVlConPer)		//06 - VALOR CONTRIBUICAO A RECOLHER
	aAdd (aReg[nPos],Self:cPer)	    		//07 - PERIODO DA APURACAO
	aAdd (aReg[nPos],Self:cDtOper)		    //08 - DATA RECEBIMENTO
Else
	aReg[nPos][4] += Self:nConDifA		 	//03 - VL_CONT_APUR_DIFER		
	aReg[nPos][6] += Self:nCrdDesc			//05 - VALRO CRED. DESCONTAR
	aReg[nPos][7] += Self:nVlConPer			//06 - VALOR CONTRIBUICAO A RECOLHER
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM350()
@description Método que inclui inforemaçõs no registro M350, referente ao		
			   PIS sobre a Folha de salário Este registro não possui relação
			   com nenhum outro registro da EFD Contribuições.	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM350() Class EFDCBLOCOM

Local nPos	:= 0
//Somente poderá ter 1 registro M350 por arquivo. Entã verifico se já existe registro,
//se já existir apenas acumulo.
If len(Self:aRegM350) < 1
	//Busca próxima chave para registro
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac,'M350')
	aAdd(Self:aRegM350, {})
	nPos := Len(Self:aRegM350)
	aAdd (Self:aRegM350[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aRegM350[nPos], 'M350')			   	//01 - REG	
	aAdd (Self:aRegM350[nPos], Self:nTotFol)		//02 - VL_TOT_FOL		   		
	aAdd (Self:aRegM350[nPos], Self:nExcFol)		//03 - VL_EXC_BC		   		
	aAdd (Self:aRegM350[nPos], Self:nBasCalc)		//04 - VL_TOT_BC		   		
	aAdd (Self:aRegM350[nPos], Self:nAlq)			//05 - ALIQ_PIS_FOL		   		
	aAdd (Self:aRegM350[nPos], Self:nTotPag)		//06 - VL_TOT_CONT_FOL
Else
	Self:aRegM350[1][3] += Self:nTotFol			//02 - VL_TOT_FOL
	Self:aRegM350[1][4] += Self:nExcFol			//03 - VL_EXC_BC
	Self:aRegM350[1][5] += Self:nBasCalc			//04 - VL_TOT_BC
	Self:aRegM350[1][7] += Self:nTotPag			//06 - VL_TOT_CONT_FOL  					
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM400()
@description Método que irá chamar método AddM400800 para geração do 
			   registro M400.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM400() Class EFDCBLOCOM

Self:AddM400800('M400',Self:aRegM400)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM800()
@description Método que irá chamar método AddM400800 para geração do 
			   registro M400.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM800() Class EFDCBLOCOM

Self:AddM400800('M800',Self:aRegM800)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM400800()
@description Este método gera os registros M400 e M800. Estes registros 
			   irão demonstrar as receitas não tributadas no período.
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M400 ou M800	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM400800(cReg, aReg) Class EFDCBLOCOM

Local nPos	:= 0

nPos := aScan (aReg, {|aX|	SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ;  
							  aX[3]==Self:cCST .AND. aX[5]==Self:cCodCtb  })

If nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)			   	   	//01 - REG
	aAdd (aReg[nPos], Self:cCST)			//02 - CST_PIS  	   	
	aAdd (aReg[nPos], Self:nVlBrut)		  	//03 - VL_TOT_REC   	   	
	aAdd (aReg[nPos], Self:cCodCtb)			//04 - COD_CTA
	aAdd (aReg[nPos], Self:cDescr )			//05 - DESC_COMPL   
	
Else
	Self:cGrupoReg	:= aReg[nPos][1]
	aReg[nPos][4]+= Self:nVlBrut  			//03 - VL_TOT_REC 
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM410()
@description Método que irá chamar método AddM400800 para geração do 
			   registro M410.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM410() Class EFDCBLOCOM

Self:AddM410810('M410',Self:aRegM410)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM810()
@description Método que irá chamar método AddM400800 para geração do 
			   registro M810.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM810() Class EFDCBLOCOM

Self:AddM410810('M810',Self:aRegM810)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM410810()
@description Este método gera os registros M410 e M810. Estes são registros
			   filhos dos registros M400 e M800, demonstrarão o detalhamento
			   das receitas não tributadas.
@param	cReg,String,Registro a ser adicionado
@param aReg,Array,Informações dos Registros M410 ou M810	
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM410810(cReg, aReg) Class EFDCBLOCOM

Local nPos	:= 0

nPos := aScan (aReg, {|aX|	SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ;  
						 	  aX[3]==Self:cCNatRec .AND. aX[5]==Self:cCodCtb})
If nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd (aReg, {})
	nPos := Len(aReg)	
	aAdd (aReg[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)			   	   	//01 - REG
	aAdd (aReg[nPos], Self:cCNatRec)		//02 - NAT_REC
	aAdd (aReg[nPos], Self:nVlBrut)		  	//03 - VL_REC
	aAdd (aReg[nPos], Self:cCodCtb) 		//04 - COD_CTA   	   	
	aAdd (aReg[nPos], Self:cDescr)			//05 - DESC_COMPL  
Else
	aReg[nPos][4]+= Self:nVlBrut   			//03 - VL_TOT_REC   	   	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM001(cIndMovto) Class EFDCBLOCOM

Self:AbreBloco('M001',@Self:aRegM001,cIndMovto)

Return Self:aRegM001

//-------------------------------------------------------------------
/*/{Protheus.doc} AddM990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddM990(nQtde) Class EFDCBLOCOM

Self:FechaBloco('M990',@Self:aRegM990, nQtde) 

Return Self:aRegM990
 