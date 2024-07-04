#include "protheus.ch"
#include "agrar650a.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25

#DEFINE IMP_SPOOL 2
#define DMPAPER_A4 9

Static __oFnt10C  := TFont():New("Arial",10,10,,.F., , , , .T., .F.)
Static __oFnt10N  := TFont():New("Arial",10,10,,.T., , , , .T., .F.)
Static __oFnt14N  := TFont():New("Arial",12,12,,.T., , , , .T., .F.)


/** {Protheus.doc} AGRAR650A
@param: 	Nil
@author: 	marina.muller
@since: 	19/09/2017
@Uso: 		SIGAAGR - Relatorio de Etiquetas
 */
Function AGRAR650A(aParam)

	Local oReport			:= Nil
	Local cDirPrint			:= GetTempPath() // Dirétorio Temporário
	Local lRet 				:= .T.
	Local lAdjustToLegacy 	:= .F.
	Private _cFileName 		:= "AGRAR650A"
	Private _aRet           := {"",""}
	Private _nLweb   		:= 10

    //recebe o filtro passado pelo browse do AGRA650
    Default aParam			:= {}

	If !DXD->(ColumnPos('DXD_CODUNI'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf

    oReport := FWMSPrinter():New(_cFileName, IMP_SPOOL, lAdjustToLegacy, cDirPrint, .T.,,,,.T.)// Ordem obrigátoria de configuração do relatório
	oReport:cPathPDF := cDirPrint  // Diretório para o arquivo PDF
	oReport:SetMargin(50,50,0,0) // Seta as margens
	oReport:lServer := .F.
	oReport:nDevice := IMP_SPOOL // Tipo de impressão
	oReport:Setup() // Abre a tela de setup para o usuário

	oReport:SetPortrait() // Seta modo retrato como padrão
	oReport:SetPaperSize(DMPAPER_A4)

	If oReport:nModalResult == PD_OK
		lRet := GeraRelat(oReport, aParam)
    Else
    	oReport:Cancel()
    	lRet := .F.
    EndIf

    if lRet
        _aRet := {_cFileName+".pdf",""}
    else
        _aRet := {"",""}
    endif

    if lRet
        oReport:EndPage()
        oReport:Print()

    endIf

    FreeObj(oReport)

    MS_FLUSH()

Return _aRet


/*/{Protheus.doc} GeraRelat
//Função responsável pela geração do relatório
@author marina.muller
@since 19/09/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function GeraRelat(oReport, aParam)
	Local cAliasQry     := GetNextAlias()
	Local lRet     		:= .T.
	Local nLinhaBar		:= 0
	Local nLinPix       := 0
	Local nColBar		:= 0

	Local cFilialB      := ""
	Local cSafra        := ""
	Local cProdutor     := ""
	Local cLojaPro      := ""
	Local cFazenda      := ""
	Local nX            := 0
	Local nI            := 1
	Local cQry          := ""
	Local cWhere        := ""
	Local lquebra       := .F.

	Private _nColAux    := 0
	Private _nPag  		:= 1
	Private _nLeft      := 40
	Private _nRight     := 1730
	Private _nCol0      := _nLeft
	Private _nTop       := 130
	Private _nTopInt    := _nTop
	Private _nLinOri    := 46
	Private _nTweb    	:= 3
	Private _nLweb    	:= 10

	if oReport:GetOrientation() == 2 //se o usuário informou paisagem
	    _nLeft  	:= 40
	    _nRight  := 2390
	    _nCol0   := _nLeft
	    _nTop    := 130
	    _nTopInt := _nTop
	    _nLinOri := 30
	endIf

	//se o relatório for chamado pelo AGRA650
	If Funname() = "AGRA650"
		//Se tiver filtro no browse utilizamos como filtro no relatório
		If !Empty(aParam)
			cWhere += "AND "
			For nX := 1 to Len(aParam)
				If !Empty(aParam[nX][3])
				   cWhere += aParam[nX][3] + IIF(nX < Len(aParam)," AND ","")
				Else
				   cWhere += aParam[nX][2] + IIF(nX < Len(aParam)," AND ","")
				EndIf   
			Next nX
		EndIf
	EndIf	

	cQry := " SELECT * "
	cQry += " FROM " +RetSqlName("DXD")+ " DXD "
	cQry += " WHERE DXD.D_E_L_E_T_ =  ' ' "
	
	If !Empty(cWhere) .And. Funname() = "AGRA650"
		cQry += cWhere
	EndIf
	
	cQry += " ORDER BY DXD_FILIAL, DXD_SAFRA, DXD_PRDTOR, DXD_LJPRO, DXD_FAZ, DXD_CODIGO"

	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)

	oReport:StartPage()
	CabPagRet(oReport, cAliasQry)

    // seta valor default primeira vez
	cFilialB  := (cAliasQry)->DXD_FILIAL
	cSafra    := (cAliasQry)->DXD_SAFRA
	cProdutor := (cAliasQry)->DXD_PRDTOR
	cLojaPro  := (cAliasQry)->DXD_LJPRO
	cFazenda  := (cAliasQry)->DXD_FAZ

	nLinhaBar 	:= 14
	nLinPix     := 14
	nColBar     := 10

	While !(cAliasQry)->(Eof())
        //Se filial/safra/produtor/loja/fazenda for diferente começa outra página
		If (cFilialB != (cAliasQry)->DXD_FILIAL) .Or. (cSafra != (cAliasQry)->DXD_SAFRA) .Or.;
		   (cProdutor != (cAliasQry)->DXD_PRDTOR) .Or. (cLojaPro != (cAliasQry)->DXD_LJPRO) .Or.;
		   (cFazenda != (cAliasQry)->DXD_FAZ)

			cFilialB  := (cAliasQry)->DXD_FILIAL
			cSafra    := (cAliasQry)->DXD_SAFRA
			cProdutor := (cAliasQry)->DXD_PRDTOR
			cLojaPro  := (cAliasQry)->DXD_LJPRO
			cFazenda  := (cAliasQry)->DXD_FAZ

			oReport:EndPage()
			oReport:StartPage()

			_nTop := 130
			nLinhaBar := 14
			nLinPix   := 14
			nColBar   := 10
			_nColAux  := 0
			nI := 1
			_nPag++

			CabPagRet(oReport, cAliasQry)
		EndIf

		lquebra := .F.
		oReport:FWMSBAR( 'CODE128', nLinhaBar, nColBar, Alltrim((cAliasQry)->DXD_CODUNI), oReport, .F., , .T., 0.025, 1.5, .f., 'Courier New', '', .F. ) // Imprime o código de barras
		nLinPix   += 10
		oReport:Say(nLinPix * nColBar, 120, (cAliasQry)->DXD_CODUNI, __oFnt10C)
		nLinPix    -= 0.5
		nLinhaBar  += 8
		
		If nI % 6 == 0 // Se houver 6 registros ou multiplos de 5, finaliza a página
			oReport:EndPage()
			oReport:StartPage()

			_nTop     := 130
			nLinhaBar := 14
			nLinPix   := 14
			nColBar   := 10
			_nColAux  := 0
			lquebra   := .T.
			_nPag++
			
		EndIf

		nI++
		(cAliasQry)->( dbSkip() )
		If lquebra
			CabPagRet(oReport,cAliasQry)
		EndIf
	EndDo

	(cAliasQry)->( dbCloseArea() )

Return lRet


/*/{Protheus.doc} CabPagRet
//Função que imprime os dados do relatório
@author marina.muller
@since 19/09/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function CabPagRet(oReport, cAliasQry)
	Local cFileLogo    := ''
	Local cNmEmp
	Local cNmFilial
	Local cBlocoIni    := ""
	Local cBlocoFim    := ""
    Local aSaveArea    := GetArea()
	Local cAliasDXD    := GetNextAlias()
	Local nI           := 1

    //Carrega e Imprime Logotipo da Empresa
    fLogoEmp(@cFileLogo)

	if file(cFilelogo)
		_nColAux += 30
		oReport:SayBitmap(_nTop/_nTweb, _nColAux, cFileLogo, (180)/_nTweb, (050)/_nTweb)
		_nColAux := 0
	EndIf

	_nColAux += 30
	oReport:Line(_nTop/_nTweb, _nColAux, (_nTop/_nTweb), (_nRight/_nTweb) - 20)

	_nTop += 45

	_nColAux += 170
	oReport:Say(_nTop/_nTweb, _nColAux, STR0001, __oFnt14N) //#"Romaneio de Amostras para Análise por Bloco"

	_nTop -= 40
	_nColAux += 320
	oReport:Say(((_nTop)/_nTweb)+_nLweb, _nColAux, STR0011 +AllTrim(Str(_nPag)), __oFnt10C) //#"Página: "

	_nColAux := 0
	_nTop += 85

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	EndIf

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

	_nColAux += 30
	oReport:Say(_nTop/_nTweb, _nColAux, "SIGA/" + _cFileName + "/v." + cVersao, __oFnt10N)
	oReport:Say(_nTop/_nTweb, (_nRight/_nTweb) - 105, STR0003 + Dtoc(dDataBase), __oFnt10N) //#"Emissão...: "

	_nTop += 28

	oReport:Say(_nTop/_nTweb, _nColAux, STR0002 + cNmEmp + " / " + cNmFilial, __oFnt10N) //#"Empresa...: "
	oReport:Say(_nTop/_nTweb, (_nRight/_nTweb) - 83, RptHora + Time(), __oFnt10N)

	_nTop += 20
	_nColAux := 0

	_nColAux := 30

	oReport:Line(_nTop/_nTweb, _nColAux, (_nTop/_nTweb), (_nRight/_nTweb) - 20)

	_nTop += 90
	_nColAux := 0

	_nColAux += 30 //Safra
	oReport:Say(_nTop/_nTweb, _nColAux, STR0004, __oFnt10N) //#"Safra: "
	_nColAux += 25
	oReport:Say(_nTop/_nTweb, _nColAux, (cAliasQry)->DXD_SAFRA, __oFnt10C)

	_nTop 	+= 45
	_nColAux := 0

	_nColAux += 30  //Codigo+Loja+Nome
	oReport:Say(_nTop/_nTweb, _nColAux, STR0005, __oFnt10N) //#"Entidade: "
	_nColAux += 40
	oReport:Say(_nTop/_nTweb, _nColAux, (cAliasQry)->DXD_PRDTOR + "/" + (cAliasQry)->DXD_LJPRO +;
	" - " + Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasQry)->(DXD_PRDTOR+DXD_LJPRO),"NJ0_NOME"), __oFnt10C)

	_nColAux += 205 //Fazenda+Nome
	oReport:Say(_nTop/_nTweb, _nColAux, STR0006, __oFnt10N) //#"Fazenda: "
	_nColAux += 38
	oReport:Say(_nTop/_nTweb, _nColAux, (cAliasQry)->DXD_FAZ + " - " + Posicione("NN2",2,FWxFilial("NN2")+(cAliasQry)->DXD_FAZ,"NN2_NOME"), __oFnt10C)

    // atribui valor do bloco inicial
    cBlocoIni := (cAliasQry)->DXD_CODIGO

    //busca valor do bloco final para mesma filial/safra/produtor/loja/fazenda
	BeginSql Alias cAliasDXD
	Select DXD.DXD_CODIGO
	FROM %Table:DXD% DXD
	WHERE DXD.%NotDel%
	  AND DXD.DXD_FILIAL = %exp:(cAliasQry)->DXD_FILIAL%
	  AND DXD.DXD_SAFRA  = %exp:(cAliasQry)->DXD_SAFRA%
	  AND DXD.DXD_PRDTOR = %exp:(cAliasQry)->DXD_PRDTOR%
	  AND DXD.DXD_LJPRO  = %exp:(cAliasQry)->DXD_LJPRO%
	  AND DXD.DXD_FAZ    = %exp:(cAliasQry)->DXD_FAZ%
	  AND DXD.DXD_CODIGO > %exp:(cAliasQry)->DXD_CODIGO%
	  EndSQL

    (cAliasDXD)->(dbGoTop())
    If (cAliasDXD)->( !Eof() )
	    While (cAliasDXD)->( !Eof() )
	    
		    // atribui valor do bloco final
		    cBlocoFim := (cAliasDXD)->DXD_CODIGO

	       //quando atingir último registro da sequência que poder ser impresso naquela página
	       If nI == 5
		      Exit
		   EndIf   
	    	
    	   nI++
    	   (cAliasDXD)->( dbSkip() )
		EndDo
	EndIf	
    (cAliasDXD)->( dbCloseArea() )
    RestArea( aSaveArea )
    
    //se tiver apenas o bloco inicial o bloco final é igual 
    If Empty(cBlocoFim)
       cBlocoFim := cBlocoIni 	
    EndIf

	_nTop 	+= 45
	_nColAux := 0

	_nColAux += 30  //Fardo Inicial
	oReport:Say(_nTop/_nTweb, _nColAux, STR0007, __oFnt10N) //#"Bloco Inicial: "
	_nColAux +=  54
	oReport:Say(_nTop/_nTweb, _nColAux, cBlocoIni, __oFnt10C)

	_nColAux += 100
	oReport:Say(_nTop/_nTweb, _nColAux, STR0008, __oFnt10N) //#"Bloco Final: "
	_nColAux +=  48
	oReport:Say(_nTop/_nTweb, _nColAux, cBlocoFim, __oFnt10C)

	_nTop += 25
	_nColAux := 0

	_nColAux := 30

	oReport:Line(_nTop/_nTweb, _nColAux, (_nTop/_nTweb), (_nRight/_nTweb) - 20)

Return

