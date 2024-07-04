#Include 'protheus.ch'

Class CNXImporter
	Data cErro
	Data oReader
	Data aPreImp
	Data aImp
	Data nQtdImp

	Method new()
	Method destroy()
	Method destroyImp(aOut)
	Method getError()
	Method setError(cErro)
	Method setReader(oReader)
	Method tryExec(lSuccess, cError, oExecutor)
	Method import()
	Method save(oBenef, aOut, lIncrementa)
EndClass

Method new() Class CNXImporter
	self:cErro := ""
	self:nQtdImp := 0

	self:oReader := nil
	self:aPreImp := {}
	self:aImp := {}
Return self

Method destroy() Class CNXImporter

	if !Empty(self:oReader)
		self:oReader:destroy()
		FreeObj(self:oReader)
		self:oReader := nil
	EndIf
	self:destroyImp(self:aPreImp)
	self:destroyImp(self:aImp)
Return

Method destroyImp(aOut) Class CNXImporter
	Local nOut := 0
	Local nLen := Len(aOut)

	For nOut := 1 to nLen
		If !Empty(aOut[nOut])
			aOut[nOut]:destroy()
			FreeObj(aOut[nOut])
			aOut[nOut] := nil
		EndIf
	Next nOut
Return

Method getError() Class CNXImporter
Return self:cErro

Method setError(cErro) Class CNXImporter
	self:cErro := cErro
Return

Method setReader(oReader) Class CNXImporter
	self:oReader := oReader
Return

Method tryExec(lSuccess, cError, oExecutor) Class CNXImporter
	if !lSuccess
		self:setError( IIf(Empty(cError),oExecutor:getError(),cError) )
	EndIf
Return lSuccess

Method import() Class CNXImporter
	Local lSuccess := .T.
	Local nIni := microseconds()
	Local nTotal := 0
	Local nIncremento := 0

	lSuccess := self:tryExec(self:oReader:readFile(), "",self:oReader)
	If lSuccess
		oBenef := self:oReader:getFirst()
		lSuccess := self:tryExec(!Empty(oBenef), "Nenhum registro encontrado")
		nTotal := self:oReader:getCount()
		nIncremento := int(nTotal/10)
		If !isBlind()
			ProcRegua(10)
		EndIf
		If lSuccess
			lSuccess := self:save(oBenef, self:aPreImp, .F.)
			If lSuccess
				lSuccess := self:save(oBenef, self:aImp, .F.)
				If lSuccess
					Do While self:oReader:hasNext() //.AND. self:nQtdImp < 100
						oBenef := self:oReader:getNext()
						lSuccess := self:save(oBenef, self:aImp, .T.)
						If self:nQtdImp == 1 .OR. self:nQtdImp % nIncremento == 0
							If !isBlind()
								IncProc( "Total de beneficiários: " + AllTrim(Str(nTotal)) + ". Total de processados: " + AllTrim( Str(self:nQtdImp) ) )
							EndIf
							conout("Benef. cadastrados: " + Alltrim(Str(self:nQtdImp)))
							conout("Tempo decorrido: " + Alltrim(Str(microseconds() - nIni)) )
						EndIf
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf

	conout("Benef. cadastrados: " + Alltrim(Str(self:nQtdImp)))
	conout("Tempo decorrido: " + Alltrim(Str(microseconds() - nIni)) )
Return lSuccess

Method save(oBenef, aOut, lIncrementa) Class CNXImporter
	Local nOut := 0
	Local nLen := Len(aOut)
	Local lSuccess := .T.
	Default lIncrementa := .T.

	For nOut := 1 to nLen
		lSuccess :=  lSuccess .AND. aOut[nOut]:save(oBenef)
	Next nOut
	If lSuccess .AND. lIncrementa
		self:nQtdImp++
	EndIf
Return lSuccess