#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCO0();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCO0()
@description Classe que irá realizar gravação dos registros do bloco zero.
			   Este bloco demonstra informações cadastrais que serão utilizadas pelos
			   demais blocos da EFD. Esta classe não herda nenhuma propiredade		   

@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCO0 FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS DA CLASSE
//-----------------------------------------------------

Data dDtIni		as Date		READONLY		//Data Inicial
Data dDtFin		as Date		READONLY		//Data Final
Data cNome			as String		READONLY		//Nome
Data cCpf			as String		READONLY		//CPF
Data cCnpj			as String		READONLY		//CNPJ
Data cUF			as String		READONLY		//UF
Data cCodMun		as String		READONLY		//Código município
Data cSuframa		as String		READONLY		//Código Suframa
Data cDescr		as String		READONLY		//Descrição
Data cInfComp		as String		READONLY		//INformação Complementar
Data cEnder		as String		READONLY		//Endereço
Data cNumEnd		as String		READONLY		//Númedo de endereço
Data cCompEnd		as String		READONLY		//Complemento endereço
Data cBairro		as String		READONLY		//Bairro
Data cIe			as String		READONLY		//INscrição Estadual
Data cIm			as String		READONLY		//INscrição Municipal
Data cUnMedida	as String		READONLY		//Unidade de medida
Data cCodAnt		as String		READONLY		//Código anterior

//0000
Data cVersao		as String		READONLY		//Código da versão do layout
Data cTpEscri		as String		READONLY		//Tipo de escrituração
Data cSitEsp		as String		READONLY		//Indicador de situação especial
Data cRecibo		as String		READONLY		//Número recibo entrega anterior
Data cNAtPj		as String		READONLY		//Indicador de Natureza da PJ
Data cAtivid		as String		READONLY		//Indicador de Atividade

//0035
Data cIdScp		as String		READONLY		//Identificação de SCP

//0100
Data cCrc			as String		READONLY		//CRC contabilista
Data cCep			as String		READONLY		//CEP contabilista
Data cTel			as String		READONLY		//Telefone
Data cFax			as String		READONLY		//Fax
Data cEmail		as String		READONLY		//Email

//0110
Data cIndTrib		as String		READONLY		//Código de incidência Tributária
Data cIndApro		as String		READONLY		//CIndicador do método de apropriação
Data cConApu		as String		READONLY		//Indicador do tipo de contribuição apurada
Data cCrtLp		as String		READONLY		//Critério lucro presumido

//0111
Data nRecMI		as Integer		READONLY		//Receita bruta mercado interno
Data nRecNT		as Integer		READONLY		//Receita bruta não tributada
Data nRecEx		as Integer		READONLY		//Receita bruta exportação
Data nRecCum		as Integer		READONLY		//Receita Bruta Cumulativa
Data nRecTot		as Integer		READONLY		//Receita Bruta total

//0120
Data cMes			as String		READONLY		//Mês da dispensa

//0140
Data cCodEstab	as String		READONLY		//Código do estabelecimento

//0145
Data cIncPer		as String		READONLY		//Código incidência tributária no período
Data nRecBruta	as Integer		READONLY		//Valor da receita bruta total no período
Data nRecAtiv		as Integer		READONLY		//Valor da receita atividades
Data nRecCPR		as Integer		READONLY		//Valor da receita sujeita CPR

//0150
Data cCodPart		as String		READONLY		//Código particiante
Data cCodPais		as String		READONLY		//Código do país

//0200
Data cCodItem		as String		READONLY		//Código do item/produto
Data cCodBarra	as String		READONLY		//Código de barra
Data cTpItem		as String		READONLY		//Tipo do item
Data cNcm			as String		READONLY		//NCM
Data cExIp			as String		READONLY		//EX_IPI
Data cGenero		as String		READONLY		//Código do gênero
Data cLst			as String		READONLY		//Código LST
Data nAqlIcms		as Integer		READONLY		//Alíquota interna do ICMS

//0206
Data cCodAnp		as String		READONLY		//Código de combustível ANP

//0208
Data cTabMarca	as String		READONLY		//Código tabela marca
Data cGrpMarca	as String		READONLY		//código do grupo marca

//0400
Data cNatOper		as String		READONLY		//Código dfe Natureza da operação

//0450
Data cCodInfo		as String		READONLY		//Código da informação complementar

//0500
Data cNatCtb		as String		READONLY		//Código da natureza da conta contábil
Data cTpCtb		as String		READONLY		//Tipo de conta
Data cNivel		as String		READONLY		//Nível
Data cCodCtb		as String		READONLY		//Código conta ctb
Data cCodCtbRfb	as String		READONLY		//Código da conta RFB

//0600
Data cCCusto	as String		READONLY		//Código do centro de custo

//0900
Data nRecA
Data nNRBA
Data nRecC
Data nNRBC
Data nRecD
Data nNRBD
Data nRecF
Data nNRBF
Data nRecI
Data nNRBI
Data nRec1
Data nNRB1

//-------------------------------------------------------------
//ARRAY DOS REGISTROS DO BLOCO 0
//-------------------------------------------------------------
Data aReg0000		as Array		HIDDEN		
Data aReg0001		as Array		HIDDEN
Data aReg0900		as Array		HIDDEN
Data aReg0990		as Array		HIDDEN
Data aReg0035		as Array		HIDDEN		
Data aReg0100		as Array		HIDDEN		
Data aReg0110		as Array		HIDDEN
Data aReg0111		as Array		HIDDEN
Data aReg0120		as Array		HIDDEN
Data aReg0140		as Array		HIDDEN
Data aReg0145		as Array		HIDDEN
Data aReg0150		as Array		HIDDEN
Data aReg0190		as Array		HIDDEN
Data aReg0200		as Array		HIDDEN
Data aReg0205		as Array		HIDDEN
Data aReg0206		as Array		HIDDEN
Data aReg0208		as Array		HIDDEN
Data aReg0400		as Array		HIDDEN
Data aReg0450		as Array		HIDDEN
Data aReg0500		as Array		HIDDEN
Data aReg0600		as Array		HIDDEN
	
//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()

Method Add0000()
Method Add0035()
Method Add0100()
Method Add0110()
Method Add0111()
Method Add0120()
Method Add0140()
Method Add0145()
Method Add0150()
Method Add0190()
Method Add0200()
Method Add0205()
Method Add0206()
Method Add0208()
Method Add0400()
Method Add0450()
Method Add0500()
Method Add0600()
Method Add0001()
Method Add0900()
Method Add0990()

Method setDtIni( dDtIni)
Method setDtFin( dDtFin) 
Method setNome( cNome)
Method setCpf( cCpf)
Method setCnpj( cCnpj)
Method setUF( cUF)
Method setCodMun( cCodMun)
Method setSuframa( cSuframa)
Method setDescr( cDescr)
Method setInfComp( cInfComp)
Method setEnder( cEnder) 
Method setNumEnd( cNumEnd)
Method setCompEnd( cCompEnd)
Method setBairro( cBairro) 
Method setIe( cIe)
Method setIm( cIm)
Method setUnMedid( cUnMedida)
Method setCodAnt( cCodAnt)
Method setVersao( cVersao)
Method setTpEscri( cTpEscri)
Method setSitEsp( cSitEsp)
Method setRecibo( cRecibo)
Method setNAtPj( cNAtPj) 
Method setAtivid( cAtivid)
Method setIdScp( cIdScp) 
Method setCrc( cCrc) 
Method setCep( cCep)
Method setTel( cTel) 
Method setFax( cFax)
Method setEmail( cEmail) 
Method setIndTrib( cIndTrib) 
Method setIndApro( cIndApro) 
Method setConApu( cConApu) 
Method setCrtLp( cCrtLp) 
Method setRecMI( nRecMI) 
Method setRecNT( nRecNT) 
Method setRecEx( nRecEx) 
Method setRecCum( nRecCum) 
Method setRecTot( nRecTot) 
Method setMes( cMes)
Method setCodEsta( cCodEstab)
Method setIncPer( cIncPer)
Method setRecBrut( nRecBruta)
Method setRecAtiv( nRecAtiv) 
Method setRecCPR( nRecCPR)
Method setCodPart( cCodPart)
Method setCodPais( cCodPais)
Method setCodItem( cCodItem) 
Method setCodBarr( cCodBarra)
Method setTpItem( cTpItem) 
Method setNcm( cNcm) 
Method setExIp( cExIp)
Method setGenero( cGenero)
Method setLst( cLst) 
Method setAqlIcms( nAqlIcms) 
Method setCodAnp( cCodAnp) 
Method setTabMarc( cTabMarca) 
Method setGrpMarc( cGrpMarca)
Method setNatOper( cNatOper) 
Method setCodInfo( cCodInfo)
Method setNatCtb( cNatCtb) 
Method setTpCtb( cTpCtb) 
Method setNivel( cNivel) 
Method setCodCtb( cCodCtb)
Method setCodRfb( cCodCtbRfb)
Method setCCusto( cCCusto) 

Method setRecA(value)
Method setNRBA(value)
Method setRecC(value)
Method setNRBC(value)
Method setRecD(value)
Method setNRBD(value)
Method setRecF(value)
Method setNRBF(value)
Method setRecI(value)
Method setNRBI(value)
Method setRec1(value)
Method setNRB1(value)

Method get0140()
Method get0145()
Method get0150()
Method get0400()
Method get0450()
Method get0500()
Method get0600()
Method get0120()
Method get0035()

Method get0190()
Method get0200()
Method get0205()
Method get0206()
Method get0208()
Method get0900()

Method cls0205()
Method cls0206()
Method cls0208()
Method cls0450()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCO0
Self:cJob	:= '00'
Self:Clear()
Self:ClsNotaEfd()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
Método que inicializa as proriedades da classe

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Clear() Class EFDCBLOCO0

Self:dDtIni		:= CTod("  /  /    ")		//Data Inicial
Self:dDtFin		:= CTod("  /  /    ")		//Data Final
Self:cNome			:= ''		//Nome
Self:cCpf			:= ''		//CPF
Self:cCnpj			:= ''		//CNPJ
Self:cUF			:= ''		//UF
Self:cCodMun		:= ''		//Código município
Self:cSuframa		:= ''		//Código Suframa
Self:cDescr		:= ''		//Descrição
Self:cInfComp		:= ''		//INformação Complementar
Self:cEnder		:= ''		//Endereço
Self:cNumEnd		:= ''		//Númedo de endereço
Self:cCompEnd		:= ''		//Complemento endereço
Self:cBairro		:= ''		//Bairro
Self:cIe			:= ''		//INscrição Estadual
Self:cIm			:= ''		//INscrição Municipal
Self:cUnMedida	:= ''		//Unidade de medida
Self:cCodAnt		:= ''		//Código anterior
Self:cVersao		:= ''		//Código da versão do layout
Self:cTpEscri		:= ''		//Tipo de escrituração
Self:cSitEsp		:= ''		//Indicador de situação especial
Self:cRecibo		:= ''		//Número recibo entrega anterior
Self:cNAtPj		:= ''		//Indicador de Natureza da PJ
Self:cAtivid		:= ''		//Indicador de Atividade
Self:cIdScp		:= ''		//Identificação de SCP
Self:cCrc			:= ''		//CRC contabilista
Self:cCep			:= ''		//CEP contabilista
Self:cTel			:= ''		//Telefone
Self:cFax			:= ''		//Fax
Self:cEmail		:= ''		//Email
Self:cIndTrib		:= ''		//Código de incidência Tributária
Self:cIndApro		:= ''		//CIndicador do método de apropriação
Self:cConApu		:= ''		//Indicador do tipo de contribuição apurada
Self:cCrtLp		:= ''		//Critério lucro presumido
Self:nRecMI		:= 0		//Receita bruta mercado interno
Self:nRecNT		:= 0		//Receita bruta não tributada
Self:nRecEx		:= 0		//Receita bruta exportação
Self:nRecCum		:= 0		//Receita Bruta Cumulativa
Self:nRecTot		:= 0		//Receita Bruta total
Self:cMes			:= ''		//Mês da dispensa
Self:cCodEstab	:= ''		//Código do estabelecimento
Self:cIncPer		:= ''		//Código incidência tributária no período
Self:nRecBruta	:= 0		//Valor da receita bruta total no período
Self:nRecAtiv		:= 0		//Valor da receita atividades
Self:nRecCPR		:= 0		//Valor da receita sujeita CPR
Self:cCodPart		:= ''		//Código particiante
Self:cCodPais		:= ''		//Código do país
Self:cCodItem		:= ''		//Código do item/produto
Self:cCodBarra	:= ''		//Código de barra
Self:cTpItem		:= ''		//Tipo do item
Self:cNcm			:= ''		//NCM
Self:cExIp			:= ''		//EX_IPI
Self:cGenero		:= ''		//Código do gênero
Self:cLst			:= ''		//Código LST
Self:nAqlIcms		:= 0		//Alíquota interna do ICMS
Self:cCodAnp		:= ''		//Código de combustível ANP
Self:cTabMarca	:= ''		//Código tabela marca
Self:cGrpMarca	:= ''		//código do grupo marca
Self:cNatOper		:= ''		//Código dfe Natureza da operação
Self:cCodInfo		:= ''		//Código da informação complementar
Self:cNatCtb		:= ''		//Código da natureza da conta contábil
Self:cTpCtb		:= ''		//Tipo de conta
Self:cNivel		:= ''		//Nível
Self:cCodCtb		:= ''		//Código conta ctb
Self:cCodCtbRfb	:= ''		//Código da conta RFB
Self:cCCusto		:= ''		//Código do centro de custo
Self:nRecA := 0
Self:nNRBA := 0
Self:nRecC := 0
Self:nNRBC := 0
Self:nRecD := 0
Self:nNRBD := 0
Self:nRecF := 0
Self:nNRBF := 0
Self:nRecI := 0
Self:nNRBI := 0
Self:nRec1 := 0
Self:nNRB1 := 0
Self:aReg0001		:= {}
Self:aReg0900		:= {}
Self:aReg0990		:= {}
Self:aReg0000		:= {}		
Self:aReg0035		:= {}		
Self:aReg0100		:= {}		
Self:aReg0110		:= {}
Self:aReg0111		:= {}
Self:aReg0120		:= {}
Self:aReg0140		:= {}
Self:aReg0145		:= {}
Self:aReg0150		:= {}
Self:aReg0190		:= {}
Self:aReg0200		:= {}
Self:aReg0205		:= {}
Self:aReg0206		:= {}
Self:aReg0208		:= {}
Self:aReg0400		:= {}
Self:aReg0450		:= {}
Self:aReg0500		:= {}
Self:aReg0600		:= {}

Return

Method setDtIni( dDtIni) Class EFDCBLOCO0
	Self:dDtIni := dDtIni
Return
Method setDtFin( dDtFin) Class EFDCBLOCO0
	Self:dDtFin := dDtFin
Return
Method setNome( cNome) Class EFDCBLOCO0
	Self:cNome := cNome
Return
Method setCpf( cCpf) Class EFDCBLOCO0
	Self:cCpf := cCpf
Return
Method setCnpj( cCnpj) Class EFDCBLOCO0
	Self:cCnpj := cCnpj
Return
Method setUF( cUF) Class EFDCBLOCO0
	Self:cUF := cUF
Return
Method setCodMun( cCodMun) Class EFDCBLOCO0
	Self:cCodMun := cCodMun
Return
Method setSuframa( cSuframa) Class EFDCBLOCO0
	Self:cSuframa := cSuframa
Return
Method setDescr( cDescr) Class EFDCBLOCO0
	Self:cDescr := cDescr
Return
Method setInfComp( cInfComp) Class EFDCBLOCO0
	Self:cInfComp := cInfComp
Return
Method setEnder( cEnder) Class EFDCBLOCO0
	Self:cEnder := cEnder
Return
Method setNumEnd( cNumEnd) Class EFDCBLOCO0
	Self:cNumEnd := cNumEnd
Return
Method setCompEnd( cCompEnd) Class EFDCBLOCO0
	Self:cCompEnd := cCompEnd
Return
Method setBairro( cBairro) Class EFDCBLOCO0
	Self:cBairro := cBairro
Return
Method setIe( cIe) Class EFDCBLOCO0
	Self:cIe := cIe
Return
Method setIm( cIm) Class EFDCBLOCO0
	Self:cIm := cIm
Return
Method setUnMedid( cUnMedida) Class EFDCBLOCO0
	Self:cUnMedida := cUnMedida
Return
Method setCodAnt( cCodAnt) Class EFDCBLOCO0
	Self:cCodAnt := cCodAnt
Return
Method setVersao( cVersao) Class EFDCBLOCO0
	Self:cVersao := cVersao
Return
Method setTpEscri( cTpEscri) Class EFDCBLOCO0
	Self:cTpEscri := cTpEscri
Return
Method setSitEsp( cSitEsp) Class EFDCBLOCO0
	Self:cSitEsp := cSitEsp
Return
Method setRecibo( cRecibo) Class EFDCBLOCO0
	Self:cRecibo := cRecibo
Return
Method setNAtPj( cNAtPj) Class EFDCBLOCO0
	Self:cNAtPj := cNAtPj
Return
Method setAtivid( cAtivid) Class EFDCBLOCO0
	Self:cAtivid := cAtivid
Return
Method setIdScp( cIdScp) Class EFDCBLOCO0
	Self:cIdScp := cIdScp
Return
Method setCrc( cCrc) Class EFDCBLOCO0
	Self:cCrc := cCrc
Return
Method setCep( cCep) Class EFDCBLOCO0
	Self:cCep := cCep
Return
Method setTel( cTel) Class EFDCBLOCO0
	Self:cTel := cTel
Return
Method setFax( cFax) Class EFDCBLOCO0
	Self:cFax := cFax
Return
Method setEmail( cEmail) Class EFDCBLOCO0
	Self:cEmail := cEmail
Return
Method setIndTrib( cIndTrib) Class EFDCBLOCO0
	Self:cIndTrib := cIndTrib
Return
Method setIndApro( cIndApro) Class EFDCBLOCO0
	Self:cIndApro := cIndApro
Return
Method setConApu( cConApu) Class EFDCBLOCO0
	Self:cConApu := cConApu
Return
Method setCrtLp( cCrtLp) Class EFDCBLOCO0
	Self:cCrtLp := cCrtLp
Return
Method setRecMI( nRecMI) Class EFDCBLOCO0
	Self:nRecMI := nRecMI
Return
Method setRecNT( nRecNT) Class EFDCBLOCO0
	Self:nRecNT := nRecNT
Return
Method setRecEx( nRecEx) Class EFDCBLOCO0
	Self:nRecEx := nRecEx
Return
Method setRecCum( nRecCum) Class EFDCBLOCO0
	Self:nRecCum := nRecCum
Return
Method setRecTot( nRecTot) Class EFDCBLOCO0
	Self:nRecTot := nRecTot
Return
Method setMes( cMes) Class EFDCBLOCO0
	Self:cMes := cMes
Return
Method setCodEsta( cCodEstab) Class EFDCBLOCO0
	Self:cCodEstab := cCodEstab
Return
Method setIncPer( cIncPer) Class EFDCBLOCO0
	Self:cIncPer := cIncPer
Return
Method setRecBrut( nRecBruta) Class EFDCBLOCO0
	Self:nRecBruta := nRecBruta
Return
Method setRecAtiv( nRecAtiv) Class EFDCBLOCO0
	Self:nRecAtiv := nRecAtiv
Return
Method setRecCPR( nRecCPR) Class EFDCBLOCO0
	Self:nRecCPR := nRecCPR
Return
Method setCodPart( cCodPart) Class EFDCBLOCO0
	Self:cCodPart := cCodPart
Return
Method setCodPais( cCodPais) Class EFDCBLOCO0
	Self:cCodPais := cCodPais
Return
Method setCodItem( cCodItem) Class EFDCBLOCO0
	Self:cCodItem := cCodItem
Return
Method setCodBarr( cCodBarra) Class EFDCBLOCO0
	Self:cCodBarra := cCodBarra
Return
Method setTpItem( cTpItem) Class EFDCBLOCO0
	Self:cTpItem := cTpItem
Return
Method setNcm( cNcm) Class EFDCBLOCO0
	Self:cNcm := cNcm
Return
Method setExIp( cExIp) Class EFDCBLOCO0
	Self:cExIp := cExIp
Return
Method setGenero( cGenero) Class EFDCBLOCO0
	Self:cGenero := cGenero
Return
Method setLst( cLst) Class EFDCBLOCO0
	Self:cLst := cLst
Return
Method setAqlIcms( nAqlIcms) Class EFDCBLOCO0
	Self:nAqlIcms := nAqlIcms
Return
Method setCodAnp( cCodAnp) Class EFDCBLOCO0
	Self:cCodAnp := cCodAnp
Return
Method setTabMarc( cTabMarca) Class EFDCBLOCO0
	Self:cTabMarca := cTabMarca
Return
Method setGrpMarc( cGrpMarca) Class EFDCBLOCO0
	Self:cGrpMarca := cGrpMarca
Return
Method setNatOper( cNatOper) Class EFDCBLOCO0
	Self:cNatOper := cNatOper
Return
Method setCodInfo( cCodInfo) Class EFDCBLOCO0
	Self:cCodInfo := cCodInfo
Return
Method setNatCtb( cNatCtb) Class EFDCBLOCO0
	Self:cNatCtb := cNatCtb
Return
Method setTpCtb( cTpCtb) Class EFDCBLOCO0
	Self:cTpCtb := cTpCtb
Return
Method setNivel( cNivel) Class EFDCBLOCO0
	Self:cNivel := cNivel
Return
Method setCodCtb( cCodCtb) Class EFDCBLOCO0
	Self:cCodCtb := cCodCtb
Return
Method setCodRfb( cCodCtbRfb) Class EFDCBLOCO0
	Self:cCodCtbRfb := cCodCtbRfb
Return
Method setCCusto( cCCusto) Class EFDCBLOCO0
	Self:cCCusto := cCCusto
Return

Method setRecA( value) Class EFDCBLOCO0
	Self:nRecA := value
Return

Method setNRBA( value) Class EFDCBLOCO0
	Self:nNRBA := value
Return

Method setRecC( value) Class EFDCBLOCO0
	Self:nRecC := value
Return

Method setNRBC( value) Class EFDCBLOCO0
	Self:nNRBC := value
Return

Method setRecD( value) Class EFDCBLOCO0
	Self:nRecD := value
Return

Method setNRBD( value) Class EFDCBLOCO0
	Self:nNRBD := value
Return

Method setRecF( value) Class EFDCBLOCO0
	Self:nRecF += value
Return

Method setNRBF( value) Class EFDCBLOCO0
	Self:nNRBF += value
Return

Method setRecI( value) Class EFDCBLOCO0
	Self:nRecI := value
Return

Method setNRBI( value) Class EFDCBLOCO0
	Self:nNRBI := value
Return

Method setRec1( value) Class EFDCBLOCO0
	Self:nRec1 := value
Return

Method setNRB1( value) Class EFDCBLOCO0
	Self:nNRB1 := value
Return

Method get0140( ) Class EFDCBLOCO0
Return	Self:aReg0140

Method get0145( ) Class EFDCBLOCO0
Return	Self:aReg0145

Method get0150( ) Class EFDCBLOCO0
Return	Self:aReg0150

Method get0400( ) Class EFDCBLOCO0
Return	Self:aReg0400

Method get0450( ) Class EFDCBLOCO0
Return	Self:aReg0450

Method get0500( ) Class EFDCBLOCO0
Return	Self:aReg0500

Method get0600( ) Class EFDCBLOCO0
Return	Self:aReg0600

Method get0120( ) Class EFDCBLOCO0
Return	Self:aReg0120

Method get0035( ) Class EFDCBLOCO0
Return	Self:aReg0035

Method get0190( ) Class EFDCBLOCO0
Return	Self:aReg0190

Method get0200( ) Class EFDCBLOCO0
Return	Self:aReg0200

Method get0205( ) Class EFDCBLOCO0
Return	Self:aReg0205

Method get0206( ) Class EFDCBLOCO0
Return	Self:aReg0206

Method get0208( ) Class EFDCBLOCO0
Return	Self:aReg0208

Method get0900( ) Class EFDCBLOCO0
Return	Self:aReg0900

Method cls0205( ) Class EFDCBLOCO0
	Self:aReg0205	:= {}
Return

Method cls0206( ) Class EFDCBLOCO0
	Self:aReg0206	:= {}
Return	

Method cls0208( ) Class EFDCBLOCO0
	Self:aReg0208	:= {}
Return	

Method cls0450( ) Class EFDCBLOCO0
	Self:aReg0450	:= {}
Return	


//-------------------------------------------------------------------
/*/{Protheus.doc} Add0000()
@description Método para inclusão do registro 0000, que é o regstro de
			   abertura do arquivo digital e a identificação da pessoa
			   jurídica. Somente terá um registro 0000 no arquivo texto.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0000() Class EFDCBLOCO0
Local nPos		:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,'', '0000')

aAdd(Self:aReg0000, {})
nPos:=	Len (Self:aReg0000)
aAdd (Self:aReg0000[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0000[nPos], '0000')				//01 - REG
aAdd (Self:aReg0000[nPos], Self:cVersao)		//02 - COD_VER
aAdd (Self:aReg0000[nPos], Self:cTpEscri)		//03 - TIPO_ESCRIT
aAdd (Self:aReg0000[nPos], Self:cSitEsp)		//04 - IND_SIT_ESP
aAdd (Self:aReg0000[nPos], Self:cRecibo)		//05 - NUM_REC_ANTERIOR
aAdd (Self:aReg0000[nPos], Self:dDtIni)		//06 - DT_INI
aAdd (Self:aReg0000[nPos], Self:dDtFin)		//07 - DT_FIM
aAdd (Self:aReg0000[nPos], Self:cNome)	       //08 - NOME
aAdd (Self:aReg0000[nPos], Self:cCnpj)			//09 - CNPJ
aAdd (Self:aReg0000[nPos], Self:cUF)			//10 - UF
aAdd (Self:aReg0000[nPos], Self:cCodMun)		//10 - COD_MUN
aAdd (Self:aReg0000[nPos], Self:cSuframa)		//12 - SUFRAMA
aAdd (Self:aReg0000[nPos], Self:cNAtPj)		//13 - IND_NAT_PJ
aAdd (Self:aReg0000[nPos], Self:cAtivid)		//14 - IND_ATIV

Return Self:aReg0000

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0035()
@description Método para inclusão do registro 0035. Trata da identificação
			    da Sociedade em Conta participação SCP.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0035() Class EFDCBLOCO0

Local nPos				:= 0
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0035')

aAdd (Self:aReg0035, {})
nPos	:=	Len (Self:aReg0035)
aAdd (Self:aReg0035[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0035[nPos], '0035')				//01 - REG
aAdd (Self:aReg0035[nPos], Self:cIdScp)		//02 - COD_SCP
aAdd (Self:aReg0035[nPos], Self:cNome) 		//03 - DESC_SCP
aAdd (Self:aReg0035[nPos], Self:cInfComp)  	//04 - INF_COMP

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0100()
@description Método para inclusão do registro 0100. Demonstra a identificação
			  do contabilista.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0100() Class EFDCBLOCO0
Local nPos		:= 0
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0100')
aAdd (Self:aReg0100, {})
nPos	:=	Len (Self:aReg0100)
aAdd (Self:aReg0100[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0100[nPos], '0100')				//01 - REG
aAdd (Self:aReg0100[nPos], Self:cNome)			//02 - NOME
aAdd (Self:aReg0100[nPos], Self:cCpf)			//03 - CPF
aAdd (Self:aReg0100[nPos], Self:cCrc)			//04 - CRC
aAdd (Self:aReg0100[nPos], Self:cCnpj)			//05 - CNPJ
aAdd (Self:aReg0100[nPos], Self:cCep)			//06 - CEP
aAdd (Self:aReg0100[nPos], Self:cEnder)		//07 - END
aAdd (Self:aReg0100[nPos], Self:cNumEnd)		//08 - NUM
aAdd (Self:aReg0100[nPos], Self:cCompEnd)		//09 - COMPL
aAdd (Self:aReg0100[nPos], Self:cBairro)		//10 - BAIRRO
aAdd (Self:aReg0100[nPos], Self:cTel)			//11 - FONE
aAdd (Self:aReg0100[nPos], Self:cFax)			//12 - FAX
aAdd (Self:aReg0100[nPos], Self:cEmail)		//13 - EMAIL
aAdd (Self:aReg0100[nPos], Self:cCodMun)		//14 - COD_MUN

Return Self:aReg0100

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0110()
@description Método para inclusão do registro 0110. Este registro irá demonstrar
			   as informações do regime de apuração adotada pelo contribuinte.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0110() Class EFDCBLOCO0
Local nPos		:= 0
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0110')

aAdd (Self:aReg0110, {})
nPos	:=	Len (Self:aReg0110)
aAdd (Self:aReg0110[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0110[nPos], '0110')				//01 - REG
aAdd (Self:aReg0110[nPos], Self:cIndTrib)		//02 - COD_INC_TRIB
aAdd (Self:aReg0110[nPos], Self:cIndApro)		//03 - IND_APRO_CRED
aAdd (Self:aReg0110[nPos], Self:cConApu)		//04 - COD_TIPO_CONT

//Verifica se deve ou não preencher o campo 05 do registro, pois existem situações onde o registro
//deve ser somente 4 campos. Nestas situações basta não preencher a propriedade cCrtLp
//If !Empty(Self:cCrtLp)
	aAdd (Self:aReg0110[nPos],Self:cCrtLp)		//05 - IND_REG_CUM
//EndIF

Return Self:aReg0110

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0111()
@description Método para inclusão do registro 0111. Neste registro teremos
			   os totais de receita bruta do período. Aqui é o somatório de todas
			   as filiais, que será utilizado para cálculo do rateio proporcional 
			   dos créditos.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0111() Class EFDCBLOCO0
Local nPos		:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0111')
aAdd (Self:aReg0111, {})
nPos := Len(Self:aReg0111)
aAdd (Self:aReg0111[nPos], Self:cGrupoReg)					//RELACIONAMENTO
aAdd (Self:aReg0111[nPos], '0111')								//01 - REG
aAdd (Self:aReg0111[nPos], Self:nRecMI)						//02 - REC_BRU_NCUM_TRIB_MI
aAdd (Self:aReg0111[nPos], Self:nRecNT)						//03 - REC_BRU_ NCUM_NT_MI
aAdd (Self:aReg0111[nPos], Self:nRecEx)						//04 - REC_BRU_ NCUM_EXP
aAdd (Self:aReg0111[nPos], Self:nRecCum)						//05 - REC_BRU_CUM
aAdd (Self:aReg0111[nPos], Self:nRecTot)						//06 - REC_BRU_TOTAL

Return Self:aReg0111

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0120()
@description Método para inclusão do registro 0120. Serão demonstrados neste
			   registro os meses dispensados da entrega da EFD. Este registro
			   somente é gerado no final de cada ano.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0120() Class EFDCBLOCO0

Local nPos		:= 0

Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0120')
aAdd (Self:aReg0120, {})
nPos	:=	Len (Self:aReg0120)
aAdd (Self:aReg0120[nPos], Self:cGrupoReg)					//RELACIONAMENTO
aAdd (Self:aReg0120[nPos], '0120')					//01 - REG
aAdd (Self:aReg0120[nPos], Self:cMes)		   		//02 - MES_DISPENSA
aAdd (Self:aReg0120[nPos], Self:cInfComp)	   		//03 - INF_COMP

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0140()
@description Método para inclusão do registro 0140. Este registro 
			   identifica o estabelecimento/Filial.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//------------------------------------------------------------------
METHOD Add0140() Class EFDCBLOCO0

Local nPos		:= 0

nPos := aScan (Self:aReg0140, {|aX|  aX[5]== Self:cCnpj	})

IF nPos  == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0140')
	aAdd(Self:aReg0140, {})
	nPos	:=	Len (Self:aReg0140)
	aAdd (Self:aReg0140[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aReg0140[nPos], '0140' ) 				//01-REG
	aAdd (Self:aReg0140[nPos], Self:cCodEstab)    	//02-COD_EST
	aAdd (Self:aReg0140[nPos], Self:cNome)  		   	//03-NOME
	aAdd (Self:aReg0140[nPos], Self:cCnpj)  			//04-CNPJ
	aAdd (Self:aReg0140[nPos], Self:cUF)  				//05-UF
	aAdd (Self:aReg0140[nPos], Self:cIe) 			 	//06-IE
	aAdd (Self:aReg0140[nPos], Self:cCodMun)  		//07-COD_MUN
	aAdd (Self:aReg0140[nPos], Self:cIm)  				//08-IM
	aAdd (Self:aReg0140[nPos], Self:cSuframa)  		//09-SUFRAMA
Else
	Self:cGrupoReg	:= Self:aReg0140[nPos][1]
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Add0145()
@description Método para inclusão do registro 0145. Aqui teremos informações
			   sobre os valores da CPRB do estabelecimento
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0145() Class EFDCBLOCO0

Local nPos		:= 0

If Len(Self:aReg0145)==0
	aAdd (Self:aReg0145, {})
	nPos	:=	Len (Self:aReg0145)	
	aAdd (Self:aReg0145[nPos], Self:cRelac)		//RELACIONAMENTO
	aAdd (Self:aReg0145[nPos], '0145') 			//01-REG
	aAdd (Self:aReg0145[nPos], Self:cIncPer) 		//02-COD_INC_TRIB
	aAdd (Self:aReg0145[nPos], Self:nRecBruta) 	//03-VL_REC_TOT
	aAdd (Self:aReg0145[nPos], Self:nRecAtiv) 	//04-VL_REC_ATIV
	aAdd (Self:aReg0145[nPos], Self:nRecCPR) 		//05-VL_REC_DEMAIS_ATIV
	aAdd (Self:aReg0145[nPos], Self:cInfComp) 	//06-INFO_COMPL
Else
	Self:aReg0145[1][4] 	+= Self:nRecBruta			//03-VL_REC_TOT
	Self:aReg0145[1][5]	+= Self:nRecAtiv			//04-VL_REC_ATIV
	Self:aReg0145[1][6]	+= Self:nRecCPR			//05-VL_REC_DEMAIS_ATIV
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0150()
@description Método para inclusão do registro 0150. Este registro é o
			   cadastro de participantes, que será utilizado por qualquer
			   registro da EFD que contém particiante. Este registro é filho
			   do registro 0140.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0150() Class EFDCBLOCO0

Local nPos		:= 0

If !Self:lMT
	Self:aReg0150	:= {}
EndIF

IF nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0150')
	aAdd (Self:aReg0150, {})
	nPos	:=	Len (Self:aReg0150)
	aAdd (Self:aReg0150[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (Self:aReg0150[nPos], '0150') 		//01-REG
	aAdd (Self:aReg0150[nPos], Self:cCodPart) //02-COD_PART
	aAdd (Self:aReg0150[nPos], Self:cNome) 	//03-NOME
	aAdd (Self:aReg0150[nPos], Self:cCodPais) //04-COD_PAIS
	aAdd (Self:aReg0150[nPos], Self:cCnpj) 	//05-CNPJ
	aAdd (Self:aReg0150[nPos], Self:cCpf) 		//06-CPF
	aAdd (Self:aReg0150[nPos], Self:cIe) 		//07-IE
	aAdd (Self:aReg0150[nPos], Self:cCodMun) 	//08-COD_MUN
	aAdd (Self:aReg0150[nPos], Self:cSuframa) //09-SUFRAMA
	aAdd (Self:aReg0150[nPos], Self:cEnder) 	//10-END
	aAdd (Self:aReg0150[nPos], Self:cNumEnd) 	//11-NUM
	aAdd (Self:aReg0150[nPos], Self:cCompEnd) //12-COMPL
	aAdd (Self:aReg0150[nPos], Self:cBairro) 	//13-BAIRRO
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0190()
@description Método para inclusão do registro 0190. Aqui serão registradas
			   todas as unidades de medidas utilizadas nos produtos do registro
			   0200 de produto.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0190() Class EFDCBLOCO0

Local nPos		:= 0

If !Self:lMT
	Self:aReg0190	:= {}
EndIF

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0190')
aAdd(Self:aReg0190, {})
nPos	:=	Len (Self:aReg0190)	
aAdd (Self:aReg0190[nPos], Self:cGrupoReg)									//RELACIONAMENTO
aAdd (Self:aReg0190[nPos], '0190')											//01 - REG
aAdd (Self:aReg0190[nPos], Self:cUnMedida)								//02 - UNI
aAdd (Self:aReg0190[nPos], Self:cDescr)									//03 - DESCR


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Add0200()
@description Método para inclusão do registro 0200. Neste registro serão
			   demonstrados todos os produtos utilizados em qualquer registro
			   dos blocos da EFD.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//------------------------------------------------------------------
METHOD Add0200() Class EFDCBLOCO0

Local nPos		:= 0

If !Self:lMT
	Self:aReg0200	:= {}
EndIF

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0200')
aAdd(Self:aReg0200, {})
nPos	:=	Len (Self:aReg0200)
aAdd (Self:aReg0200[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0200[nPos], '0200')				//01 - REG
aAdd (Self:aReg0200[nPos], Self:cCodItem)     //02 - COD_ITEM
aAdd (Self:aReg0200[nPos], Self:cDescr) 		//03 - DESCR_ITEM
aAdd (Self:aReg0200[nPos], Self:cCodBarra) 	//04 - COD_BARRA
aAdd (Self:aReg0200[nPos], Self:cCodAnt)		//05 - COD_ANT_IETM
aAdd (Self:aReg0200[nPos], Self:cUnMedida)	//06 - UNI_INV
aAdd (Self:aReg0200[nPos], Self:cTpItem)		//07 - TIPO_ITEM
aAdd (Self:aReg0200[nPos], Self:cNcm)			//08 - COD_NCM
aAdd (Self:aReg0200[nPos], Self:cExIp)	 		//09 - EX_IPI
aAdd (Self:aReg0200[nPos], Self:cGenero)		//10 - COD_GEN
aAdd (Self:aReg0200[nPos], Self:cLst)			//11 - COD_LST
aAdd (Self:aReg0200[nPos], Self:nAqlIcms)  	//12 - ALIQ_ICM

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0205()
@description Método para inclusão do registro 0205. Este registro tem objetivo
			   de demonstrar as alterações que houveram no produto.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0205() Class EFDCBLOCO0

Local nPos		:= 0

If !Self:lMT
	Self:aReg0205	:= {}
Endif
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0205')
aAdd(Self:aReg0205, {})
nPos	:=	Len (Self:aReg0205)
aAdd(Self:aReg0205[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd(Self:aReg0205[nPos], '0205')			//01 - REG
aAdd(Self:aReg0205[nPos], Self:cDescr)		//02 - DESCR_ANT_ITEM
aAdd(Self:aReg0205[nPos], Self:dDtIni)		//03 - DT_INI
aAdd(Self:aReg0205[nPos], Self:dDtFin)		//04 - DT_FIM
aAdd(Self:aReg0205[nPos], Self:cCodAnt)	//05 - COD_ANT_ITEM - LAYOUT 2010

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0206()
@description Método para inclusão do registro 0206. Este registro demonstra
			   o código de combustivel da tabela ANP.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0206() Class EFDCBLOCO0

Local nPos		:= 0

If !Self:lMT
	Self:aReg0206	:= {}
EndIF

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0206')
aAdd(Self:aReg0206, {})
nPos := Len(Self:aReg0206)
aAdd(Self:aReg0206[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0206[nPos], '0206')		   //01 - REG
aAdd (Self:aReg0206[nPos], Self:cCodAnp) //02 - COD_COMB 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0208()
@description Método para inclusão do registro 0208. Este registro traz detalhes
			   de marca comercial
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0208() Class EFDCBLOCO0

Local nPos		:= 0

If !Self:lMT
	Self:aReg0208	:= {}
EndIF
	
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0208')
aAdd(Self:aReg0208, {})
nPos := Len(Self:aReg0208)	
aAdd (Self:aReg0208[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0208[nPos], '0208')				//01 - REG
aAdd (Self:aReg0208[nPos], Self:cTabMarca)	//02 - COD_TAB
aAdd (Self:aReg0208[nPos], Self:cGrpMarca)	//03 - COD_GRU            				
aAdd (Self:aReg0208[nPos], Self:cDescr)		//04 - MARCA_COM	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0400()
@description Método para inclusão do registro 0400.Registro correspondente a
			   Tabela de Natureza da Operação/Prestação
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0400() Class EFDCBLOCO0

Local nPos		:= 0

If !Self:lMT
	Self:aReg0400	:= {}
EndIF

If nPos==0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0400')
	aAdd (Self:aReg0400, {})
	nPos	:=	Len (Self:aReg0400)	
	aAdd (Self:aReg0400[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aReg0400[nPos], '0400')			//01 - REG
	aAdd (Self:aReg0400[nPos], Self:cNatOper)	//02 - COD_NAT
	aAdd (Self:aReg0400[nPos], Self:cDescr)	//03 - DESCR_NAT
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0450()
@description Método para inclusão do registro 0450. Registro que terá todos
			   os códigos de informações complementares dos blocos da EFD.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0450() Class EFDCBLOCO0

Local nPos		:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0450')


aAdd(Self:aReg0450, {})
nPos	:=	Len (Self:aReg0450)
aAdd (Self:aReg0450[nPos], Self:cGrupoReg)		//RELACIONAMENTO
aAdd (Self:aReg0450[nPos], '0450')			//REG
aAdd (Self:aReg0450[nPos], Self:cCodInfo)    //COD_INF
aAdd (Self:aReg0450[nPos], Self:cDescr)      //TXT

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0500()
@description Método para inclusão do registro 0500. Registro que irá demonstrar
			   todos os códigos de conta contábil dos blocos da EFD.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0500() Class EFDCBLOCO0

Local nPos		:= 0
										 
If !Self:lMT
	Self:aReg0500	:= {}
EndIF
										  	
If nPos == 0		
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0500')
	aAdd(Self:aReg0500, {})
	nPos	:=	Len (Self:aReg0500)	                           		
	aAdd (Self:aReg0500[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aReg0500[nPos], '0500') 			//01-REG
	aAdd (Self:aReg0500[nPos], Self:dDtIni)  		//02-DT_ALT
	aAdd (Self:aReg0500[nPos], Self:cNatCtb)  	//03-COD_NAT_CC
	aAdd (Self:aReg0500[nPos], Self:cTpCtb) 		//04-IND_CTA
	aAdd (Self:aReg0500[nPos], Self:cNivel) 		//05-NIVEL 
	aAdd (Self:aReg0500[nPos], Self:cCodCtb) 		//06-COD_CTA
	aAdd (Self:aReg0500[nPos], Self:cNome) 		//07-NOME_CTA
	aAdd (Self:aReg0500[nPos], Self:cCodCtbRfb)	//08-COD_CTA_REF
	aAdd (Self:aReg0500[nPos], Self:cCnpj) 		//09-CNPJ_EST 
EndIF

REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0600()
@description Método para inclusão do registro 0600. Registro que demonstrar
			   todos os códigos de centro de custo utilizados nos blocos da EFD.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0600() Class EFDCBLOCO0

Local nPos		:= 0
/*
nPos	:= aScan (Self:aReg0600, {|aX|  aX[1]== Self:cRelac 	.AND. ;
										    aX[4]==Self:cCCusto}) 
*/
If !Self:lMT
	Self:aReg0600	:= {}
EndIF
If nPos == 0 
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '0600')
	aAdd(Self:aReg0600, {})
	nPos	:=	Len (Self:aReg0600)	
	aAdd (Self:aReg0600[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aReg0600[nPos], '0600')				//01-REG
	aAdd (Self:aReg0600[nPos], Self:dDtIni)		//02-DT_ALT
	aAdd (Self:aReg0600[nPos], Self:cCCusto)		//03-COD_CCUSC
	aAdd (Self:aReg0600[nPos], Self:cDescr)		//04-CCUS		
Endif 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0001(cIndMovto) Class EFDCBLOCO0

Self:AbreBloco('0001',@Self:aReg0001,cIndMovto)

Return Self:aReg0001

//-------------------------------------------------------------------
/*/{Protheus.doc} Add0990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add0990(nQtde) Class EFDCBLOCO0

Self:FechaBloco('0990',@Self:aReg0990, nQtde) 

Return Self:aReg0990
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Add0900()
@description Método para adicionar novo registro 0900
@author Erick G. Dias
@since 08/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Method Add0900() Class EFDCBLOCO0

Local nPos		:= 0
Local nTotal	:= Self:nRecA + Self:nRecC + Self:nRecD + Self:nRecF + Self:nRecI + Self:nRec1
Local nNrbTotal	:= Self:nNRBA + Self:nNRBC + Self:nNRBD + Self:nNRBF + Self:nNRBI + Self:nNRB1

//Somente poderá ter 1 registro 0900 no arquivo
nPos := Len(Self:aReg0900)

If nPos == 0
	aAdd(Self:aReg0900,{"","",0,0,0,0,0,0,0,0,0,0,0,0,0,0})
	nPos := Len(Self:aReg0900)
	Self:aReg0900[nPos][1] :=  FSA008SReg(@Self:aNumeracao,Self:cRelac, "0900") //Relacionamento
	Self:aReg0900[nPos][2] :=  '0900'//01-REG
EndIF

Self:aReg0900[nPos][3]  += Self:nRecA//02-REC_TOTAL_BLOCO_A
Self:aReg0900[nPos][4]  += Self:nNRBA//03-REC_NRB_BLOCO_A
Self:aReg0900[nPos][5]  += Self:nRecC//04-REC_TOTAL_BLOCO_C
Self:aReg0900[nPos][6]  += Self:nNRBC//05-REC_NRB_BLOCO_C
Self:aReg0900[nPos][7]  += Self:nRecD//06-REC_TOTAL_BLOCO_D
Self:aReg0900[nPos][8]  += Self:nNRBD//07-REC_NRB_BLOCO_D
Self:aReg0900[nPos][9]  += Self:nRecF//08-REC_TOTAL_BLOCO_F
Self:aReg0900[nPos][10] += Self:nNRBF//09-REC_NRB_BLOCO_F	
Self:aReg0900[nPos][11] += Self:nRecI//10-REC_TOTAL_BLOCO_I
Self:aReg0900[nPos][12] += Self:nNRBI//11-REC_NRB_BLOCO_I
Self:aReg0900[nPos][13] += Self:nRec1//12-REC_TOTAL_BLOCO_1
Self:aReg0900[nPos][14] += Self:nNRB1//13-REC_NRB_BLOCO_1
Self:aReg0900[nPos][15] += nTotal//14-REC_TOTAL_PERIODO
Self:aReg0900[nPos][16] += nNrbTotal//15-REC_TOTAL_NRB_PERÍODO	

Return