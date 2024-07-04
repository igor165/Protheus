#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION FISX002();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} NOTAEFD()
@description Classe utilizada para geração do arquivo texto da EFD Contribuições.
			   Nesta classe teremos os atributos/informações que são em comum
			   para todos os registros da EFD. As demais classes específicas de cada
			   bloco irão herdar estas informações para pode gerar os registros.
			   Sempre que houver informação genérica entre os registros, deverão
			   ser informados aqui, que automaticamente as demais classes filhas
			   terão acesso aos tributos e variáveis declaradas aqui.

@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS NOTAEFD FROM EFDGEN

//-----------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO DO DOCUMENTO FISCAL
//-----------------------------------------------------
Data cnNumNf		as String		READONLY		//Número do documento fiscal
Data cnSerie		as String		READONLY		//Série do documento Fiscal
Data cnSubSerie		as String		READONLY		//Subsérie do documento Fiscal
Data cnCodPart		as String		READONLY		//Código participante Cliente ou Fornecedor
Data cnChaveNfe		as String		READONLY		//Chave eletrônica do documento
Data cnSitDoc		as String		READONLY		//Código da situação do documento
Data cnModelo		as String		READONLY		//Modelo do documento Fiscal
Data cnIndOper		as String		READONLY		//Indicador de operação da nota
Data cnIndEmit		as String		READONLY		//Indicador do emitente
Data nnValorNf		as Integer		READONLY		//Valor total da nota fiscal
Data nnValDesc		as Integer		READONLY		//Valor total do desconto da nota
Data nnBasePis		as Integer		READONLY		//Valor total da base de cálculo de PIS
Data nnBaseCof		as Integer		READONLY		//Valor total da base de cálculo de COFINS
Data nnValPis		as Integer		READONLY		//Valor total do valor de PIS
Data nnValCof		as Integer		READONLY		//Valor Total do valor de COFINS
Data dnEmissao		as Date			READONLY		//Data de emissão do documento
Data dnEntrada		as Date			READONLY		//Data de entrada do documento
Data dnDtDe			as Date			READONLY		//Data inicial de Processamento
Data dnDtAte		as Date			READONLY		//Data final de Processamento
Data cnInfCmp		as String		READONLY		//Infomcação COmplementar do documento fiscal.

//-------------------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO AO ITEM DO DOCUMENTO FISCAL
//-------------------------------------------------------------
Data ciNumitem		as String		READONLY		//Número do item
Data ciCCusto		as String		READONLY		//Código do Centro de Custo
Data ciContaCtb		as String		READONLY		//Código da conta contábil
Data ciCodItem		as String		READONLY		//Código do produto utilizado
Data ciTNatRec		as String		READONLY		//Tabela da natureza da Receita
Data ciCNatRec		as String		READONLY		//Código da natureza da receita
Data ciGNatRec		as String		READONLY		//Grupo da Natureza da Receita
Data ciCSTPis		as String		READONLY		//CST de PIS
Data ciCSTCof		as String		READONLY		//CST da Cofins
Data ciCodBcc		as String		READONLY		//Código da base de cálculo do Crédito
Data ciCFOP			as String		READONLY		//CFOP
Data niValItem		as Integer		READONLY		//Valor do item
Data niAlqPis		as Integer		READONLY		//Alíquota de PIS
Data niAlqCof		as Integer		READONLY		//Alíquota da COFINS
Data niBasePis		as Integer		READONLY		//Valor da base de cálculo de PIS
Data niBaseCof		as Integer		READONLY		//Valor da base de cálculo de COFINS
Data niValPis		as Integer		READONLY		//Valor de PIS
Data niValCof		as Integer		READONLY		//Valor da COFINS
Data niValDesc		as Integer		READONLY		//Valor do desconto do item
Data niQtde			as Integer		READONLY		//Quantidade de produto do item
Data niBasePaut		as Integer		READONLY		//Quantidade de produto do item
Data diDNatRec		as Date			READONLY		//Data da alíquota da natureza da Receita.
Data cProRef		as String		READONLY		//Número do processo referenciado
Data cTpProRef		as String		READONLY		//Tipo do processo referenciado
Data aReg9001		as Array		READONLY		//Array com informações de controle do bloco.
Data aReg9999		as Array		READONLY		//Array com informações de controle do bloco.
Data aReg9990		as Array		READONLY		//Array com informações de controle do bloco.
Data aReg9900		as Array		READONLY		//Array com informações de controle do bloco.
Data aRegA010		as Array		READONLY		//Array de identificação do estabelecimento bloco A
Data aRegC010		as Array		READONLY		//Array de identificação do estabelecimento bloco C
Data aRegD010		as Array		READONLY		//Array de identificação do estabelecimento bloco D
Data aRegF010		as Array		READONLY		//Array de identificação do estabelecimento bloco F
Data aRegI010		as Array		READONLY		//Array de identificação do estabelecimento bloco I
Data aRegP010		as Array		READONLY		//Array de identificação do estabelecimento bloco P
Data cReg			as Array		READONLY		//Nome do registro a ser processado
Data cCnpj			as Array		READONLY		//CNPJ
Data cInd			as Array		READONLY		//Indicador escrioturação
Data cInfComp		as Array		READONLY		//Informação complementar
Data nVlPauta		as Integer		READONLY		//valor da pauta gravado no livro
Data nBaseQtd		as Integer		READONLY		//Base de cálculo em quantidade
Data nAlqReais		as Integer		READONLY		//Valor da alíquota em reais
Data cDedbpis		as String		READONLY
Data cDedbcof		as String		READONLY

//--------------------------------------------------------------------------
//PROPRIEDADE PARA A INFORMAÇÃO PAI QUE DEVERÁ SER O PRIMEIRO CAMPO DO ARRAY
//--------------------------------------------------------------------------
Data cRelac		as String		READONLY		//Esta variável terá o conteúdo de relacionamento para gravação na tabela.
Data aNumeracao	as Array		READONLY
Data cGrupoReg	As String		READONLY		//Grupo do registro
Data lMT		As Boolean		READONLY		//Indica se está processando em MultiThread
Data cJob		As String		READONLY		//Indica se está processando em MultiThread
Data dDtDe		As Date			READONLY		//Data Incial da geração do arquivo
Data dDtAte		As Date			READONLY		//Data Final do arquivo

Data c010 		As Date 		READONLY


//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method OperPauta()
Method ClsNotaEfd()
Method ProcRef(cReg,aReg)
Method AbreBloco(cReg,aReg,cIndMov)
Method FechaBloco(cReg,aReg, nQtde)
Method IdentEstab(cReg,aReg,cCnpj,cInd,cInfComp)
Method InfComplNf(cReg,aReg,cCodInf,cTxtCompl)
Method Add9900(cReg,nQtde)
Method AddA010(cReg)
Method AddC010(cReg)
Method AddD010(cReg)
Method AddF010(cReg)
Method AddI010(cReg)
Method AddP010(cReg)
Method Add9001()
Method Add9990()
Method Add9999()
Method getA010()
Method getD010()
Method getC010()
Method getF010()
Method getI010()
Method getP010()
Method TrataSet(xValor)


Method setnNumNf( cnNumNf)
Method setnSerie( cnSerie)
Method setnSubSerie( cnSubSerie )
Method setCodPart( cnCodPart)
Method setChvNfe( cnChaveNfe)
Method setnSitDoc( cnSitDoc)
Method setnModelo( cnModelo)
Method setIndOper( cnIndOper)
Method setIndEmit( cnIndEmit)
Method setValorNf( nnValorNf)
Method setnVlDesc( nnValDesc)
Method setnBasPis( nnBasePis)
Method setnBasCof( nnBaseCof)
Method setnValPis( nnValPis)
Method setnValCof( nnValCof)
Method setEmissao( dnEmissao)
Method setEntrada( dnEntrada)
Method setnDtDe( dnDtDe)
Method setnDtAte( dnDtAte)
Method setnInfCmp( cnInfCmp)
Method setNumitem( ciNumitem)
Method setiCCusto( ciCCusto)
Method setConta( ciContaCtb)
Method setCodItem( ciCodItem)
Method setTNatRec( ciTNatRec)
Method setCNatRec( ciCNatRec)
Method setGNatRec( ciGNatRec)
Method setiCSTPis( ciCSTPis)
Method setiCSTCof( ciCSTCof)
Method setiCodBcc( ciCodBcc)
Method setiCFOP( ciCFOP)
Method setValItem( niValItem)
Method setiAlqPis( niAlqPis)
Method setiAlqCof( niAlqCof)
Method setiBasPis( niBasePis)
Method setiBasCof( niBaseCof)
Method setiValPis( niValPis)
Method setiValCof( niValCof)
Method setiVaDesc( niValDesc)
Method setiQtde( niQtde)
Method setiBsPaut(niBasePaut)
Method setDNatRec( diDNatRec)
Method setProRef( cProRef)
Method setTProRef( cTpProRef)
Method setRegistr( cReg)
Method setCnpj( cCnpj)
Method setInd( cInd)
Method setInfComp( cInfComp)
Method setRelac( cRelac)
Method setVlPauta (nVlPauta)
Method LimpaX010(c010)
Method getAlqReal()
Method getBaseQtd()
Method setMT()
Method getMT()
Method setJob()
Method setDedbpis( cDedbpis)
Method setDedbcof( cDedbcof)
Method getDedbpis()
Method getDedbcof()

Method setDtDeAte()
Method getDtDe()
Method getDtAte()

Method setaNumer()
Method getaNumer()
Method getGrupo()
Method get9900()

Method getnSitDoc()


ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Erick G. Dias
@since 24/10/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class NOTAEFD

Self:dDtDe			:= CTod("  /  /    ")
Self:dDtAte		:= CTod("  /  /    ")
Self:ClsNotaEfd()

Return


Method setMT(lMT) Class NOTAEFD
	Self:lMT	:= lMT
Return

Method setJob(cJOb) Class NOTAEFD
	Self:cJOb	:= cJOb
Return

Method setDtDeAte(dDtDe,dDtAte) Class NOTAEFD
	Self:dDtDe		:= dDtDe
	Self:dDtAte	:= dDtAte
Return

Method getDtDe() Class NOTAEFD
Return Self:dDtDe

Method getDtAte() Class NOTAEFD
Return Self:dDtAte

Method getMT() Class NOTAEFD
Return Self:lMT

Method setaNumer( aNumeracao) Class NOTAEFD
	Self:aNumeracao := aNumeracao
Return

Method getaNumer() Class NOTAEFD
Return Self:aNumeracao

Method setRelac( cRelac) Class NOTAEFD
	Self:cRelac := cRelac
Return
Method setnNumNf( cnNumNf) Class NOTAEFD
	Self:cnNumNf := cnNumNf
Return

Method setnSerie( cnSerie) Class NOTAEFD
	Self:cnSerie := cnSerie
Return

Method setnSubSerie( cnSubSerie) Class NOTAEFD
	Self:cnSubSerie := cnSubSerie
Return

Method setCodPart( cnCodPart) Class NOTAEFD
	Self:cnCodPart := cnCodPart
Return

Method setChvNfe( cnChaveNfe) Class NOTAEFD
	Self:cnChaveNfe := cnChaveNfe
Return

Method setnSitDoc( cnSitDoc) Class NOTAEFD
	Self:cnSitDoc := cnSitDoc
Return

Method getnSitDoc() Class NOTAEFD
Return Self:cnSitDoc

Method setnModelo( cnModelo) Class NOTAEFD
	Self:cnModelo := cnModelo
Return

Method setIndOper( cnIndOper) Class NOTAEFD
	Self:cnIndOper := cnIndOper
Return

Method setIndEmit( cnIndEmit) Class NOTAEFD
	Self:cnIndEmit := cnIndEmit
Return

Method setValorNf( nnValorNf, lAcum) Class NOTAEFD
	Default lAcum := .F.
	If lAcum
		Self:nnValorNf += nnValorNf
	Else
		Self:nnValorNf := nnValorNf
	EndIF
Return

Method setnVlDesc( nnValDesc, lAcum) Class NOTAEFD
	Default lAcum := .F.
	If lAcum
		Self:nnValDesc += nnValDesc
	Else
		Self:nnValDesc := nnValDesc
	EndIF
Return

Method setnBasPis( nnBasePis, lAcum) Class NOTAEFD
	Default lAcum := .F.
	If lAcum
		Self:nnBasePis += nnBasePis
	Else
		Self:nnBasePis := nnBasePis
	EndIF
Return

Method setnBasCof( nnBaseCof, lAcum) Class NOTAEFD
	Default lAcum := .F.
	If lAcum
		Self:nnBaseCof += nnBaseCof
	Else
		Self:nnBaseCof := nnBaseCof
	EndIF
Return

Method setnValPis( nnValPis, lAcum) Class NOTAEFD
	Default lAcum := .F.
	If lAcum
		Self:nnValPis := nnValPis
	Else
		Self:nnValPis := nnValPis
	EndIF
Return

Method setnValCof( nnValCof, lAcum) Class NOTAEFD
	Default lAcum := .F.
	If lAcum
		Self:nnValCof += nnValCof
	Else
		Self:nnValCof := nnValCof
	EndIF
Return

Method setEmissao( dnEmissao) Class NOTAEFD
	Self:dnEmissao := dnEmissao
Return

Method setEntrada( dnEntrada) Class NOTAEFD
	Self:dnEntrada := dnEntrada
Return

Method setnDtDe( dnDtDe) Class NOTAEFD
	Self:dnDtDe := dnDtDe
Return

Method setnDtAte( dnDtAte) Class NOTAEFD
	Self:dnDtAte := dnDtAte
Return

Method setnInfCmp( cnInfCmp) Class NOTAEFD
	Self:cnInfCmp := cnInfCmp
Return

Method setNumitem( ciNumitem) Class NOTAEFD
	Self:ciNumitem := ciNumitem
Return

Method setiCCusto( ciCCusto) Class NOTAEFD
	Self:ciCCusto := ciCCusto
Return

Method setConta( ciContaCtb) Class NOTAEFD
	Self:ciContaCtb := ciContaCtb
Return

Method setCodItem( ciCodItem) Class NOTAEFD
	Self:ciCodItem := ciCodItem
Return

Method setTNatRec( ciTNatRec) Class NOTAEFD
	Self:ciTNatRec := ciTNatRec
Return

Method setCNatRec( ciCNatRec) Class NOTAEFD
	Self:ciCNatRec := ciCNatRec
Return

Method setGNatRec( ciGNatRec) Class NOTAEFD
	Self:ciGNatRec := ciGNatRec
Return

Method setiCSTPis( ciCSTPis) Class NOTAEFD
	Self:ciCSTPis := ciCSTPis
Return

Method setiCSTCof( ciCSTCof) Class NOTAEFD
	Self:ciCSTCof := ciCSTCof
Return

Method setiCodBcc( ciCodBcc) Class NOTAEFD
	Self:ciCodBcc := ciCodBcc
Return

Method setiCFOP( ciCFOP) Class NOTAEFD
	Self:ciCFOP := ciCFOP
Return

Method setValItem( niValItem) Class NOTAEFD
	Self:niValItem := niValItem
Return

Method setiAlqPis( niAlqPis) Class NOTAEFD
	Self:niAlqPis := Self:TrataSet(niAlqPis)
Return

Method setiAlqCof( niAlqCof) Class NOTAEFD
	Self:niAlqCof := Self:TrataSet(niAlqCof)
Return
Method setiBasPis( niBasePis) Class NOTAEFD
	Self:niBasePis = niBasePis
Return
Method setiBasCof( niBaseCof) Class NOTAEFD
	Self:niBaseCof = niBaseCof
Return
Method setiValPis( niValPis) Class NOTAEFD
	Self:niValPis = niValPis
Return
Method setiValCof( niValCof) Class NOTAEFD
	Self:niValCof = niValCof
Return
Method setiVaDesc( niValDesc) Class NOTAEFD
	Self:niValDesc = niValDesc
Return
Method setiQtde( niQtde) Class NOTAEFD
	Self:niQtde = niQtde
Return

Method setiBsPaut(niBasePaut)Class NOTAEFD
	Self:niBasePaut = niBasePaut
Return

Method setDNatRec( diDNatRec) Class NOTAEFD
	Self:diDNatRec = diDNatRec
Return
Method setProRef( cProRef) Class NOTAEFD
	Self:cProRef = cProRef
Return
Method setTProRef( cTpProRef) Class NOTAEFD
	Self:cTpProRef = cTpProRef
Return
Method setRegistr( cReg) Class NOTAEFD
	Self:cReg = cReg
Return
Method setCnpj( cCnpj) Class NOTAEFD
	Self:cCnpj = cCnpj
Return
Method setInd( cInd) Class NOTAEFD
	Self:cInd = cInd
Return
Method setInfComp( cInfComp) Class NOTAEFD
	Self:cInfComp = cInfComp
Return

Method setVlPauta( nVlPauta) Class NOTAEFD
	Self:nVlPauta	 = nVlPauta
Return

Method LimpaX010(c010) Class NOTAEFD
	Local nPos		:= 0
	Local Auxc010	:= SubStr(c010,1,4)

	If 'A010' == Auxc010
		nPos := aScan (Self:aRegA010, {|aX|  AllTrim(aX[1])==AllTrim(c010)})
		If nPos > 0
			aDel(Self:aRegA010,nPos)
			aSize(Self:aRegA010,Len(Self:aRegA010)-1)
		Endif

	ElseIf 'C010' == Auxc010
		nPos := aScan (Self:aRegC010, {|aX|  AllTrim(aX[1])==AllTrim(c010)})
		If nPos > 0
			aDel(Self:aRegC010,nPos)
			aSize(Self:aRegC010,Len(Self:aRegC010)-1)
		Endif
	ElseIF 'D010' == Auxc010
		nPos := aScan (Self:aRegD010, {|aX|  AllTrim(aX[1])==AllTrim(c010)})
		If nPos > 0
			aDel(Self:aRegD010,nPos)
			aSize(Self:aRegD010,Len(Self:aRegD010)-1)
		Endif
	ElseIF 'F010' == Auxc010
		nPos := aScan (Self:aRegF010, {|aX|  AllTrim(aX[1])==AllTrim(c010)})
		If nPos > 0
			aDel(Self:aRegF010,nPos)
			aSize(Self:aRegF010,Len(Self:aRegF010)-1)
		Endif
	EndIf
Return

Method getAlqReal() Class NOTAEFD
Return Self:nAlqReais

Method getBaseQtd() Class NOTAEFD
Return Self:nBaseQtd

Method getGrupo() Class NOTAEFD
Return Self:cGrupoReg

Method get9900() Class NOTAEFD
Return Self:aReg9900

Method setDedbpis( cDedbpis) Class NOTAEFD
	Self:cDedbpis := cDedbpis
Return

Method setDedbcof( cDedbcof) Class NOTAEFD
	Self:cDedbcof := cDedbcof
Return

Method getDedbpis() Class NOTAEFD
Return Self:cDedbpis

Method getDedbcof() Class NOTAEFD
Return Self:cDedbcof

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
@description Método que inicializa/limpa todos os atributos da classe
@param cOpcao,String,1-Limpa somente nota,2-Limpa somente item,3-Limpa nota e item.
@author Erick G. Dias
@since 17/10/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD ClsNotaEfd(lArray) Class NOTAEFD

Default lArray	:= .T.

Self:cnNumNf		:= ''		//Número do documento fiscal
Self:cnSerie		:= ''		//Série do documento Fiscal
Self:cnSubSerie		:= ''		//Subsérie do documento Fiscal
Self:cnCodPart	:= ''		//Código participante Cliente ou Fornecedor
Self:cnChaveNfe	:= ''		//Chave eletrônica do documento
Self:cnSitDoc		:= ''		//Código da situação do documento
Self:cnModelo		:= ''		//Modelo do documento Fiscal
Self:cnIndOper	:= ''		//Indicador de operação da nota
Self:cnIndEmit	:= ''		//Indicador do emitente
Self:nnValorNf	:= 0		//Valor total da nota fiscal
Self:nnValDesc	:= 0		//Valor total do desconto da nota
Self:nnBasePis	:= 0		//Valor total da base de cálculo de PIS
Self:nnBaseCof	:= 0		//Valor total da base de cálculo de COFINS
Self:nnValPis		:= 0		//Valor total do valor de PIS
Self:nnValCof		:= 0		//Valor Total do valor de COFINS
Self:dnEmissao	:= CTod("  /  /    ")		//Self:de emissão do documento
Self:dnEntrada	:= CTod("  /  /    ")		//Self:de entrada do documento
Self:dnDtDe		:= CTod("  /  /    ")		//Self:inicial de Processamento
Self:dnDtAte		:= CTod("  /  /    ")		//Self:final de Processamento
Self:cnInfCmp		:= ''		//Infomcação COmplementar do documento fiscal.

//-------------------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO AO ITEM DO DOCUMENTO FISCAL
//-------------------------------------------------------------
Self:ciNumitem	:= ''		//Número do item
Self:ciCCusto		:= ''		//Código do Centro de Custo
Self:ciContaCtb	:= ''		//Código da conta contábil
Self:ciCodItem	:= ''		//Código do produto utilizado
Self:ciTNatRec	:= ''		//Tabela da natureza da Receita
Self:ciCNatRec	:= ''		//Código da natureza da receita
Self:ciGNatRec	:= ''		//Grupo da Natureza da Receita
Self:ciCSTPis		:= ''		//CST de PIS
Self:ciCSTCof		:= ''		//CST da Cofins
Self:ciCodBcc		:= ''		//Código da base de cálculo do Crédito
Self:ciCFOP		:= ''		//CFOP
Self:niValItem	:= 0		//Valor do item
Self:niAlqPis		:= 0		//Alíquota de PIS
Self:niAlqCof		:= 0		//Alíquota da COFINS
Self:niBasePis	:= 0		//Valor da base de cálculo de PIS
Self:niBaseCof	:= 0		//Valor da base de cálculo de COFINS
Self:niValPis		:= 0		//Valor de PIS
Self:niValCof		:= 0		//Valor da COFINS
Self:niValDesc	:= 0		//Valor do desconto do item
Self:niQtde		:= 0		//Quantidade de produto do item
Self:niBasePaut	:= 0		//Base Pauta
Self:diDNatRec	:= CTod("  /  /    ")		//Self:da alíquota da natureza da Receita.
Self:cProRef		:= ''		//Número do processo referenciado
Self:cTpProRef	:= ''		//Tipo do processo referenciado
Self:nVlPauta		:= 0
Self:nBaseQtd		:= 0
Self:nAlqReais	:= 0
Self:lMT			:= .F.
Self:cDedbpis	:= ''
Self:cDedbcof	:= ''
//Self:cJob			:= '00'
Self:c010		:= ""

IF lArray
	Self:aRegA010		:= {}
	Self:aRegC010		:= {}
	Self:aRegD010		:= {}
	Self:aRegF010		:= {}
	Self:aRegI010		:= {}
	Self:aRegP010		:= {}
	Self:aReg9900		:= {}		//Array com informações de controle do bloco.
	Self:aReg9001		:= {}		//Array com informações de controle do bloco.
	Self:aReg9990		:= {}		//Array com informações de controle do bloco.
	Self:aReg9999		:= {}		//Array com informações de controle do bloco.	'
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRef()
@description Método genérico para gravação de informações de processo
			   referenciado. Existem registros de processo referenciado
			   nos blocos A, C, D, F, I e 1, todos com a mesma estrutura
			   e formato de campos, por este motivo este método será geérico
			   para qualquer registro de processo referenciado destes blocos.

@param cReg,String,Registro processado que deverá ser gravado no array
@param aReg,Array,Array do registro pertinente a ser gerado
@author Erick G. Dias
@since 22/10/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD ProcRef(cReg,aReg) Class NOTAEFD

Local nPos	:= 0

nPos := aScan (aReg, {|aX| aX[1]== Self:cRelac  .AND.;
							   aX[3] ==Self:cProRef})
IF nPos == 0
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cRelac)			//Relacionamento com registro pai
	aAdd (aReg[nPos], cReg)					//01 - REG
	aAdd (aReg[nPos], Self:cProRef)			//02 - NUM_PROC
	aAdd (aReg[nPos], Self:cTpProRef)		//03 - IND_PROC
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add9001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add9001(cIndMovto) Class NOTAEFD

Self:AbreBloco('9001',@Self:aReg9001,cIndMovto)

Return Self:aReg9001

//-------------------------------------------------------------------
/*/{Protheus.doc} Add9990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add9990(nQtde) Class NOTAEFD

Self:FechaBloco('9990',@Self:aReg9990, nQtde)

Return Self:aReg9990

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreBloco()
@description Método que gera registro de abertura do bloco. Será utilizado
			   para geração dos registro 0001, A001, C001, D001, F001, I001,
			   M001, P001, 1001 e 9001.
@param cReg,String,Registro processado que deverá ser gravado no array
@param aReg,Array,Array do registro pertinente a ser gerado
@param cIndMov,String,Indicador que será gravada no registro de abertura do bloco
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AbreBloco(cReg,aReg,cIndMov) Class NOTAEFD

Local nPos	:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,'', cReg)

aAdd(aReg, {})
nPos := Len(aReg)
aAdd (aReg[nPos], Self:cGrupoReg)	//Relacionamento com registro pai
aAdd (aReg[nPos], cReg)			//01 - REG
aAdd (aReg[nPos], cIndMov)		//02 - IND_MOV

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaBloco()
@description Método que gera registro de encerramento do bloco. Será utilizado
			   para geração dos registro 0990, A990, C990, D990, F990, I990,
			   M990, P990, 1990 e 9990.
@param cReg,String,Registro processado que deverá ser gravado no array
@param aReg,Array,Array do registro pertinente a ser gerado
@param nQtde,Numérico,Quantidade de registro que será gravada no registro de encerramento do bloco
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD FechaBloco(cReg,aReg, nQtde) Class NOTAEFD

Local nPos	:= 0
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,'', cReg)
aAdd(aReg, {})
nPos := Len(aReg)
aAdd (aReg[nPos], Self:cGrupoReg)	//Relacionamento com registro pai
aAdd (aReg[nPos], cReg)		//01 - REG
aAdd (aReg[nPos], nQtde)		//02 - QTD_LIN

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IdentEstab()
@description Método que gera o registro de identificação do estabelecimento,
			   para geração dos registros A010, C010, D010, F010, I010, P010.

@param cReg,String,Registro processado que deverá ser gravado no array
@param aReg,Array,Array do registro pertinente a ser gerado
@param cCnpj,String,Cnpj da filial que deverá constar no registro
@param cInd,String,Indicador da escrituração para C010 ou indicador de atividade para I010
@param cInfComp,String,Informação complementar para registro I010
@author Erick G. Dias

@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD IdentEstab(aReg) Class NOTAEFD

Local	 	nPos		:= 0

If aScan (aReg, {|aX| AllTrim(aX[2])==Self:cCnpj}) == 0
	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos],Self:cRelac) 		//01-Relacionamento
	aAdd (aReg[nPos],Self:cReg) 		//01-REG
	aAdd (aReg[nPos], Self:cCnpj)		//02-CNPJ
	//-------------------------------------------------------------------
	//Para bloco C o registro possui 3 campos
	//Para bloco I campo possui 4 campos
	//Para os demais blocos registro possui somente 2 campos
	//-------------------------------------------------------------------
	If Self:cReg == 'C010'
		aAdd (aReg[nPos], Self:cInd)		//03-IND_ESCRI
	ElseIF Self:cReg == 'I010'
		aAdd (aReg[nPos], Self:cInd)		//03-IND_ATIV
		aAdd (aReg[nPos], Self:cInfComp)		//04-INFO_COMPL
	EndIF
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InfComplNf()
@description Método que gera registros de informação complementar dodocumento
			   fiscal, registros A110 e C110.

@param cReg,String,Registro processado que deverá ser gravado no array
@param aReg,Array,Array do registro pertinente a ser gerado
@param cCodInf,String,Código da informação complementar do documento fiscal
@param cTxtCompl,String,Texto para descrição complementar do código.
@author Erick G. Dias

@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD InfComplNf(cReg,aReg,cCodInf,cTxtCompl) Class NOTAEFD

Local nPos	:= 0

aAdd(aReg, {})
nPos :=	Len (aReg)
aAdd (aReg[nPos], cReg)					//01 - REG
aAdd (aReg[nPos], cCodInf) 				//02 - COD_INF
aAdd (aReg[nPos], cTxtCompl)          //03 - TXT_COMPL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddA010()
@description Método que irá gerar registro A010
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddA010() Class NOTAEFD

Self:IdentEstab(Self:aRegA010)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getA010()
@description Método que irá retornar array do registro A010
@author Erick G. Dias
@since 01/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD getA010() Class NOTAEFD
Return Self:aRegA010

//-------------------------------------------------------------------
/*/{Protheus.doc} getD010()
@description Método que irá retornar array do registro A010
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD getD010() Class NOTAEFD
Return Self:aRegD010

//-------------------------------------------------------------------
/*/{Protheus.doc} getC010()
@description Método que irá retornar array do registro C010
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD getC010() Class NOTAEFD
Return Self:aRegC010



METHOD getF010() Class NOTAEFD
Return Self:aRegF010

METHOD getI010() Class NOTAEFD
Return Self:aRegI010

METHOD getP010() Class NOTAEFD
Return Self:aRegP010

//-------------------------------------------------------------------
/*/{Protheus.doc} AddC010()
@description Método que irá gerar registro C010
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddC010() Class NOTAEFD

Self:IdentEstab(Self:aRegC010)

Return Self:aRegC010


//-------------------------------------------------------------------
/*/{Protheus.doc} AddD010()
@description Método que irá gerar registro D010
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD010() Class NOTAEFD

Self:IdentEstab(Self:aRegD010)

Return Self:aRegD010


//-------------------------------------------------------------------
/*/{Protheus.doc} AddF010()
@description Método que irá gerar registro F010
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF010() Class NOTAEFD

Self:IdentEstab(Self:aRegF010)

Return Self:aRegF010

//-------------------------------------------------------------------
/*/{Protheus.doc} AddI010()
@description Método que irá gerar registro I010
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddI010() Class NOTAEFD

Self:IdentEstab(Self:aRegI010)

Return Self:aRegI010

//-------------------------------------------------------------------
/*/{Protheus.doc} AddP010()
@description Método que irá gerar registro P010
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddP010() Class NOTAEFD

Self:IdentEstab(Self:aRegP010)

Return Self:aRegP010

//-------------------------------------------------------------------
/*/{Protheus.doc} Add9900()
@description Método que popula o registro 9900. Registro contador de conferência
			   do arquivo.

@param cReg,String,Nome do registro referente o contador
@param nQtde,Numérico,Quantidade do registro
@author Erick G. Dias

@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add9900(cReg,nQtde) Class NOTAEFD

Local nPos	:= 0
nPos := aScan (Self:aReg9900, {|aX| aX[3]==cReg})

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,'', '9900')
	aAdd(Self:aReg9900, {})
	nPos :=	Len (Self:aReg9900)
	aAdd (Self:aReg9900[nPos], Self:cGrupoReg)	//01 - REG
	aAdd (Self:aReg9900[nPos], '9900')	//01 - REG
	aAdd (Self:aReg9900[nPos], cReg)	//02 - REG_BLC
	aAdd (Self:aReg9900[nPos], nQtde)	//03 - QTD_REG_BLC
Else
	Self:aReg9900[nPos] +=	nQtde		//03 - QTD_REG_BLC
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add9999()
@description Método que gera último regiustro do arquivo


@param nQtde,Numérico,Quantidade do registro
@author Erick G. Dias

@since 28/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add9999(nQtde) Class NOTAEFD

Local nPos	:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,'', '9999')
aAdd(Self:aReg9999, {})
nPos :=	Len (Self:aReg9999)
aAdd (Self:aReg9999[nPos], Self:cGrupoReg)	//Relacionamento
aAdd (Self:aReg9999[nPos], '9999')	//01 - REG
aAdd (Self:aReg9999[nPos], nQtde)	//02 - QTD_LIN

Return Self:aReg9999


//-------------------------------------------------------------------
/*/{Protheus.doc} OperPauta()
@description Método que irá realizar conversão dos valores de pauta

@param cTrib,String,Indica qual tributo deverá ser processado, 1-PIS, 2-COFINS
@return lRet, Lógico, Indica que houve conversão de valores
@author Erick G. Dias
@since 11/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method OperPauta(cTrib,lSecUnMed) Class NOTAEFD
Local nAliqRec	:= 0
Local lRet			:= .F.
Default lSecUnMed	:= .F.

DbSelectArea ("CCZ")
CCZ->(DbSetOrder (1))

IF Self:nVlPauta > 0 .And. AllTrim(Self:ciTNatRec) =='4311' .AND. CCZ->(msSeek(xFilial("CCZ")+Self:ciTNatRec+Self:ciCNatRec+Self:ciGNatRec+dTos(Self:diDNatRec))) .and. CCZ->CCZ_TABELA == '4311'
	if cTrib == '1'	//Pis
		nAliqRec := CCZ->CCZ_ALQPIS
	ElseIF cTrib == '2'	//Cofins
		nAliqRec := CCZ->CCZ_ALQCOF
	EndIF

	IF nAliqRec > 0

		Self:nAlqReais	:= nAliqRec

		If lSecUnMed
			Self:nBaseQtd 	:= Self:niBasePaut //Segunda Unidade de medida através do parâmetro MV_PISCOFP
		Else
			Self:nBaseQtd 	:= NoRound((Self:nVlPauta/nAliqRec) * Self:niQtde,3) //Cálculo através do legado
		EndIF
		lRet	:= .T.
	EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataSet()
@description Metodo para tratamento dos valores passados para os metodos
"set" de alguns atributos, que conforme a situacao recebem um array...Por
exemplo na consolidacao do multithread, quando o valor eh setado a partir
do array do registro ja montado e a posicao contem um array c/ os decimais.

Exemplo: Campo 08 - QUANT_BC_PIS/QUANT_BC_COFINS método "AddC18X".

@param xValor, Valor passado para o metodo set. Pode ser array ou numerico.
@return nRet, Numerico, Valor a ser atribuido no atributo.
@author Joao Victor Pellegrini
@since 28/01/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Method TrataSet(xValor) Class NOTAEFD

Local nRet := 0

If ValType(xValor) == "A" .And. Len(xValor) >= 1
	If ValType(xValor[1]) == "N"
		nRet := xValor[1]
	Else
		nRet := 0
	EndIf
Else
	if ValType(xValor) == "C"
		nRet := val(xValor)
	else
		nRet := xValor
	endif
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ARRAYTOTMP()
@description Classe que irá efetuar controle da gravação das informações
			   formatadas de um array, gerar a linha do arquivo e realizar
			   gravação da informação na tabela. Aqui também irá criar a
			   tabela conforme parâmetros passados para classe.
@author Erick G. Dias
@since 04/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

CLASS ARRAYTOTMP

Data cAliasTmp		as String		READONLY		//Alias da tabela temporária que deverá ser criada
Data cArqTmp			as String		READONLY		//Arquivo da tabela temporária que deverá ser criada
Data cAliasCAd		as String		READONLY		//Alias da tabela temporária que deverá ser criada
Data cArqCad			as String		READONLY		//Arquivo da tabela temporária que deverá ser criada
Data cIndice			as String		READONLY		//Indíce que deverá ser utilizado na criação da tabela
Data cDelimit			as String		READONLY		//Delimitador para separação entre os campos do registro
Data aCampos			as Array		READONLY		//Array com estrutura da tabela a ser criada.
Data aRegistro		as Array		READONLY		//Array com informação do registro a ser processado
Data nPosRelac		as Integer		READONLY		//Posição do array que representa
Data cLinhaTxt		as String 		READONLY		//Linha que deverá ser gravada na tabela
Data cGrupo			as String 		READONLY		//Conteúdo do grupo que deverá ser gravado na tabela.
Data cBloco			as String 		READONLY		//Número do bloco que deverá ser gravado na tabela.
Data cRegistro		as String 		READONLY		//Registro que deverá ser gravado na tabela temporária.
Data cDiretorio		as String 		READONLY		//Registro que deverá ser gravado na tabela temporária.
Data lHtml				as Boolean		READONLY		//tratamento para HTML



Data cPathArq		as String 		READONLY		//Registro que deverá ser gravado na tabela temporária.
Data cNomeArq		as String 		READONLY		//Registro que deverá ser gravado na tabela temporária.
Data cRecno		as String 		READONLY		//Registro que deverá ser gravado na tabela temporária.

Method New()
Method CriaTabela()
Method CriaTabCad()

Method DelTabela()
Method DelTabCad()
Method GravaLinha()
Method GravaCad()
Method ProCad()

Method GeraLinha()
Method GetAlias()
Method GetArqDbf()
Method SetAlias()
Method SetArqDbf()
Method GravaTXT()

Method OpenTAbTmp()
Method OpenTAbCad()

Method getNomeArq()


Method getAlsCad()
Method getArqCad()


Method SetRegistr()
Method GrvReg()
Method SetGrupo()
Method SetBloco()
Method SetLinha()
Method setJob()

Method setDiretor()
Method setHtml()
Method SetPath()
Method setNomeArq()
Method setRecno()


ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class ARRAYTOTMP

	Self:aRegistro	:={}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabela()
@description Método que irá criar a tabela temporária para gravação dos registros.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD CriaTabela(lCtree) Class ARRAYTOTMP

Local aCmp	   := {}
//TRATAMENTO DO NOME DA TABELA DEVIDO A ESTOURO NO ORACLE
Local cAno		:= RIGHT(ALLTRIM(STR(Year(dDataBase))),2)
Local cMes		:= Alltrim(Str(Month( dDatabase)))
Local cDia 		:= Alltrim(Str(Day( dDatabase)))
Local cDtSec	:= NTOC(VAL(cDia+cMes+cAno+AllTrim(StrTran(Str(Seconds()),".",""))) ,16)

Local cAliasTRB 	:= "FISA008" + cDtSec
Local cArquivo  	:= cAliasTRB+GetDBExtension() //Recupera o nome fisico gerado

//Self:cAliasTmp	:=	GetNextAlias()
aAdd (aCmp, {'NROBLOCO',	'C', 	002,	0})	//Número correspondente do bloco
aAdd (aCmp, {'REGISTRO',	'C', 	004,	0})	//Registro que deverá ser gravado
aAdd (aCmp, {'GRUPO',	'C', 	065,	0})	//Código do grupo utilizado para ordenação da tabela, no momento da gravação do arquivo texto
aAdd (aCmp, {'CONTEUDO',	'C', 	500,	0})	//Conteúdo da linha a ser gravada no arquivo texto.

Self:cAliasTmp		:= cAliasTRB
Self:cArqTmp			:= cArquivo


IF lCtree //.AND. Findfunction('FWOpenTemp')
	FWOpenTemp(Self:cAliasTmp,aCmp,Self:cArqTmp)
	
	If "SQLITE" $ RealRdd()
		IndRegua(Self:cAliasTmp,GetNextAlias(),"NROBLOCO+GRUPO+REGISTRO",,,'NROBLOCO+GRUPO+REGISTRO')
	Else
		IndRegua(Self:cAliasTmp,'GRUPO',"NROBLOCO+GRUPO+REGISTRO",,,'NROBLOCO+GRUPO+REGISTRO')
	Endif

Else //cria tabela em DBF.
	Self:cArqTmp	:= CriaTrab (aCmp)
	DbUseArea (.T., __LocalDriver, Self:cArqTmp, Self:cAliasTmp)
	IndRegua (Self:cAliasTmp, Self:cArqTmp, 'NROBLOCO+GRUPO+REGISTRO')
EndIF


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabela()
@description Método que irá criar a tabela temporária para gravação dos registros.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD CriaTabCad(cNomeTab,cTpTab) Class ARRAYTOTMP

Local aCmp		:= {}
//TRATAMENTO DO NOME DA TABELA DEVIDO A ESTOURO NO ORACLE
Local cDtSec	:= NTOC(VAL(FWTimeStamp(1,dDataBase,Time())) ,16)

Default cNomeTab	:= 'FSA008CAD' + cDtSec

aAdd (aCmp, {'TIPOCOD',	'C', 	002,	0})	//Indica o tipo de código utilizado.
aAdd (aCmp, {'REG0140',	'C', 	013,	0})	//Relacionamento com Registro pai 0140
aAdd (aCmp, {'CODIGO',	'C', 	060,	0})	//Código utilizado

If cTpTab ==  '1' //lTop

	Self:cArqCad	:= cNomeTab
	Self:cAliasCad	:= cNomeTab


	PCCriaTab( Self:cArqCad , Self:cAliasCad, aCmp,'TIPOCOD+CODIGO+REG0140')
ElseIf cTpTab == '2' //DBF
	Self:cArqCad	:=cNomeTab+ GetDBExtension()
	Self:cAliasCad	:= cNomeTab

	Self:cArqCad	:= CriaTrab (aCmp)
	DbUseArea (.T., __LocalDriver, Self:cArqCad, Self:cAliasCad)
	IndRegua (Self:cAliasCad, Self:cArqCad, 'TIPOCOD+CODIGO+REG0140')
ElseIF cTpTab == '3' //.AND. Findfunction('FWOpenTemp')  //CTREE
	Self:cArqCad	:=cNomeTab+ GetDBExtension()
	Self:cAliasCad	:= cNomeTab

	FWOpenTemp(Self:cAliasCad,aCmp,Self:cArqCad)

	If "SQLITE" $ RealRdd()
		IndRegua(Self:cAliasCad,GetNextAlias(),"TIPOCOD+CODIGO+REG0140",,,'TIPOCOD+CODIGO+REG0140')
	Else
		IndRegua(Self:cAliasCad,'TIPOCOD',"TIPOCOD+CODIGO+REG0140",,,'TIPOCOD+CODIGO+REG0140')
	Endif

EndIF


Return


METHOD OpenTAbTmp(cAliasTRB,cArquivo) Class ARRAYTOTMP

Self:cAliasTmp		:= cAliasTRB
Self:cArqTmp			:= cArquivo

DbUseArea(.F., __LocalDriver, cArquivo, cAliasTRB)

dbSelectArea(cAliasTRB)

Return

METHOD OpenTAbCad(cAliasTRB,cArquivo) Class ARRAYTOTMP

Self:cAliasCad		:= cAliasTRB
Self:cArqCad			:= cArquivo


DbUseArea(.T., __cRdd, cArquivo, cAliasTRB,.T.,.F.)
( cAliasTRB )->( dbClearIndex() , dbSetIndex( cArquivo + '_01' ) )

Return

Method getNomeArq() Class  ARRAYTOTMP
Return IIf(Self:lHtml,Self:cNomeArq,Self:cDiretorio+Self:cNomeArq)

//-------------------------------------------------------------------
/*/{Protheus.doc} DelTabela()
@description Método que apaga a tabela temporária criada para geração do arquivo texto.
			   Para utilizar este método deverá passar o alias e o nome do arquivo antes.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD DelTabela() Class ARRAYTOTMP

If FindFunction("FWCLOSETEMP")

	FWCLOSETEMP(Self:cAliasTmp)
Else

	(Self:cAliasTmp)->(DbCloseArea ())
EndiF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelTabcad()
@description Método que apaga a tabela temporária criada para geração do arquivo texto.
			   Para utilizar este método deverá passar o alias e o nome do arquivo antes.
@author Erick G. Dias
@since 08/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD DelTabcad() Class ARRAYTOTMP

If FindFunction("FWCLOSETEMP")
	FWCLOSETEMP(Self:cAliasCad)
Else
	(Self:cAliasCad)->(DbCloseArea ())
EndiF

If TcCanOpen( Self:cArqCad )
	TcDelFile( Self:cArqCad )
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraLinha()
@description Método que irá gerar a linha a ser gravada na tabela temporária.
			   Irá percorrer o array do registro montando campo a campo
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD GeraLinha() Class ARRAYTOTMP
Local nContR	:= 0
Local nContC	:= 0
Local nDecimal	:= 2
Local cLinha	:= '|'
Local cConteudo	:= ''
Local cType		:= ''

Self:cDelimit	:= '|'
	//Laço para percorrer os registros
	For nContR	:= 1 to Len(Self:aRegistro)
		//sempre a primeira posição será o relacionamento dos registros,
		//por este motivo busca aqui a primeira posição.
		Self:cGrupo	:= AllTrim(Self:aRegistro[nContR][1])
		Self:cRegistro:= AllTrim(Self:aRegistro[nContR][2])
		Self:setRegistr(Self:cRegistro)
		//Laço para percorrer os campos dos registros
		For nContC	:= 2 to Len(Self:aRegistro[nContR])

			cType	:= ValType(Self:aRegistro[nContR][nContC])

			If cType == 'A'

				IF  valtype(Self:aRegistro[nContR][nContC][1]) == 'N'
					//Pega quantidade de casas decimais na segunda posição informada no campo
					nDecimal	:=	Self:aRegistro[nContR][nContC][2]
					//Formata colocando víergula no lugar de ponto, e formatando decimais conforme passado na segunda posição do array
					cConteudo	:= AllTrim(StrTran(Str(Self:aRegistro[nContR][nContC][1],,nDecimal), ".", ","))
				Else
					cConteudo	:= AllTrim(Self:aRegistro[nContR][nContC][1])
				EndiF

			ElseIf cType == 'N'
				nDecimal	:= 2
				cConteudo	:= AllTrim(StrTran(Str(Self:aRegistro[nContR][nContC],,nDecimal), ".", ","))
			ElseIf cType == 'C'
				cConteudo	:= AllTrim(Self:aRegistro[nContR][nContC])
			ElseIf cType == 'D'
				cConteudo	:= StrZero(Day(Self:aRegistro[nContR][nContC]), 2) + StrZero(Month(Self:aRegistro[nContR][nContC]), 2) + StrZero(Year(Self:aRegistro[nContR][nContC]), 4)
			Else
				cConteudo	:= ''
			EndIf

			cLinha += cConteudo + Self:cDelimit

		Next nContC//Fim do laço dos campos
		Self:cLinhaTxt 	:= cLinha

		//Aqui chama método para realizar a gravação do registro na tabela temporária
		Self:GravaLinha()
		cLinha	:= '|'
	Next nContR//Fim do laço do registro

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRegistr()
@description Método que irá receber o registro, e irá identificar qual o número
			  correspondente do bloco para este ergistro
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

METHOD SetRegistr(cReg) Class ARRAYTOTMP

Local cBloco	:= SubStr(cReg,1,1)

//Abaixo tratamento para identificar qual o número do bloco pertinente para gravação na tabela temporária
Do Case
	Case cBloco == '0'
		Self:cBloco	:= '01'
	Case cBloco == 'A'
		Self:cBloco	:= '02'
	Case cBloco == 'C'
		Self:cBloco	:= '03'
	Case cBloco == 'D'
		Self:cBloco	:= '04'
	Case cBloco == 'F'
		Self:cBloco	:= '05'
	Case cBloco == 'I'
		Self:cBloco	:= '06'
	Case cBloco == 'M'
		Self:cBloco	:= '07'
	Case cBloco == 'P'
		Self:cBloco	:= '08'
	Case cBloco == '1'
		Self:cBloco	:= '09'
	Case cBloco == '9'
		Self:cBloco	:= '10'
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaLinha()
@description Método que irá gravar a linha já processada na tabela temporária.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD GravaLinha() Class ARRAYTOTMP

RecLock(Self:cAliasTmp,.T.)
Replace NROBLOCO 			With Self:cBloco
Replace REGISTRO    		With Self:cRegistro
Replace GRUPO     		With Self:cGrupo
Replace CONTEUDO     	With Self:cLinhaTxt
MsUnLock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCad()
@description Método que irá gravar a linha já processada na tabela temporária.
@author Erick G. Dias
@since 08/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD GravaCad(cTipo, cCodigo,cReg0140) Class ARRAYTOTMP

RecLock(Self:cAliasCad,.T.)
Replace TIPOCOD 			With cTipo
Replace CODIGO    		With cCodigo
Replace REG0140			With cReg0140

MsUnLock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProCad()
@description Método que irá gravar a linha já processada na tabela temporária.
@author Erick G. Dias
@since 08/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD ProCad(cTipo, cCodigo, cRegPai) Class ARRAYTOTMP

Local lExiste	:= .F.

Default cRegPai	:= ''

If !Empty(cCodigo) .AND. (Self:cAliasCad)->(MsSeek(cTipo+Padr(cCodigo,60)+cRegPai))
	lExiste	:= .T.
Else
	Self:GravaCad(cTipo, cCodigo,cRegPai)
EndIF

Return lExiste


METHOD getAlsCad() Class ARRAYTOTMP
Return Self:cAliasCad

METHOD getArqCad() Class ARRAYTOTMP
Return Self:cArqCad


//-------------------------------------------------------------------
/*/{Protheus.doc} GetAlias()
@description Método que retorna o alias da tabela temporária criada.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD GetAlias() Class ARRAYTOTMP
Return Self:cAliasTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} GetArqDbf()
@description Método que retorna o nome fisíco da tabela temporária criada.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD GetArqDbf() Class ARRAYTOTMP
Return Self:cArqTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} SetAlias()
@description Método que seta o alias da tabela temporária criada.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD SetAlias(cValue) Class ARRAYTOTMP
	Self:cAliasTmp	:= cValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetArqDbf()
@description Método que seta o nome fisíco da tabela temporária criada.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD SetArqDbf(cValue) Class ARRAYTOTMP
	Self:cArqTmp	:= cValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvReg()
@description Método que seta o nome do registro a ser gravado
@author Erick G. Dias
@since 18/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD GrvReg(aRegistro) Class ARRAYTOTMP

Local nA			:= 0
Local lTaf			:= Iif (Type("lExtTAFContr") <> "U", lExtTAFContr, .F.)

//Passa array para classe
Self:aRegistro	:= aRegistro

If !lTaf
	Self:GeraLinha() //Grava o registro
Else
	If Len(aRegistro) > 0
		For nA:=1 to Len(aRegistro)
			AADD(aRegExtTaf,aRegistro[nA])
		Next
	Endif
Endif

Return aRegistro

//-------------------------------------------------------------------
/*/{Protheus.doc} SetGrupo()
@description Método que seta o grupo do registro a ser gravado
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD SetGrupo(cValue) Class ARRAYTOTMP

Self:cGrupo	:= cValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBloco()
@description Método que seta o bloco do registro a ser gravado
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD SetBloco(cValue) Class ARRAYTOTMP

Self:cBloco	:= cValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLinha()
@description Método que seta a linha do registro a ser gravado
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD SetLinha(cValue) Class ARRAYTOTMP

Self:cLinhaTxt	:= cValue

Return

METHOD SetDiretor(cValue) Class ARRAYTOTMP

Self:cDiretorio	:= cValue

Return

METHOD SetHtml(lValue) Class ARRAYTOTMP

Self:lHtml	:= lValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPath()
@description Método que seta o caminho do arquivo texto a ser gravado
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method SetPath(cValue) Class ARRAYTOTMP

Self:cPathArq	:= cValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} setNomeArq()
@description Método que seta o nome do arquivo a ser gravado.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method setNomeArq(cValue) Class ARRAYTOTMP

Self:cNomeArq := cValue

Return


Method setRecno(cValue) Class ARRAYTOTMP

Self:cRecno	:= cValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaTXT()
@description Método que irá fazer a cópia da tabela temporária para arquivo texto.
			   Importante lembrar que a tabela deverá ser ordenada antes de realizar
			   COPY TO, para ser gravada exatamente da forma ordenada, que será
			   a ordem exigida pela EFD Contribuições.
@author Erick G. Dias
@since 05/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method GravaTXT() Class ARRAYTOTMP

Local cNomeTmp		:= AllTrim( GetSrvProfString( "StartPath" , "" ) )+'EFDCON - '+cFilAnt+'.Txt'
Local cNomeReal	:= Self:cDiretorio+Self:cNomeArq
Local bError
Local lErro	:= .F.
Local cFunc			:= 'CPYS2TW'

dbSelectArea(Self:cAliasTmp)
(Self:cAliasTmp)->(DBSetOrder(1))
(Self:cAliasTmp)->(DbGoTop ())
Set Filter To

bError := ErrorBlock( {|| lErro := .T. } )
BEGIN SEQUENCE

	Copy to &cNomeReal FIELDS 'CONTEUDO' DELIMITED WITH ''

END SEQUENCE
ErrorBlock( bError )

If lErro
	//Alert('Erro ao gravar arquivo texto')
	dbSelectArea(Self:cAliasTmp)
	(Self:cAliasTmp)->(DBSetOrder(1))
	(Self:cAliasTmp)->(DbGoTop ())
	Set Filter To
	bError := ErrorBlock( {|| lErro := .T. , cNomeTmp:='XXXXXX' } )
	BEGIN SEQUENCE

		Copy to &cNomeTmp FIELDS 'CONTEUDO' DELIMITED WITH ''

	END SEQUENCE
	ErrorBlock( bError )
EndIf

If Self:lHtml .and. FindFunction(cFunc)
	msgAlert("Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador.")
	If !lErro
		&(cFunc+'("'+cNomeReal+'")')
	Else
		&(cFunc+'("'+cNomeTmp+'")')
	EndIf
EndIf
Return Iif(lErro,cNomeTmp,'')

