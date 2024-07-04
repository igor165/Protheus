// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSCScoreCard.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"

/*--------------------------------------------------------------------------------------
@class TBSCScoreCard
Scorecard - objeto e um cartao completo coletado e comparado.
Deve retornar de operacao makecard de alguma tabela boa para tal.
Não possui tabela propria. (Objeto gerado em tempo de execuçao)
--------------------------------------------------------------------------------------*/
class TBSCScoreCard from TBIObject

	// dados     
	data fnID
	data fnOrdem
	data fnCardX
	data fnCardY
	data flVisivel

	data fcNome
	data fcDescricao
	data fcEntity
	data fnEntID

	data fnVermelho
	data fnAmarelo
	data fnVerde
	data fnAzul	
	data fnIndicador	
	data fnPercMeta

	data fdDataAlvo
	data fnFeedBack

	data fcUnidade
	data fnInicial
	data fnFinal
	data fnAtual
	data fnAnterior
	data fnAlvo

	data fcInicial
	data fcFinal
	data fcAtual
	data fcAnterior
	data fcAlvo
	data fcPercMeta
	data fnRealVermelho
	data fnRealAmarelo
	data fnRealVerde
	data fnRealAzul

	data fnDecimais
	data fcTipoInd
	data fcInfluencia
	data fnPeso
	data flAscendente
	
	// construtores
	method New() constructor
	method NewBSCScoreCard()

	method oToXMLCard()

endclass
	
method New() class TBSCScoreCard
	::NewBSCScoreCard()
return
method NewBSCScoreCard() class TBSCScoreCard
	::fnId := 0
	::fnOrdem := 0
	::fnCardx := 0
	::fnCardy := 0
	::flVisivel := .f.
	::flAscendente := .t.
return

// oToXMLCard()
method oToXMLCard() class TBSCScoreCard
	local oXMLCard := TBIXMLNode():New("CARD")

	oXMLCard:oAddChild(TBIXMLNode():New("ID", ::fnID))
	oXMLCard:oAddChild(TBIXMLNode():New("ORDEM", ::fnOrdem))

	oXMLCard:oAddChild(TBIXMLNode():New("CARDX", ::fnCardx))	// Coord dashboard
	oXMLCard:oAddChild(TBIXMLNode():New("CARDY", ::fnCardy))	// Coord dashboard
	oXMLCard:oAddChild(TBIXMLNode():New("VISIVEL", ::flVisivel))// Visible dashboard

	oXMLCard:oAddChild(TBIXMLNode():New("NOME", ::fcNome))
	oXMLCard:oAddChild(TBIXMLNode():New("DESCRICAO", ::fcDescricao))
	oXMLCard:oAddChild(TBIXMLNode():New("ENTITY", ::fcEntity))
	oXMLCard:oAddChild(TBIXMLNode():New("ENTID", ::fnEntID))

	oXMLCard:oAddChild(TBIXMLNode():New("FEEDBACK", ::fnFeedBack))
	oXMLCard:oAddChild(TBIXMLNode():New("INDICADOR", ::fnIndicador))
	oXMLCard:oAddChild(TBIXMLNode():New("DECIMAIS", ::fnDecimais))

	oXMLCard:oAddChild(TBIXMLNode():New("VERMELHO", ::fnVermelho))
	oXMLCard:oAddChild(TBIXMLNode():New("AMARELO", ::fnAmarelo))
	oXMLCard:oAddChild(TBIXMLNode():New("VERDE", ::fnVerde))
	oXMLCard:oAddChild(TBIXMLNode():New("AZUL", ::fnAzul))
	oXMLCard:oAddChild(TBIXMLNode():New("RVERMELHO", ::fnRealVermelho))
	oXMLCard:oAddChild(TBIXMLNode():New("RAMARELO", ::fnRealAmarelo))
	oXMLCard:oAddChild(TBIXMLNode():New("RVERDE", ::fnRealVerde))
	oXMLCard:oAddChild(TBIXMLNode():New("RAZUL", ::fnRealAzul))

	oXMLCard:oAddChild(TBIXMLNode():New("UNIDADE", ::fcUnidade))
	oXMLCard:oAddChild(TBIXMLNode():New("INICIAL", ::fnInicial))
	oXMLCard:oAddChild(TBIXMLNode():New("FINAL", ::fnFinal))
	oXMLCard:oAddChild(TBIXMLNode():New("ATUAL", ::fnAtual)) 
	
	oXMLCard:oAddChild(TBIXMLNode():New("ANTERIOR", ::fnAnterior))

	oXMLCard:oAddChild(TBIXMLNode():New("TIPOIND", ::fcTipoInd))
	oXMLCard:oAddChild(TBIXMLNode():New("INFLUENCIA", ::fcInfluencia))
	oXMLCard:oAddChild(TBIXMLNode():New("PESO", ::fnPeso))
	oXMLCard:oAddChild(TBIXMLNode():New("ASCENDENTE", ::flAscendente))	
return oXMLCard

function _BSCScorecard()
return ::New()