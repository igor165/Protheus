#include "protheus.ch"
#include "tbiconn.ch"

static __aPrepared := {}

//-----------------------------------------------------------------------
/*/{Protheus.doc} gnreXMLEnv
Função que monta o XML único de envio para GNRE ao TSS.

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 12.25

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
user function GnreXMLEnv( cAliasSF6 )
local cId			:= ''
local cString		:= ''
local cUf			:= ''
local cMVUFGNWS		:= GetNewPar('MV_UFGNWS' ,'') //Apenas as UF's que possuem GNRE Web Service.
Local cLote			:= ""
Local lLote			:= .F.
Local cTotal		:= 0
Local dDTPgto		:= CTOD("  /  /    ")
Local lDifal		:= .F.

default cAliasSF6   := ( PARAMIXB[1] )

Private cVersao		:= GetMv('MV_GNREVE' ,,'1.00')
Private lExtCPOTag  := .F.

If IsInCallStack("FISA214")
	lLote	:= .T.
	cLote	:= "L"
ENdIf

DbSelectArea("SF6")      
lExtCPOTag := SF6->(FieldPos("F6_TIPOGNU")) > 0

cUF			:= IIF( lLote , alltrim((cAliasSF6)->CIB_EST) , alltrim((cAliasSF6)->F6_EST))
cNumGNRE	:= IIF( lLote , alltrim((cAliasSF6)->CIB_ID)  , alltrim((cAliasSF6)->F6_NUMERO))
lDifal		:= (cAliasSF6)->F6_TIPOIMP $ 'B'

//Tratamento para ID
cId	 := cLote + cUF + cNumGNRE

//Cabeçalho XML
cString := '<gnre id="gnre:' +  cNumGNRE  + '" tssversao="2.00">'
cString += '<versaoGuia>' + cVersao + '</versaoGuia>'
If cVersao >= '2.00'
	cString += '<dadosGNRE>'
	cString += '<tipoGnre>'+TpGNRE(cAliasSF6,lLote)+'</tipoGnre>'
	cString	+= '<uf>' + cUF + '</uf>'
	cString	+= '<numerognre>' +  cNumGNRE  + '</numerognre>'
	cString	+= Emitente(cUF, lDifal)
	cString += '<itensGNRE>'

EndIf

If cUF $ cMVUFGNWS
	cTotal	:= TotGNRE(cAliasSF6,lLote)
	dDTPgto	:= DTPgto(cAliasSF6,lLote)
	If lLote
		// Itens via FISA214 2.00
		While (cAliasSF6)->(!Eof())
			cString += GeraItem( cAliasSF6 , lLote  )
			(cAliasSF6)->(DbSkip())
		End
	Else
		// Itens via FISA095 1.00 E 2.00
		cString +=  GeraItem( cAliasSF6 , lLote  )
	EndIf
EndIf

If cVersao >= '2.00'
	cString += '</itensGNRE>'
	cString += '<valorGNRE>' + AllTrim(ConvType( cTotal ,15,2))  + '</valorGNRE>'
	cString += '<pagamento>' + AllTrim(DTOS( dDTPgto  ) ) + '</pagamento>'
	cString += '</dadosGNRE>'
EndIf

cString += '</gnre>'
cString := IIf(!empty(cString),encodeUTF8(cString ), "")

return ({cId,cString})

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetDest
Função retorna o Destinatário da GNRE.

@author Raphael Augustos
@since 17.10.2019
@version 12.25

@return	aDest		Array com informações do Destinatário.
/*/
//-----------------------------------------------------------------------
static function RetDest(cCliFor, cLjCliFor, cOper, cTpDoc, cAliasSF6, cVersao)

local aReturn		:= {}
//local cTpPessoa		:= ""
local cCpfCnpj		:= ""
local cInsEst		:= ""
local cRzSocial		:= ""
local cCodMun		:= ""
Local cDescMun		:= ""
Local cEstado		:= ""

default cCliFor		:= ""
default cLjCliFor	:= ""
default cOper		:= ""


if cOper == '2' .And. !cTpDoc $ 'B|D' 	//Saída
	dbselectarea ('SA1')				//Cadastro do Cliente
	SA1->(dbsetorder (1))
	SA1->(dbseek(xFilial('SA1')+cCliFor+cLjCliFor))

	cCpfCnpj	:= alltrim( SA1->A1_CGC )
	cInsEst		:= iif(!empty(SA1->A1_INSCR) .And. alltrim(SA1->A1_INSCR)<>'ISENTO',ConvType(VldIE(SA1->A1_INSCR,.F.,.F.)),'')
	cRzSocial	:= Alltrim( SA1->A1_NOME )
	If cVersao == "1.00" .And. SA1->A1_EST == 'ES'
		cCodMun		:= fGetMunDua(Alltrim(SA1->A1_COD_MUN))
	Else
		cCodMun		:= alltrim( SA1->A1_COD_MUN )
	EndIf	
	cDescMun	:= alltrim( SA1->A1_MUN )
	cEstado		:= alltrim( SA1->A1_EST )
else
	dbselectarea ('SA2')				//Cadastro do Cliente
	SA2->(dbsetorder (1))
	SA2->(dbseek(xFilial('SA2')+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA))

	cCpfCnpj	:= alltrim( SA2->A2_CGC )
	cInsEst		:= iif(!empty(SA2->A2_INSCR) .And. alltrim(SA2->A2_INSCR)<>'ISENTO',ConvType(VldIE(SA2->A2_INSCR,.F.,.F.)),'')
	cRzSocial	:= alltrim( SA2->A2_NOME )
	If cVersao == "1.00" .And. SA2->A2_EST == 'ES'
		cCodMun		:= fGetMunDua(Alltrim(SA2->A2_COD_MUN))
	Else
		cCodMun		:= alltrim( SA2->A2_COD_MUN )
	EndIf
	cDescMun	:= alltrim( SA2->A2_MUN )
	cEstado		:= alltrim( SA2->A2_EST )
endif 

//Preenchimento do Array
aadd(aReturn,{ cCpfCnpj,;
				 cInsEst,;
				 cRzSocial,;
				 cCodMun,;
				 cDescMun,;
				 cEstado})

return aReturn
//-----------------------------------------------------------------------
/*/{Protheus.doc} ConvType
@author Simone dos Santos de Oliveira
@since 17.10.2019
@version 12.25
/*/
//-----------------------------------------------------------------------
static function ConvType(xValor,nTam,nDec)

local cNovo 	:= ''

default nDec 	:= 0

do case
	case valtype(xValor)=='N'
		if xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))
		else
			cNovo := '0'
		endif
	case valtype(xValor)== 'D'
		cNovo := FsDateConv(xValor,'YYYYMMDD')
		cNovo := substr(cNovo,1,4)+'-'+substr(cNovo,5,2)+'-'+substr(cNovo,7)
	case valtype(xValor)=='C'
		if nTam == nil
			xValor := AllTrim(xValor)
		endif

		default nTam := 60

		cNovo := AllTrim(EnCodeUtf8(NoAcento(substr(xValor,1,nTam))))
endcase

return(cNovo)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetCampAdic
Função retorna as informações extras referente à gnre.
@author Simone dos Santos de Oliveira
@since 03/03/2016
@version 12.25
/*/
//-----------------------------------------------------------------------
static function RetCampAdic( cUF, cCodRec )

local aInfExtra		:= {}
local cWhere		:= ''
local cFiltro		:= ''
local cIndex		:= ''
local cAmbiente		:= alltrim(GetMv('MV_AMBGNRE',,'2'))
local cAliasF0N		:= 'F0N'
local nX			:= 0

default cUF			:= ''
default cCodRec		:= ''


if !( empty(cUF) .and. empty(cCodRec) .and. empty(cAmbiente) )

	dbselectarea('F0N')
	F0N->(dbsetorder(1))

	#IFDEF TOP

		if (TcSrvType ()<>"AS/400")
			lQuery    := .T.
			cAliasF0N := GetNextAlias()

			cWhere := "%"
			cWhere += "F0N.F0N_FILIAL = '"+xFilial ("F0N")+"' AND"
			cWhere += " F0N.F0N_UF = '"+ cUF +"' AND F0N.F0N_CODREC = '"+ cCodRec +"' "
			cWhere += " AND F0N.F0N_AMBWS = '" + cAmbiente + "' "
			cWhere += "AND F0N.D_E_L_E_T_ = '' "
			cWhere += "%"


			BeginSql Alias cAliasF0N
				SELECT * FROM %Table:F0N% F0N WHERE %Exp:cWhere% ORDER BY %Order:F0N%
			EndSql

		else
	#EndIf
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro := 'F0N_FILIAL=="'+xFilial ("F0N")+'".And.'
			cFiltro += 'F0N_UF =="'+ cUF +'".And. F0N_CODREC =="'+ cCodRec +'" '
			cFiltro += '.And. F0N_AMBWS == "'+cAmbiente+'" '
			indregua (cAliasF0N, cIndex, F0N->(IndexKey ()),, cFiltro)
			nIndex := retindex(cAliasF0N)
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			dbSelectArea (cAliasF0N)
			dbSetOrder (nIndex+1)
	#IFDEF TOP
		endif
	#EndIf

dbSelectArea (cAliasF0N)
(cAliasF0N)->(dbGoTop ())

	while !(cAliasF0N)->(eof ())

		aadd(aInfExtra,{})
		nX := len(aInfExtra)

		aadd(aInfExtra[nX],(cAliasF0N)->F0N_CODSEF)
		aadd(aInfExtra[nX],(cAliasF0N)->F0N_TIPO)
		aadd(aInfExtra[nX],(cAliasF0N)->F0N_CODINT)
		aadd(aInfExtra[nX],(cAliasF0N)->F0N_OBRIGA)
		aadd(aInfExtra[nX],(cAliasF0N)->F0N_TITULO)
		aadd(aInfExtra[nX],(cAliasF0N)->F0N_CODINT)

		(cAliasF0N)->(dbSkip())
	enddo
endif

#IFDEF TOP
	dbSelectArea(cAliasF0N)
	dbCloseArea()
#ELSE
	dbSelectArea(cAliasF0N)
	retindex(cAliasF0N)
	ferase(nIndex+OrdBagExt())
#ENDIF

return aInfExtra

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetVlrAdic
Função retorna o campo conforme Código interno apresentado na tabela F0N

@author Simone dos Santos de Oliveira
@since 03/03/2016
@version 12.25

/*/
//-----------------------------------------------------------------------
static function RetVlrAdic( cCodInterno, cAliasSF6 )

local cValAdic	:= ''
local cCampo		:= ''

default cCodInterno := ''

if ! empty(cCodInterno)

	do case
   		case cCodInterno $ 'OBS' 												//Observação
			cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_OBSERV')))

		case cCodInterno $ 'INF' 												//Informação Complementar
			cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_INF')))

		case cCodInterno $ 'CHV' 												//Chave NF-e / DF-e / Ct-e
			cValAdic	:= SF3->(FieldGet(FieldPos('F3_CHVNFE')))

		case cCodInterno $ 'DEM#DSA' 											//Data de Emissão NF#Data Saída
			cValAdic	:= SF3->(FieldGet(FieldPos('F3_EMISSAO')))
			cValAdic	:= iif(! empty(cValAdic), dtos(cValAdic), '')

		case cCodInterno $ 'DET'  												//Detalhamento da Receita
			cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_DETRECE')))

		case cCodInterno $ 'NNF'  												//Num. NF
			cValAdic	:= SF3->(FieldGet(FieldPos('F3_NFISCAL')))

		case cCodInterno $ 'ATM'  												//Atualização Monetária
			cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_ATMON')))
			cValAdic	:= ConvType(cValAdic,15,2)

		case cCodInterno $ 'NRE' 		 										//Nome Remetente
			cValAdic	:= SM0->(FieldGet(FieldPos('M0_NOMECOM')))

		case cCodInterno $ 'CNP'  												//CNPJ Remetente
			cValAdic	:= SM0->(FieldGet(FieldPos('M0_CGC')))

		case cCodInterno $ 'JRS'  												//Juros
			cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_JUROS')))
			cValAdic	:= ConvType(cValAdic,15,2)

		case cCodInterno $ 'MLT'  												//Multa
			cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_MULTA')))
			cValAdic	:= ConvType(cValAdic,15,2)

		case cCodInterno $ 'MOR'  												//Municipio de Origem
			cValAdic	:= SM0->(FieldGet(FieldPos('M0_CODMUN')))

		case cCodInterno $ 'CRG#CNA#CIN#DES#GST#MCR#PCA#PTS#VLD'				//Carga#Cnae#Conhec. Interno#Cnae#Dt Desembaraço#Guia ST#Manif. de Carga#Placa Caminhão#Prot. de caminhão#Valor Aduaneiro
			cCampo		:= RetNwCmp( cCodInterno )
			cValAdic	:= iif(! empty(cCampo), (cAliasSF6)->(FieldGet(FieldPos(cCampo))),'')

		otherwise
			cValAdic	:= ' '

	endCase
endif

return cValAdic

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetNwCmp
Função retorna campo que não é tratado por padrão no sistema

@author Simone dos Santos de Oliveira
@since 03/03/2016
@version 12.25

/*/
//-----------------------------------------------------------------------
static function RetNwCmp( cCdInt )

local cValAdc		:= ''
local cMVNWCODGN	:= alltrim(GetNewPar('MV_NWCODGN',' '))

default cCdInt	:= ''

if !(empty( cCdInt ) .and. empty( cMVNWCODGN )) .and. ( cCdInt $ cMVNWCODGN)

	cValAdc := substr(cMVNWCODGN,at(cCdInt,cMVNWCODGN),at('/',cMVNWCODGN)-1)
	cValAdc := substr(cValAdc,at('F6',cValAdc),len(cValAdc))

endif

return cValAdc

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTpDoc
Função retorna tipo de documento de origem

@author Simone dos Santos de Oliveira
@since 06/04/2016
@version 12.25

/*/
//-----------------------------------------------------------------------
static function RetTpDoc( cEspecie , cUF , cCodRec)

local cTipoDoc	:= ''

default cEspecie	:= ''
default cUF			:= ''
default cCodRec		:= ''

if ! empty( cEspecie )
	do case
		case cUF == "SC" .And. cCodRec == "100030"
			cTipoDoc := '10'
		case cUF == "PR" .And. cCodRec == "100099"
			cTipoDoc := '10'
		case cUF == "PE" .And. cCodRec == "100099"
			cTipoDoc := '22'
		case alltrim( cEspecie )== "NFA"
			cTipoDoc := '01'
		case Alltrim( cEspecie )$ "NF/SPED/NTST/NFCEE"
			cTipoDoc := '10'
		case Alltrim( cEspecie )== "CA"
			cTipoDoc := '08'
		case Alltrim( cEspecie )$ "CTR/CTE"
			cTipoDoc := '07'
		OtherWise
			cTipoDoc := ''
	endcase
endif

return cTipoDoc

//-----------------------------------------------------------------------
/*/{Protheus.doc} Emitente
Geração do conjunto emitente
@author Raphael Augustos
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function Emitente(cUF, lDifal)
Local cString	:= ""
Local cInsc		:= ""
Local cEmail	:= ""
Local cFoneEmi	:= ""
Local aTelEmi	:= {}

Default cUF		:= ""
//Emitente
cInsc 	 := IESubTrib(cUF, lDifal)
cEmail	 := GetNewPar("MV_EMAILGN","")

aTelEmi	 := FisGetTel(SM0->M0_TEL,,,.T.)
cFoneEmi := aTelEmi[2] // Código da Área
cFoneEmi += aTelEmi[3] // Código do Telefone

cString	+= '<emitente>'

cString	+= '<cnpjcpf>' + SM0->M0_CGC + '</cnpjcpf>'
cString	+= '<nome>' + ConvType(SM0->M0_NOMECOM) + '</nome>'
cString	+= '<ie>' + cInsc + '</ie>'
cString	+= '<endereco>' + ConvType(SM0->M0_ENDENT) + '</endereco>'
cString	+= '<municipio>' + alltrim(SM0->M0_CODMUN) + '</municipio>'
cString	+= '<descmun>' + alltrim(SM0->M0_CIDENT) + '</descmun>'
cString	+= '<uf>' + alltrim(SM0->M0_ESTENT) + '</uf>'
cString	+= '<cep>' + allTrim(SM0->M0_CEPENT) + '</cep>'
cString	+= '<telefone>' + cFoneEmi + '</telefone>'
cString	+= '<email>' + alltrim(cEmail) + '</email>'
cString	+= '<inscufavorecida>' + iif(!empty(cInsc), "1","2") + '</inscufavorecida>' // Indica se tem ou não IE na UF favorecida para utilização do TSS

cString	+= '</emitente>'
Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} Valores
Geração do conjunto Valores
@author Raphael Augustos
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function Valores(cAliasSF6, nQtd, cVersao)
Local cString		:= ""
Local nValPrinc		:= 0
Local nValTotal		:= 0
Local nValFecp		:= 0
Local lExcecao		:= cVersao >= "2.00" .And. (cAliasSF6)->F6_EST $ "GO/RR"
Local nValFund		:= Iif( (cAliasSF6)->(Fieldpos("F6_VALFUND")) > 0, (cAliasSF6)->F6_VALFUND, 0 ) 
Local lGerAgrup		:= Iif((cAliasSF6)->F6_EST $ SuperGetMv("MV_SOMAGNR"), .T., .F.)

Default nQtd		:= 0

nValPrinc := (cAliasSF6)->F6_VALOR

If lExcecao // Ao transmitir guia para o estado de Goias e Roraima não devem ser informadas as tags atumonetaria, juros e multa, pois é retornada rejeicao 700. 
	nValTotal := (cAliasSF6)->F6_VALOR
Else
	nValTotal := (cAliasSF6)->F6_VALOR + (cAliasSF6)->F6_ATMON + (cAliasSF6)->F6_JUROS + (cAliasSF6)->F6_MULTA
EndIf


If nValFund > 0 
	nValFecp := nValFund
Else
	// Só executará a função Valfep quando não existir o campo F6_VALFUND ou se o seu valor for zerado.
	//Para que a função seja executada existe uma checagem se a Guia é diferente de FECP pois a guia aglutinada é gerada como o imposto principal (ST/Difal)
	//A checagem se o estado da guia é igual a RJ se deve ao fato de que quando se trata do RJ sempre é gerado aglutinado ST+FECP, a chacagem do parametro MV_SOMAGNR se deve pois este parametro é usado para gerar guias de Difal agrupadas.   
	nValFecp := Iif((cAliasSF6)->F6_FECP == '2' .And. (lGerAgrup .Or. (cAliasSF6)->F6_EST == "RJ") .And. (cAliasSF6)->F6_TIPOIMP $ "3B" , ValFecp((cAliasSF6)->F6_DOC, (cAliasSF6)->F6_SERIE, (cAliasSF6)->F6_OPERNF, (cAliasSF6)->F6_TIPOIMP, (cAliasSF6)->F6_NUMERO, (cAliasSF6)->F6_MESREF, (cAliasSF6)->F6_ANOREF, (cAliasSF6)->F6_VALOR), 0)
Endif

cString	+= '<valores>'

If !lExcecao // Ao transmitir guia para o estado de Goias e Roraima não devem ser informadas as tags atumonetaria, juros e multa, pois é retornada rejeicao 700. 
	cString	+= '<atumonetaria tipo="51">'+ ConvType((cAliasSF6)->F6_ATMON,15,2)  + '</atumonetaria>'
	cString	+= '<juros tipo="41">' + ConvType((cAliasSF6)->F6_JUROS,15,2) + '</juros>'
	cString	+= '<multa tipo="31">' + ConvType((cAliasSF6)->F6_MULTA,15,2) + '</multa>'
EndIf
cString	+= '<valordeducao>' + ConvType((cAliasSF6)->F6_VIMPDED,15,2) + '</valordeducao>'
If nValFecp > 0
	cString	+= '<principal tipo="11">' + ConvType(nValPrinc - nValFecp,15,2) + '</principal>'
	cString += '<principal tipo="12">' + ConvType(nValFecp,15,2) + '</principal>'
	cString	+= '<total tipo="21">' + ConvType(nValTotal - nValFecp,15,2) + '</total>'
	cString += '<total tipo="22">' + ConvType(nValFecp,15,2) + '</total>'
Else
	cString	+= '<principal tipo="11">' + ConvType(nValPrinc,15,2) + '</principal>'
	If !(cAliasSF6)->F6_EST == "RR" // Para o estado de Roraima a tag tipo 21 não é aceita em conjunto com a tag 11
		cString	+= '<total tipo="21">' + ConvType(nValTotal,15,2) + '</total>'
	Endif
EndIf
cString	+= '<atualizacao>' + Iif(nValTotal-nValPrinc > 0,ConvType(nValTotal,15,2),ConvType(nValTotal-nValPrinc,15,2)) + '</atualizacao>'
cString	+= '<qtde>' + ConvType(nQtd,15,2) + '</qtde>'
cString	+= '</valores>'
Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} Destinatario
Geração do conjunto Destinatario
@author Raphael Augustos
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function Destinatario(aDestinat)
Local cString		:= ""
Local cCpfCnpj 		:= ""
Local cInscDest 	:= ""
Local cNomeDest 	:= ""
Local cMunDest 		:= ""
Local cDescMunDs 	:= ""
Local cCodArea		:= ""
Default aDestinat	:= {}

If len(aDestinat) > 0
	cCpfCnpj	:= allTrim(aDestinat[1,1])
	cInscDest	:= allTrim(aDestinat[1,2])
	cNomeDest	:= allTrim(aDestinat[1,3])
	cMunDest	:= allTrim(aDestinat[1,4])
	cDescMunDs	:= allTrim(aDestinat[1,5])
	cCodArea	:= SubStr(allTrim(aDestinat[1,4]),1,2)
EndIf

cString	+= '<destinatario>'
cString	+= '<cnpjcpf>' + cCpfCnpj + '</cnpjcpf>'
cString	+= '<ie>' + cInscDest + '</ie>'
cString	+= '<nome>' + ConvType(cNomeDest) + '</nome>'
cString	+= '<municipio>' + cMunDest + '</municipio>'
cString	+= '<descmun>' + cDescMunDs + '</descmun>'
cString	+= '<inscufavorecida>' + iif(!empty(cInscDest), "1","2") + '</inscufavorecida>' // Indica se tem ou não IE na UF favorecida para utilização do TSS
cString	+= '</destinatario>'

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} Referencia
Geração do conjunto Referencia
@author Raphael Augustos
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function Referencia(cAliasSF6)
Local cString	:= ""

cString	+= '<referencia>'
cString	+= '<periodo>' + iif(! empty((cAliasSF6)->F6_REF) .And. (cAliasSF6)->F6_REF$"1","0","") + '</periodo>'
cString	+= '<mes>' + strzero((cAliasSF6)->F6_MESREF,2) + '</mes>'
cString	+= '<ano>' + cvaltochar((cAliasSF6)->F6_ANOREF) + '</ano>'
cString	+= '<parcela>1</parcela>'
cString	+= '</referencia>'
Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} Transporte
Geração do conjunto Transporte
@author Raphael Augustos
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function Transporte(cAliasSF6)
Local cString	:= ""

cString	+= '<transporte>'
cString	+= '<manifcarga></manifcarga>'
cString	+= '<cti></cti>'
cString	+= '<dtdesmbaraco></dtdesmbaraco>'
cString	+= '<manifcarga></manifcarga>'
cString	+= '<valoradua></valoradua>'
cString	+= '</transporte>'
Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} Sintegra
Geração do conjunto Sintegra
@author Raphael Augustos
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function Sintegra(cAliasSF6)
Local cString	:= ""

cString	+= '<sintegra>'
cString	+= '<protocoloTED></protocoloTED>'
cString	+= '<justificativa></justificativa>'
cString	+= '</sintegra>'
Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} Campoadic
Geração do conjunto Campoadic
@author Simone dos Santos de Oliveira
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function Campoadic(cAliasSF6)
Local cString	:= ""
Local cExtra	:= ""
Local lGera		:= .T.
Local lObriga	:= .F.
Local nX		:= 1
Local aInfAdic	:= {}

aInfAdic := RetCampAdic( AllTrim((cAliasSF6)->F6_EST), AllTrim((cAliasSF6)->F6_CODREC) )

for nX:= 1 to len( aInfAdic )

	cCodAdic := alltrim(aInfAdic [nX,1])
	cTpAdic  := alltrim(aInfAdic [nX,2])
	cValor   := AllTrim( RetVlrAdic( aInfAdic [nX,3], cAliasSF6 ) )
	lObriga  := iif( aInfAdic [nX,4]$'1S', .T., .F. )
	cTitulo  := alltrim(upper(aInfAdic [nX,5]))
	cCodInt  := alltrim(aInfAdic [nX,6])

	if lObriga .or. ! empty( cValor )

		//Tratamento quando for do tipo Data
		if cTpAdic $ 'D'
			cValor := substr(cValor,1,4)+ '-' + substr(cValor,5,2) + '-' + substr(cValor,7,2)
		endif

		//Tratamento para considerar apenas uma Chave quando há mais de uma Chave cadastrada na tabela F0N
		if cCodInt == 'CHV'

			//Tratamento quando a espécie é SPED
			cEspecie	:= iif( cEspecie == 'SPED', 'NFE', cEspecie)

			if ! empty(cEspecie)
				if ! (cEspecie $  cTitulo .or. ( cEspecie == 'NFE' .and. cTitulo $ 'CHAVE DE ACESSO|CHAVE DA NOTA FISCAL ELETRONICA' ))
					lGera := .f.
				endif
			endif

		endif

		if lGera
			cExtra	+= '<campoadic>'
			cExtra	+= '<cod>' +  cCodAdic + '</cod>'
			cExtra	+= '<tipo>' + cTpAdic +'</tipo>'
			cExtra	+= '<valor>' + cValor + '</valor>'
			cExtra	+= '</campoadic>'
		endif
	endif

next

If ! empty( cExtra )
	cString	+= '<camposadic>'
		cString += cExtra
	cString	+= '</camposadic>'
EndIf
Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} IdentGNRE
Geração do conjunto IdentGNRE
@author Raphael Augustos
@since 10/10/2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function IdentGNRE(cAliasSF6,nQtd,aDestinat, cVersao)
Local cString	 := ""
Local cCodRec	 := ""
Local cUF		 := ""
Local cNumGNRE	 := alltrim((cAliasSF6)->F6_NUMERO)
Local lVerTagRJ	 := .F.
Local cPerApur	 := AllTrim((cAliasSF6)->F6_REF)
Local cTpDocOrig := ""
Local cCpfCnpj   := ""
Local cEmissNF   := ""
Local cNumeroNF  := ""
Local cSerieNf   := ""
Local cTipoNf    := ""
Local cChvNFe    := ""
Local cCodArea   := ""
Local cProduto	 := ""
Local lF6CODAREA := SF6->(FieldPos("F6_CODAREA")) > 0

//Código Receita
cCodRec	:= alltrim((cAliasSF6)->F6_CODREC)
cUF		:= alltrim((cAliasSF6)->F6_EST)
//Para RJ e Receita 100099 -> exceto para natureza = 4 - Substituicao Tributaria por Responsabilidade.
lVerTagRJ := cUF=="RJ".And.cCodRec$"100099"
cProduto := iif(! empty((cAliasSF6)->F6_CODPROD), cValtoChar((cAliasSF6)->F6_CODPROD),"")

cString	+= '<identgnre>'
cString	+= '<uf>' + cUF + '</uf>'
cString	+= '<numerognre>' +  cNumGNRE  + '</numerognre>'
cString	+= '<receita>' + cCodRec + '</receita>'
cString	+= '<detreceita>' + allTrim((cAliasSF6)->F6_DETRECE) + '</detreceita>'
cString	+= '<produto>' + cProduto + '</produto>'
cString	+= '<vencimento>' + dtos((cAliasSF6)->F6_DTVENC)  + '</vencimento>'
cString	+= '<convenio>' + allTrim((cAliasSF6)->F6_NUMCONV) + '</convenio>'
cString	+= '<pagamento>' + dtos((cAliasSF6)->F6_DTPAGTO) + '</pagamento>'
cString	+= Iif(lVerTagRJ,'','<fatogerador>' + Iif(valtype((cAliasSF6)->F6_DTARREC)=="D",dtos((cAliasSF6)->F6_DTARREC),(cAliasSF6)->F6_DTARREC) + '</fatogerador>')
cString	+= '<tipoperiodoapur>' + Iif( !Empty(cPerApur) , cPerApur , "0"  ) + '</tipoperiodoapur>'
cString	+= Iif(lVerTagRJ,'','<mesref>'+ ConvType((cAliasSF6)->F6_MESREF) + '</mesref>')
cString	+= Iif(lVerTagRJ,'','<anoref>' + ConvType((cAliasSF6)->F6_ANOREF) + '</anoref>')
cString	+= '<decref></decref>'
cString	+= '<observacoes>' + ConvType((cAliasSF6)->F6_OBSERV)+ '</observacoes>'
cString	+= '<informacoes>' + ConvType((cAliasSF6)->F6_INF) + '</informacoes>'
cString	+= '<infcompl>' + ConvType((cAliasSF6)->F6_DESCOMP) + '</infcompl>'
cString	+= '<dtsaimerc></dtsaimerc>'
cString	+= '<diavencimento></diavencimento>'
cString	+= '<tipoimport></tipoimport>'

//Demais informações GNRE
cString	+= '<banco>'+ AllTrim((cAliasSF6)->F6_BANCO) +'</banco>'
cString	+= '<agencia>' + AllTrim((cAliasSF6)->F6_AGENCIA) + '</agencia>'
cString	+= '<classevcto>' + AllTrim((cAliasSF6)->F6_CLAVENC) + '</classevcto>'
cString	+= '<cnpjcontrib>' + AllTrim((cAliasSF6)->F6_CNPJ) + '</cnpjcontrib>'
cString	+= '<vencaut>' + AllTrim((cAliasSF6)->F6_VENCAUT) + '</vencaut>'
cString	+= '<docorigem>' + AllTrim((cAliasSF6)->F6_DOCOR) + '</docorigem>'
cString	+= '<autentbanc>' + AllTrim((cAliasSF6)->F6_AUTENT) + '</autentbanc>'
cString	+= '<numproc>' + AllTrim((cAliasSF6)->F6_NUMPROC) + '</numproc>'
cString	+= '<indproc>' + AllTrim((cAliasSF6)->F6_INDPROC) + '</indproc>'
cString	+= '<pedidodeducao>' + AllTrim((cAliasSF6)->F6_PEDDED) + '</pedidodeducao>'
cString	+= '<issor>' + AllTrim((cAliasSF6)->F6_ISSOR) + '</issor>'
cString	+= '<codmuniss>' + AllTrim((cAliasSF6)->F6_CODMUN) + '</codmuniss>'


//Nota Fiscal - Quando for por operação
If !( empty((cAliasSF6)->F6_DOC) .And. empty((cAliasSF6)->F6_SERIE) .And. empty((cAliasSF6)->F6_CLIFOR) .And. empty((cAliasSF6)->F6_LOJA) )

	dbselectarea("SF3") //Livros Fiscais
	SF3->(dbsetorder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

	If SF3->(dbseek(xFilial("SF3")+ (cAliasSF6)->F6_CLIFOR + (cAliasSF6)->F6_LOJA + (cAliasSF6)->F6_DOC + (cAliasSF6)->F6_SERIE))

		cEmissNF	:= dtos(SF3->F3_EMISSAO)
		cNumeroNF	:= alltrim(SF3->F3_NFISCAL)
		cSerieNf	:= alltrim(SF3->F3_SERIE)
		cEspecie	:= alltrim(SF3->F3_ESPECIE)
		cTipoNf	:= iif(cEspecie=="SPED","NF-e","M")
		cChvNFe	:= alltrim(SF3->F3_CHVNFE)

		//Tipo Doc Origem
		cTpDocOrig :=	RetTpDoc( alltrim(SF3->F3_ESPECIE),cUF,cCodRec)
		cTpDocOrig := iif(! empty( cTpDocOrig ), cTpDocOrig,(cAliasSF6)->F6_TIPODOC)

		//Informações Fornecedor / Cliente
		IF SUBSTR(SF3->F3_CFO,1,1 )$ "123"//Fornecedor
			aDestinat := RetDest(SF3->F3_CLIEFOR, SF3->F3_LOJA, (cAliasSF6)->F6_OPERNF, (cAliasSF6)->F6_TIPODOC, cAliasSF6, cVersao)
		ELSE//Cliente. Neste caso é usado cliente entrega para compor a parte de destinatário
			aDestinat := RetDest(SF3->F3_CLIENT, SF3->F3_LOJENT, (cAliasSF6)->F6_OPERNF, (cAliasSF6)->F6_TIPODOC, cAliasSF6, cVersao)
		ENDIF

		If len(aDestinat) > 0
			cCpfCnpj	:= allTrim(aDestinat[1,1])
			cInscDest	:= allTrim(aDestinat[1,2])
			cNomeDest	:= allTrim(aDestinat[1,3])
			cMunDest	:= allTrim(aDestinat[1,4])
			cDescMunDs	:= allTrim(aDestinat[1,5])
			If lF6CODAREA .And. cVersao == "1.00" .And. AllTrim(aDestinat[1,6]) == 'ES'
				cCodArea	:= Alltrim((cAliasSF6)->F6_CODAREA)
			Else
				cCodArea	:= SubStr(allTrim(aDestinat[1,4]),1,2)
			EndIf	
		EndIf

		DbSelectArea("SFT")
		SFT->(DbSetOrder(1))

		If SFT->(DbSeek(xFilial("SFT")+Iif((cAliasSF6)->F6_OPERNF == '1','E','S')+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			nQtd	:= SFT->FT_QUANT
		EndIf
	EndIf
EndIf

If !lExtCPOTag .Or. (lExtCPOTag .And. Empty((cAliasSF6)->F6_TIPOGNU))
	If (cTpDocOrig == '10' .Or. (cTpDocOrig == '22' .And. cUF == 'PE')) .And. cVersao >= '2.00'
		cString	+= '<docorig>' + cChvNFe + '</docorig>'
	Else
		cString	+= '<docorig>' + allTrim((cAliasSF6)->F6_DOC) + '</docorig>'
	EndIf

	cString	+= '<tipodocorig>' + allTrim(cTpDocOrig) + '</tipodocorig>'
Else
	If (cAliasSF6)->F6_DOCORIG $ '2' .And. cVersao >= '2.00'
		cString	+= '<docorig>' + cChvNFe + '</docorig>'
	Else
		cString	+= '<docorig>' + allTrim((cAliasSF6)->F6_DOC) + '</docorig>'
	EndIf

	// É verificado se o campo é Numérico pois eventualmente ele será corrigido para Caracter
	cString	+= '<tipodocorig>' +;
		IIF( ValType( (cAliasSF6)->F6_TIPOGNU ) == "N", StrZero( (cAliasSF6)->F6_TIPOGNU, 2 ), allTrim((cAliasSF6)->F6_TIPOGNU) ) +;
		'</tipodocorig>'
EndIf

cString	+= '<cnpjcpfnf>'+ cCpfCnpj + '</cnpjcpfnf>'
cString	+= '<dataemissaonf>'+ cEmissNF + '</dataemissaonf>'
cString	+= '<numeronf>'+ cNumeroNF + '</numeronf>'
cString	+= '<serienf>'+ cSerieNf + '</serienf>'
cString	+= '<tiponf>'+ cTipoNf + '</tiponf>'
cString	+= '<chavenf>'+ cChvNFe + '</chavenf>'
cString	+= '<codarea>'+ cCodArea + '</codarea>'
cString	+= '</identgnre>'

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} GeraItem
Função responsável por gerar o corpo do XML da GNRE.
@author Raphael Augustos Ferreira
@since 17.10.2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function GeraItem( cAliasSF6, lLote)
Local cString 	 := ""
Local nQtd		 :=  0
Local cVersao	 := GetMv('MV_GNREVE' ,,'1.00')
Local aDestinat	 := {}
Private cEspecie := ""


If cVersao >= "2.00"
	cString += '<item>'
EndIf

cString	+= IdentGNRE(cAliasSF6,@nQtd,@aDestinat, cVersao)
// Emitente
If cVersao == "1.00"
	cString	+= Emitente( (cAliasSF6)->F6_EST )
EndIf
//Valores
nValPrinc := (cAliasSF6)->F6_VALOR
nValTotal := (cAliasSF6)->F6_VALOR + (cAliasSF6)->F6_ATMON + (cAliasSF6)->F6_JUROS + (cAliasSF6)->F6_MULTA
cString	+= Valores(cAliasSF6, nQtd, cVersao)
//Destinatário
cString	+= Destinatario(aDestinat)
//Referencia
cString	+= Referencia(cAliasSF6)
//Transporte
cString	+= Transporte(cAliasSF6)
//Sintegra
cString	+= Sintegra(cAliasSF6)
//Campos Adicionais
cString	+= Campoadic(cAliasSF6)

If cVersao >= "2.00"
	cString += '</item>'
EndIf

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} TpGNRE
Retorna o tipo da guia
@author Raphael Augustos Ferreira
@since 17.10.2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function TpGNRE(cAliasSF6,lLote)
Local cRet	:= "0"

If lLote
	cRet	:= (cAliasSF6)->CIB_TPGNRE
EndIf
Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TotGNRE
Retorna o Total da GNRE na versão 2.0
@author Raphael Augustos Ferreira
@since 17.10.2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function TotGNRE(cAliasSF6,lLote)
Local nValor	:= (cAliasSF6)->F6_VALOR + (cAliasSF6)->F6_ATMON + (cAliasSF6)->F6_JUROS + (cAliasSF6)->F6_MULTA

If lLote
	nValor	:= (cAliasSF6)->CIB_VALOR + (cAliasSF6)->CIB_ATUMON + (cAliasSF6)->CIB_MULTA  + (cAliasSF6)->CIB_JUROS
EndIf
Return nValor

//-----------------------------------------------------------------------
/*/{Protheus.doc} DtPgto
Retorna a Data de Pagamento da GNRE 2.0
@author Raphael Augustos Ferreira
@since 17.10.2019
@version 12.25
/*/
//-----------------------------------------------------------------------
Static Function DtPgto(cAliasSF6,lLote)
Local dData 	:= (cAliasSF6)->F6_DTPAGTO

If lLote
	dData	:= (cAliasSF6)->CIB_DTPGTO
EndIf
Return dData

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValFecp
Retorna valor do FECP
@author pereira.weslley
@since 31.03.2021
@version 12.1.27
/*/
//-----------------------------------------------------------------------
Static Function ValFecp(cNFiscal,cSerie,cOperNF,cTipoImp,cNumGuia,nMes,nAno,nValor)
Local nValFecp 		:= 0
Local aInsert 		:= {}
Local nLen 			:= 0 
Local nPosPrepared	:= 0 
Local cMD5 			:= "" 
Local nX			:= 0
Local cSelect    	:= ""
Local cFrom 		:= ""
Local cWhere		:= ""
Local cAliasQry		:= ""
Local dDatIni 		:= CTOD('01/'+strzero(nMes)+'/'+strzero(nAno))
Local dDatFim 		:= LastDay(CTOD('01/'+strzero(nMes)+'/'+strzero(nAno)))


Default cTipoImp	:= ""
Default nValor		:= 0 

//Só irá executar a quey abaixo quando as guias forem agrupadas para assim gerar as TAGS 11, 12, 21 e 22 separadamente, caso contrário não há a necessidade da geração dos mesmos.
//Secao do select
Aadd(aInsert,AllTrim(STR(nValor)))
If cTipoImp == "B" 
	cSelect := "(CASE WHEN ? "
	cSelect += " = (FT_DIFAL + FT_VFCPDIF) THEN  'A' ELSE 'E'  END) TIPOVAL, FT_VFCPDIF VALFECP"    
ElseIf cTipoImp == "3"
	cSelect := "(CASE WHEN ? "
	cSelect += " = FT_VFECPST THEN  'A' ELSE 'E'  END) TIPOVAL, FT_VFECPST VALFECP"
Endif	

//Secao do From
cFrom += RetSqlName("CDC") + " CDC " 
cFrom += " INNER JOIN " + RetSQLName("SFT") + " "

Aadd(aInsert,cValToChar(xFilial("SFT")))
cFrom += " SFT ON SFT.FT_FILIAL = ? "
cFrom += " AND CDC.CDC_DOC = SFT.FT_NFISCAL " 
cFrom += " AND CDC.CDC_SERIE = SFT.FT_SERIE " 

Aadd(aInsert, Iif(cOperNF == "1", 'E', 'S'))
cFrom += "AND SFT.FT_TIPOMOV = ? "

Aadd(aInsert,cSerie)
cFrom += "AND SFT.FT_SERIE = ? "

Aadd(aInsert,cNFiscal)
cFrom += "AND SFT.FT_NFISCAL = ? "

Aadd(aInsert,DTOS(dDatIni))
cFrom += "AND SFT.FT_ENTRADA >= ? "

Aadd(aInsert,DTOS(dDatFim))
cFrom += "AND SFT.FT_ENTRADA <= ? "

cFrom += "AND SFT.D_E_L_E_T_ = ' ' "

	//Secao do Where
Aadd(aInsert,cValToChar(xFilial("CDC")))
cWhere += "CDC.CDC_FILIAL = ? "

Aadd(aInsert,cNumGuia)
cWhere += "AND CDC.CDC_GUIA = ? " 

cWhere += " AND CDC.D_E_L_E_T_ = ' ' ORDER BY TIPOVAL"

cQuery := " SELECT " + cSelect + " FROM " + cFrom + " WHERE " + cWhere

nLen := Len(aInsert)
cMD5 := MD5(cQuery)
If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
	Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
	nPosPrepared := Len(__aPrepared)
	__aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
EndIf 
For nX := 1 to nLen
	__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX])
Next 

cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()

aInsert := aSize(aInsert,0)

cAliasQry := GetNextAlias()

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

DbSelectArea(cAliasQry)	
(cAliasQry)->(DbGotop())
While (cAliasQry)->(!EOF()) 
	If (cAliasQry)->TIPOVAL == "A"
		nValFecp := (cAliasQry)->VALFECP
		Exit
	Else
		nValFecp += (cAliasQry)->VALFECP
	Endif	
	(cAliasQry)->(DbSkip())
Enddo

(cAliasQry)->(DBCloseArea())


Return nValFecp


Static Function fGetMunDua(cMunIBGE)

Local aMunDua 		:= {}
Local nPos	  		:= 0	
Local cCodMunDua	:= ""	

	aMunDua	:=	{ {"57053", "VITORIA"                , "05309"},;
				  {"57037", "VILA VELHA"             , "05200"},;
				  {"7684" , "VILA VALERIO"           , "05176"},;
				  {"29351", "VILA PAVAO"             , "05150"},;
				  {"57010", "VIANA"                  , "05101"},;
				  {"57290", "VENDA NOVA DO IMIGRANTE", "05069"},;
				  {"57274", "VARGEM ALTA"            , "05036"},;
				  {"7668" , "SOORETAMA"              , "05010"},;
				  {"56995", "SERRA"                  , "05002"},;
				  {"7641" , "SAO ROQUE DO CANAA"     , "04955"},;
				  {"56979", "SAO MATEUS"             , "04906"},;
				  {"56952", "SAO JOSE DO CALCADO"    , "04807"},;
				  {"56936", "SAO GABRIEL DA PALHA"   , "04708"},;
				  {"29335", "SAO DOMINGOS DO NORTE"  , "04658"},;
				  {"56910", "SANTA TERESA"           , "04609"},;
				  {"57258", "SANTA MARIA DE JETIBA"  , "04559"},;
				  {"56898", "SANTA LEOPOLDINA"       , "04500"},;
				  {"56871", "RIO NOVO DO SUL"        , "04401"},;
				  {"57118", "RIO BANANAL"            , "04351"},;
				  {"56855", "PRESIDENTE KENNEDY"     , "04302"},;
				  {"7625" , "PONTO BELO"             , "04252"},;
				  {"56839", "PIUMA"                  , "04203"},;
				  {"56812", "PINHEIROS"              , "04104"},;
				  {"57150", "PEDRO CANARIO"          , "04054"},;
				  {"56790", "PANCAS"                 , "04005"},;
				  {"56774", "NOVA VENECIA"           , "03908"},;
				  {"56758", "MUQUI"                  , "03809"},;
				  {"56731", "MUNIZ FREIRE"           , "03700"},;
				  {"56715", "MUCURICI"               , "03601"},;
				  {"56693", "MONTANHA"               , "03502"},;
				  {"56677", "MIMOSO DO SUL"          , "03403"},;
				  {"57070", "MARILANDIA"             , "03353"},;
				  {"29297", "MARECHAL FLORIANO"      , "03346"},;
				  {"7609" , "MARATAIZES"             , "03320"},;
				  {"56650", "MANTENOPOLIS"           , "03304"},;
				  {"56634", "LINHARES"               , "03205"},;
				  {"57231", "LARANJA DA TERRA"       , "03163"},;
				  {"57215", "JOAO NEIVA"             , "03130"},;
				  {"56618", "JERONIMO MONTEIRO"      , "03106"},;
				  {"57134", "JAGUARE"                , "03056"},;
				  {"56596", "IUNA"                   , "03007"},;
				  {"56570", "ITARANA"                , "02900"},;
				  {"56553", "ITAPEMIRIM"             , "02801"},;
				  {"56537", "ITAGUACU"               , "02702"},;
				  {"29319", "IRUPI"                  , "02652"},;
				  {"56510", "ICONHA"                 , "02603"},;
				  {"60119", "IBITIRAMA"              , "02553"},;
				  {"56499", "IBIRACU"                , "02504"},;
				  {"57096", "IBATIBA"                , "02454"},;
				  {"56472", "GUARAPARI"              , "02405"},;
				  {"56456", "GUACUI"                 , "02306"},;
				  {"11142", "GOVERNADOR LINDEMBERG"  , "11142"},;
				  {"56430", "FUNDAO"                 , "02207"},;
				  {"56413", "ECOPORANGA"             , "02108"},;
				  {"56391", "DORES DO RIO PRETO"     , "02009"},;
				  {"56375", "DOMINGOS MARTINS"       , "01902"},;
				  {"56359", "DIVINO SAO LOURENCO"    , "01803"},;
				  {"56332", "CONCEICAO DO CASTELO"   , "01704"},;
				  {"56316", "CONCEICAO DA BARRA"     , "01605"},;
				  {"56294", "COLATINA"               , "01506"},;
				  {"56278", "CASTELO"                , "01407"},;
				  {"56251", "CARIACICA"              , "01308"},;
				  {"56235", "CACHOEIRO DE ITAPEMIRIM", "01209"},;
				  {"7587" , "BREJETUBA"              , "01159"},;
				  {"56219", "BOM JESUS DO NORTE"     , "01100"},;
				  {"56197", "BOA ESPERANCA"          , "01001"},;
				  {"56170", "BARRA DE SAO FRANCISCO" , "00904"},;
				  {"56154", "BAIXO GUANDU"           , "00805"},;
				  {"56138", "ATILIO VIVACQUA"        , "00706"},;
				  {"56111", "ARACRUZ"                , "00607"},;
				  {"56090", "APIACA"                 , "00508"},;
				  {"56073", "ANCHIETA"               , "00409"},;
				  {"57193", "ALTO RIO NOVO"          , "00359"},;
				  {"56057", "ALFREDO CHAVES"         , "00300"},;
				  {"56030", "ALEGRE"                 , "00201"},;
				  {"57339", "AGUIA BRANCA"           , "00136"},;
				  {"57177", "AGUA DOCE DO NORTE"     , "00169"},;
				  {"56014", "AFONSO CLAUDIO"         , "00102"} }

	If (nPos := aScan(aMunDua,{|x| Alltrim(x[3]) == Alltrim(cMunIBGE)})) > 0
		cCodMunDua := aMunDua[nPos][1]
	EndIf
Return cCodMunDua
