#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCOC();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCOC()
@description Classe que terá as informações específicas para geração dos 
			   registros do bloco C no SPED Contribuições. Esta classe
			   herda as propriedades e métodos da classe NOTAEFD, então aqui
			   teremos somente as propriedades pertinentes ao bloco C, bem
			   como os método para gravação dos registros, respeitando formatos
			   e hierarquia. 

@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCOC FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO DO DOCUMENTO FISCAL
//-----------------------------------------------------
Data nnAbatim		as Integer		READONLY		//Valor do abatimento não tributável			
Data nnVlMerc		as Integer		READONLY		//Valor total da mercadoria
Data nnVlFrete		as Integer		READONLY		//Valor do Frete
Data nnSeguro		as Integer		READONLY		//Valor do seguro
Data nnDespesa		as Integer		READONLY		//Valor da despesas acessórias
Data nnBsIcms		as Integer		READONLY		//Base de cálculo de ICMS
Data nnVlIcms		as Integer		READONLY		//Valor de ICMS
Data nnBsIcmsSt		as Integer		READONLY		//Base de cálculo ICMS ST
Data nnVlIcmsSt		as Integer		READONLY		//Valor do ICMS ST
Data nnIPI			as Integer		READONLY		//Valor do IPI
Data nnPisSt		as Integer		READONLY		//Valor do PIS St
Data nnCofSt		as Integer		READONLY		//Valor da COFINS ST
Data nnConKwh		as Integer		READONLY		//COnsumo total em Kw
Data nnVlNTrib		as Integer		READONLY		//Valor não tributado de ICMS
Data nnVlTerc		as Integer		READONLY		//Valor cobrado por terceiros
Data nnVlForn		as Integer		READONLY		//Valor acumulado de fornecimento
Data cnIndPgto		as String		READONLY		//Indicador de pagamento
Data cnTpFrt		as String		READONLY		//Tipo de Frete
Data cnCodMun		as String		READONLY		//Código do município
Data cnClsCon		as String		READONLY		//Classe de consumo
Data nnValCanc		as String		READONLY		//Valor do Documento Cancelado
Data cnNumNfIni		as String		READONLY		//N?mero inicial do documento
Data lBuild     	As Boolean
Data cChvAtuC600	as String		READONLY		//Chave de busca usada para "agrupar" documentos no Registro C600
Data cChvAntC600	as String		READONLY		//Chave de busca do processamento anterior usada para "agrupar" documentos no Registro C600

//-------------------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO AO ITEM DO DOCUMENTO FISCAL
//-------------------------------------------------------------
Data ciDescri		as String		READONLY		//Descrição Complementar do Item	
Data ciUnMed		as String		READONLY		//Unidade de medida do produto
Data ciIndMvto		as String		READONLY		//Indicador de Movimentação física do produto
Data ciCSTICMS		as String		READONLY		//CST do ICMS
Data ciNatOper		as String		READONLY		//Natureza Da operação
Data ciIndIpi		as String		READONLY		//Indicador de Apuração do IPI
Data ciCstIpi		as String		READONLY		//CST de IPI
Data ciEnqIpi		as String		READONLY		//Enquadramento da apuração do IPI
Data ciInfComp		as String		READONLY		//Informação Complementar
Data ciNcm			as String		READONLY		//NCM do produto
Data ciExNcm		as String		READONLY		//Extensão do código de NCM
Data ciCnpj			as String		READONLY		//CNPJ do Participante
Data niBasIcms		as Integer		READONLY		//Base de cálculo do ICMS
Data niAlqIcms		as integer		READONLY		//Alíqutoa do ICSM
Data niICMSDC		as Integer		READONLY		//Valor do ICMS debitado/creditado
Data niAlqcmsSt		as Integer		READONLY		//Alíquota do ICMS ST
Data niBsIcmsSt		as Integer		READONLY		//Base de cálculo do ICMS ST
Data niICMSST		as Integer		READONLY		//Valor do ICMS ST
Data niBasIpi		as Integer		READONLY		//Base de Cálculo do IPI
Data niAlqIpi		as Integer		READONLY		//Alíquota do IPI
Data niIpiDC		as Integer		READONLY		//Valor do IPI creditado ou debitado
Data niPisQtde		as Integer		READONLY		//Base de cálculo em quantidade de PIS
Data niPautPis		as Integer		READONLY		//Valor da Pauta de PIS/Alíquota em reais
Data niCofQtde		as Integer		READONLY		//Base de cálculo em quantidade de COFINS
Data niPautcof		as Integer		READONLY		//Valor da Pauta de COFINS/Alíquota em reais
Data cCodInfCom		as String		READONLY		//Código da Informação Complementar
Data cNumSAT		as String		READONLY		//Número de Série do equipamento SAT

//-------------------------------------------------------------
//ATRIBUTOS REFERENTE AO REGISTRO DE IMPORTAÇÃO
//-------------------------------------------------------------
Data cDocImp		as String		READONLY		//Documento de Importação		
Data cNumImp		as String		READONLY		//Número do documento de Importação
Data cDrawBack		as String		READONLY		//Númedo DrawBack
Data nVlPisImp		as Integer		READONLY		//valor do Pis pago na importação
Data nVlCofImp		as Integer		READONLY		//valor da COFINS paga na importação

//-------------------------------------------------------------
//ATRIBUTOS ESPECÍFICOS PARA REGISTROS DE CUPOM FISCAL
//-------------------------------------------------------------
Data cModEcf		as String		READONLY		//Modelo do equipamento emissor de ECF
Data cSerEcf		as String		READONLY		//Número de série do equipamento ECF
Data cNumEcf		as String		READONLY		//Número do caixa ECF
Data cCro			as String		READONLY		//Posição do contador de reinício da operação
Data cCrZ			as String		READONLY		//Posição do contador da redução Z
Data cNumCont		as String		READONLY		//Número de contador final
Data nVlGrade		as Integer		READONLY		//Valor total da grade
Data nVlBrut		as Integer		READONLY		//Valor da Venda Bruta
Data dDtRedZ		as Date			READONLY		//Dia da redução Z
		
//-------------------------------------------------------------
//ARRAYS DO BLOCO C
//-------------------------------------------------------------
Data aRegC100		as Array		READONLY		//Array com informações do registro C100
Data aRegC110		as Array		READONLY		//Array com informações do registro C110
Data aRegC111		as Array		READONLY		//Array com informações do registro C111
Data aRegC188		as Array		READONLY		//Array com informações do registro C188
Data aRegC198		as Array		READONLY		//Array com informações do registro C198
Data aRegC489		as Array		READONLY		//Array com informações do registro C489
Data aRegC499		as Array		READONLY		//Array com informações do registro C499
Data aRegC509		as Array		READONLY		//Array com informações do registro C509
Data aRegC609		as Array		READONLY		//Array com informações do registro C609

Data aRegC120		as Array		READONLY		//Array com informações do registro C120
Data aRegC170		as Array		READONLY		//Array com informações do registro C170
Data aRegC175		as Array		READONLY		//Array com informações do registro C175
Data aRegC180 		as Array		READONLY		//Array com informações do registro C180
Data aRegC181 		as Array		READONLY		//Array com informações do registro C181
Data aRegC185 		as Array		READONLY		//Array com informações do registro C185
Data aRegC190 		as Array		READONLY		//Array com informações do registro C190
Data aRegC191 		as Array		READONLY		//Array com informações do registro C191
Data aRegC195 		as Array		READONLY		//Array com informações do registro C195
Data aRegC199 		as Array		READONLY		//Array com informações do registro C199
Data aRegC380 		as Array		READONLY		//Array com informações do registro C180
Data aRegC381 		as Array		READONLY		//Array com informações do registro C181
Data aRegC385 		as Array		READONLY		//Array com informações do registro C185
Data aRegC395 		as Array		READONLY		//Array com informações do registro C395
Data aRegC396 		as Array		READONLY		//Array com informações do registro C396
Data aRegC400 		as Array		READONLY		//Array com informações do registro C400
Data aRegC405 		as Array		READONLY		//Array com informações do registro C405
Data aRegC481 		as Array		READONLY		//Array com informações do registro C481
Data aRegC485 		as Array		READONLY		//Array com informações do registro C485
Data aRegC490 		as Array		READONLY		//Array com informações do registro C490
Data aRegC491 		as Array		READONLY		//Array com informações do registro C491
Data aRegC495 		as Array		READONLY		//Array com informações do registro C495
Data aRegC500 		as Array		READONLY		//Array com informações do registro C500
Data aRegC501 		as Array		READONLY		//Array com informações do registro C501
Data aRegC505 		as Array		READONLY		//Array com informações do registro C505
Data aRegC600 		as Array		READONLY		//Array com informações do registro C600
Data aRegC601 		as Array		READONLY		//Array com informações do registro C601
Data aRegC605 		as Array		READONLY		//Array com informações do registro C605
Data aRegC001 		as Array		READONLY		//Array com informações do registro C001
Data aRegC990 		as Array		READONLY		//Array com informações do registro C990
Data aRegC860 		as Array		READONLY		//Array com informações do registro C860
Data aRegC870 		as Array		READONLY		//Array com informações do registro C870
Data aRegC880 		as Array		READONLY		//Array com informações do registro C880
Data aRegC890		as Array		READONLY		//Array com informações do registro C890
Data oHashC120
Data oHashC175
Data oHashC180
Data oHashC181
Data oHashC185
Data oHashC190
Data oHashC191
Data oHashC195
Data oHashC199
Data oHashC381
Data oHashC385
Data oHashC396
Data oHashC481	
Data oHashC485
Data oHashC501
Data oHashC505
Data oHashC600
Data oJsonC600
Data oHashC601
Data oHashC605
Data oHashC860
Data oHashC870
Data oHashC880
Data oHashC491
Data oHashC495


//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()
Method AddC100()
Method AddC110()
Method AddC120()
Method AddC170()
Method AddC175()
Method AddC180()
Method AddC181()
Method AddC185()
Method AddC18X()
Method AddC190()
Method AddC191()
Method AddC195()
Method AddC19X()
Method AddC199()
Method AddC380()
Method AddC381()
Method AddC385()
Method AddC38X()
Method AddC395()
Method AddC396()
Method AddC400()
Method AddC405()
Method AddC481()
Method AddC485()
Method AddC48X()
Method AddC490()
Method AddC491()
Method AddC495()
Method AddC49X()
Method AddC500()
Method AddC501()
Method AddC505()
Method AddC50X()
Method AddC600()
Method AddC60X()
Method AddC601()
Method AddC605()
Method AddC860()
Method AddC870()
Method AddC880()
Method AddProcRef()
Method AddC001(cIndMovto)
Method AddC990(nQtde)

Method setAbatim( nnAbatim) 
Method setVlMerc( nnVlMerc) 
Method setVlFrete( nnVlFrete) 
Method setSeguro( nnSeguro) 
Method setDespesa( nnDespesa)  
Method setBsIcms( nnBsIcms) 
Method setVlIcms( nnVlIcms) 
Method setNBIcmSt( nnBsIcmsSt) 
Method setVlIcmSt( nnVlIcmsSt) 
Method setIPI( nnIPI) 
Method setPisSt( nnPisSt)
Method setCofSt( nnCofSt) 
Method setConKwh( nnConKwh)
Method setVlNTrib( nnVlNTrib) 
Method setVlTerc( nnVlTerc)
Method setVlForn( nnVlForn)
Method setIndPgto( cnIndPgto)
Method setTpFrt( cnTpFrt) 
Method setCodMun( cnCodMun) 
Method setClsCon( cnClsCon)
Method setDescri( ciDescri) 
Method setUnMed( ciUnMed) 
Method setIndMvto( ciIndMvto) 
Method setCSTICMS( ciCSTICMS) 
Method setNatOper( ciNatOper)
Method setIndIpi( ciIndIpi) 
Method setCstIpi( ciCstIpi) 
Method setEnqIpi( ciEnqIpi)
Method setInfComp( ciInfComp)
Method setNcm( ciNcm) 
Method setExNcm( ciExNcm)
Method setiCnpj( ciCnpj) 
Method setBasIcms( niBasIcms) 
Method setAlqIcms( niAlqIcms) 
Method setICMSDC( niICMSDC) 
Method setAlqcmSt( niAlqcmsSt) 
Method setBsIcmSt( niBsIcmsSt) 
Method setICMSST( niICMSST) 
Method setBasIpi( niBasIpi) 
Method setAlqIpi( niAlqIpi) 
Method setIpiDC( niIpiDC) 
Method setPisQtde( niPisQtde) 
Method setPautPis( niPautPis) 
Method setCofQtde( niCofQtde) 
Method setPautcof( niPautcof)
Method setCodInfC( cCodInfCom) 
Method setDocImp( cDocImp) 
Method setNumImp( cNumImp) 
Method setDrawBack( cDrawBack) 
Method setVPisImp( nVlPisImp) 
Method setVCofImp( nVlCofImp) 
Method setModEcf( cModEcf) 
Method setSerEcf( cSerEcf) 
Method setNumEcf( cNumEcf) 
Method setCro( cCro) 
Method setCrZ( cCrZ) 
Method setNumCont( cNumCont) 
Method setVlGrade( nVlGrade) 
Method setVlBrut( nVlBrut) 
Method setDtRedZ( dDtRedZ)
Method setVlCanc(nnValCanc)
Method setNumSAT(cNumSAT)
Method setNfIni(cnNumNfIni)
Method setChvAtuC600(cChvAtuC600)

Method getC100()
Method getC170()
Method getC175()
Method getC120()
Method getC110()
Method getC199()

Method getC180()
Method getC181()
Method getC185()

Method getC190()
Method getC191()
Method getC195()

Method getC380()
Method getC381()
Method getC385()

Method getC395()
Method getC396()

Method getC500()
Method getC501()
Method getC505()
Method setC600()
Method getC600()
Method getC601()
Method getC605()

Method getC111()
Method getC188()
Method getC198()
Method getC489()
Method getC499()
Method getC509()
Method getC609()

Method getC400()
Method getC405()
Method getC481()
Method getC485()

Method getC490()
Method getC491()
Method getC495()

Method getC860()
Method getC870()
Method getC880()
Method getC890()

Method clsC180()
Method clsC190()

Method clsC380()
Method clsC500()
Method clsC600()
Method clsC395()
Method clsC100()

Method clsC400()
Method clsC490()

Method clsC860()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe. 

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method New() Class EFDCBLOCOC
Self:lBuild   := GetBuild() >= "7.00.131227A"
Self:cJob     := '00'
Self:Clear(.T.)
Self:ClsNotaEfd(.T.)
REturn

Method setAbatim( nnAbatim,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnAbatim += nnAbatim
	Else
		Self:nnAbatim := nnAbatim
	EndIF
Return
Method setVlMerc( nnVlMerc,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnVlMerc += nnVlMerc
	Else
		Self:nnVlMerc := nnVlMerc
	EndIF
Return
Method setVlFrete( nnVlFrete,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnVlFrete += nnVlFrete
	Else
		Self:nnVlFrete := nnVlFrete	
	EndIf
Return
Method setSeguro( nnSeguro,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnSeguro += nnSeguro
	Else
		Self:nnSeguro := nnSeguro	
	EndIF
Return
Method setDespesa( nnDespesa,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnDespesa += nnDespesa
	Else
		Self:nnDespesa := nnDespesa	
	EndIF
Return
Method setBsIcms( nnBsIcms,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnBsIcms += nnBsIcms
	Else
		Self:nnBsIcms := nnBsIcms
	EndIF
Return
Method setVlIcms( nnVlIcms, lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnVlIcms += nnVlIcms
	Else
		Self:nnVlIcms := nnVlIcms
	EndIF
Return
Method setNBIcmSt( nnBsIcmsSt,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnBsIcmsSt += nnBsIcmsSt
	Else
		Self:nnBsIcmsSt := nnBsIcmsSt	
	EndIF
Return
Method setVlIcmSt( nnVlIcmsSt,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnVlIcmsSt += nnVlIcmsSt
	Else
		Self:nnVlIcmsSt := nnVlIcmsSt	
	EndIF
Return
Method setIPI( nnIPI,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnIPI += nnIPI
	Else
		Self:nnIPI := nnIPI	
	EndIF
Return
Method setPisSt( nnPisSt,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnPisSt += nnPisSt
	Else
		Self:nnPisSt := nnPisSt	
	EndIF
Return
Method setCofSt( nnCofSt,lAcum) Class EFDCBLOCOC
	Default lAcum := .F.
	If lAcum
		Self:nnCofSt += nnCofSt
	Else
		Self:nnCofSt := nnCofSt	
	EndIF
Return
Method setConKwh( nnConKwh) Class EFDCBLOCOC
	Self:nnConKwh := nnConKwh
Return
Method setVlNTrib( nnVlNTrib) Class EFDCBLOCOC
	Self:nnVlNTrib := nnVlNTrib
Return
Method setVlTerc( nnVlTerc) Class EFDCBLOCOC
	Self:nnVlTerc := nnVlTerc
Return
Method setVlForn( nnVlForn) Class EFDCBLOCOC
	Self:nnVlForn := nnVlForn
Return
Method setIndPgto( cnIndPgto) Class EFDCBLOCOC
	Self:cnIndPgto := cnIndPgto
Return
Method setTpFrt( cnTpFrt) Class EFDCBLOCOC
	Self:cnTpFrt := cnTpFrt
Return
Method setCodMun( cnCodMun) Class EFDCBLOCOC
	Self:cnCodMun := cnCodMun
Return
Method setClsCon( cnClsCon) Class EFDCBLOCOC
	Self:cnClsCon := cnClsCon
Return
Method setDescri( ciDescri) Class EFDCBLOCOC
	Self:ciDescri := ciDescri
Return
Method setUnMed( ciUnMed) Class EFDCBLOCOC
	Self:ciUnMed := ciUnMed
Return
Method setIndMvto( ciIndMvto) Class EFDCBLOCOC
	Self:ciIndMvto := ciIndMvto
Return
Method setCSTICMS( ciCSTICMS) Class EFDCBLOCOC
	Self:ciCSTICMS := ciCSTICMS
Return
Method setNatOper( ciNatOper) Class EFDCBLOCOC
	Self:ciNatOper := ciNatOper
Return
Method setIndIpi( ciIndIpi) Class EFDCBLOCOC
	Self:ciIndIpi := ciIndIpi
Return
Method setCstIpi( ciCstIpi) Class EFDCBLOCOC
	Self:ciCstIpi := ciCstIpi
Return
Method setEnqIpi( ciEnqIpi) Class EFDCBLOCOC
	Self:ciEnqIpi := ciEnqIpi
Return
Method setInfComp( ciInfComp) Class EFDCBLOCOC
	Self:ciInfComp := ciInfComp
Return
Method setNcm( ciNcm) Class EFDCBLOCOC
	Self:ciNcm := ciNcm
Return
Method setExNcm( ciExNcm) Class EFDCBLOCOC
	Self:ciExNcm := ciExNcm
Return
Method setiCnpj( ciCnpj) Class EFDCBLOCOC
	Self:ciCnpj := ciCnpj
Return
Method setBasIcms( niBasIcms) Class EFDCBLOCOC
	Self:niBasIcms := niBasIcms
Return
Method setAlqIcms( niAlqIcms) Class EFDCBLOCOC
	Self:niAlqIcms := niAlqIcms
Return
Method setICMSDC( niICMSDC) Class EFDCBLOCOC
	Self:niICMSDC := niICMSDC
Return
Method setAlqcmSt( niAlqcmsSt) Class EFDCBLOCOC
	Self:niAlqcmsSt := niAlqcmsSt
Return
Method setBsIcmSt( niBsIcmsSt) Class EFDCBLOCOC
	Self:niBsIcmsSt := niBsIcmsSt
Return
Method setICMSST( niICMSST) Class EFDCBLOCOC
	Self:niICMSST := niICMSST
Return
Method setBasIpi( niBasIpi) Class EFDCBLOCOC
	Self:niBasIpi := niBasIpi
Return
Method setAlqIpi( niAlqIpi) Class EFDCBLOCOC
	Self:niAlqIpi := niAlqIpi
Return
Method setIpiDC( niIpiDC) Class EFDCBLOCOC
	Self:niIpiDC := niIpiDC
Return
Method setPisQtde( niPisQtde) Class EFDCBLOCOC
	Self:niPisQtde := Self:TrataSet(niPisQtde)
Return
Method setPautPis( niPautPis) Class EFDCBLOCOC
	Self:niPautPis := Self:TrataSet(niPautPis)
Return
Method setCofQtde( niCofQtde) Class EFDCBLOCOC
	Self:niCofQtde := Self:TrataSet(niCofQtde)
Return
Method setPautcof( niPautcof) Class EFDCBLOCOC
	Self:niPautcof := Self:TrataSet(niPautcof)
Return
Method setCodInfC( cCodInfCom) Class EFDCBLOCOC
	Self:cCodInfCom	:= cCodInfCom
Return
Method setDocImp( cDocImp) Class EFDCBLOCOC
	Self:cDocImp := cDocImp
Return
Method setNumImp( cNumImp) Class EFDCBLOCOC
	Self:cNumImp := cNumImp
Return
Method setDrawBack( cDrawBack) Class EFDCBLOCOC
	Self:cDrawBack := cDrawBack
Return
Method setVPisImp( nVlPisImp) Class EFDCBLOCOC
	Self:nVlPisImp := nVlPisImp
Return
Method setVCofImp( nVlCofImp) Class EFDCBLOCOC
	Self:nVlCofImp := nVlCofImp
Return
Method setModEcf( cModEcf) Class EFDCBLOCOC
	Self:cModEcf := cModEcf
Return
Method setSerEcf( cSerEcf) Class EFDCBLOCOC
	Self:cSerEcf := cSerEcf
Return
Method setNumEcf( cNumEcf) Class EFDCBLOCOC
	Self:cNumEcf := cNumEcf
Return
Method setCro( cCro) Class EFDCBLOCOC
	Self:cCro := cCro
Return
Method setCrZ( cCrZ) Class EFDCBLOCOC
	Self:cCrZ := cCrZ
Return
Method setNumCont( cNumCont) Class EFDCBLOCOC
	Self:cNumCont := cNumCont
Return
Method setVlGrade( nVlGrade) Class EFDCBLOCOC
	Self:nVlGrade := nVlGrade
Return
Method setVlBrut( nVlBrut) Class EFDCBLOCOC
	Self:nVlBrut := nVlBrut
Return
Method setDtRedZ( dDtRedZ) Class EFDCBLOCOC
	Self:dDtRedZ := dDtRedZ
Return	

Method setVlCanc(nnValCanc) Class EFDCBLOCOC
	Self:nnValCanc := nnValCanc
Return	

Method setNumSAT(cNumSAT) Class EFDCBLOCOC
	Self:cNumSAT := cNumSAT
Return

Method setNfIni(cnNumNfIni) Class EFDCBLOCOC
	Self:cnNumNfIni := cnNumNfIni
Return

Method setChvAtuC600(cChvAtuC600) Class EFDCBLOCOC
	Self:cChvAtuC600 := cChvAtuC600
Return

Method getC500() Class EFDCBLOCOC
Return Self:aRegC500	

Method getC501() Class EFDCBLOCOC
Return Self:aRegC501

Method getC505() Class EFDCBLOCOC
Return Self:aRegC505

Method setC600(aRegC600,nPos) Class EFDCBLOCOC
	Self:aRegC600[nPos]	:=	aRegC600
Return 

Method getC600(nPos) Class EFDCBLOCOC

Local aRet		:= {}
Default nPos	:= 0

//Se nPos não estiver preenchido irá retornar array inteiro com todas posições
If nPos = 0
	aRet	:= Self:aRegC600
Else
	//Se houver posição preenchida, então irá retornar posição específica
	aRet	:= Self:aRegC600[nPos]
EndIF

Return aRet	

Method getC601() Class EFDCBLOCOC
Return Self:aRegC601

Method getC605() Class EFDCBLOCOC
Return Self:aRegC605

Method getC380() Class EFDCBLOCOC
Return Self:aRegC380

Method getC381() Class EFDCBLOCOC
Return Self:aRegC381

Method getC385() Class EFDCBLOCOC
Return Self:aRegC385


Method getC395() Class EFDCBLOCOC
Return Self:aRegC395

Method getC396() Class EFDCBLOCOC
Return Self:aRegC396


Method getC180() Class EFDCBLOCOC
Return Self:aRegC180

Method getC181() Class EFDCBLOCOC
Return Self:aRegC181

Method getC185() Class EFDCBLOCOC
Return Self:aRegC185

Method getC188() Class EFDCBLOCOC
Return Self:aRegC188

Method getC190() Class EFDCBLOCOC
Return Self:aRegC190

Method getC191() Class EFDCBLOCOC
Return Self:aRegC191

Method getC195() Class EFDCBLOCOC
Return Self:aRegC195

Method getC100() Class EFDCBLOCOC
Return Self:aRegC100

Method getC170() Class EFDCBLOCOC
Return Self:aRegC170

Method getC175() Class EFDCBLOCOC
Return Self:aRegC175

Method getC111() Class EFDCBLOCOC
Return Self:aRegC111

Method getC120() Class EFDCBLOCOC
Return Self:aRegC120

Method getC110() Class EFDCBLOCOC
Return Self:aRegC110


Method getC199() Class EFDCBLOCOC
Return Self:aRegC199


Method getC198() Class EFDCBLOCOC
Return Self:aRegC198

Method getC489() Class EFDCBLOCOC
Return Self:aRegC489

Method getC499() Class EFDCBLOCOC
Return Self:aRegC499

Method getC509() Class EFDCBLOCOC
Return Self:aRegC509

Method getC609() Class EFDCBLOCOC
Return Self:aRegC609

Method getC400() Class EFDCBLOCOC
Return Self:aRegC400

Method getC405() Class EFDCBLOCOC
Return Self:aRegC405

Method getC481() Class EFDCBLOCOC
Return Self:aRegC481

Method getC485() Class EFDCBLOCOC
Return Self:aRegC485

Method getC490() Class EFDCBLOCOC
Return Self:aRegC490

Method getC491() Class EFDCBLOCOC
Return Self:aRegC491

Method getC495() Class EFDCBLOCOC
Return Self:aRegC495

Method getC860() Class EFDCBLOCOC
Return Self:aRegC860

Method getC870() Class EFDCBLOCOC
Return Self:aRegC870

Method getC880() Class EFDCBLOCOC
Return Self:aRegC880

Method getC890() Class EFDCBLOCOC
Return Self:aRegC890

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
Método que inicializa as variáveis da classe. 

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method Clear(lArray) Class EFDCBLOCOC

Local cNew	:= "HMNew()"
Default	lArray	:= .T.

Self:nnAbatim		:= 0		//Valor do abatimento não tributável			
Self:nnVlMerc		:= 0		//Valor total da mercadoria
Self:nnVlFrete	:= 0		//Valor do Frete
Self:nnSeguro		:= 0		//Valor do seguro
Self:nnDespesa	:= 0		//Valor da despesas acessórias
Self:nnBsIcms		:= 0		//Base de cálculo de ICMS
Self:nnVlIcms		:= 0		//Valor de ICMS
Self:nnBsIcmsSt	:= 0		//Base de cálculo ICMS ST
Self:nnVlIcmsSt	:= 0		//Valor do ICMS ST
Self:nnIPI			:= 0		//Valor do IPI
Self:nnPisSt		:= 0		//Valor do PIS St
Self:nnCofSt		:= 0		//Valor da COFINS ST
Self:nnConKwh		:= 0		//COnsumo total em Kw
Self:nnVlNTrib	:= 0		//Valor não tributado de ICMS
Self:nnVlTerc		:= 0		//Valor cobrado por terceiros
Self:nnVlForn		:= 0		//Valor acumulado de fornecimento
Self:cnIndPgto	:= ''		//Indicador de pagamento
Self:cnTpFrt		:= ''		//Tipo de Frete
Self:cnCodMun		:= ''		//Código do município
Self:cnClsCon		:= ''		//Classe de consumo
Self:ciDescri		:= ''		//Descrição Complementar do Item	
Self:ciUnMed		:= ''		//Unidade de medida do produto
Self:ciIndMvto	:= ''		//Indicador de Movimentação física do produto
Self:ciCSTICMS	:= ''		//CST do ICMS
Self:ciNatOper	:= ''		//Natureza Da operação
Self:ciIndIpi		:= ''		//Indicador de Apuração do IPI
Self:ciCstIpi		:= ''		//CST de IPI
Self:ciEnqIpi		:= ''		//Enquadramento da apuração do IPI
Self:ciInfComp	:= ''		//Informação Complementar
Self:ciNcm			:= ''		//NCM do produto
Self:ciExNcm		:= ''		//Extensão do código de NCM
Self:ciCnpj		:= ''		//CNPJ do Participante
Self:niBasIcms	:= 0		//Base de cálculo do ICMS
Self:niAlqIcms	:= 0		//Alíqutoa do ICSM
Self:niICMSDC		:= 0		//Valor do ICMS debitado/creditado
Self:niAlqcmsSt	:= 0		//Alíquota do ICMS ST
Self:niBsIcmsSt	:= 0		//Base de cálculo do ICMS ST
Self:niICMSST		:= 0		//Valor do ICMS ST
Self:niBasIpi		:= 0		//Base de Cálculo do IPI
Self:niAlqIpi		:= 0		//Alíquota do IPI
Self:niIpiDC		:= 0		//Valor do IPI creditado ou debitado
Self:niPisQtde	:= 0		//Base de cálculo em quantidade de PIS
Self:niPautPis	:= 0		//Valor da Pauta de PIS/Alíquota em reais
Self:niCofQtde	:= 0		//Base de cálculo em quantidade de COFINS
Self:niPautcof	:= 0		//Valor da Pauta de COFINS/Alíquota em reais
Self:cDocImp		:= ''		//Documento de Importação		
Self:cNumImp		:= ''		//Número do documento de Importação
Self:cDrawBack	:= ''		//Númedo DrawBack
Self:nVlPisImp	:= 0		//valor do Pis pago na importação
Self:nVlCofImp	:= 0		//valor da COFINS paga na importação
Self:cModEcf		:= ''		//Modelo do equipamento emissor de ECF
Self:cSerEcf		:= ''		//Número de série do equipamento ECF
Self:cNumEcf		:= ''		//Número do caixa ECF
Self:cCro			:= ''		//Posição do contador de reinício da operação
Self:cCrZ			:= ''		//Posição do contador da redução Z
Self:cNumCont		:= ''		//Número de contador final
Self:nVlGrade		:= 0		//Valor total da grade
Self:nVlBrut		:= 0		//Valor da Venda Bruta
Self:dDtRedZ		:= CTod("  /  /    ")		//Dia da redução Z
Self:nnValCanc	:=0
Self:cNumSAT		:= ''		//Número de Série do equipamento SAT
Self:cnNumNfIni		:= '' //numero inicial do documento

If lArray
	Self:aRegC100		:= {}		//Array com informações do registro C100
	Self:aRegC110		:= {}		//Array com informações do registro C110
	Self:aRegC111		:= {}		//Array com informações do registro C111
	Self:aRegC188		:= {}		//Array com informações do registro C188
	Self:aRegC198		:= {}		//Array com informações do registro C198
	Self:aRegC489		:= {}		//Array com informações do registro C489
	Self:aRegC499		:= {}		//Array com informações do registro C499
	Self:aRegC509		:= {}		//Array com informações do registro C509
	Self:aRegC609		:= {}		//Array com informações do registro C609
	Self:aRegC120		:= {}		//Array com informações do registro C120
	Self:aRegC170		:= {}		//Array com informações do registro C170
	Self:aRegC175		:= {}		//Array com informações do registro C175
	Self:aRegC180 	:= {}		//Array com informações do registro C180
	Self:aRegC181 	:= {}		//Array com informações do registro C181
	Self:aRegC185 	:= {}		//Array com informações do registro C185
	Self:aRegC190 	:= {}		//Array com informações do registro C190
	Self:aRegC191 	:= {}		//Array com informações do registro C191
	Self:aRegC195 	:= {}		//Array com informações do registro C195
	Self:aRegC199 	:= {}		//Array com informações do registro C199
	Self:aRegC380 	:= {}		//Array com informações do registro C180
	Self:aRegC381 	:= {}		//Array com informações do registro C181
	Self:aRegC385 	:= {}		//Array com informações do registro C185
	Self:aRegC395 	:= {}		//Array com informações do registro C395
	Self:aRegC396 	:= {}		//Array com informações do registro C396
	Self:aRegC400 	:= {}		//Array com informações do registro C400
	Self:aRegC405 	:= {}		//Array com informações do registro C405
	Self:aRegC481 	:= {}		//Array com informações do registro C481
	Self:aRegC485 	:= {}		//Array com informações do registro C485
	Self:aRegC490 	:= {}		//Array com informações do registro C490
	Self:aRegC491 	:= {}		//Array com informações do registro C491
	Self:aRegC495 	:= {}		//Array com informações do registro C495
	Self:aRegC500 	:= {}		//Array com informações do registro C500
	Self:aRegC501 	:= {}		//Array com informações do registro C501
	Self:aRegC505 	:= {}		//Array com informações do registro C505
	Self:aRegC600 	:= {}		//Array com informações do registro C600
	Self:aRegC601 	:= {}		//Array com informações do registro C601
	Self:aRegC605 	:= {}		//Array com informações do registro C605
	Self:aRegC001 	:= {}		//Array com informações do registro C605
	Self:aRegC860 	:= {}		//Array com informações do registro C860
	Self:aRegC870 	:= {}		//Array com informações do registro C870
	Self:aRegC880 	:= {}		//Array com informações do registro C880
	Self:aRegC890 	:= {}		//Array com informações do registro C890
	Self:aRegC990 	:= {}		//Array com informações do registro C605

	IF Self:lBuild
		Self:oHashC120 := &cNew
		Self:oHashC175 := &cNew
		Self:oHashC180 := &cNew
		Self:oHashC181 := &cNew
		Self:oHashC185 := &cNew
		Self:oHashC190 := &cNew
		Self:oHashC191 := &cNew
		Self:oHashC195 := &cNew
		Self:oHashC199 := &cNew
		Self:oHashC381 := &cNew
		Self:oHashC385 := &cNew
		Self:oHashC396 := &cNew
		Self:oHashC481 := &cNew
		Self:oHashC485 := &cNew
		Self:oHashC501 := &cNew
		Self:oHashC505 := &cNew
		Self:oHashC600 := &cNew
		Self:oJsonC600 := JsonObject():New()
		Self:oHashC601 := &cNew
		Self:oHashC605 := &cNew
		Self:oHashC860 := &cNew
		Self:oHashC870 := &cNew
		Self:oHashC880 := &cNew
		Self:oHashC491 := &cNew
		Self:oHashC495 := &cNew
	EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC100()
@description Método que inclui novo registro C100, considerando as informações
			   já passadas para objeto. Documento Fiscal Modelo 01, 1B, 04, 55 e 65
@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC100(lNew, nPosAcum,lMT) Class EFDCBLOCOC
Local nPos		:= 0

Default lNew		:= .T.
Default nPosAcum 	:= 0
Default lMT			:=.F.

If lNew
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C100')
	aAdd(Self:aRegC100, {})
	nPos	:=	Len (Self:aRegC100)
	aAdd (Self:aRegC100[nPos], Self:cGrupoReg)  		//01-RELACIONAMENTO
	aAdd (Self:aRegC100[nPos], "C100")				//01 - REG
	aAdd (Self:aRegC100[nPos], Self:cnIndOper) 	//02 - IND_OPER
	aAdd (Self:aRegC100[nPos], Self:cnIndEmit)	//03 - IND_EMIT
	aAdd (Self:aRegC100[nPos], Self:cnCodPart)	//04 - COD_PART
	aAdd (Self:aRegC100[nPos], Self:cnModelo)  	//05 - COD_MOD
	aAdd (Self:aRegC100[nPos], Self:cnSitDoc)		//06 - COD_SIT
	aAdd (Self:aRegC100[nPos], Self:cnSerie)  	//07 - SER
	aAdd (Self:aRegC100[nPos], Self:cnNumNf)  	//08 - NUM_DOC
	aAdd (Self:aRegC100[nPos], Self:cnChaveNfe) 	//09 - CHV_NFE 
	
	IF !Self:cnSitDoc$"02#03#04#05" //Situação Normal
		aAdd (Self:aRegC100[nPos], Self:dnEmissao)	//10 - DT_DOC
		aAdd (Self:aRegC100[nPos], Self:dnEntrada)	//11 - DT_E_S
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnValorNf))	//12 - VL_DOC
		aAdd (Self:aRegC100[nPos], Self:cnIndPgto)	//13 - IND_PAGTO	
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnValDesc))	//14 - VL_DESC
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnAbatim))		//15 - VL_ABAT_NT
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnVlMerc))		//16 - VL_MERC
		aAdd (Self:aRegC100[nPos], Self:cnTpFrt)		//17 - IND_FRT
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnVlFrete))	//18 - VL_FRT
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnSeguro))		//19 - VL_SEG
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnDespesa))	//20 - VL_OUT_DA
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnBsIcms))		//21 - VL_BC_ICMS
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnVlIcms))		//22 - VL_ICMS
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnBsIcmsSt))	//23 - VL_BC_ICMS_ST
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnVlIcmsSt))	//24 - VL_ICMS_ST
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnIPI)) 		//25 - VL_IPI
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnValPis))		//26 - VL_PIS
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnValCof))		//27 - VL_COFINS
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnPisSt))		//28 - VL_PIS_ST
		aAdd (Self:aRegC100[nPos], if(lMT,0,Self:nnCofSt))		//29 - VL_COF_ST
	Else
		aAdd (Self:aRegC100[nPos], '')	//10 - DT_DOC
		aAdd (Self:aRegC100[nPos], '')	//11 - DT_E_S
		aAdd (Self:aRegC100[nPos], '')	//12 - VL_DOC
		aAdd (Self:aRegC100[nPos], '')	//13 - IND_PAGTO	
		aAdd (Self:aRegC100[nPos], '')	//14 - VL_DESC
		aAdd (Self:aRegC100[nPos], '')	//15 - VL_ABAT_NT
		aAdd (Self:aRegC100[nPos], '')	//16 - VL_MERC
		aAdd (Self:aRegC100[nPos], '')	//17 - IND_FRT
		aAdd (Self:aRegC100[nPos], '')	//18 - VL_FRT
		aAdd (Self:aRegC100[nPos], '')	//19 - VL_SEG
		aAdd (Self:aRegC100[nPos], '')	//20 - VL_OUT_DA
		aAdd (Self:aRegC100[nPos], '')	//21 - VL_BC_ICMS
		aAdd (Self:aRegC100[nPos], '')	//22 - VL_ICMS
		aAdd (Self:aRegC100[nPos], '')	//23 - VL_BC_ICMS_ST
		aAdd (Self:aRegC100[nPos], '')	//24 - VL_ICMS_ST
		aAdd (Self:aRegC100[nPos], '') 	//25 - VL_IPI
		aAdd (Self:aRegC100[nPos], '')	//26 - VL_PIS
		aAdd (Self:aRegC100[nPos], '')	//27 - VL_COFINS
		aAdd (Self:aRegC100[nPos], '')	//28 - VL_PIS_ST
		aAdd (Self:aRegC100[nPos], '')	//29 - VL_COF_ST	
	EndIF
ElseIF !Self:cnSitDoc$"02#03#04#05"
	nPos	:= nPosAcum
	
	Self:aRegC100[nPos][13] += Self:nnValorNf		//12 - VL_DOC	
	Self:aRegC100[nPos][15] += Self:nnValDesc		//14 - VL_DESC
	Self:aRegC100[nPos][16] += Self:nnAbatim		//15 - VL_ABAT_NT
	Self:aRegC100[nPos][17] += Self:nnVlMerc		//16 - VL_MERC	
	Self:aRegC100[nPos][19] += Self:nnVlFrete		//18 - VL_FRT
	Self:aRegC100[nPos][20] += Self:nnSeguro		//19 - VL_SEG
	Self:aRegC100[nPos][21] += Self:nnDespesa		//20 - VL_OUT_DA
	Self:aRegC100[nPos][22] += Self:nnBsIcms		//21 - VL_BC_ICMS
	Self:aRegC100[nPos][23] += Self:nnVlIcms		//22 - VL_ICMS
	Self:aRegC100[nPos][24] += Self:nnBsIcmsSt	//23 - VL_BC_ICMS_ST
	Self:aRegC100[nPos][25] += Self:nnVlIcmsSt	//24 - VL_ICMS_ST
	Self:aRegC100[nPos][26] += Self:nnIPI 			//25 - VL_IPI
	Self:aRegC100[nPos][27] += Self:nnValPis		//26 - VL_PIS
	Self:aRegC100[nPos][28] += Self:nnValCof		//27 - VL_COFINS
	Self:aRegC100[nPos][29] += Self:nnPisSt		//28 - VL_PIS_ST
	Self:aRegC100[nPos][30] += Self:nnCofSt		//29 - VL_COF_ST	
	
EndIF



Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC110()
@description Método que gera registros de informação complementar dodocumento 
			   fiscal, registro C110. 		   

@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC110() Class EFDCBLOCOC

Local nPos	:= 0

aAdd(Self:aRegC110, {})
nPos :=	Len (Self:aRegC110)
aAdd (Self:aRegC110[nPos], Self:cRelac)  		//RELACIONAMENTO
aAdd (Self:aRegC110[nPos], 'C110')				//01 - REG
aAdd (Self:aRegC110[nPos], Self:cCodInfCom) 	//02 - COD_INF
aAdd (Self:aRegC110[nPos], Self:ciDescri)     //03 - TXT_COMPL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProcRef()
@description Método que inclui novo registros C111, C188, C198, C149
			   C499, C509, C609 e C890, todos de Processo referenciado.
			   Utiliza método herdado da classe NOTAEFD
@author Erick G. Dias
@since14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddProcRef(cReg) Class EFDCBLOCOC

Do Case
	Case cReg == 'C111'	
		Self:ProcRef('C111',@Self:aRegC111)
	Case cReg == 'C188'
		Self:ProcRef('C188',@Self:aRegC188)
	Case cReg == 'C198'
		Self:ProcRef('C198',@Self:aRegC198)
	Case cReg == 'C489'
		Self:ProcRef('C489',@Self:aRegC489)	
	Case cReg == 'C499'
		Self:ProcRef('C499',@Self:aRegC499)
	Case cReg == 'C509'
		Self:ProcRef('C509',@Self:aRegC509)
	Case cReg == 'C609'	
		Self:ProcRef('C609',@Self:aRegC609)
	Case cReg == 'C890'
		Self:ProcRef('C890',@Self:aRegC890)
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC120()
@description Método que inclui novo registro C120, considerando as informações
			   já passadas para objeto. Neste registro serão geradas informações
			   de complemento de Importação modelo 01.
@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC120() Class EFDCBLOCOC

Local nPos		:= 0
Local cChave    := Self:cRelac +;
				   Self:cNumImp +;
				   Self:cDrawBack

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashC120,cChave)
Else
	nPos := aScan (Self:aRegC120, {|aX| aX[1]== Self:cRelac  .AND.;
										 aX[4] ==Self:cNumImp .AND. ;
										 aX[7] ==Self:cDrawBack })
Endif
If nPos == 0
	aAdd(Self:aRegC120, {})
	nPos	:=	Len (Self:aRegC120)
	aAdd (Self:aRegC120[nPos], Self:cRelac)  		//RELACIONAMENTO
	aAdd (Self:aRegC120[nPos], "C120")				//01 - REG
	aAdd (Self:aRegC120[nPos], Self:cDocImp)		//02 - COD_DOC_IMP
	aAdd (Self:aRegC120[nPos], Self:cNumImp)		//03 - NUM_DOC_IMP
	aAdd (Self:aRegC120[nPos], Self:nVlPisImp)	//04 - PIS_IMP
	aAdd (Self:aRegC120[nPos], Self:nVlCofImp)	//05 - COF_IMP
	aAdd (Self:aRegC120[nPos], Self:cDrawBack)	//06 - NUM_ACDRAW
	
	If Self:lBuild
		Self:AddHash(Self:oHashC120,cChave,nPos)
	EndIF
Else
	Self:aRegC120[nPos][5]	+=	Self:nVlPisImp	//04 - PIS_IMP
	Self:aRegC120[nPos][6]	+= Self:nVlCofImp		//05 - COF_IMP
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC170()
@description Método que inclui novo registro C170, considerando as informações
			   já passadas para objeto. Itens relacionados no registro C100.
@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC170() Class EFDCBLOCOC

Local nPos		:= 0
Local lPauta	:= Self:niPautPis > 0 //Se houver valor de alíquota em reais então trata de operação com pauta
Local lCanc	:= Self:cnSitDoc =='02'
 
Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C170')
aAdd(Self:aRegC170, {})
nPos	:=	Len (Self:aRegC170)
aAdd (Self:aRegC170[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
aAdd (Self:aRegC170[nPos], "C170")				//01 - REG
aAdd (Self:aRegC170[nPos], Self:ciNumitem)	//02 - NUM_ITEM
aAdd (Self:aRegC170[nPos], Self:ciCodItem)	//03 - COD_ITEM
aAdd (Self:aRegC170[nPos], Iif(lCanc,'',Self:ciDescri))		//04 - DESCR_COMPL
aAdd (Self:aRegC170[nPos], {Self:niQtde,5})		//05 - QTD
aAdd (Self:aRegC170[nPos], Self:ciUnMed)		//06 - UNID
aAdd (Self:aRegC170[nPos], Self:niValItem)	//07 - VL_ITEM
aAdd (Self:aRegC170[nPos], Iif(lCanc,'',Self:niValDesc))	//08 - VL_DESC_I
aAdd (Self:aRegC170[nPos], Self:ciIndMvto)	//09 - IND_MOV
aAdd (Self:aRegC170[nPos], Self:ciCSTICMS)	//10 - CST
aAdd (Self:aRegC170[nPos], Self:ciCFOP)		//11 - CFOP
aAdd (Self:aRegC170[nPos], Self:ciNatOper)	//12 - COD_NAT
aAdd (Self:aRegC170[nPos], Self:niBasIcms)	//13 - VL_BC_ICMS_I
aAdd (Self:aRegC170[nPos], Self:niAlqIcms)	//14 - ALIQ_ICMS
aAdd (Self:aRegC170[nPos], Self:niICMSDC)		//15 - VL_ICMS_I
aAdd (Self:aRegC170[nPos], Self:niBsIcmsSt)	//16 - VL_BC_ST_I
aAdd (Self:aRegC170[nPos], Self:niAlqcmsSt)	//17 - ALIQ_ST
aAdd (Self:aRegC170[nPos], Self:niICMSST)		//18 - VL_ST_I
aAdd (Self:aRegC170[nPos], Self:ciIndIpi)		//19 - IND_APUR
aAdd (Self:aRegC170[nPos], Self:ciCstIpi)		//20 - CST_IPI
aAdd (Self:aRegC170[nPos], Self:ciEnqIpi)		//21 - COD_ENQ
aAdd (Self:aRegC170[nPos], Self:niBasIpi)		//22 - VL_BC_IPI
aAdd (Self:aRegC170[nPos], Self:niAlqIpi)		//23 - ALIQ_IPI
aAdd (Self:aRegC170[nPos], Self:niIpiDC)		//24 - VL_IPI
aAdd (Self:aRegC170[nPos], Self:ciCSTPis)		//25 - CST_PIS
aAdd (Self:aRegC170[nPos], Iif(lPauta,'',Self:niBasePis))//26 - VL_BC_PIS
aAdd (Self:aRegC170[nPos], {Iif(lPauta,'',Self:niAlqPis),4})//27 - ALIQ_PIS
aAdd (Self:aRegC170[nPos], {Iif(lPauta,Self:niPisQtde,''),3})	//28 - QUANT_BC_PIS
aAdd (Self:aRegC170[nPos], {Iif(lPauta,Self:niPautPis,''),4})	//29 - ALIQ_PIS - Reais
aAdd (Self:aRegC170[nPos], Self:niValPis)		//30 - VL_PIS
aAdd (Self:aRegC170[nPos], Self:ciCSTCof)		//31 - CST_COFINS
aAdd (Self:aRegC170[nPos], Iif(lPauta,'',Self:niBaseCof))	//32 - VL_BC_COFINS
aAdd (Self:aRegC170[nPos], {Iif(lPauta,'',Self:niAlqCof),4})		//33 - ALIQ_COFIN
aAdd (Self:aRegC170[nPos], {Iif(lPauta,Self:niCofQtde,''),3})	//34 - QUANT_BC_COFINS
aAdd (Self:aRegC170[nPos], {Iif(lPauta,Self:niPautcof,''),4})	//35 - ALIQ_COFINS - Reais
aAdd (Self:aRegC170[nPos], Self:niValCof)		//36 - VL_COFINS
aAdd (Self:aRegC170[nPos], Self:ciContaCtb)	//37 - COD_CTA

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC175()
@description Método que inclui novo registro C175, considerando as informações
			   já passadas para objeto. Neste registro teremos as informações
			   de NFC-e modelo 65
@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC175() Class EFDCBLOCOC

Local nPos		:= 0
Local lPauta	:= Self:niPautPis > 0

Local cChave	:= Self:cRelac +;
				   Self:ciCFOP +;
				   Self:ciCSTPis+;
				   cValtochar(Iif(lPauta,Self:niPautPis,Self:niAlqPis))+;	
				   cValtochar(Iif(lPauta,Self:niPautcof,Self:niAlqCof))+;  
				   Self:ciCSTCof

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashC175,cChave)
Else
	nPos := aScan(Self:aRegC175, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac  .AND.;
										aX[3]==Self:ciCFOP .And. ;							
									   aX[6]==Self:ciCSTPis .And. ;				
									   Iif(lPauta,aX[10]== Self:niPautPis,aX[8]==Self:niAlqPis).And. ;	
									   Iif(lPauta,aX[16]==Self:niPautcof,aX[14]==Self:niAlqCof) .AND.;  
									   aX[12]==Self:ciCSTCof  })											 
										 
Endif
If nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C175')
	aAdd(Self:aRegC175, {})
	nPos	:=	Len (Self:aRegC175)
	aAdd (Self:aRegC175[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
	aAdd (Self:aRegC175[nPos], "C175")				//01 - REG
	aAdd (Self:aRegC175[nPos], Self:ciCFOP)		//02 - CFOP
	aAdd (Self:aRegC175[nPos], Self:niValItem)	//03 - VL_OPR
	aAdd (Self:aRegC175[nPos], Self:niValDesc)	//04 - VL_DESC
	aAdd (Self:aRegC175[nPos], Self:ciCSTPis)		//05 - CST_PIS
	aAdd (Self:aRegC175[nPos], Iif(lPauta,'',Self:niBasePis))	//06 - VL_BC_PIS
	aAdd (Self:aRegC175[nPos], Iif(lPauta,'',Self:niAlqPis))		//07 - ALIQ_PIS
	aAdd (Self:aRegC175[nPos], Iif(lPauta,Self:niPisQtde,''))	//08 - QUANT_BC_PIS
	aAdd (Self:aRegC175[nPos], Iif(lPauta,Self:niPautPis,''))	//09 - ALIQ_PIS - Reais
	aAdd (Self:aRegC175[nPos], Self:niValPis)		//10 - VL_PIS
	aAdd (Self:aRegC175[nPos], Self:ciCSTCof)		//11 - CST_COFINS
	aAdd (Self:aRegC175[nPos], Iif(lPauta,'',Self:niBaseCof))	//12 - VL_BC_COFINS
	aAdd (Self:aRegC175[nPos], Iif(lPauta,'',Self:niAlqCof))		//13 - ALIQ_COFIN
	aAdd (Self:aRegC175[nPos], Iif(lPauta,Self:niCofQtde,''))	//14 - QUANT_BC_COFINS
	aAdd (Self:aRegC175[nPos], Iif(lPauta,Self:niPautcof,''))	//15 - ALIQ_COFINS - Reais
	aAdd (Self:aRegC175[nPos], Self:niValCof)		//16 - VL_COFINS
	aAdd (Self:aRegC175[nPos], Self:ciContaCtb)	//17 - COD_CTA
	aAdd (Self:aRegC175[nPos], Self:ciInfComp)	//18 - INFO_COMPL

	If Self:lBuild
		Self:AddHash(Self:oHashC175,cChave,nPos)
	EndIF
Else
	Self:aRegC175[nPos][4]	+=	Self:niValItem
	Self:aRegC175[nPos][5]	+= Self:niValDesc	
	Self:aRegC175[nPos][11] += Self:niValPis
	Self:aRegC175[nPos][17] += Self:niValCof
	IF lPauta
		Self:aRegC175[nPos][9]	+= Self:niPisQtde
		Self:aRegC175[nPos][15]	+= Self:niCofQtde
	
	Else
		Self:aRegC175[nPos][13]	+= Self:niBaseCof
		Self:aRegC175[nPos][07]	+= Self:niBasePis
	EndIF
		
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC180()
@description Método que inclui novo registro C180, considerando as informações
			   já passadas para objeto. Este registro irá demonstrar a consolidaçã
			   das notas fiscais eletrônicas e cupom fiscal eletrônico modelos 55
			   e 65 respectivamnte. Este registro é pai dos registros C181 e C185.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC180() Class EFDCBLOCOC

Local nPos		:= 0
Local cChave    := Self:cRelac +;
				   Self:cRelac +;
				   Self:ciCodItem


//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashC180,cChave)
Else
	//Este registro é acumulado por código de produto.
	nPos := aScan (Self:aRegC180, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac  .AND.;
										 aX[6] ==AllTrim(Self:ciCodItem)})
Endif

IF nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C180')
	aAdd(Self:aRegC180, {})
	nPos	:=	Len (Self:aRegC180)
	aAdd (Self:aRegC180[nPos], Self:cGrupoReg)  				//RELACIONAMENTO
	aAdd (Self:aRegC180[nPos], "C180")						//01 - REG
	aAdd (Self:aRegC180[nPos], Self:cnModelo)				//02 - COD_MOD
	aAdd (Self:aRegC180[nPos], Self:dnDtDe)				//03 - DT_DOC_INI
	aAdd (Self:aRegC180[nPos], Self:dnDtAte)				//04 - DT_DOC_FIN
	aAdd (Self:aRegC180[nPos], AllTrim(Self:ciCodItem))	//05 - COD_ITEM
	aAdd (Self:aRegC180[nPos], Self:ciNcm)					//06 - COD_NCM
	aAdd (Self:aRegC180[nPos], Self:ciExNcm)				//07 - EX_IPI
	aAdd (Self:aRegC180[nPos], Self:niValItem)			//08 - VL_TOT_ITEM

	If Self:lBuild
		Self:AddHash(Self:oHashC180,cChave,nPos)
	EndIF
Else
	Self:cGrupoReg	:=Self:aRegC180[nPos][1]
	//Se já existir no registro o mesmo código de produto, então ele será acumulado.
	Self:aRegC180[nPos][9] += Self:niValItem				//08 - VL_TOT_ITEM
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC181()
@description Método que realiza chamada do método AddC18X para registro C181
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC181() Class EFDCBLOCOC

Self:AddC18X('C181',@Self:aRegC181,@Self:oHashC181)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC185()
@description Método que realiza chamada do método AddC18X para registro C185
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC185() Class EFDCBLOCOC

Self:AddC18X('C185',@Self:aRegC185,@Self:oHashC185)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC18X()
@description Método que inclui novo registro C181 e C185, considerando as informações
			   já passadas para objeto. Estes registros são filhos do registro C180,
			   aqui serão gerados tanto registro C181 quanto C185, dependendo das
			   informações passadas por parâmetro.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,,É o array pertinten ao registro gerado, C181 ou C185 
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC18X(cReg,aReg,oHash) Class EFDCBLOCOC

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local lPauta		:= .F.
Local cChave    := ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'C181'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	nPautaTrib		:= Self:niPautPis
	nBsQtdTRib		:= Self:niPisQtde
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'C185'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	nPautaTrib		:= Self:niPautCof
	nBsQtdTRib		:= Self:niCofQtde
	cCstTrib		:= Self:ciCSTCof	
EndIF
//É necessário realizar tratamento diferentes quando houver operação com pauta, para diferenciar os registros, devemos ora 
//buscar campo de alíquota em percentual, e quando pauta devemos olhar alíquota em reais.
lPauta:= Iif(cCstTrib == '03',.T.,.F.)

cChave := Self:cRelac + cCstTrib + Self:ciCFOP + Self:ciContaCtb + cValtochar(Iif(lPauta, nPautaTrib, nAlqTrib))
//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else
	//Verifica se registro já existe, considerando variação entre pauta e alíquota em percentual.
	nPos := aScan (aReg, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
							   aX[3]==cCstTrib .AND. ;
							   aX[4]==Self:ciCFOP .AND. ;
						      aX[12]==Self:ciContaCtb .AND.;
							  Iif(lPauta,aX[10][1]==nPautaTrib,aX[8][1]==nAlqTrib)})
Endif
IF nPos == 0
	//Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], Self:cRelac)  				//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)							//01 - REG
	aAdd (aReg[nPos], cCstTrib	)					//02 - CST_PIS/CST_COFINS
	aAdd (aReg[nPos], Self:ciCFOP)					//03 - CFOP
	aAdd (aReg[nPos], Self:niValItem)				//04 - VL_ITEM
	aAdd (aReg[nPos], Self:niValDesc)				//05 - VL_DESC
	aAdd (aReg[nPos], Iif(lPauta,"",nBaseTrib))	//06 - VL_BC_PIS/VL_BC_COFINS
	aAdd (aReg[nPos], {Iif(lPauta,"",nAlqTrib),4})	//07 - ALIQ_PIS/ALIQ_COFINS
	aAdd (aReg[nPos], {Iif(lPauta,nBsQtdTRib,""),3})	//08 - QUANT_BC_PIS/QUANT_BC_COFINS
	aAdd (aReg[nPos], {Iif(lPauta,nPautaTrib,""),4})	//09 - ALIQ_PIS_QUANT/ALIQ_COFINS_QUANT
	aAdd (aReg[nPos], nValTrib)						//10 - VL_PIS/VL_COFINS
	aAdd (aReg[nPos], Self:ciContaCtb)				//11 - COD_CTA

	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	//Caso já houver registro, então so valores sderão acumulados aqui.
	aReg[nPos][5]		+= Self:niValItem				//04 - VL_ITEM
	aReg[nPos][6]		+= Self:niValDesc				//05 - VL_DESC
	aReg[nPos][11]	+=	nValTrib					//10 - VL_PIS/VL_COFINS
	If lPauta
		aReg[nPos][9][1]	+=	nBsQtdTRib					//08 - QUANT_BC_PIS/QUANT_BC_COFINS
	Else
		aReg[nPos][7]	+=	nBaseTrib					//06 - VL_BC_PIS/VL_BC_COFINS
	EndIf	
	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC190()
@description Método que inclui novo registro C190, considerando as informações
			   já passadas para objeto. Este registro irá demonstrar a consolidaçã
			   das notas fiscais eletrônicas e cupom fiscal eletrônico modelos 55
			   e 65 respectivamnte com direito ao créditos.
			   Este registro é pai dos registros C191 e C195.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC190() Class EFDCBLOCOC

Local nPos	 :=	0
Local cChave := Self:cRelac +;
				AllTrim(Self:ciCodItem)

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashC190,cChave)
Else
	nPos := aScan (Self:aRegC190, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
										aX[6]==AllTrim(Self:ciCodItem)}) 
EndIf

IF nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C190')
	aAdd(Self:aRegC190, {})
	nPos	:=	Len (Self:aRegC190)
	aAdd (Self:aRegC190[nPos], Self:cGrupoReg)  				//RELACIONAMENTO
	aAdd (Self:aRegC190[nPos], "C190")						//01 - REG
	aAdd (Self:aRegC190[nPos], Self:cnModelo)				//02 - COD_MOD
	aAdd (Self:aRegC190[nPos], Self:dnDtDe)				//03 - DT_REF_INI
	aAdd (Self:aRegC190[nPos], Self:dnDtAte)				//04 - DT_REF_FIN
	aAdd (Self:aRegC190[nPos], AllTrim(Self:ciCodItem))	//05 - COD_ITEM
	aAdd (Self:aRegC190[nPos], Self:ciNcm)					//06 - COD_NCM
	aAdd (Self:aRegC190[nPos], Self:ciExNcm)				//07 - EX_IPI
	aAdd (Self:aRegC190[nPos], Self:niValItem)			//08 - VL_TOT_ITEM
	If Self:lBuild
		Self:AddHash(Self:oHashC190,cChave,nPos)
	EndIF
Else
	Self:cGrupoReg	:=Self:aRegC190[nPos][1]
	Self:aRegC190[nPos][9]	+=	Self:niValItem			//08 - VL_TOT_ITEM
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC191()
@description Método que irá chamar método AddC19X para gerar registro C191
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC191() Class EFDCBLOCOC

Self:AddC19X('C191',@Self:aRegC191,@Self:oHashC191)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC195()
@description Método que irá chamar método AddC19X para gerar registro C195
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC195() Class EFDCBLOCOC

Self:AddC19X('C195',@Self:aRegC195,@Self:oHashC195)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC19X()
@description Método que inclui novo registro C191 e C195, considerando as informações
			   já passadas para objeto. Estes registros são filhos do registro C190,
			   aqui serão gerados tanto registro C191 quanto C195, dependendo das
			   informações passadas por parâmetro.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,,É o array pertinten ao registro gerado, C191 ou C195
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC19X(cReg,aReg,oHash) Class EFDCBLOCOC

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local lPauta		:= .F.
Local cChave    := ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'C191'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	nPautaTrib		:= Self:niPautPis
	nBsQtdTRib		:= Self:niPisQtde
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'C195'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	nPautaTrib		:= Self:niPautCof
	nBsQtdTRib		:= Self:niCofQtde
	cCstTrib		:= Self:ciCSTCof	
EndIF

//Tratamento para diferenciar alíquota em percentual da alíoquota em reais(pauta pis cofins)
//lPauta:= Iif(cCstTrib == '03',.T.,.F.)

//Tratamento para notas de entrada com Pauta
If (nBsQtdTRib > 0 .And. nPautaTrib > 0) 
	lPauta := .T.
Endif
cChave := Self:cRelac + Self:ciCnpj + cCstTrib + Self:ciCFOP + Self:ciContaCtb + cValtochar(Iif(lPauta, nPautaTrib, nAlqTrib))
//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else

	nPos := aScan (aReg, {|aX| aX[1]== Self:cRelac  .AND.;
								aX[3]==Self:ciCnpj .AND. ;
								aX[4]==cCstTrib .AND. ;
								aX[5]==Self:ciCFOP .AND. ;
								aX[13]==Self:ciContaCtb .AND. ;
								Iif(lPauta ,aX[11][1]==nPautaTrib,aX[9][1]==nAlqTrib)})
Endif
If nPos	== 0	
	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], Self:cRelac)  				//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)							//01 - REG
	aAdd (aReg[nPos], Self:ciCnpj	)				//02 - CCNPJ_CPF_PART
	aAdd (aReg[nPos], cCstTrib	)					//03 - CST_PIS/CST_COFINS
	aAdd (aReg[nPos], Self:ciCFOP)					//04 - CFOP
	aAdd (aReg[nPos], Self:niValItem)				//05 - VL_ITEM
	aAdd (aReg[nPos], Self:niValDesc)				//06 - VL_DESC
	aAdd (aReg[nPos], Iif(lPauta,"",nBaseTrib))	//07 - VL_BC_PIS/VL_BC_COFINS
	aAdd (aReg[nPos], {Iif(lPauta,"",nAlqTrib),4})	//08 - ALIQ_PIS/ALIQ_COFINS
	aAdd (aReg[nPos], {Iif(lPauta,nBsQtdTRib,""),3})	//09 - QUANT_BC_PIS/QUANT_BC_COFINS
	aAdd (aReg[nPos], {Iif(lPauta,nPautaTrib,""),4})	//10 - ALIQ_PIS_QUANT/ALIQ_COFINS_QUANT
	aAdd (aReg[nPos], nValTrib)						//11 - VL_PIS/VL_COFINS
	aAdd (aReg[nPos], Self:ciContaCtb)				//12 - COD_CTA
	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	//Somente acumula os valores.
	aReg[nPos][6]+= Self:niValItem					//05 - VL_ITEM	
	aReg[nPos][7]+= Self:niValDesc					//06 - VL_DESC
	aReg[nPos][12]+=nValTrib							//11 - VL_PIS	
	If lPauta
		aReg[nPos][11][1]+= nPautaTrib					//10 - ALIQ_PIS_QUANT	    				
	Else		
		aReg[nPos][8]+= nBaseTrib					//07 - VL_BC_PIS	    				
	EndIF
	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC199()
@description Método que inclui novo registro C199, considerando as informações
			   já passadas para objeto. Neste registro serão geradas informações
			   de complemento de Importação modelo 55.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC199() Class EFDCBLOCOC

Local nPos		:= 0
Local cChave    := Self:cRelac +;
				   Self:cNumImp +;
				   Self:cDrawBack

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashC199,cChave)
Else
	nPos := aScan (Self:aRegC199, {|aX| aX[1]== Self:cRelac  .AND.;
										 aX[4] ==Self:cNumImp .AND.;
										 aX[7] ==Self:cDrawBack })
Endif										
IF nPos	 == 0
	aAdd(Self:aRegC199, {})
	nPos	:=	Len (Self:aRegC199)
	aAdd (Self:aRegC199[nPos], Self:cRelac)  		//RELACIONAMENTO
	aAdd (Self:aRegC199[nPos], "C199")				//01 - REG
	aAdd (Self:aRegC199[nPos], Self:cDocImp)		//02 - COD_DOC_IMP
	aAdd (Self:aRegC199[nPos], Self:cNumImp)		//03 - NUM_DOC_IMP
	aAdd (Self:aRegC199[nPos], Self:nVlPisImp)	//04 - PIS_IMP
	aAdd (Self:aRegC199[nPos], Self:nVlCofImp)	//05 - COF_IMP
	aAdd (Self:aRegC199[nPos], Self:cDrawBack)	//06 - NUM_ACDRAW
	If Self:lBuild
		Self:AddHash(Self:oHashC199,cChave,nPos)
	EndIF
Else
	Self:aRegC199[nPos][5]	+=	Self:nVlPisImp	//04 - PIS_IMP
	Self:aRegC199[nPos][6]	+= Self:nVlCofImp		//05 - COF_IMP
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC380()
@description Método que inclui novo registro C380. Este registro é 
			   referente a venda para consumidor final modelo 02, que 
			   são documentos não emitidos por ECF. Este registro terá
			   os C381 e C385 como registros filhos.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC380() Class EFDCBLOCOC
Local nPos		:=	0
Local cNF		:= Right(AllTrim(Self:cnNumNf),6)	


//A chave do C380 é a espéce, como contempla somente uma espécie, então apenas verifico se já 
//existe alguma informação no registro para saber se deve ou não acumular valores.	
If Len(Self:aRegC380) ==0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C380') 	
	aAdd(Self:aRegC380, {})
	nPos	:=	Len (Self:aRegC380)
	aAdd (Self:aRegC380[nPos], Self:cGrupoReg)  							//RELACIONAMENTO
	aAdd (Self:aRegC380[nPos], "C380")									//01 - REG
	aAdd (Self:aRegC380[nPos], Self:cnModelo)		   					//02 - COD_MOD
	aAdd (Self:aRegC380[nPos], Self:dnDtDe)							//03 - DT_DOC_INI
	aAdd (Self:aRegC380[nPos], Self:dnDtAte)							//04 - DT_DOC_FIN
	
	If !Empty(Self:cnNumNfIni)
		aAdd (Self:aRegC380[nPos], Self:cnNumNfIni)										//05 - NUM_DOC_INI
	Else
		aAdd (Self:aRegC380[nPos], cNF)										//05 - NUM_DOC_INI
	EndIf

	aAdd (Self:aRegC380[nPos], cNF)										//06 - NUM_DOC_FIN
	aAdd (Self:aRegC380[nPos], Self:niValItem)						//07 - VL_DOC		
	aAdd (Self:aRegC380[nPos], Self:nnValCanc)						//08 - VL_DOC_CANC
Else
	Self:cGrupoReg	:=  Self:aRegC380[1][1]
	Self:aRegC380[1][8] +=Self:niValItem	        					//07 - VL_DOC
	Self:aRegC380[1][9] +=Self:nnValCanc								//08 - VL_DOC_CANC
	
	//Verifica se número da nota é inferior ao número inicial, se for este número inicial é atualizado
	If cNF < Self:aRegC380[1][6]   										//05 - NUM_DOC_INI
		Self:aRegC380[1][6]:= cNF
	EndIf
	//Verifica se o número da nota é maior que o número final, se sim então este número final é atualizado
	If cNF > Self:aRegC380[1][7]   										//06 - NUM_DOC_FIN
		Self:aRegC380[1][7]:=  cNF
	EndIf	

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC381()
@description Método que irá chamar método AddC38X para gerar registro C381
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC381() Class EFDCBLOCOC

Self:AddC38X('C381',@Self:aRegC381,@Self:oHashC381)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC385()
@description Método que irá chamar método AddC38X para gerar registro C385
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC385() Class EFDCBLOCOC

Self:AddC38X('C385',@Self:aRegC385,@Self:oHashC385)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC38X()
@description Método para geração dos registro C381 e C385. Estes registros
			   são filhos dos registros C380. Esta método será utilizado para
			   gerar C381 e também C385, de acordo com os parâmetros passados
			   no método.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,Array,É o array pertinten ao registro gerado, C381 ou C385
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC38X(cReg,aReg,oHash) Class EFDCBLOCOC

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local lPauta		:= .F.
Local cChave    :=''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'C381'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	nPautaTrib		:= Self:niPautPis
	nBsQtdTRib		:= Self:niPisQtde
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'C385'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	nPautaTrib		:= Self:niPautCof
	nBsQtdTRib		:= Self:niCofQtde
	cCstTrib		:= Self:ciCSTCof	
EndIF
//Tratamento para diferenciar alíquota em percentua da alíoquota em reais(auta pis cofins)
lPauta:= Iif(cCstTrib == '03',.T.,.F.)

cChave := Self:cRelac + cCstTrib + Self:ciCodItem + Self:ciContaCtb + cValtochar(Iif(lPauta, nPautaTrib, nAlqTrib))
//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else
	//Verificação para poder acumular os valores
	nPos := aScan (aReg, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac  .AND. ;
									aX[3]==cCstTrib .AND. ;
							   		aX[4]==Self:ciCodItem .AND. ;
							    	aX[11]==Self:ciContaCtb .AND. ;
									Iif(lPauta, aX[9][1]== nPautaTrib , aX[7][1]== nAlqTrib ) })
Endif
IF nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)	
	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], Self:cGrupoReg)  				//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)								//01 - REG
	aAdd (aReg[nPos], cCstTrib)							//02 - CST_PIS
	aAdd (aReg[nPos], Self:ciCodItem)					//03 - COD_ITEM
	aAdd (aReg[nPos], Self:niValItem)					//04 - VL_ITEM
	aAdd (aReg[nPos], Iif(lPauta,"",nBaseTrib))		//05 - VL_BC_PIS
	aAdd (aReg[nPos], {Iif(lPauta,"", nAlqTrib),4})		//06 - ALIQ_PIS
	aAdd (aReg[nPos], {Iif(lPauta,nBsQtdTRib,""),3})		//07 - QUANT_BC_PIS
	aAdd (aReg[nPos], {Iif(lPauta,nPautaTrib,""),4})		//08 - ALIQ_PIS_QUANT
	aAdd (aReg[nPos], nValTrib)							//09 - VL_PIS
	aAdd (aReg[nPos], Self:ciContaCtb)					//10 - COD_CTA

	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	aReg[nPos][5]+= Self:niValItem						//04 - VL_ITEM
	aReg[nPos][10]+= nValTrib								//09 - VL_PIS
	IF lPauta
		aReg[nPos][8][1]+= nBsQtdTRib						//07 - QUANT_BC_PIS
	Else
		aReg[nPos][6]+= nBaseTrib						//05 - VL_BC_PIS
	EndIF				
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC395()
@description Método que inclui novo registro C395. Este registro é 
			   referente a venda para consumidor final modelo 02, que 
			   são documentos não emitidos por ECF. Aqui serão tratados
			   os valores de créditos de PIS e COFINS. Este registro terá
			   o c396 como registro filho.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC395(lNew, nPosAcum) Class EFDCBLOCOC
Local nPos	:= 0
Default lNew		:= .T.
Default nPosAcum	:= 0

If lNew
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C395')
	AAdd(Self:aRegC395, {})
	nPos	:=	Len (Self:aRegC395)
	aAdd (Self:aRegC395[nPos], Self:cGrupoReg)  							//RELACIONAMENTO
	aAdd (Self:aRegC395[nPos], 'C395')								//01 - REG
	aAdd (Self:aRegC395[nPos], Self:cnModelo)						//02 - COD_MOD
	aAdd (Self:aRegC395[nPos], Self:cnCodPart)					//03 - COD_PART
	aAdd (Self:aRegC395[nPos], Self:cnSerie)						//04 - SER
	aAdd (Self:aRegC395[nPos], '')									//05 - SUB_SER
	aAdd (Self:aRegC395[nPos],Right(AllTrim(Self:cnNumNf),6))	//06 - NUM_DOC
	aAdd (Self:aRegC395[nPos], Self:dnEmissao)   					//07 - DT_DOC
	aAdd (Self:aRegC395[nPos], 0)									//08 - VL_DOC
Else	
	nPos	:=  nPosAcum
	Self:aRegC395[nPos][9] += Self:nnValorNf						//08 - VL_DOC
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC396()
@description Método que inclui novo registro C396. Este registro é 
			   referente aos itens da venda para consumidor final modelo 02, que 
			   são documentos não emitidos por ECF. Aqui serão tratados
			   os valores de créditos de PIS e COFINS. Este registro tem
			   o c395 como registro pai.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC396() Class EFDCBLOCOC

Local nPos		:= 0
Local lRet      := !(AllTrim(Self:ciCodBcc) $ "09|11")
Local cChave    := Self:cRelac +;
				   Self:ciCodItem +;
				   Self:ciCodBcc +;
				   Self:ciCSTPis +;
				   cValtochar(Self:niAlqPis) +;
				   cValtochar(Self:niAlqCof) +;
				   cValtochar(Self:niAlqCof) +;
				   Self:ciContaCtb
If lRet
	//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
	If Self:lBuild
		nPos := Self:FindHash(Self:oHashC396,cChave)
	Else
	//Este registro é acumulado por código de produto.
		//Verifica se já existe informação no C396
		nPos := aScan (Self:aRegC396, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 		.AND. ; 	
												aX[03] ==  Self:ciCodItem  .AND. ;
												aX[06] == Self:ciCodBcc 	.AND. ;
												aX[07] == Self:ciCSTPis  	.AND. ;
												aX[09][1] == Self:niAlqPis .AND. ;
												aX[11] == Self:ciCSTCof  	.AND. ;
												aX[13][1] == Self:niAlqCof .AND. ;
												aX[15] == Self:ciContaCtb})
	Endif

	If nPos == 0
		Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C396')
		aAdd(Self:aRegC396, {})
		nPos	:=	Len (Self:aRegC396)
		aAdd (Self:aRegC396[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
		aAdd (Self:aRegC396[nPos], "C396")				//01 - REG
		aAdd (Self:aRegC396[nPos], Self:ciCodItem)	//02 - COD_ITEM
		aAdd (Self:aRegC396[nPos], Self:niValItem)	//03 - VL_ITEM
		aAdd (Self:aRegC396[nPos], Self:niValDesc)	//04 - VL_DESC
		aAdd (Self:aRegC396[nPos], Self:ciCodBcc)		//05 - NAT_BC_CRED 
		aAdd (Self:aRegC396[nPos], Self:ciCSTPis)		//06 - CST_PIS
		aAdd (Self:aRegC396[nPos], Self:niBasePis)	//07 - VL_BC_PIS
		aAdd (Self:aRegC396[nPos], {Self:niAlqPis,4})	//08 - ALIQ_PIS
		aAdd (Self:aRegC396[nPos], Self:niValPis)		//09 - VL_PIS
		aAdd (Self:aRegC396[nPos], Self:ciCSTCof)		//10 - CST_COFINS
		aAdd (Self:aRegC396[nPos], Self:niBaseCof)	//11 - VL_BC_COFINS 
		aAdd (Self:aRegC396[nPos], {Self:niAlqCof,4})	//12 - ALIQ_COFINS
		aAdd (Self:aRegC396[nPos], Self:niValCof)		//13 - VL_COFINS
		aAdd (Self:aRegC396[nPos], Self:ciContaCtb)	//14 - COD_CTA
		If Self:lBuild
			Self:AddHash(Self:oHashC396,cChave,nPos)
		EndIF
	Else
		//Acumula os valores
		Self:aRegC396[nPos][4]  += Self:niValItem		//03 - VL_ITEM					   	
		Self:aRegC396[nPos][5]  += Self:niValDesc		//04 - VL_DESC					
		Self:aRegC396[nPos][8]  += Self:niBasePis		//07 - VL_BC_PIS						
		Self:aRegC396[nPos][10]  += Self:niValPis	 	//09 - VL_PIS  					
		Self:aRegC396[nPos][12] += Self:niBaseCof	  	//11 - VL_BC_COFINS  						
		Self:aRegC396[nPos][14] += Self:niValCof		//13 - VL_COFINS
	EndIF
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC400()
@description Método que inclui novo registro c400. Este registro terá as 
			   informações do equipamente ECF, e será gerado caso usuário
			   gere o arquivo escolhendo opção de consolidação de individualização
			   de cupom fiscal.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC400() Class EFDCBLOCOC
Local nPos	:= 0

nPos := aScan (Self:aRegC400, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND.  aX[5]== Self:cSerEcf})

IF nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C400')
	aAdd(Self:aRegC400, {})
	nPos	:=	Len (Self:aRegC400)
	aAdd (Self:aRegC400[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
	aAdd (Self:aRegC400[nPos], "C400"			)	 	//01 - REG
	aAdd (Self:aRegC400[nPos], "2D"				)	 	//02 - COD_MOD
	aAdd (Self:aRegC400[nPos], Self:cModEcf	)	 	//03 - ECF_MOD
	aAdd (Self:aRegC400[nPos], Self:cSerEcf	)	 	//04 - ECF_FAB
	aAdd (Self:aRegC400[nPos], Self:cNumEcf	)	 	//05 - ECF_CX
	
Else
	Self:cGrupoReg	:= Self:aRegC400[nPos][1]
EndIF 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC405()
@description Método que inclui novo registro C405. Este registro irá
			   demonstrar informações de redução Z. Terá um registro gerado
			   para cada redução do mês, para cada equipamente ECF.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC405(cChaveC405) Class EFDCBLOCOC
Local nPos	:= 0

DEFAULT cChaveC405 := ""

nPos := Ascan(Self:aRegC405, {|x| AllTrim(x[1]) == AllTrim(cChaveC405)})

IF nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C405')
	aAdd(Self:aRegC405, {})
	nPos	:=	Len (Self:aRegC405)
	aAdd (Self:aRegC405[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
	aAdd (Self:aRegC405[nPos], "C405"			) 	   	//01 - REG
	aAdd (Self:aRegC405[nPos], Self:dDtRedZ	)	 	//02 - DT_DOC
	aAdd (Self:aRegC405[nPos], Self:cCro   	) 	   	//03 - CRO
	aAdd (Self:aRegC405[nPos], Self:cCrZ		)	 	//04 - CRZ
	aAdd (Self:aRegC405[nPos], Self:cNumCont	) 	   	//05 - NUM_COO_FIN
	aAdd (Self:aRegC405[nPos], Self:nVlGrade	)	 	//06 - GT_FIN
	aAdd (Self:aRegC405[nPos], Self:nVlBrut + Self:nnValCanc)	//07 - VL_BRT
Else
	Self:cGrupoReg			:= Self:aRegC405[nPos][1]
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC481()
@description Método que chama método AddC48X para gerar registro C481
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC481() Class EFDCBLOCOC

Self:AddC48X('C481',@Self:aRegC481,@Self:oHashC481)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddC485()
@description Método que chama método AddC48X para gerar registro C481
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC485() Class EFDCBLOCOC

Self:AddC48X('C485',@Self:aRegC485, @Self:oHashC485)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC48X()
@description Método que inclui novo registro C481 e C485. Estes registros 
			   são detalhamento por item de cupom fiscal. Estes registros
			   serão gerados quando as operações de cupom forem individualizadas.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,Array,É o array pertinten ao registro gerado, C481 ou C485 
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC48X(cReg,aReg, oHash) Class EFDCBLOCOC

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local lPauta		:= .F.
Local cChave		:= ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'C481'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	nPautaTrib		:= Self:niPautPis
	nBsQtdTRib		:= Self:niPisQtde
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'C485'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	nPautaTrib		:= Self:niPautCof
	nBsQtdTRib		:= Self:niCofQtde
	cCstTrib		:= Self:ciCSTCof	
EndIF
//É necessário realizar tratamento diferentes quando houver operação com pauta, para diferenciar os registros, devemos ora 
//buscar campo de alíquota em percentual, e quando pauta devemos olhar alíquota em reais.
lPauta:= Iif(cCstTrib == '03',.T.,.F.)

cChave	:= Self:cRelac + cCstTrib + Self:ciCodItem + Self:ciContaCtb + cValtochar(Iif(lPauta, nPautaTrib, nAlqTrib))

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos	:= Self:FindHash(oHash,cChave)

Else
//Verifica se registro já existe
nPos := aScan (aReg, {|aX|	aX[1] == Self:cRelac  	.AND. ; 
							aX[3]==cCstTrib			.AND. ;
							aX[10]==Self:ciCodItem	.AND. ;
							aX[11]==Self:ciContaCtb	.AND. ;
							Iif(lPauta , aX[8][1]==nPautaTrib ,aX[6][1]==nAlqTrib) })
							
EndIF 

If nPos == 0
	aAdd(aReg, {})
	nPos	:=	Len (aReg)			
	aAdd (aReg[nPos], Self:cRelac)  					//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)								//01 - REG		
	aAdd (aReg[nPos], cCstTrib)							//02 - CST_PIS	
	aAdd (aReg[nPos], Self:niValItem)					//03 - VL_ITEM
	aAdd (aReg[nPos], Iif(lPauta,"",nBaseTrib))		//04 - VL_BC_PIS
	aAdd (aReg[nPos], {Iif(lPauta,"",nAlqTrib),4})		//05 - ALIQ_PIS
	aAdd (aReg[nPos], {Iif(lPauta,nBsQtdTRib,""),3})		//06 - QUANT_BC_PIS
	aAdd (aReg[nPos], {Iif(lPauta,nPautaTrib,""),4})		//07 - ALIQ_PIS_QUANT
	aAdd (aReg[nPos], nValTrib)							//08 - VL_PIS
	aAdd (aReg[nPos], Self:ciCodItem)					//09 - COD_ITEM
	aAdd (aReg[nPos], Self:ciContaCtb)					//10 - COD_CTA
	
	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
	
Else
	//Acumula valor e base de cálculo
	aReg[nPos][4]+= Self:niValItem						//03 - VL_ITEM
	aReg[nPos][9]+= nValTrib								//08 - VL_PIS
	If lPauta
		aReg[nPos][7][1]+= nBsQtdTRib						//06 - QUANT_BC_PIS
	Else
		aReg[nPos][5]+= nBaseTrib	   					//04 - VL_BC_PIS		
	EndIF
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC490()
@description Método que inclui novo registro C490, que é o tatalizado
			   das valores de cupom fiscal. Este registro terá os C491 e C495
			   como registros Filhos. Estes registrso serão gerados somente
			   quando solicitado as informações de cupom fiscal agrupado.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC490() Class EFDCBLOCOC

Local nPos	:=	0

nPos := aScan (Self:aRegC490, {|aX| aX[5]==Self:cnModelo}) 
										 
IF nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C490')
	aAdd(Self:aRegC490, {})
	nPos := Len(Self:aRegC490)			
	aAdd (Self:aRegC490[nPos], Self:cGrupoReg)  	//RELACIONAMENTO
	aAdd (Self:aRegC490[nPos], "C490")				//01 - REG
	aAdd (Self:aRegC490[nPos], Self:dnDtDe)		//02 - DT_DOC_INI
	aAdd (Self:aRegC490[nPos], Self:dnDtAte)		//03 - DT_DOC_FIN			
	aAdd (Self:aRegC490[nPos], Self:cnModelo)		//04 - COD_MOD  
Else
	Self:cGrupoReg	:= Self:aRegC490[nPos][1]
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC491()
@description Método que irá chamar método AddC49X para gerar registro C491
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC491() Class EFDCBLOCOC

Self:AddC49X('C491',@Self:aRegC491,@Self:oHashC491)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC495()
@description Método que irá chamar método AddC49X para gerar registro C491
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC495() Class EFDCBLOCOC

Self:AddC49X('C495',@Self:aRegC495,@Self:oHashC495)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC49X()
@description Método que inclui novo registro C491 e C495. Estes registros 
			   são detalhamento por item de cupom fiscal. Estes registros
			   serão gerados quando as operações de cupom forem agrupadas.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,Array,É o array pertinten ao registro gerado, C491 ou C495 
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC49X(cReg,aReg,oHash) Class EFDCBLOCOC

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local lPauta		:= .F.
Local cChave		:= ""

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'C491'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	nPautaTrib		:= Self:niPautPis
	nBsQtdTRib		:= Self:niPisQtde
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'C495'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	nPautaTrib		:= Self:niPautCof
	nBsQtdTRib		:= Self:niCofQtde
	cCstTrib		:= Self:ciCSTCof	
EndIF
//É necessário realizar tratamento diferentes quando houver operação com pauta, para diferenciar os registros, devemos ora 
//buscar campo de alíquota em percentual, e quando pauta devemos olhar alíquota em reais.
lPauta:= Iif(cCstTrib == '03',.T.,.F.)

cChave := Self:cRelac + Self:ciCodItem + cCstTrib + Self:ciCFOP + Self:ciContaCtb + cValtochar(Iif(lPauta, nPautaTrib, nAlqTrib))

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos	:= Self:FindHash(oHash,cChave)
Else
	nPos := aScan (aReg, {|aX| aX[1] == Self:cRelac  	.AND. ;
								  aX[3]==Self:ciCodItem 		.AND. ;
								  aX[4]==cCstTrib 			.AND. ;
								  aX[5]==Self:ciCFOP 		.AND. ;
								  aX[12]==Self:ciContaCtb  	.AND. ;
								  Iif(lPauta ,aX[10][1]==nPautaTrib,aX[8][1]==nAlqTrib) })
EndIf

IF nPos == 0
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cRelac)  					//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)						  		//01 - REG		
	aAdd (aReg[nPos], Self:ciCodItem)					//02 - COD_ITEM
	aAdd (aReg[nPos], cCstTrib)							//03 - CST_PIS
	aAdd (aReg[nPos], Self:ciCFOP)				   		//04 - CFOP
	aAdd (aReg[nPos], Self:niValItem)					//05 - VL_ITEM	
	aAdd (aReg[nPos], Iif(lPauta,"",nBaseTrib))		//06 - VL_BC_PIS
	aAdd (aReg[nPos], {Iif(lPauta,"",nAlqTrib),4})		//07 - ALIQ_PIS
	aAdd (aReg[nPos], {Iif(lPauta,nBsQtdTRib,""),3})		//08 - QUANT_BC_PIS
	aAdd (aReg[nPos], {Iif(lPauta,nPautaTrib,""),4})	  	//09 - ALIQ_PIS_QUANT
	aAdd (aReg[nPos], nValTrib)				   	  		//10 - VL_PIS
	aAdd (aReg[nPos], Self:ciContaCtb )				//11 - COD_CTA
	
	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	aReg[nPos][6]+= Self:niValItem						//05 - VL_ITEM	
	aReg[nPos][11]+=nValTrib				   				//10 - VL_PIS
	If lPauta
		aReg[nPos][9][1]+= nBsQtdTRib						//08 - QUANT_BC_PIS	    	
	Else
		aReg[nPos][7]+= nBaseTrib						//06 - VL_BC_PIS	    	
	EndIF
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC500()
@description Método que inclui novo registro C500. Operações de compra
			   com documentos modelo 06, 29 28 e 55. O modelo 55 deve ir
			   para registro C100 ou C180, porém existe uma exceção
			   de energia elétrica, onde algns Estados é permitido o modelo
			   55 na venda de energia elétrica.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC500(lNew,nPosAcum) Class EFDCBLOCOC

Local nPos		:=	0
Local lCanc		:= Self:cnSitDoc =='02' 

Default	lNew	:= .T.
Default nPosAcum	:= 0

IF lNew
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C500')	
	aAdd(Self:aRegC500, {})
	nPos := Len(Self:aRegC500)
	aAdd (Self:aRegC500[nPos], Self:cGrupoReg) 						//RELACIONAMENTO
	aAdd (Self:aRegC500[nPos], 'C500')									//01 - REG
	aAdd (Self:aRegC500[nPos], Iif(lCanc,'',Self:cnCodPart))		//02 - COD_PART		
	aAdd (Self:aRegC500[nPos], Self:cnModelo)							//03 - CST_MOD
	aAdd (Self:aRegC500[nPos], Self:cnSitDoc)							//04 - COD_SIT
	aAdd (Self:aRegC500[nPos], Self:cnSerie)							//05 - SER
	aAdd (Self:aRegC500[nPos], '')										//06 - SUB
	aAdd (Self:aRegC500[nPos], Self:cnNumNf)							//07 - NUM_DOC
	aAdd (Self:aRegC500[nPos], Iif(lCanc ,'' ,Self:dnEmissao))		//08 - DT_DOC
	aAdd (Self:aRegC500[nPos], Iif(lCanc ,'' ,Self:dnEntrada))		//09 - DT_ENT
	aAdd (Self:aRegC500[nPos], Iif(lCanc,'',0))						//10 - VL_DOC
	aAdd (Self:aRegC500[nPos], Iif(lCanc,'',0))						//11 - VL_ICMS
	aAdd (Self:aRegC500[nPos], Iif(lCanc,'' ,Self:cCodInfCom))		//12 - COD_INF
	aAdd (Self:aRegC500[nPos], Iif(lCanc,'',0))						//13 - VL_PIS
	aAdd (Self:aRegC500[nPos], Iif(lCanc,'',0))						//14 - VL_COFINS
	//Campo obrigatório a partir de 2020
	If Year(Self:dnEntrada) >= 2020
		aAdd (Self:aRegC500[nPos], Iif(lCanc .OR. !Self:cnModelo $ "55/66",'',Self:cnChaveNfe))	//15 - CHV_DOCe
	Endif	
Else
	nPos	:= nPosAcum
	Self:aRegC500[nPos][11]	+= Iif(lCanc ,'' ,Self:nnValorNf)		//10 - VL_DOC
	Self:aRegC500[nPos][12]	+= Iif(lCanc ,'' ,Self:nnVlIcms)		//11 - VL_ICMS
	Self:aRegC500[nPos][14]	+= Iif(lCanc ,'' ,Self:nnValPis)		//13 - VL_PIS
	Self:aRegC500[nPos][15]	+= Iif(lCanc ,'' ,Self:nnValCof)		//14 - VL_COFINS
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC501()
@description Método para adicionar novo registro C501 através do método  AddC60X
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC501() Class EFDCBLOCOC

Self:AddC50X('C501',@Self:aRegC501,@Self:oHashC501)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC505()
@description Método para adicionar novo registro C505 através do método  AddC60X
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC505() Class EFDCBLOCOC

Self:AddC50X('C505',@Self:aRegC505,@Self:oHashC505)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC50X()
@description Método que inclui novo registro C501 e C505. Estes registros
			  são o detalhamento dos itens do registro pai C500
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,Array,É o array pertinten ao registro gerado, C501 ou C505
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC50X(cReg,aReg,oHash) Class EFDCBLOCOC

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local cCstTrib	:= ''
Local cChave    := ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'C501'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis	
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'C505'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof	
	cCstTrib		:= Self:ciCSTCof	
EndIF

cChave := Self:cRelac + cCstTrib + cValToChar(nAlqTrib) + Self:ciContaCtb
//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else
	//Verifica se existe registro com esta chave abaixo
	nPos := aScan (aReg, {|aX| 	aX[1]== Self:cRelac 	.AND. ;
								aX[3]==cCstTrib 			.AND. ;
								aX[7][1]==nAlqTrib 			.AND.;
							  	aX[9]==Self:ciContaCtb})
Endif

IF nPos == 0	
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cRelac)		//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)					//01 - REG		
	aAdd (aReg[nPos], cCstTrib)				//02 - CST_PIS
	aAdd (aReg[nPos], Self:niValItem)		//03 - VL_ITEM
	aAdd (aReg[nPos], Self:ciCodBcc)		//04 - NAT_BC_CRED
	aAdd (aReg[nPos], nBaseTrib)			//05 - VL_BC_PIS
	aAdd (aReg[nPos], {nAlqTrib,4})			//06 - ALIQ_PIS
	aAdd (aReg[nPos], nValTrib)				//07 - VL_PIS
	aAdd (aReg[nPos], Self:ciContaCtb )	//08 - COD_CTA 
	
	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	//Apenas acumula os valores
	aReg[nPos][4]+= Self:niValItem			//03 - VL_ITEM
	aReg[nPos][6]+= nBaseTrib				//05 - VL_BC_PIS	
	aReg[nPos][8]+= nValTrib					//07 - VL_PIS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC600()
@description Método que inclui novo registro C500. Operações de receita
			   com documentos modelo 06, 29 e 28. 
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC600(nQtdCanc,nQtdCons) Class EFDCBLOCOC
Local nPos	:= 0
Local cQtdCanc	:= ''
Local cQtdCons	:= ''
Local cChave    := Self:cRelac +;
				   Self:cnModelo +;
				   Self:cnCodMun +;
				   Self:cnSerie +;
				   Self:cnClsCon +;
				   cValtochar(Self:dnEmissao)

Default nQtdCanc	:= 0
Default nQtdCons	:= 0

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashC600,cChave)
Else
	nPos := aScan (Self:aRegC600, {|aX| 	SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
									 aX[3]==Self:cnModelo  			.AND. ;
							 		 aX[4]==Self:cnCodMun 			.AND. ;
							 		 aX[5]==Self:cnSerie 			.AND. ;
							 		 aX[7]==Self:cnClsCon 			.AND. ;
							 		 aX[10]==Self:dnEmissao})
Endif

If nPos == 0
	
	If nQtdCanc == 0
		cQtdCanc	:= Iif(Self:cnSitDoc == "02","1","0")
	Else
		cQtdCanc	:= cValToChar(nQtdCanc)
	EndIF
	
	IF nQtdCons == 0
		cQtdCons	:= '1'
	Else
		cQtdCons	:= cValToChar(nQtdCons)
	EndIF
	
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C600')
	aAdd(Self:aRegC600, {})
	nPos := Len(Self:aRegC600)
	nPosRetur := nPos
	aAdd (Self:aRegC600[nPos], Self:cGrupoReg)  			//RELACIONAMENTO
	aAdd (Self:aRegC600[nPos], 'C600')						//01 - REG
	aAdd (Self:aRegC600[nPos], Self:cnModelo)				//02 - COD_MOD
	aAdd (Self:aRegC600[nPos], Self:cnCodMun)				//03 - COD_MUN
	aAdd (Self:aRegC600[nPos], Self:cnSerie)				//04 - SER
	aAdd (Self:aRegC600[nPos], '')							//05 - SUB
	aAdd (Self:aRegC600[nPos], Self:cnClsCon)				//06 - COD_CONS
	aAdd (Self:aRegC600[nPos], cQtdCons)					//07 - QTD_CONS
	aAdd (Self:aRegC600[nPos], cQtdCanc)					//08 - QTD_CANC
	aAdd (Self:aRegC600[nPos], Self:dnEmissao)				//09 - DT_DOC
	aAdd (Self:aRegC600[nPos], Self:nnValorNf)				//10 - VL_DOC
	aAdd (Self:aRegC600[nPos], Self:nnValDesc)				//11 - VL_DESC
	aAdd (Self:aRegC600[nPos], CVALTOCHAR(Self:nnConKwh))	//12 - CONS
	aAdd (Self:aRegC600[nPos], Self:nnVlForn)				//13 - VL_FORN
	aAdd (Self:aRegC600[nPos], Self:nnVlNTrib)				//14 - VL_SERV_NT
	aAdd (Self:aRegC600[nPos], Self:nnVlTerc)				//15 - VL_TERC
	aAdd (Self:aRegC600[nPos], Self:nnDespesa)				//16 - VL_DA
	aAdd (Self:aRegC600[nPos], Self:nnBsIcms)				//17 - VL_BC_ICMS
	aAdd (Self:aRegC600[nPos], Self:nnVlIcms)				//18 - VL_ICMS
	aAdd (Self:aRegC600[nPos], Self:nnBsIcmsSt)				//19 - VL_BC_ICMS_ST
	aAdd (Self:aRegC600[nPos], Self:nnVlIcmsSt)				//20 - VL_ICMS_ST
	aAdd (Self:aRegC600[nPos], Self:nnValPis)				//21 - VL_PIS
	aAdd (Self:aRegC600[nPos], Self:nnValCof)				//22 - VL_COFINS

	If Self:lBuild
		Self:AddHash(Self:oHashC600,cChave,nPos)
	EndIF
	// Somente acumulará quando não for chamado pelo multi-thread
	If nQtdCanc == 0 .and. nQtdCons == 0
		// Atribuio as quantidades para o objeto Json
		Self:oJsonC600['QTD_CONS_' + cChave] := cQtdCons // Quantidade Consolidade
		Self:oJsonC600['QTD_CANC_' + cChave] := cQtdCanc // Quantidade Cancelada
		// Atribuo a chave para a chave antiga
		Self:cChvAntC600 := Self:cChvAtuC600
	EndIf
Else
	Self:cGrupoReg	:= Self:aRegC600[nPos][1]

	// Somente acumulará quando não for chamado pelo multi-thread
	If nQtdCanc == 0 .and. nQtdCons == 0
		cQtdCons := cValToChar(Val(Self:oJsonC600['QTD_CONS_' + cChave]))
		cQtdCanc := cValToChar(Val(Self:oJsonC600['QTD_CANC_' + cChave]))

		If Self:cChvAtuC600 <> Self:cChvAntC600
			// Atribuo a chave atual para a chave anterior
			Self:cChvAntC600 := Self:cChvAtuC600

			cQtdCons := cValToChar(Val(cQtdCons) + 1)  		// Quantidade Consolidade
			Self:oJsonC600['QTD_CONS_' + cChave] := cQtdCons

			If (Self:cnSitDoc $ "02#03") // Se for diferente de cancelado e relacionados
				cQtdCanc := cValToChar(Val(cQtdCanc) + 1)  	// Quantidade Cancelada
				Self:oJsonC600['QTD_CANC_' + cChave] := cQtdCanc
			EndIf
		EndIf
	EndIf

	Self:aRegC600[nPos][8]:= cQtdCons																	//07 - QTD_CONS
	Self:aRegC600[nPos][9]:= cQtdCanc																	//08 - QTD_CANC
	Self:aRegC600[nPos][11]+= Self:nnValorNf															//10 - VL_DOC
	Self:aRegC600[nPos][12]+= Self:nnValDesc				   											//11 - VL_DESC
	Self:aRegC600[nPos][13]:= cvaltochar(val(Self:aRegC600[nPos][13]) + Self:nnConKwh)					//12 - CONS
	Self:aRegC600[nPos][14]+= Self:nnVlForn																//13 - VL_FORN
	Self:aRegC600[nPos][15]+= Self:nnVlNTrib															//14 - VL_SERV_NT
	Self:aRegC600[nPos][16]+= Self:nnVlTerc																//15 - VL_TERC
	Self:aRegC600[nPos][17]+= Self:nnDespesa															//16 - VL_DA
	Self:aRegC600[nPos][18]+= Self:nnBsIcms																//17 - VL_BC_ICMS
	Self:aRegC600[nPos][19]+= Self:nnVlIcms																//18 - VL_ICMS
	Self:aRegC600[nPos][20]+= Self:nnBsIcmsSt															//19 - VL_BC_ICMS_ST
	Self:aRegC600[nPos][21]+= Self:nnVlIcmsSt															//20 - VL_ICMS_ST
	Self:aRegC600[nPos][22]+= Self:nnValPis																//21 - VL_PIS
	Self:aRegC600[nPos][23]+= Self:nnValCof																//22 - VL_COFINS 	

EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC601()
@description Método para adicionar novo registro C601 através do método  AddC60X
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC601() Class EFDCBLOCOC

Self:AddC60X('C601',@Self:aRegC601,@Self:oHashC601)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC605()
@description Método para adicionar novo registro C605 através do método  AddC60X
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC605() Class EFDCBLOCOC

Self:AddC60X('C605',@Self:aRegC605,@Self:oHashC605)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC60X()
@description Método que inclui novo registro C601 e C605. Estes registros
			  são o detalhamento dos itens do registro pai C600
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,Array,É o array pertinten ao registro gerado, C601 ou C605
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC60X(cReg,aReg,oHash) Class EFDCBLOCOC

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local cCstTrib	:= ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'C601'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis	
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'C605'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof	
	cCstTrib		:= Self:ciCSTCof	
EndIF

cChave := Self:cRelac + cCstTrib + cValToChar(nAlqTrib) + Self:ciContaCtb
//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else

	nPos := aScan (aReg, {|aX|	aX[1]== Self:cRelac 	.AND. ; 
							   aX[3]==cCstTrib 			.AND. ;
							   aX[6][1]==nAlqTrib 			.AND. ;
							   aX[8]==Self:ciContaCtb})
Endif

If nPos == 0
	
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cRelac)  			//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)						//01 - REG		
	aAdd (aReg[nPos], cCstTrib)					//02 - CST_PIS
	aAdd (aReg[nPos], Self:niValItem)			//03 - VL_ITEM
	aAdd (aReg[nPos], nBaseTrib)				//04 - VL_BC_PIS		
	aAdd (aReg[nPos], {nAlqTrib,4})				//05 - ALIQ_PIS
	aAdd (aReg[nPos], nValTrib)					//06 - VL_PIS
	aAdd (aReg[nPos], Self:ciContaCtb )		//07 - COD_CTA 

	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	aReg[nPos][4] +=	Self:niValItem			//03 - VL_ITEM
	aReg[nPos][5] +=	nBaseTrib					//04 - VL_BC_PIS
	aReg[nPos][7] +=	nValTrib					//06 - VL_PIS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC860()
@description Método que inclui novo registro c860. Este registro terá as 
			   informações do equipamente SAT-CF-E, e será gerado caso usuário
			   gere o arquivo escolhendo opção de consolidação de individualização
			   de cupom fiscal.
@author Mauro A. Gonçalves
@since 23/07/2015
@version 11.90.
/*/
//-------------------------------------------------------------------
METHOD AddC860() Class EFDCBLOCOC

Local nPos	:= 0
Local cNF	:= Right(AllTrim(Self:cnNumNf),6)

Local cChave := "59" +;
				Self:cNumSAT +;
				cValtochar(Self:dnEmissao)


//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashC860,cChave)
Else
	nPos := aScan(Self:aRegC860, {|aX| aX[3]=="59" .And. aX[4]==Self:cNumSAT .And. aX[5]==Self:dnEmissao})
Endif

If nPos == 0
	Self:cGrupoReg := FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C860')
	aAdd(Self:aRegC860, {})
	nPos	:=	Len(Self:aRegC860)
	aAdd(Self:aRegC860[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd(Self:aRegC860[nPos], "C860")			//01 - REG
	aAdd(Self:aRegC860[nPos], "59"	)			//02 - COD_MOD
	aAdd(Self:aRegC860[nPos], Self:cNumSAT)		//03 - NR_SAT
	aAdd(Self:aRegC860[nPos], Self:dnEmissao)	//04 - DT_DOC	
	If !Empty(Self:cnNumNfIni)
		aAdd(Self:aRegC860[nPos], Self:cnNumNfIni)				//05 - DOC_INI
	Else
		aAdd(Self:aRegC860[nPos], cNF)				//05 - DOC_INI
	EndIF

	aAdd(Self:aRegC860[nPos], cNF)				//06 - DOC_FIM

	If Self:lBuild
		Self:AddHash(Self:oHashC860,cChave,nPos)
	EndIF
Else
	Self:cGrupoReg	:= Self:aRegC860[nPos][1]
	//Verifica se número da nota é inferior ao nadmiúmero inicial, se for este número inicial é atualizado
	//Utilizando VAL() pois na comparacao de strings a nota "10" seria menor do que a nota "9". 
	//No "order by" este problema tambem acontece. Por isso foi feito um CAST para integer na query principal(FISA008)
	//para que as notas ja cheguem aqui ordenadas...do contrario estas comparacoes de maior ou menor nao
	//funcionariam corretamente.
	If Val(cNF) < Val(Self:aRegC860[nPos][6])				//05 - DOC_INI
		Self:aRegC860[nPos][6]:= cNF
	EndIf
	//Verifica se o número da nota é maior que o número final, se sim então este número final é atualizado
	If Val(cNF) > Val(Self:aRegC860[nPos][7])				//06 - DOC_FIM
		Self:aRegC860[nPos][7]:= cNF
	EndIf
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AddC870()
@description Método que inclui novo registro c870. Este registro terá as 
			   informações do resumo diário de documentos emitidos por 
			   equipamento SAT-CF-E (CÓDIGO 59) – PIS/PASEP E COFINS.
@author Mauro A. Gonçalves
@since 23/07/2015
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC870() Class EFDCBLOCOC

Local nPos	:= 0
Local cChave := ''

cChave	:= Self:cRelac + Self:ciCodItem + Self:ciCFOP + Self:ciCSTPis + cValToChar(Self:niAlqPis) + Self:ciCSTCof + cValToChar(Self:niAlqCof) + Self:ciContaCtb  

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos	:= Self:FindHash(Self:oHashC870,cChave)
Else
	nPos := aScan(Self:aRegC870, {|aX| SubStr(aX[1],1,Len(Self:cRelac))==Self:cRelac .And.;
											aX[03]==Self:ciCodItem .And. ;
											aX[04]==Self:ciCFOP  .And. ;
											aX[07]==Self:ciCSTPis  .And. ;
											aX[09][1]==Self:niAlqPis  .And. ;
											aX[11]==Self:ciCSTCof  .And. ;
											aX[13][1]==Self:niAlqCof  .And. ;
											aX[15]==Self:ciContaCtb })
EndIf									

IF nPos == 0
	//Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C870')
	aAdd(Self:aRegC870, {})
	nPos	:=	Len(Self:aRegC870)
	aAdd(Self:aRegC870[nPos], Self:cGrupoReg)			//RELACIONAMENTO
	aAdd(Self:aRegC870[nPos], "C870")					//01 - REG
	aAdd(Self:aRegC870[nPos], Self:ciCodItem)			//02 - COD_ITEM
	aAdd(Self:aRegC870[nPos], Self:ciCFOP)				//03 - CFOP
	aAdd(Self:aRegC870[nPos], Self:niValItem)			//04 - VL_ITEM
	aAdd(Self:aRegC870[nPos], Self:niValDesc)			//05 - VL_DESC
	aAdd(Self:aRegC870[nPos], Self:ciCSTPis)			//06 - CST_PIS
	aAdd(Self:aRegC870[nPos], Self:niBasePis)			//07 - VL_BC_PIS
	aAdd(Self:aRegC870[nPos], {Self:niAlqPis,4})		//08 - ALIQ_PIS
	aAdd(Self:aRegC870[nPos], Self:niValPis)			//09 - VL_PIS
	aAdd(Self:aRegC870[nPos], Self:ciCSTCof)			//10 - CST_COFINS
	aAdd(Self:aRegC870[nPos], Self:niBaseCof)			//11 - VL_BC_COFINS
	aAdd(Self:aRegC870[nPos], {Self:niAlqCof,4})		//12 - ALIQ_COFINS
	aAdd(Self:aRegC870[nPos], Self:niValCof)			//13 - VL_COFINS
	aAdd(Self:aRegC870[nPos], Self:ciContaCtb)			//14 - COD_CTA
	
	If Self:lBuild
		Self:AddHash(Self:oHashC870,cChave,nPos)
	EndIF	
Else
	Self:cGrupoReg			:= Self:aRegC870[nPos][1]
	Self:aRegC870[nPos][05]	+= Self:niValItem	//04 - VL_ITEM
	Self:aRegC870[nPos][06]	+= Self:niValDesc	//05 - VL_DESC
	Self:aRegC870[nPos][08]	+= Self:niBasePis	//07 - VL_BC_PIS
	Self:aRegC870[nPos][10]	+= Self:niValPis	//09 - VL_PIS
	Self:aRegC870[nPos][12]	+= Self:niBaseCof	//11 - VL_BC_COFINS
	Self:aRegC870[nPos][14]	+= Self:niValCof	//13 - VL_COFINS
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AddC880()
@description Método que inclui novo registro c880. Este registro terá as 
			   informações do resumo diário de documentos emitidos por 
			   equipamento SAT-CF-E (CÓDIGO 59) – PIS/PASEP E COFINS.
			   Operação com pauta
@author Mauro A. Gonçalves
@since 23/07/2015
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC880() Class EFDCBLOCOC

Local nPos		:= 0
Local cChave 	:= ''

cChave  := Self:cRelac + Self:ciCodItem
//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos	:= Self:FindHash(Self:oHashC880,cChave)
Else
	nPos := aScan(Self:aRegC880, {|aX| SubStr(aX[1],1,Len(Self:cRelac))==Self:cRelac .And. aX[03]==Self:ciCodItem})  
Endif

IF nPos == 0
	//Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'C880')
	aAdd(Self:aRegC880, {})
	nPos	:=	Len(Self:aRegC880)
	aAdd(Self:aRegC880[nPos], Self:cGrupoReg)  						//RELACIONAMENTO
	aAdd(Self:aRegC880[nPos], "C880")	 								//01 - REG
	aAdd(Self:aRegC880[nPos], Self:ciCodItem)						 	//02 - COD_ITEM
	aAdd(Self:aRegC880[nPos], Self:ciCFOP)	 							//03 - CFOP
	aAdd(Self:aRegC880[nPos], Self:niValItem)						 	//04 - VL_ITEM
	aAdd(Self:aRegC880[nPos], Self:niValDesc)						 	//05 - VL_DESC
	aAdd(Self:aRegC880[nPos], Self:ciCSTPis) 						 	//06 - CST_PIS
	aAdd(Self:aRegC880[nPos], Self:niBasePis)					 		//07 - VL_BC_PIS
	aAdd(Self:aRegC880[nPos], {Self:niAlqPis,4})						//08 - ALIQ_PIS
	aAdd(Self:aRegC880[nPos], Self:niValPis)	 						//09 - VL_PIS
	aAdd(Self:aRegC880[nPos], Self:ciCSTCof)						 	//10 - CST_COFINS
	aAdd(Self:aRegC880[nPos], Self:niBaseCof) 						//11 - VL_BC_COFINS
	aAdd(Self:aRegC880[nPos], {Self:niAlqCof,4})						//12 - ALIQ_COFINS
	aAdd(Self:aRegC880[nPos], Self:niValCof)	 						//13 - VL_COFINS
	aAdd(Self:aRegC880[nPos], Self:ciContaCtb)					 	//14 - COD_CTA	

	If Self:lBuild
		Self:AddHash(Self:oHashC880,cChave,nPos)
	EndIF	
Else
	Self:cGrupoReg			:= Self:aRegC880[nPos][1]
	Self:aRegC880[nPos][05]	+= Self:niValItem	//04 - VL_ITEM
	Self:aRegC880[nPos][06]	+= Self:niValDesc	//05 - VL_DESC
	Self:aRegC880[nPos][10]	+= Self:niValPis	//09 - VL_PIS
	Self:aRegC880[nPos][14]	+= Self:niValCof	//13 - VL_COFINS
EndIF 

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AddC001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC001(cIndMovto) Class EFDCBLOCOC

Self:AbreBloco('C001',@Self:aRegC001,cIndMovto)

Return Self:aRegC001

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC990(nQtde) Class EFDCBLOCOC

Self:FechaBloco('C990',@Self:aRegC990, nQtde) 

Return Self:aRegC990



//-------------------------------------------------------------------
/*/{Protheus.doc} clsC500()
@description Método para limpar variáveis utilizadas no registro C500
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC500() Class EFDCBLOCOC
Local cNew := "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC500	:= {}
Self:aRegC501	:= {}
Self:aRegC505	:= {}
Self:aRegC509	:= {}

IF Self:lBuild
	FreeObj(Self:oHashC501)
	Self:oHashC501 := nil

	Self:oHashC501 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashC505)
	Self:oHashC505 := nil

	Self:oHashC505 := &cNew
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC600()
@description Método para limpar variáveis utilizadas no registro C600
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC600() Class EFDCBLOCOC
Local cNew := "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC600	:= {}
Self:aRegC601	:= {}
Self:aRegC605	:= {}
Self:aRegC609	:= {}

IF Self:lBuild
	FreeObj(Self:oHashC600)
	Self:oHashC600 := nil

	Self:oHashC600 := &cNew

	FreeObj(Self:oJsonC600)
	Self:oJsonC600 := nil
Endif

IF Self:lBuild
	FreeObj(Self:oHashC601)
	Self:oHashC601 := nil

	Self:oHashC601 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashC605)
	Self:oHashC605 := nil

	Self:oHashC605 := &cNew
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC380()
@description Método para limpar variáveis utilizadas no registro C380
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC380() Class EFDCBLOCOC
Local cNew := "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC380	:= {}
Self:aRegC381	:= {}
Self:aRegC385	:= {}

IF Self:lBuild
	FreeObj(Self:oHashC381)
	Self:oHashC381 := nil

	Self:oHashC381 := &cNew
Endif
IF Self:lBuild
	FreeObj(Self:oHashC385)
	Self:oHashC385 := nil

	Self:oHashC385 := &cNew
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC395()
@description Método para limpar variáveis utilizadas no registro C395
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC395() Class EFDCBLOCOC
Local cNew := "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC395	:= {}
Self:aRegC396	:= {}

IF Self:lBuild
	FreeObj(Self:oHashC396)
	Self:oHashC396 := nil

	Self:oHashC396 := &cNew
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC180()
@description Método para limpar variáveis utilizadas no registro C180
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC180() Class EFDCBLOCOC
Local cNew := "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC180	:= {}
Self:aRegC181	:= {}
Self:aRegC185	:= {}
Self:aRegC188	:= {}

IF Self:lBuild
	FreeObj(Self:oHashC180)
	Self:oHashC180 := nil

	Self:oHashC180 := &cNew
Endif
IF Self:lBuild
	FreeObj(Self:oHashC181)
	Self:oHashC181 := nil

	Self:oHashC181 := &cNew
Endif
IF Self:lBuild
	FreeObj(Self:oHashC185)
	Self:oHashC185 := nil

	Self:oHashC185 := &cNew
Endif



Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC190()
@description Método para limpar variáveis utilizadas no registro C180
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC190() Class EFDCBLOCOC
Local cNew := "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC190	:= {}
Self:aRegC191	:= {}
Self:aRegC195	:= {}
Self:aRegC198	:= {}
Self:aRegC199	:= {}

IF Self:lBuild
	FreeObj(Self:oHashC190)
	Self:oHashC190 := nil

	Self:oHashC190 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashC191)
	Self:oHashC191 := nil

	Self:oHashC191 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashC195)
	Self:oHashC195 := nil

	Self:oHashC195 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashC199)
	Self:oHashC199 := nil

	Self:oHashC199 := &cNew
Endif


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC100()
@description Método para limpar variáveis utilizadas no registro C170
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC100() Class EFDCBLOCOC
Local cNew := "HMNew()"

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC100	:= {}
Self:aRegC170	:= {}
Self:aRegC175	:= {}
Self:aRegC111	:= {}

Self:aRegC110	:= {}
Self:aRegC120	:= {}


IF Self:lBuild
	FreeObj(Self:oHashC120)
	Self:oHashC120 := nil

	Self:oHashC120 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashC175)
	Self:oHashC175 := nil

	Self:oHashC175 := &cNew
Endif



Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC400()
@description Método para limpar variáveis utilizadas no registro C170
@author Erick G. Dias
@since 04/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC400() Class EFDCBLOCOC

Local cNew := "HMNew()"

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC400 := {}
Self:aRegC405 := {}
Self:aRegC481 := {}
Self:aRegC485 := {}
Self:aRegC489 := {}

IF Self:lBuild
	FreeObj(Self:oHashC481)
	Self:oHashC481 := nil

	FreeObj(Self:oHashC485)
	Self:oHashC485 := nil

	Self:oHashC481 := &cNew
	Self:oHashC485 := &cNew
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC490()
@description Método para limpar variáveis utilizadas no registro C170
@author Erick G. Dias
@since 04/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC490() Class EFDCBLOCOC

Local cNew := "HMNew()"

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC490	:= {}
Self:aRegC491	:= {}
Self:aRegC495	:= {}
Self:aRegC499	:= {}

IF Self:lBuild

	FreeObj(Self:oHashC491)
	Self:oHashC491 := nil

	FreeObj(Self:oHashC495)
	Self:oHashC495 := nil

	Self:oHashC491 := &cNew
	Self:oHashC495 := &cNew

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsC860()
@description Método para limpar variáveis utilizadas no registro C860
e C870
@author Mauro A. Gonçalves
@since 23/07/2015
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsC860() Class EFDCBLOCOC

Local cNew	:= "HMNew()"

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegC860	:= {}
Self:aRegC870	:= {}
Self:aRegC880	:= {}
Self:aRegC890	:= {}

IF Self:lBuild
	FreeObj(Self:oHashC860)
	Self:oHashC860 := nil

	Self:oHashC860 := &cNew
Endif

If Self:lBuild
	FreeObj(Self:oHashC870)
	Self:oHashC870 := NIL
	
	Self:oHashC870 := &cNew	
EndIf

If Self:lBuild
	FreeObj(Self:oHashC880)
	Self:oHashC880 := NIL
	
	Self:oHashC880 := &cNew	
EndIf

Return
 