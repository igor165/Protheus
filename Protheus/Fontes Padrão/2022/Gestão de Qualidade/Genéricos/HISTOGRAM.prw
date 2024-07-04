#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Class Histograma

	DATA cortes      AS Array
	DATA frequencia  AS Array
	DATA m_debug     AS BOOLEAN
	DATA m_entries   AS INTEGER
	DATA m_hist      AS Array
	DATA m_max       AS NUMBER
	DATA m_min       AS NUMBER
	DATA m_name      AS String
	DATA m_nbins     AS INTEGER
	DATA m_overflow  AS NUMBER
	DATA m_underflow AS NUMBER
	DATA maior       AS NUMBER
	DATA media       AS NUMBER
	DATA menor       AS NUMBER
	DATA nb          AS OBJECT

	//METHOD Histogram(nome, nbins, minimo, maximo)
	METHOD New() CONSTRUCTOR
	METHOD fill()
	METHOD findBin()
	METHOD Floor()
	METHOD area()
	METHOD mean()
	METHOD entries()
	METHOD nome()
	METHOD numberOfBins()
	METHOD minimo()
	METHOD maximo()
	METHOD overflow()
	METHOD getArray()
	METHOD montaX()
	METHOD montaY()
	METHOD getDebug()
	METHOD setDebug(flag)
	METHOD getMin(aPontos)
	METHOD getMax(aPontos)
	METHOD getCortes()
	METHOD getFrequencia()
	METHOD mediasHisto()

ENDCLASS


METHOD getCortes() CLASS HISTOGRAMA
Return frequencia


METHOD getFrequencia() CLASS HISTOGRAMA
Return frequencia

METHOD New(nome, aPontos) CLASS HISTOGRAMA

	::cortes     := {}
	::frequencia := {}
	::m_nbins     := Len(aPontos)
	::m_name      := nome
	::m_hist      := Array(30) // DEIXAR COMO 30 - Acordado em 23/04
	AFILL(::m_hist, 0)       
	::m_underflow := 0
	::m_overflow  := 0
	::menor       := ::mediasHisto(aPontos)[1]
	::media       := ::mediasHisto(aPontos)[2]
	::maior       := ::mediasHisto(aPontos)[3]
	::m_min       := ::getMin(aPontos) //Menor valor das medições
	::m_max       := ::getMax(aPontos) //Maior valor das medições
	::m_entries   := 0
	::m_debug     := .f.

	::fill(aPontos)

	::nb := NB():New(aPontos)
	::nb:getNB(aPontos)

	::montaX()
	::montaY()
Return


METHOD fill(x) CLASS HISTOGRAMA
Local nI := 0

	If ValType(x) == "A"
		For nI := 1 to Len(x)
			::fill(x[nI])
		Next
	EndIf

	If ValType(x) == "A"
		Return
	EndIf

	bin := ::findBin(x)

	If (bin:isUnderflow)
		::m_underflow++
	EndIf

	If (bin:isOverflow)
		::m_overflow++
	EndIf

	If (bin:isInRange)
		::m_hist[bin:index] += 1
	EndIf

	::m_entries++

Return

METHOD findBin(x) CLASS HISTOGRAMA
Local nI := 1
Local nHighEdge := 0
Local nBinWidth := 0

	bin := BinInfo():New()
	bin:isInRange   := .F.
	bin:isUnderflow := .F.
	bin:isOverflow  := .F.
	// first check if x is outside the range of the normal histogram bins
	If (x < ::m_min)
		bin:isUnderflow := .T.
	ElseIf (x > ::m_max)
		bin:isOverflow  := .T.
	Else
		// search for histogram bin into which x falls
		//nBinWidth := (::m_max - ::m_min) / Floor(Sqrt(::m_nbins)) 23/04
		//VERIFICAR COM O IVO SE SERÁ 20 FIXO (ESTIMATIVA CLASSES DA PLANILHA) - PARTE 2/2
		nBinWidth := (::m_max - ::m_min) / 20//Incremento

		While nI < Len(::m_hist)
			nHighEdge = ::m_min + (nI) * nBinWidth
			If (x <= nHighEdge)
				bin:isInRange := .T.
				bin:index     := nI
				Exit
			EndIf
			nI++
		End

	EndIf

Return bin


METHOD mean() CLASS HISTOGRAMA
	Local nI   := 0
	Local nSum := 0
	Local nBinCenVal := 0
	Local nBinWidth  := (::m_max - ::m_min) / ::m_nbins

	While nI < ::m_nbins
		nBinCenVal := m_min + (nI + 0.5) * nBinWidth
		nSum       += ::m_hist[nI] * nBinCenVal
		nI++
	End

Return (nSum / (::m_entries - ::m_overflow - ::m_underflow))

METHOD area() CLASS HISTOGRAMA
Local nSum := 0
Local nI   := 0

While nI < ::m_nbins
	nSum += ::m_hist[nI]
	nI++
End

Return nSum


METHOD Floor(nNumber) CLASS HISTOGRAMA

If nNumber < 0
	nNumber := (nNumber - 1)
EndIf
nNumber := Int(nNumber)

Return nNumber


METHOD montaX() CLASS HISTOGRAMA
Local nbinWidth  := (::m_max - ::m_min) / Floor(Sqrt(::m_nbins))
Local nbiLowEdge := 0
Local nI         := 0

	While nI < ::m_nbins
		nI++
		nbiLowEdge := ::m_min + nI * nbinWidth
		AADD(::cortes, nbiLowEdge )
	End

Return

METHOD montaY() CLASS HISTOGRAMA
Local nI

For nI := 1 to Len(::m_hist)
	AADD(::frequencia, ::m_hist[nI] )
Next

Return

METHOD entries() CLASS HISTOGRAMA
Return ::m_entries

METHOD nome() CLASS HISTOGRAMA
Return ::m_name

METHOD numberOfBins() CLASS HISTOGRAMA
Return ::m_nbins

METHOD minimo() CLASS HISTOGRAMA
Return ::m_min

METHOD maximo() CLASS HISTOGRAMA
Return ::m_max

METHOD overflow() CLASS HISTOGRAMA
Return ::m_overflow

METHOD getArray() CLASS HISTOGRAMA
Return ::m_hist

METHOD setDebug(flag) CLASS HISTOGRAMA
	::m_debug := flag
Return



//---------------------------------------------------------------------
/*/{Protheus.doc} getDebug
Retorna 
@author Marcos Wagner Junior
@since 15/10/2019
@version P12
@return m_debug Conteudo do campo.
/*/
//---------------------------------------------------------------------
 METHOD getDebug() Class HISTOGRAMA

 Return ::m_debug


METHOD getMin(aPontos) CLASS HISTOGRAMA
	Local aCopPon := {}
	
	aCopPon := Aclone(aPontos)
	aCopPon := aSort(aCopPon) 
Return aCopPon[1]

METHOD getMax(aPontos) CLASS HISTOGRAMA
	Local aCopPon := {}
	
	aCopPon := Aclone(aPontos)
	aCopPon := aSort(aCopPon) 
Return aCopPon[Len(aCopPon)]

/*/{Protheus.doc} mediasHisto
Retorna o menor valor, a media e o maior valor de um array de numeros
@author rafael.kleestadt
@since 08/07/2020
@version 1.0
@param aPontos, array, array contendo os valores a serem verificados
@return aRet, array, vetor contendo o menor, a media e o maior valor do array recebido por parametro
/*/
METHOD mediasHisto(aPontos) CLASS HISTOGRAMA
Local nX      := 0
Local nSoma   := 0
Local nMedia  := 0
Local nMaior  := 0
Local nMenor  := 0
Local aRet    := {}
Local aCopPon := {}

aCopPon := Aclone(aPontos)

ASORT(aCopPon,,, { |x, y| x > y } )
nMaior  := aCopPon[1]
nMenor  := aCopPon[LEN(aCopPon)]

For nX := 1 To Len(aCopPon)
	If aCopPon[nX] <> 0
		nSoma += aCopPon[nX]
	EndIf
Next nX
nMedia := nSoma / LEN(aCopPon)

aRet := {nMenor, nMedia, nMaior}

Return aRet
