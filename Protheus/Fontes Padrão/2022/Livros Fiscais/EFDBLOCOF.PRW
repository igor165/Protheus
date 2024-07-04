#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCOF();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCOF()
@description Classe que terá as informações específicas para geração dos 
			   registros do bloco A no SPED Contribuições. Esta classe
			   herda as propriedades e métodos da classe NOTAEFD, então aqui
			   teremos somente as propriedades pertinentes ao bloco F, bem
			   como os método para gravação dos registros, respeitando formatos
			   e hierarquia. 

@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCOF FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS DA CLASSE
//-----------------------------------------------------
Data cIndOper		as String		READONLY		//Indicador do tipo de operação
Data dDtOper		as Date		READONLY		//Data da operação
Data nVlOper		as Integer		READONLY		//Valor da operação
Data cOriCrd		as String		READONLY		//Indicador da origem do crédito
Data cDescri		as String		READONLY		//Descrição complementar da operação
Data cIdeBem		as String		READONLY		//Identificação do bem
Data cUtiBem		as String		READONLY		//Identificação da utilização do bem
Data nDeprec		as Integer		READONLY		//Valor da depreciação do bem
Data nVlExclu		as Integer		READONLY		//Valor da parcela a excluir
Data cMesAqui		as String		READONLY		//Mês da aquisição
Data nValAqui		as Integer		READONLY		//Valor da aquisição
Data nValCred		as Integer		READONLY		//Valor do crédito da aquisição
Data cIndParc		as String		READONLY		//Indicador do número de parcelas
Data nValEstq		as Integer		READONLY		//Valor total do Estoque de abertura
Data nParEstq		as Integer		READONLY		//Valor da parcela do estoque de abertura
Data nBasEstq		as Integer		READONLY		//Base de cálculo sobre estoque de baertura
Data nEstqMes		as Integer		READONLY		//Valor da base de cálculo mensal de estoque de abertura
Data nValRecb		as Integer		READONLY		//Valor Total de receita recebida
Data cICmpRec		as String		READONLY		//Indicador da composição da receita
Data cCnpj			as String		READONLY		//CNPJ / CPF do participante
Data nRecDet		as Integer		READONLY		//Valor da receita detalhada
Data nRecAuf		as Integer		READONLY		//Valor da receita Auferida
Data cNatRet		as String		READONLY		//Indicador da Natureza de retenção
Data dDtRet		as Date		READONLY		//Data retenção
Data nBasRet		as Integer		READONLY		//Base de cálculo retenção
Data nTotRet		as Integer		READONLY		//Valor total retido na fonte
Data cCodRec		as String		READONLY		//Código da receita
Data cRegime		as String		READONLY		//Regime, Cumulativo, não cumulativo
Data nPisRet		as Integer		READONLY		//Valor PIS retido na fonte
Data nCofRet		as Integer		READONLY		//Valor COFINS retido na fonte
Data cIndDec		as String		READONLY		//Indicador do declarante da retenção de fonte

Data cOriDed		as String		READONLY		//Indicador da origem da dedução
Data nDedPis		as Integer		READONLY		//Valor a deduzir de PIS
Data nDedCof		as Integer		READONLY		//Valor a deduzir de COFINS
Data nBasDed		as Integer		READONLY		//Base de cálculo de outras deduções


//F200
Data cTpOpImob		as String		READONLY		//Indicador do tipo de operação
Data cTpUnImob		as String		READONLY		//Tipo unidade imobilizria
Data cNome				as String		READONLY		//Identificação/Nome Empreendiment
Data nTotImob			as Integer		READONLY		//valor total da unidade imobiliaria
Data nRecAcum			as Integer		READONLY		//Valor recebido acumulado
Data nRecMes			as Integer		READONLY		//Valor recebido no mês
Data nPercent			as Integer		READONLY		//Percentual da receita recebida
Data cNatImob			as String		READONLY		//Natureza específica do empreendimento
//F205
Data nCIncAnt			as Integer		READONLY		//Valor total do custo incorrido acumulado até mês anterior
Data nCIncMes			as Integer		READONLY		//Valor do custo incorrido no mês
Data nTotCinc			as Integer		READONLY		//Total do custo incorrido
Data nExCInc			as Integer		READONLY		//Custo incorrido sem direito ao crédito
Data nCPisAnt			as Integer		READONLY		//Credito ate perdio anterior pis 
Data nCPisMes			as Integer		READONLY		//Credito para decontar no período pis
Data nCPisFut			as Integer		READONLY		//Credito para períodos futuros pis
Data nCCofAnt			as Integer		READONLY		//Credito ate perdio anterior COFINS
Data nCCofMes			as Integer		READONLY		//Credito para decontar no período COFINS
Data nCCOfFut			as Integer		READONLY		//Credito para períodos futuros COFINS

//F210
Data nTotCOrc			as Integer		READONLY		//Valor total do custo orçado
Data nExCOrc			as Integer		READONLY		//Valor exclusão custo orçado
Data nBasCOrc			as Integer		READONLY		//Base de cálculo sobre custo orçado
Data aRegF100		as Array		READONLY		
Data aRegF120		as Array		READONLY		
Data aRegF200		as Array		READONLY
Data aRegF205		as Array		READONLY
Data aRegF210		as Array		READONLY
Data aRegF130		as Array		READONLY		
Data aRegF150		as Array		READONLY		
Data aRegF500		as Array		READONLY		
Data aRegF510		as Array		READONLY		
Data aRegF525		as Array		READONLY		
Data aRegF550		as Array		READONLY		
Data aRegF560		as Array		READONLY		
Data aRegF600		as Array		READONLY		
Data aRegF700		as Array		READONLY
Data aRegF111		as Array		READONLY	
Data aRegF129		as Array		READONLY	
Data aRegF139		as Array		READONLY	
Data aRegF211		as Array		READONLY	
Data aRegF509		as Array		READONLY	
Data aRegF519		as Array		READONLY	
Data aRegF559		as Array		READONLY	
Data aRegF569		as Array		READONLY
Data aRegF001		as Array		READONLY
Data aRegF990		as Array		READONLY	
Data aRegF800		as Array		READONLY

//F800
Data cNatEven		as String		READONLY
Data dDtEven		as Date		READONLY
Data cSuCnpj		as String		READONLY
Data cPeriod		as String		READONLY
Data cCodCre		as String		READONLY
Data nValPis		as String		READONLY
Data nValCof		as Integer		READONLY
Data cPcCisa		as Integer		READONLY	

//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()

METHOD setIndOper( cIndOper) 
METHOD setDtOper( dDtOper) 
METHOD setVlOper( nVlOper) 
METHOD setOriCrd( cOriCrd)
METHOD setDescri( cDescri)
METHOD setIdeBem( cIdeBem)
METHOD setUtiBem( cUtiBem) 
METHOD setDeprec( nDeprec) 
METHOD setVlExclu( nVlExclu)
METHOD setMesAqui( cMesAqui) 
METHOD setValAqui( nValAqui) 
METHOD setValCred( nValCred) 
METHOD setIndParc( cIndParc) 
METHOD setValEstq( nValEstq) 
METHOD setParEstq( nParEstq) 
METHOD setBasEstq( nBasEstq) 	
METHOD setEstqMes( nEstqMes) 
METHOD setValRecb( nValRecb) 
METHOD setICmpRec( cICmpRec) 
METHOD setCnpj( cCnpj) 
METHOD setRecDet( nRecDet) 
METHOD setRecAuf( nRecAuf) 
METHOD setNatRet( cNatRet) 
METHOD setDtRet( dDtRet) 
METHOD setBasRet( nBasRet) 
METHOD setTotRet( nTotRet)
METHOD setCodRec( cCodRec) 
METHOD setRegime( cRegime) 
METHOD setPisRet( nPisRet) 
METHOD setCofRet( nCofRet) 
METHOD setIndDec( cIndDec)
METHOD setOriDed( cOriDed) 
METHOD setDedPis( nDedPis)	
METHOD setDedCof( nDedCof) 
METHOD setBasDed( nBasDed) 
Method setTpOpImob( cTpOpImob) 	
Method setTpUnImob( cTpUnImob) 	
Method setNome( cNome) 	
Method setTotImob( nTotImob) 	
Method setRecAcum( nRecAcum) 	
Method setRecMes( nRecMes) 
Method setPercent( nPercent) 
Method setNatImob( cNatImob) 
Method setCIncAnt( nCIncAnt) 
Method setCIncMes( nCIncMes) 
Method setTotCinc( nTotCinc) 
Method setExCInc( nExCInc) 	
Method setCPisAnt( nCPisAnt) 	
Method setCPisMes( nCPisMes) 	
Method setCPisFut( nCPisFut) 	
Method setCCofAnt( nCCofAnt) 	
Method setCCofMes( nCCofMes) 	
Method setCCOfFut( nCCOfFut) 	
Method setTotCOrc( nTotCOrc) 	
Method setExCOrc( nExCOrc) 	
Method setBasCOrc( nBasCOrc)
Method AddF001(cIndMovto)
Method AddF990(nQtde)

Method setNatEven(cNatEven)		 
Method setDtEven(dDtEven)
Method setSuCnpj(cSuCnpj)		 
Method setPeriod(cPeriod)		 
Method setCodCre(cCodCre)		 		 
Method setValPis(nValPis)		 
Method setValCof(nValCof)		 
Method setPcCisa(cPcCisa)
Method getF111()
Method getF700()
Method getF800()
Method getF150()
Method getF129()
Method getF130()
Method getF139()
Method getF600()
Method getF500()
Method getF509()
Method getF510()
Method getF519()
Method getF525()
Method getF010()


Method getF550()
Method getF559()
Method getF560()
Method getF569()

Method getF200()
Method getF205()
Method getF210()


Method clsF200()

Method clsF550()

Method clsF100()
Method clsF120()
Method clsF130()

Method clsF150()
Method clsF700()

Method clsF800()
Method AddF100()
Method AddF120()
Method AddF130(lAgrupa)
Method AddF150()
Method AddF200()
Method AddF205()
Method AddF210()
Method AddF50X() //método para incluir F500,F510, F550 e F560
Method AddF500()
Method AddF510()
Method AddF550()
Method AddF560()
Method AddF525()
Method AddF600()
Method AddF700()
Method AddF800()
METHOD AddProcRef(cReg)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCOF
Self:cJob	:= '00'
Self:Clear()
Self:ClsNotaEfd()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear(lArray)
@description Método que inicializa as propriedades da classe

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method Clear(lArray) Class EFDCBLOCOF

Default lArray	:= .T.

Self:cIndOper		:= ''		//Indicador do tipo de operação
Self:dDtOper		:= CTod("  /  /    ")		//Self:da operação
Self:nVlOper		:= 0		//Valor da operação
Self:cOriCrd		:= ''		//Indicador da origem do crédito
Self:cDescri		:= ''		//Descrição complementar da operação
Self:cIdeBem		:= ''		//Identificação do bem
Self:cUtiBem		:= ''		//Identificação da utilização do bem
Self:nDeprec		:= 0		//Valor da depreciação do bem
Self:nVlExclu		:= 0		//Valor da parcela a excluir
Self:cMesAqui		:= ''		//Mês da aquisição
Self:nValAqui		:= 0		//Valor da aquisição
Self:nValCred		:= 0		//Valor do crédito da aquisição
Self:cIndParc		:= ''		//Indicador do número de parcelas
Self:nValEstq		:= 0		//Valor total do Estoque de abertura
Self:nParEstq		:= 0		//Valor da parcela do estoque de abertura
Self:nBasEstq		:= 0		//Base de cálculo sobre estoque de baertura
Self:nEstqMes		:= 0		//Valor da base de cálculo mensal de estoque de abertura
Self:nValRecb		:= 0		//Valor Total de receita recebida
Self:cICmpRec		:= ''		//Indicador da composição da receita
Self:cCnpj			:= ''		//CNPJ / CPF do participante
Self:nRecDet		:= 0		//Valor da receita detalhada
Self:nRecAuf		:= 0		//Valor da receita Auferida
Self:cNatRet		:= ''		//Indicador da Natureza de retenção
Self:dDtRet		:= CTod("  /  /    ")		//Self:retenção
Self:nBasRet		:= 0		//Base de cálculo retenção
Self:nTotRet		:= 0		//Valor total retido na fonte
Self:cCodRec		:= ''		//Código da receita
Self:cRegime		:= ''		//Regime, Cumulativo, não cumulativo
Self:nPisRet		:= 0		//Valor PIS retido na fonte
Self:nCofRet		:= 0		//Valor COFINS retido na fonte
Self:cIndDec		:= ''		//Indicador do declarante da retenção de fonte
Self:cOriDed		:= ''		//Indicador da origem da dedução
Self:nDedPis		:= 0		//Valor a deduzir de PIS
Self:nDedCof		:= 0		//Valor a deduzir de COFINS
Self:nBasDed		:= 0		//Base de cálculo de outras deduções
Self:cTpOpImob		:= ''		//Indicador do tipo de operação
Self:cTpUnImob		:= ''		//Tipo unidade imobilizria
Self:cNome				:= ''		//Identificação/Nome Empreendiment
Self:nTotImob			:= 0		//valor total da unidade imobiliaria
Self:nRecAcum			:= 0		//Valor recebido acumulado
Self:nRecMes			:= 0		//Valor recebido no mês
Self:nPercent			:= 0		//Percentual da receita recebida
Self:cNatImob			:= ''		//Natureza específica do empreendimentoo
Self:nCIncAnt			:= 0		//Valor total do custo incorrido acumulado até mês anterior
Self:nCIncMes			:= 0		//Valor do custo incorrido no mês
Self:nTotCinc			:= 0		//Total do custo incorrido
Self:nExCInc			:= 0		//Custo incorrido sem direito ao crédito
Self:nCPisAnt			:= 0		//Credito ate perdio anterior pis 
Self:nCPisMes			:= 0		//Credito para decontar no período pis
Self:nCPisFut			:= 0		//Credito para períodos futuros pis
Self:nCCofAnt			:= 0		//Credito ate perdio anterior COFINS
Self:nCCofMes			:= 0		//Credito para decontar no período COFINS
Self:nCCOfFut			:= 0		//Credito para períodos futuros COFINS
Self:nTotCOrc			:= 0		//Valor total do custo orçado
Self:nExCOrc			:= 0		//Valor exclusão custo orçado
Self:nBasCOrc			:= 0		//Base de cálculo sobre custo orçado

//F800
Self:cNatEven			:= ""	 
Self:dDtEven			:= ""
Self:cSuCnpj		 	:= ""
Self:cPeriod		 	:= ""
Self:cCodCre		 	:= ""
Self:nValPis		 	:= 0
Self:nValCof		 	:= 0
Self:cPcCisa			:= ""
If lArray
	Self:aRegF100		:= {}		
	Self:aRegF120		:= {}		
	Self:aRegF200		:= {}
	Self:aRegF205		:= {}
	Self:aRegF210		:= {}
	Self:aRegF130		:= {}		
	Self:aRegF150		:= {}		
	Self:aRegF500		:= {}		
	Self:aRegF510		:= {}		
	Self:aRegF525		:= {}		
	Self:aRegF550		:= {}		
	Self:aRegF560		:= {}		
	Self:aRegF600		:= {}		
	Self:aRegF700		:= {}
	Self:aRegF111		:= {}	
	Self:aRegF129		:= {}	
	Self:aRegF139		:= {}	
	Self:aRegF211		:= {}	
	Self:aRegF509		:= {}	
	Self:aRegF519		:= {}	
	Self:aRegF559		:= {}	
	Self:aRegF569		:= {}
	Self:aRegF001		:= {}
	Self:aRegF990		:= {}
	Self:aRegF800		:= {}
EndIF

Return

METHOD setIndOper( cIndOper) Class EFDCBLOCOF
	Self:cIndOper := cIndOper
Return

METHOD setDtOper( dDtOper) Class EFDCBLOCOF
	Self:dDtOper := dDtOper
Return

METHOD setVlOper( nVlOper) Class EFDCBLOCOF
	Self:nVlOper := nVlOper
Return

METHOD setOriCrd( cOriCrd) Class EFDCBLOCOF
	Self:cOriCrd := cOriCrd
Return

METHOD setDescri( cDescri) Class EFDCBLOCOF
	Self:cDescri := cDescri
Return

METHOD setIdeBem( cIdeBem) Class EFDCBLOCOF
	Self:cIdeBem := cIdeBem
Return

METHOD setUtiBem( cUtiBem) Class EFDCBLOCOF
	Self:cUtiBem := cUtiBem
Return

METHOD setDeprec( nDeprec) Class EFDCBLOCOF
	Self:nDeprec := nDeprec
Return

METHOD setVlExclu( nVlExclu) Class EFDCBLOCOF
	Self:nVlExclu := nVlExclu
Return

METHOD setMesAqui( cMesAqui) Class EFDCBLOCOF
	Self:cMesAqui := cMesAqui
Return

METHOD setValAqui( nValAqui) Class EFDCBLOCOF
	Self:nValAqui := nValAqui
Return

METHOD setValCred( nValCred) Class EFDCBLOCOF
	Self:nValCred := nValCred
Return

METHOD setIndParc( cIndParc) Class EFDCBLOCOF
	Self:cIndParc := cIndParc
Return

METHOD setValEstq( nValEstq) Class EFDCBLOCOF
	Self:nValEstq := nValEstq
Return

METHOD setParEstq( nParEstq) Class EFDCBLOCOF
	Self:nParEstq := nParEstq
Return

METHOD setBasEstq( nBasEstq) Class EFDCBLOCOF
	Self:nBasEstq := nBasEstq
Return

METHOD setEstqMes( nEstqMes) Class EFDCBLOCOF
	Self:nEstqMes := nEstqMes
Return

METHOD setValRecb( nValRecb) Class EFDCBLOCOF
	Self:nValRecb := nValRecb
Return

METHOD setICmpRec( cICmpRec) Class EFDCBLOCOF
	Self:cICmpRec := cICmpRec
Return

METHOD setCnpj( cCnpj) Class EFDCBLOCOF
	Self:cCnpj := cCnpj
Return

METHOD setRecDet( nRecDet) Class EFDCBLOCOF
	Self:nRecDet := nRecDet
Return

METHOD setRecAuf( nRecAuf) Class EFDCBLOCOF
	Self:nRecAuf := nRecAuf
Return

METHOD setNatRet( cNatRet) Class EFDCBLOCOF
	Self:cNatRet := cNatRet
Return

METHOD setDtRet( dDtRet) Class EFDCBLOCOF
	Self:dDtRet := dDtRet
Return

METHOD setBasRet( nBasRet) Class EFDCBLOCOF
	Self:nBasRet := nBasRet
Return

METHOD setTotRet( nTotRet) Class EFDCBLOCOF
	Self:nTotRet := nTotRet
Return

METHOD setCodRec( cCodRec) Class EFDCBLOCOF
	Self:cCodRec := cCodRec
Return

METHOD setRegime( cRegime) Class EFDCBLOCOF
	Self:cRegime := cRegime
Return
METHOD setPisRet( nPisRet) Class EFDCBLOCOF
	Self:nPisRet := nPisRet
Return

METHOD setCofRet( nCofRet) Class EFDCBLOCOF
	Self:nCofRet := nCofRet
Return

METHOD setIndDec( cIndDec) Class EFDCBLOCOF
	Self:cIndDec := cIndDec
Return

METHOD setOriDed( cOriDed) Class EFDCBLOCOF
	Self:cOriDed := cOriDed
Return

METHOD setDedPis( nDedPis) Class EFDCBLOCOF
	Self:nDedPis := nDedPis
Return
METHOD setDedCof( nDedCof) Class EFDCBLOCOF
	Self:nDedCof := nDedCof
Return

METHOD setBasDed( nBasDed) Class EFDCBLOCOF
	Self:nBasDed := nBasDed
Return

Method setTpOpImob( cTpOpImob) Class EFDCBLOCOF
	Self:cTpOpImob := cTpOpImob
Return

Method setTpUnImob( cTpUnImob) Class EFDCBLOCOF
	Self:cTpUnImob := cTpUnImob
Return

Method setNome( cNome) Class EFDCBLOCOF
	Self:cNome := cNome
Return

Method setTotImob( nTotImob) Class EFDCBLOCOF
	Self:nTotImob := nTotImob
Return

Method setRecAcum( nRecAcum) Class EFDCBLOCOF
	Self:nRecAcum := nRecAcum
Return

Method setRecMes( nRecMes) Class EFDCBLOCOF
	Self:nRecMes := nRecMes
Return

Method setPercent( nPercent) Class EFDCBLOCOF
	Self:nPercent := nPercent
Return

Method setNatImob( cNatImob) Class EFDCBLOCOF
	Self:cNatImob := cNatImob
Return

Method setCIncAnt( nCIncAnt) Class EFDCBLOCOF
	Self:nCIncAnt := nCIncAnt
Return
Method setCIncMes( nCIncMes) Class EFDCBLOCOF
	Self:nCIncMes := nCIncMes
Return

Method setTotCinc( nTotCinc) Class EFDCBLOCOF
	Self:nTotCinc := nTotCinc
Return

Method setExCInc( nExCInc) Class EFDCBLOCOF
	Self:nExCInc := nExCInc
Return

Method setCPisAnt( nCPisAnt) Class EFDCBLOCOF
	Self:nCPisAnt := nCPisAnt
Return

Method setCPisMes( nCPisMes) Class EFDCBLOCOF
	Self:nCPisMes := nCPisMes
Return

Method setCPisFut( nCPisFut) Class EFDCBLOCOF
	Self:nCPisFut := nCPisFut
Return
Method setCCofAnt( nCCofAnt) Class EFDCBLOCOF
	Self:nCCofAnt := nCCofAnt
Return

Method setCCofMes( nCCofMes) Class EFDCBLOCOF
	Self:nCCofMes := nCCofMes
Return

Method setCCOfFut( nCCOfFut) Class EFDCBLOCOF
	Self:nCCOfFut := nCCOfFut
Return

Method setTotCOrc( nTotCOrc) Class EFDCBLOCOF
	Self:nTotCOrc := nTotCOrc
Return

Method setExCOrc( nExCOrc) Class EFDCBLOCOF
	Self:nExCOrc := nExCOrc
Return

Method setBasCOrc( nBasCOrc) Class EFDCBLOCOF
	Self:nBasCOrc := nBasCOrc
Return	
Method setNatEven(cNatEven)	Class EFDCBLOCOF
	Self:cNatEven := cNatEven
Return	 
Method setDtEven(dDtEven) Class EFDCBLOCOF
	Self:dDtEven := dDtEven
Return	 
Method setSuCnpj(cSuCnpj) Class EFDCBLOCOF
	Self:cSuCnpj := cSuCnpj
Return			 
Method setPeriod(cPeriod) Class EFDCBLOCOF
	Self:cPeriod := cPeriod
Return	 	 
Method setCodCre(cCodCre) Class EFDCBLOCOF
	Self:cCodCre := cCodCre
Return		 		 
Method setValPis(nValPis) Class EFDCBLOCOF
	Self:nValPis := nValPis
Return		 
Method setValCof(nValCof) Class EFDCBLOCOF
	Self:nValCof := nValCof
Return		 
Method setPcCisa(cPcCisa) Class EFDCBLOCOF
	Self:cPcCisa := cPcCisa
Return

Method getF600() Class EFDCBLOCOF
Return	Self:aRegF600

Method getF111() Class EFDCBLOCOF
Return	Self:aRegF111

Method getF700() Class EFDCBLOCOF
Return	Self:aRegF700

Method getF150() Class EFDCBLOCOF
Return	Self:aRegF150

Method getF129() Class EFDCBLOCOF
Return	Self:aRegF129

Method getF130() Class EFDCBLOCOF
Return	Self:aRegF130

Method getF139() Class EFDCBLOCOF
Return	Self:aRegF139

Method getF500() Class EFDCBLOCOF
Return	Self:aRegF500

Method getF510() Class EFDCBLOCOF
Return	Self:aRegF510

Method getF525() Class EFDCBLOCOF
Return	Self:aRegF525

Method getF010() Class EFDCBLOCOF
Return	Self:aRegF010

Method getF200() Class EFDCBLOCOF
Return	Self:aRegF200

Method getF205() Class EFDCBLOCOF
Return	Self:aRegF205

Method getF210() Class EFDCBLOCOF
Return	Self:aRegF210

Method getF550() Class EFDCBLOCOF
Return	Self:aRegF550

Method getF559() Class EFDCBLOCOF
Return	Self:aRegF559

Method getF509() Class EFDCBLOCOF
Return	Self:aRegF509

Method getF519() Class EFDCBLOCOF
Return	Self:aRegF519

Method getF560() Class EFDCBLOCOF
Return	Self:aRegF560

Method getF569() Class EFDCBLOCOF
Return	Self:aRegF569

Method getF800() Class EFDCBLOCOF
Return	Self:aRegF800
//-------------------------------------------------------------------
/*/{Protheus.doc} AddF100()
@description Método que inclui novo registro F100. Neste registro serão 
			   demonstradas as operações que não possuem vinculo com documento fiscal,
			   porém dão direito ao crédito ou débito de PIS e COFINS
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF100() Class EFDCBLOCOF

Local nPos				:= 0

Self:aRegF100			:= {}
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F100')

aAdd(Self:aRegF100, {})
nPos := Len(Self:aRegF100)
aAdd (Self:aRegF100[nPos], Self:cGrupoReg)  	//RELACIONAMENTO
aAdd (Self:aRegF100[nPos], 'F100')				//01 - REG
aAdd (Self:aRegF100[nPos], Self:cIndOper)		//02 - IND_OPER	
aAdd (Self:aRegF100[nPos], Self:cnCodPart)	//03 - COD_PART
aAdd (Self:aRegF100[nPos], Self:ciCodItem)					//04 - COD_ITEM
aAdd (Self:aRegF100[nPos], Self:dDtOper)		//05 - DT_OPER
aAdd (Self:aRegF100[nPos], Self:nVlOper)		//06 - VL_OPER
aAdd (Self:aRegF100[nPos], Self:ciCSTPis)		//07 - CST_PIS
aAdd (Self:aRegF100[nPos], {Self:niBasePis,4})	//08 - VL_BC_PIS
aAdd (Self:aRegF100[nPos], {Self:niAlqPis,4})		//09 - ALIQ_PIS
aAdd (Self:aRegF100[nPos], Self:niValPis)		//10 - VL_PIS
aAdd (Self:aRegF100[nPos], Self:ciCSTCof)		//11 - CST_COFINS
aAdd (Self:aRegF100[nPos], {Self:niBaseCof,4})	//12 - VL_BC_COFINS
aAdd (Self:aRegF100[nPos], {Self:niAlqCof,4})		//13 - ALIQ_COFINS
aAdd (Self:aRegF100[nPos], Self:niValCof)		//14 - VL_COFINS
aAdd (Self:aRegF100[nPos], Self:ciCodBcc)		//15 - NAT_BC_CRED
aAdd (Self:aRegF100[nPos], Self:cOriCrd )		//16 - IND_ORIG_CRED
aAdd (Self:aRegF100[nPos], Self:ciContaCtb )	//17 - COD_CTA
aAdd (Self:aRegF100[nPos], Self:ciCCusto ) 	//18 - COD_CCUS
aAdd (Self:aRegF100[nPos], Self:cDescri)		//19 - DESC_DOC_OPER	

Return Self:aRegF100

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF120()
@description Método que inclui novo registro F120. Neste registro teremos
			   os valores de crédito de bem no ativo fixo por depreciação.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF120() Class EFDCBLOCOF

Local nPos				:= 0

Self:aRegF120			:= {}
Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F120')

aAdd(Self:aRegF120, {})	
nPos	:=	Len (Self:aRegF120)	
aAdd (Self:aRegF120[nPos], Self:cGrupoReg)  			//RELACIONAMENTO
aAdd (Self:aRegF120[nPos], 'F120') 					//01-REG
aAdd (Self:aRegF120[nPos], Self:ciCodBcc) 			//02-NAT_BC_CRED
aAdd (Self:aRegF120[nPos], Self:cIdeBem) 				//03-IDENT_BEM_IMOB	
aAdd (Self:aRegF120[nPos], Self:cOriCrd ) 			//04-IND_ORIG_CRED	
aAdd (Self:aRegF120[nPos], Self:cUtiBem) 				//05-IND_UTIL_BEM_IMOB	
aAdd (Self:aRegF120[nPos], Self:nDeprec) 				//06-VL_OPER_DEP	
aAdd (Self:aRegF120[nPos], Self:nVlExclu) 		 	//07-PARC_OPER_NAO_BC_CRED
aAdd (Self:aRegF120[nPos], Self:ciCSTPis) 			//08-CST_PIS
aAdd (Self:aRegF120[nPos], Self:niBasePis) 			//09-VL_BC_PIS	
aAdd (Self:aRegF120[nPos], {Self:niAlqPis,4})			//10-ALIQ_PIS	
aAdd (Self:aRegF120[nPos], Self:niValPis)				//11-VL_PIS	
aAdd (Self:aRegF120[nPos], Self:ciCSTCof) 			//12-CST_COFINS	
aAdd (Self:aRegF120[nPos], Self:niBaseCof) 			//13-VL_BC_COFINS	
aAdd (Self:aRegF120[nPos], {Self:niAlqCof,4})			//14-ALIQ_COFINS
aAdd (Self:aRegF120[nPos], Self:niValCof)				//15-VL_COFINS	
aAdd (Self:aRegF120[nPos], Self:ciContaCtb) 			//16-COD_CTA
aAdd (Self:aRegF120[nPos], Self:ciCCusto) 			//17-COD_CCUS	
aAdd (Self:aRegF120[nPos], Self:cDescri) 				//18-DESC_ BEM_IMOB

Return Self:aRegF120


//-------------------------------------------------------------------
/*/{Protheus.doc} AddF130()
@description Método que inclui novo registro F130. Neste registro teremos
			   os valores de crédito de bem no ativo fixo por aquisição.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF130(lAgrupa) Class EFDCBLOCOF

Local nPos		:= 0
Default lAgrupa := .F.

IF lAgrupa
	
	nPos := aScan (Self:aRegF130, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ; 
										 aX[4]==Self:cIdeBem 		.AND. ;
										 aX[5]==Self:cOriCrd 		.AND. ;
										 aX[6]==Self:cUtiBem		.AND. ;
										 aX[7]==Self:cMesAqui 		.AND. ;
										 aX[11]==Self:cIndParc 		.AND. ;
										 aX[12]==Self:ciCSTPis 		.AND. ;
										 aX[14][1]==Self:niAlqPis 	.AND. ;
										 aX[16]==Self:ciCSTCof 		.AND. ;
										 aX[18][1]==Self:niAlqCof 	.AND. ;
										 aX[20]==Self:ciContaCtb 	.AND. ;
										 aX[21]==Self:ciCCusto })
//Agrupado
//IDENT_BEM_IMOB + IND_ORIG_CRED + IND_UTIL_BEM_IMOB + MES_OPER_AQUIS + IND_NR_PARC + CST_PIS + ALIQ_PIS + CST_COFINS + 
//ALIQ_COFINS + COD_CTA + COD_CCUS										 
										 
	If nPos == 0
		Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F130')
		aAdd(Self:aRegF130, {})
		nPos :=	Len (Self:aRegF130)	
		aAdd (Self:aRegF130[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
		aAdd (Self:aRegF130[nPos], 'F130') 					//01-REG
		aAdd (Self:aRegF130[nPos], Self:ciCodBcc) 			//02-NAT_BC_CRED
		aAdd (Self:aRegF130[nPos], Self:cIdeBem) 			//03-IDENT_BEM_IMOB	
		aAdd (Self:aRegF130[nPos], Self:cOriCrd) 			//04-IND_ORIG_CRED	
		aAdd (Self:aRegF130[nPos], Self:cUtiBem) 			//05-IND_UTIL_BEM_IMOB	
		aAdd (Self:aRegF130[nPos], Self:cMesAqui)			//06-MES_OPER_AQUIS	
		aAdd (Self:aRegF130[nPos], Self:nValAqui) 			//07-VL_OPER_AQUIS
		aAdd (Self:aRegF130[nPos], Self:nVlExclu) 			//08-PARC_OPER_NAO_BC_CRED	
		aAdd (Self:aRegF130[nPos], Self:nValAqui - Self:nVlExclu) 			//09-VL_BC_CRED	
		aAdd (Self:aRegF130[nPos], Self:cIndParc) 			//10-IND_NR_PARC
		aAdd (Self:aRegF130[nPos], Self:ciCSTPis) 			//11-CST_PIS		
		aAdd (Self:aRegF130[nPos], Self:niBasePis) 			//12-VL_BC_PIS
		aAdd (Self:aRegF130[nPos], {Self:niAlqPis,4})		//13-ALIQ_PIS
		aAdd (Self:aRegF130[nPos], Self:niValPis )			//14-VL_PIS
		aAdd (Self:aRegF130[nPos], Self:ciCSTCof) 			//15-CST_COFINS	
		aAdd (Self:aRegF130[nPos], Self:niBaseCof) 			//16-VL_BC_COFINS
		aAdd (Self:aRegF130[nPos], {Self:niAlqCof,4})		//17-ALIQ_COFINS
		aAdd (Self:aRegF130[nPos], Self:niValCof )			//18-VL_COFINS
		aAdd (Self:aRegF130[nPos], Self:ciContaCtb) 		//19-COD_CTA
		aAdd (Self:aRegF130[nPos], Self:ciCCusto) 			//20-COD_CCUS
		aAdd (Self:aRegF130[nPos], Self:cDescri) 			//21-DESC_BEM_IMOB		
	Else
		Self:aRegF130[nPos][8] += Self:nValAqui 			//07-VL_OPER_AQUIS
		Self:aRegF130[nPos][9] += Self:nVlExclu 			//08-PARC_OPER_NAO_BC_CRED
		Self:aRegF130[nPos][10]+= Self:nValAqui - Self:nVlExclu //09-VL_BC_CRED
		Self:aRegF130[nPos][13]+= Self:niBasePis 		//12-VL_BC_PIS
		Self:aRegF130[nPos][15]+= Self:niValPis 			//14-VL_PIS
		Self:aRegF130[nPos][17]+= Self:niBaseCof 		//16-VL_BC_COFINS
		Self:aRegF130[nPos][19]+= Self:niValCof 			//18-VL_COFINS
		Self:aRegF130[nPos][22] := ''					//21-DESC_BEM_IMOB
		
	Endif
										 
Else	
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F130')
	Self:aRegF130	:= {}

	aAdd(Self:aRegF130, {})
	nPos	:=	Len (Self:aRegF130)	
	aAdd (Self:aRegF130[nPos], Self:cGrupoReg)  			//RELACIONAMENTO
	aAdd (Self:aRegF130[nPos], 'F130') 					//01-REG
	aAdd (Self:aRegF130[nPos], Self:ciCodBcc) 			//02-NAT_BC_CRED
	aAdd (Self:aRegF130[nPos], Self:cIdeBem) 				//03-IDENT_BEM_IMOB	
	aAdd (Self:aRegF130[nPos], Self:cOriCrd) 				//04-IND_ORIG_CRED	
	aAdd (Self:aRegF130[nPos], Self:cUtiBem) 				//05-IND_UTIL_BEM_IMOB	
	aAdd (Self:aRegF130[nPos], Self:cMesAqui)				//06-MES_OPER_AQUIS	
	aAdd (Self:aRegF130[nPos], Self:nValAqui) 			//07-VL_OPER_AQUIS
	aAdd (Self:aRegF130[nPos], Self:nVlExclu) 			//08-PARC_OPER_NAO_BC_CRED	
	aAdd (Self:aRegF130[nPos], Self:nValAqui - Self:nVlExclu) 			//09-VL_BC_CRED	
	aAdd (Self:aRegF130[nPos], Self:cIndParc) 			//10-IND_NR_PARC	
	aAdd (Self:aRegF130[nPos], Self:ciCSTPis) 			//11-CST_PIS	
	aAdd (Self:aRegF130[nPos], Self:niBasePis) 			//12-VL_BC_PIS		   	  
	aAdd (Self:aRegF130[nPos], {Self:niAlqPis,4})			//13-ALIQ_PIS		
	aAdd (Self:aRegF130[nPos], Self:niValPis )			//14-VL_PIS
	aAdd (Self:aRegF130[nPos], Self:ciCSTCof) 			//15-CST_COFINS	
	aAdd (Self:aRegF130[nPos], Self:niBaseCof) 			//16-VL_BC_COFINS
	aAdd (Self:aRegF130[nPos], {Self:niAlqCof,4})			//17-ALIQ_COFINS	
	aAdd (Self:aRegF130[nPos], Self:niValCof )			//18-VL_COFINS	
	aAdd (Self:aRegF130[nPos], Self:ciContaCtb) 			//19-COD_CTA	
	aAdd (Self:aRegF130[nPos], Self:ciCCusto) 			//20-COD_CCUS	
	aAdd (Self:aRegF130[nPos], Self:cDescri) 				//21-DESC_BEM_IMOB	
Endif

Return Self:aRegF130


//-------------------------------------------------------------------
/*/{Protheus.doc} AddF150()
@description Método que inclui novo registro F150. Neste registro teremos
			   os valores de créditos de abertura de estoque.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF150() Class EFDCBLOCOF

Local nPos	:= 0

nPos := aScan (Self:aRegF150, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ; 
										 aX[3]==Self:ciCodBcc .AND. ;
										 aX[8]==Self:ciCSTPis .AND. ;
										 aX[9][1]==Self:niAlqPis .AND. ;
										 aX[11]==Self:ciCSTCof .AND. ;
										 aX[12][1]==Self:niAlqCof .AND. ;
										 aX[15]==Self:ciContaCtb })
If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F150')
	aAdd(Self:aRegF150, {})
	nPos := Len(Self:aRegF150)
	aAdd (Self:aRegF150[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
	aAdd (Self:aRegF150[nPos], 'F150')				//01 - REG
	aAdd (Self:aRegF150[nPos],Self:ciCodBcc )		//02 - NAT_BC_CRED
	aAdd (Self:aRegF150[nPos],Self:nValEstq )		//03 - VL_TOT_EST
	aAdd (Self:aRegF150[nPos],Self:nParEstq )		//04 - EST_IMP
	aAdd (Self:aRegF150[nPos],Self:nBasEstq)		//05 - VL_BC_EST
	aAdd (Self:aRegF150[nPos],Self:nEstqMes )		//06 - VL_BC_MEN_EST
	aAdd (Self:aRegF150[nPos],Self:ciCSTPis )		//07 - CST_PIS
	aAdd (Self:aRegF150[nPos],{Self:niAlqPis,4})	//08 - ALIQ_PIS
	aAdd (Self:aRegF150[nPos],Self:niValPis )		//09 - VL_CREDPIS
	aAdd (Self:aRegF150[nPos],Self:ciCSTCof)		//10 - CST_COFINS
	aAdd (Self:aRegF150[nPos],{Self:niAlqCof,4})	//11 - ALIQ_COFINS
	aAdd (Self:aRegF150[nPos],Self:niValCof )		//12 - VL_CRED_COFINS
	aAdd (Self:aRegF150[nPos],Self:cDescri)		//13 - DESCR_EST
	aAdd (Self:aRegF150[nPos],Self:ciContaCtb )	//14 - COD_CTA	
		
Else
	Self:aRegF150[nPos][4] += Self:nValEstq 	//03 - VL_TOT_EST
	Self:aRegF150[nPos][5] += Self:nParEstq  	//04 - EST_IMP
	Self:aRegF150[nPos][6] += Self:nBasEstq	//05 - VL_BC_EST
	Self:aRegF150[nPos][7] += Self:nEstqMes 	//06 - VL_BC_MEN_EST	
	Self:aRegF150[nPos][10] += Self:niValPis  	//09 - VL_CREDPIS
	Self:aRegF150[nPos][13] += Self:niValCof	//12 - VL_CRED_COFINS
EndIF	   

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF200()
@description Método que inclui novo registro F200. Registro referente receitas
			   decorrentes da atividade imobiliária.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF200() Class EFDCBLOCOF

Local nPos	:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F200')
aAdd(Self:aRegF200, {})
nPos := Len(Self:aRegF200)
aAdd (Self:aRegF200[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
aAdd (Self:aRegF200[nPos], 'F200')				//01-Registro
aAdd (Self:aRegF200[nPos], Self:cTpOpImob)	//02-IND_OPER
aAdd (Self:aRegF200[nPos], Self:cTpUnImob)	//03-UNID_IMOB
aAdd (Self:aRegF200[nPos], Self:cNome)			//04-IDENT_EMP
aAdd (Self:aRegF200[nPos], Self:cDescri)		//05-DESC_UNID_IMOB
aAdd (Self:aRegF200[nPos], Self:cnNumNf)		//06-NUM_CONT
aAdd (Self:aRegF200[nPos], Self:cCnpj)			//07-CPF_CNPJ_ADQU
aAdd (Self:aRegF200[nPos], Self:dnEmissao)	//08-DT_OPER
aAdd (Self:aRegF200[nPos], Self:nTotImob)		//09-VL_TOT_VEND
aAdd (Self:aRegF200[nPos], Self:nRecAcum)		//10-VL_REC_ACUM
aAdd (Self:aRegF200[nPos], Self:nRecMes)		//11-VL_TOT_REC
aAdd (Self:aRegF200[nPos], Self:ciCSTPis)		//12-CST_PIS
aAdd (Self:aRegF200[nPos], Self:niBasePis)	//13-VL_BC_PIS
aAdd (Self:aRegF200[nPos], {Self:niAlqPis,4})	//14-ALIQ_PIS
aAdd (Self:aRegF200[nPos], Self:niValPis)		//15-VL_PIS
aAdd (Self:aRegF200[nPos], Self:ciCSTCof)		//16-CST_COFINS
aAdd (Self:aRegF200[nPos], Self:niBaseCof)	//17-VL_BC_COFINS
aAdd (Self:aRegF200[nPos], {Self:niAlqCof,4})	//18-ALIQ_COFINS
aAdd (Self:aRegF200[nPos], Self:niValCof)		//19-VL_COFINS
aAdd (Self:aRegF200[nPos], Self:nPercent)		//20-PERC_REC_RECEB
aAdd (Self:aRegF200[nPos], Self:cNatImob)		//21-IND_NAT_EMP
aAdd (Self:aRegF200[nPos], Self:cnInfCmp)		//22-INF_COMP

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddF205()
@description Método que inclui novo registro F20. Registro referente 
			   operações imobiliária - custo incorrido
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF205() Class EFDCBLOCOF

Local nPos	:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F205')
aAdd(Self:aRegF205, {})
nPos := Len(Self:aRegF205)
aAdd (Self:aRegF205[nPos], Self:cGrupoReg)  			//RELACIONAMENTO
aAdd (Self:aRegF205[nPos], 'F205')					//01-Registro
aAdd (Self:aRegF205[nPos], Self:nCIncAnt)			//02-VL_CUS_INC_ACUM_ANT
aAdd (Self:aRegF205[nPos], Self:nCIncMes)			//03-VL_CUS_INC_PER_ESC
aAdd (Self:aRegF205[nPos], Self:nTotCinc)			//04-VL_CUS_INC_ACUM
aAdd (Self:aRegF205[nPos], Self:nExCInc)			//05-VL_EXC_BC_CUS_INC_ACUM
aAdd (Self:aRegF205[nPos], Self:niBasePis)		//06-VL_BC_CUS_INC
aAdd (Self:aRegF205[nPos], Self:ciCSTPis)			//07-CST_PIS
aAdd (Self:aRegF205[nPos], {Self:niAlqPis,4})		//08-ALIQ_PIS
aAdd (Self:aRegF205[nPos], Self:niValPis)			//09-VL_CRED_PIS_ACUM
aAdd (Self:aRegF205[nPos], Self:nCPisAnt)			//10-VL_CRED_PIS_DESC_ANT
aAdd (Self:aRegF205[nPos], Self:nCPisMes)			//11-VL_CRED_PIS_DESC
aAdd (Self:aRegF205[nPos], Self:nCPisFut)			//12-VL_CRED_PIS_DESC_FUT
aAdd (Self:aRegF205[nPos], Self:ciCSTCof)			//13-CST_COFINS
aAdd (Self:aRegF205[nPos], {Self:niAlqCof,4})		//14-ALIQ_COFINS
aAdd (Self:aRegF205[nPos], Self:niValCof)			//15-VL_CRED_COFINS_ACUM
aAdd (Self:aRegF205[nPos], Self:nCCofAnt)			//16-VL_CRED_COFINS_DESC_ANT
aAdd (Self:aRegF205[nPos], Self:nCCofMes)			//17-VL_CRED_COFINS_DESC
aAdd (Self:aRegF205[nPos], Self:nCCOfFut)			//18-VL_CRED_COFINS_DESC_FUT

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF210()
@description Método que inclui novo registro F20. Registro referente 
			   operações imobiliária - custo orçado
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF210() Class EFDCBLOCOF

Local nPos	:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F210')
aAdd(Self:aRegF210, {})
nPos := Len(Self:aRegF210)
aAdd (Self:aRegF210[nPos], Self:cGrupoReg)  			//RELACIONAMENTO
aAdd (Self:aRegF210[nPos], 'F210')					//01-Registro
aAdd (Self:aRegF210[nPos], Self:nTotCOrc)			//02-VL_CUS_ORC
aAdd (Self:aRegF210[nPos], Self:nExCOrc)			//03-VL_EXC
aAdd (Self:aRegF210[nPos], Self:nBasCOrc)			//04-VL_CUS_ORC_AJU
aAdd (Self:aRegF210[nPos], Self:niBasePis)		//05-VL_BC_CRED
aAdd (Self:aRegF210[nPos], Self:ciCSTPis)			//06-CST_PIS
aAdd (Self:aRegF210[nPos], {Self:niAlqPis,4})		//07-ALIQ_PIS
aAdd (Self:aRegF210[nPos], Self:niValPis)			//08-VL_CRED_PIS_UTIL
aAdd (Self:aRegF210[nPos], Self:ciCSTCof)			//09-CST_COFINS
aAdd (Self:aRegF210[nPos], {Self:niAlqCof,4})		//10-ALIQ_COFINS
aAdd (Self:aRegF210[nPos], Self:niValCof)			//11-VL_CRED_COFINS_UTIL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF500()
@description Método que inclui novo registro F500.
			   Este registro terá informações dos débitos do regime de caixa,
			   com alíquotas em percentual.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF500() Class EFDCBLOCOF

//Faz chamada do método AddF50X, indicando que irá processar registro F500
Self:AddF50X('F500', @Self:aRegF500)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF510()
@description Método que inclui novo registro F510.
			   Este registro terá informações dos débitos do regime de caixa,
			   com alíquotas em reais.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF510() Class EFDCBLOCOF

//Faz chamada do método AddF50X, indicando que irá processar registro F510
Self:AddF50X('F510', @Self:aRegF510)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF550()
@description Método que inclui novo registro F550.
			   Este registro terá informações dos débitos do regime de competência,
			   com alíquotas em percentual.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF550() Class EFDCBLOCOF

//Faz chamada do método AddF50X, indicando que irá processar registro F550
Self:AddF50X('F550', @Self:aRegF550)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF560()
@description Método que inclui novo registro F560.
			   Este registro terá informações dos débitos do regime de competênia,
			   com alíquotas em reais.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF560() Class EFDCBLOCOF

//Faz chamada do método AddF50X, indicando que irá processar registro F560
Self:AddF50X('F560', @Self:aRegF560)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF50X()
@description Método que inclui novo registro F500 F510, F550 e F560.
			   O F500 e F510 pertencem ao regime de caixa, já F550 e F560
			   ao regime de competência, porém os 4 registros possuem 
			   exatamente a mesma estrutura, com mesmos campos e informações,
			   por este motivo serão tratados no mesmo método, alterando 
			   conforme os parâmetros do métodos.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF50X(cReg, aReg) Class EFDCBLOCOF

Local nPos	:= 0

nPos := aScan (aReg, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac	.AND. ;  
							   aX[4]==Self:ciCSTPis 		.AND. ;
							   aX[7][1]==Self:niAlqPis 		.AND. ;
							   aX[9]==Self:ciCSTCof 		.AND. ;
							   aX[12][1]==Self:niAlqCof 	.AND. ;
							   aX[14]==Self:cnModelo 	.AND. ;
							   aX[15]==Self:ciCFOP 		.AND.;
							   aX[16]==Self:ciContaCtb  .AND. ;
							   aX[17]==Self:cDescri})
If nPos == 0 
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cGrupoReg)  			//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)					//01-Registro
	aAdd (aReg[nPos], Self:nRecAuf)			//02-VL_REC_CAIXA
	aAdd (aReg[nPos], Self:ciCSTPis)   	//03-CST_PIS
	aAdd (aReg[nPos], Self:niValDesc)		//04-VL_DESC_PIS
	aAdd (aReg[nPos], Self:niBasePis)   	//05-VL_BC_PIS
	aAdd (aReg[nPos], {Self:niAlqPis,4})   	//06-ALIQ_PIS
	aAdd (aReg[nPos], Self:niValPis )   	//07-VL_PIS
	aAdd (aReg[nPos], Self:ciCSTCof)   	//08-CST_COFINS
	aAdd (aReg[nPos], Self:niValDesc)		//09-VL_DESC_COFINS
	aAdd (aReg[nPos], Self:niBaseCof)  	//10-VL_BC_COFINS
	aAdd (aReg[nPos], {Self:niAlqCof,4} )  	//11-ALIQ_COFINS
	aAdd (aReg[nPos], Self:niValCof )  	//12-VL_COFINS
	aAdd (aReg[nPos], Self:cnModelo)  		//13-COD_MOD
	aAdd (aReg[nPos], Self:ciCFOP) 			//14-CFOP
	aAdd (aReg[nPos], Self:ciContaCtb) 	//15-COD_CTA
	aAdd (aReg[nPos], Self:cDescri)  		//16-INF_COMPL	
Else
	Self:cGrupoReg	:= aReg[nPos][1]	
	aReg[nPos][3]		+=	Self:nRecAuf		//02-VL_REC_CAIXA
	aReg[nPos][5]		+=	Self:niValDesc	//04-VL_DESC_PIS
	aReg[nPos][6]		+=	Self:niBasePis	//05-VL_BC_PIS	
	aReg[nPos][8]		+=	Self:niValPis		//07-VL_PIS	
	aReg[nPos][10]	+=	Self:niValDesc 	//09-VL_DESC_COFINS	
	aReg[nPos][11]	+=	Self:niBaseCof	//10-VL_BC_COFINS		
	aReg[nPos][13]	+=	Self:niValCof		//12-VL_COFINS			
		
EndIf	


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF525()
@description Método que inclui novo registro F525. Neste registro teremos
			   os valores de receita do regime de caixa de forma detalhada.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF525() Class EFDCBLOCOF

Local nPos	:= 0

nPos := aScan (Self:aRegF525, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	 	.AND. ;   
										 aX[4]==Self:cICmpRec 		.AND. ;
										 aX[5]==Self:cCnpj 			.AND. ;
										 aX[6]==Self:cnNumNf 		.AND. ;
								    	 aX[7]==Self:ciCodItem 		.AND. ;
								    	 aX[9]==Self:ciCSTPis 		.AND. ;
								    	 aX[10]==Self:ciCSTCof 		.AND.;
									     aX[11]==Self:cDescri 		.AND. ;
									     aX[12]==Self:ciContaCtb})

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F525')
	aAdd(Self:aRegF525, {})
	nPos := Len(Self:aRegF525)
	aAdd (Self:aRegF525[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (Self:aRegF525[nPos],'F525')				//01-Registro
	aAdd (Self:aRegF525[nPos], Self:nValRecb)		//02-VL_REC
	aAdd (Self:aRegF525[nPos], Self:cICmpRec)   	//03-IND_REC
	aAdd (Self:aRegF525[nPos], Self:cCnpj)   		//04-CNPJ_CPF
	aAdd (Self:aRegF525[nPos], Self:cnNumNf)   	//05-NUM_DOC
	aAdd (Self:aRegF525[nPos], Self:ciCodItem)   	//06-COD_ITEM
	aAdd (Self:aRegF525[nPos], Self:nRecDet)   	//07-VL_REC_DET
	aAdd (Self:aRegF525[nPos], Self:ciCSTPis)   	//08-CST_PIS
	aAdd (Self:aRegF525[nPos], Self:ciCSTCof)   	//09-CST_COFINS
	aAdd (Self:aRegF525[nPos], Self:cDescri)  	//10-INFO_COMPL
	aAdd (Self:aRegF525[nPos], Self:ciContaCtb)  	//11-COD_CTA
Else
	Self:aRegF525[nPos][8]	+=	Self:nRecDet		//07-VL_REC_DET
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF600()
@description Método que inclui novo registro F600 Neste registro teremos
			   os valores de retenção na Fonte de PIS e COFINS.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF600() Class EFDCBLOCOF

Local nPos  := 0
Local cData := SubStr(Dtos(Self:dDtRet),7,2) + SubStr(Dtos(Self:dDtRet),5,2) + SubStr(Dtos(Self:dDtRet),1,4)
Local dDtFim:= LastDay(Self:dDtRet)
Local cDtFim:= ""

nPos := aScan (Self:aRegF600, {|aX|	SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac	.AND. ;
											aX[3]==Self:cNatRet		.AND. ;
											ax[8] == Self:cRegime	.AND. ;
											ax[9] == Self:cCnpj		.AND. ;
											ax[12] == Self:cIndDec})
IF nPos ==0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F600')
	aAdd(Self:aRegF600, {})
	nPos := Len(Self:aRegF600)
	aAdd (Self:aRegF600[nPos], Self:cGrupoReg)			//RELACIONAMENTO
	aAdd (Self:aRegF600[nPos], 'F600')					//01 - REG
	aAdd (Self:aRegF600[nPos], Self:cNatRet)			//02 - IND_NAT_RET
	aAdd (Self:aRegF600[nPos], cData )					//03 - DT_RET
	aAdd (Self:aRegF600[nPos], {Self:nBasRet,4})		//04 - VL_BC_RET
	aAdd (Self:aRegF600[nPos], Self:nTotRet)			//05 - VL_RET
	aAdd (Self:aRegF600[nPos], Self:cCodRec)			//06 - COD_REC
	aAdd (Self:aRegF600[nPos], Self:cRegime)			//07 - IND_NAT_REC
	aAdd (Self:aRegF600[nPos], Self:cCnpj)				//08 - CNPJ
	aAdd (Self:aRegF600[nPos], Self:nPisRet)			//09 - VL_RET_PIS
	aAdd (Self:aRegF600[nPos], Self:nCofRet)			//10 - VL_RET_COFINS
	aAdd (Self:aRegF600[nPos], Self:cIndDec)			//11 - IND_REC
Else
	cDtFim := SubStr(Dtos(dDtFim),7,2) + SubStr(Dtos(dDtFim),5,2) + SubStr(Dtos(dDtFim),1,4)
	Self:aRegF600[nPos][4]  := cDtFim				//05 - VL_RET
	Self:aRegF600[nPos][5][1]  += Self:nBasRet			//04 - VL_BC_RET
	Self:aRegF600[nPos][6]  += Self:nTotRet			//05 - VL_RET
	Self:aRegF600[nPos][10] += Self:nPisRet			//09 - VL_RET_PIS
	Self:aRegF600[nPos][11] += Self:nCofRet			//10 - VL_RET_COFINS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF700()
@description Método que inclui novo registro F700 Neste registro teremos
			   os valores das demais deduções no período.
@author Erick G. Dias
@since 21/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF700() Class EFDCBLOCOF

Local nPos	:= 0

nPos := aScan(Self:aRegF700,{|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	 	.AND. ;  
									   aX[3]==Self:cOriDed 		.And. ;
									   aX[4]==Self:cRegime 		.And. ;
									   aX[8]==Self:cCnpj})

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F700')
	aAdd(Self:aRegF700, {})
	nPos := Len(Self:aRegF700)
	aAdd (Self:aRegF700[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aRegF700[nPos], 'F700')				//01 - REG
	aAdd (Self:aRegF700[nPos],Self:cOriDed)		//02 - IND_ORI_DED
	aAdd (Self:aRegF700[nPos],Self:cRegime)		//03 - IND_NAT_DED
	aAdd (Self:aRegF700[nPos],Self:nDedPis)		//04 - VL_DED_PIS
	aAdd (Self:aRegF700[nPos],Self:nDedCof)		//05 - VL_DED_COFINS
	aAdd (Self:aRegF700[nPos],Self:nBasDed)		//06 - VL_BC_OPER
	aAdd (Self:aRegF700[nPos],Self:cCnpj)			//07 - CNPJ
	aAdd (Self:aRegF700[nPos],Self:cDescri)		//08 - INF_COMP
Else
	Self:aRegF700[nPos][5] += Self:nDedPis			//04 - VL_DED_PIS
	Self:aRegF700[nPos][6] += Self:nDedCof			//05 - VL_DED_COFINS
	Self:aRegF700[nPos][7] += Self:nBasDed			//06 - VL_BC_OPER
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF800()
@description Método que inclui novo registro F800 
@author Henrique Pereira
@since 14/06/2016
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF800() Class EFDCBLOCOF

Local nPos	:= 0
/*
nPos := aScan(Self:aRegF700,{|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	 	.AND. ;  
									   aX[3]==Self:cOriDed 		.And. ;
									   aX[4]==Self:cRegime 		.And. ;
									   aX[8]==Self:cCnpj})*/

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'F800')
	aAdd(Self:aRegF800, {})
	nPos := Len(Self:aRegF800)
	aAdd (Self:aRegF800[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aRegF800[nPos], 'F800')				//01 - REG
	aAdd (Self:aRegF800[nPos],Self:cNatEven)		//02 - IND_NAT_EVEN
	aAdd (Self:aRegF800[nPos],Self:dDtEven)		//03 - DT_EVEN
	aAdd (Self:aRegF800[nPos],Self:cSuCnpj)		//04 - CNPJ_SUCED
	aAdd (Self:aRegF800[nPos],Self:cPeriod)		//05 - PA_CONT_CRED
	aAdd (Self:aRegF800[nPos],Self:cCodCre)		//06 - COD_CRED
	aAdd (Self:aRegF800[nPos],Self:nValPis)		//07 - VL_CRED_PIS
	aAdd (Self:aRegF800[nPos],Self:nValCof)		//08 - VL_CRED_COFINS
	aAdd (Self:aRegF800[nPos],Self:cPcCisa)		//08 - PER_CRED_CIS
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProcRef()
@description Método que inclui novo registros F111, F129, F139,
			   F211, F509, F519, F559 e F569, todos de Processo referenciado.			  
@author Erick G. Dias
@since14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddProcRef(cReg) Class EFDCBLOCOF

Do Case
	Case cReg == 'F111'	
		Self:ProcRef('F111',@Self:aRegF111)
	Case cReg == 'F129'
		Self:ProcRef('F129',@Self:aRegF129)
	Case cReg == 'F139'
		Self:ProcRef('F139',@Self:aRegF139)
	Case cReg == 'F211'
		Self:ProcRef('F211',@Self:aRegF211)	
	Case cReg == 'F509'
		Self:ProcRef('F509',@Self:aRegF509)
	Case cReg == 'F519'
		Self:ProcRef('F519',@Self:aRegF519)		
	Case cReg == 'F559'
		Self:ProcRef('F559',@Self:aRegF559)
	Case cReg == 'F569'
		Self:ProcRef('F569',@Self:aRegF569)
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF001(cIndMovto) Class EFDCBLOCOF

Self:AbreBloco('F001',@Self:aRegF001,cIndMovto)

Return Self:aRegF001

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddF990(nQtde) Class EFDCBLOCOF

Self:FechaBloco('F990',@Self:aRegF990, nQtde) 

Return Self:aRegF990

//-------------------------------------------------------------------
/*/{Protheus.doc} clsF200()
@description Método que limpa variáveis do F200
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsF200() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF200	:= {}
Self:aRegF205	:= {}
Self:aRegF210	:= {}

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} clsF100()
@description Método que limpa variáveis do F100
@author Erick G. Dias
@since 05/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsF100() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF100	:= {}
Self:aRegF111	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsF120()
@description Método que limpa variáveis do F100
@author Erick G. Dias
@since 05/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsF120() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF120	:= {}
Self:aRegF129	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsF130()
@description Método que limpa variáveis do F100
@author Erick G. Dias
@since 05/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsF130() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF130	:= {}
Self:aRegF139	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsF150()
@description Método que limpa variáveis do F100
@author Erick G. Dias
@since 05/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsF150() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF150	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsF700()
@description Método que limpa variáveis do F100
@author Erick G. Dias
@since 05/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsF700() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF700	:= {}

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} clsF800()
@description Método que limpa variáveis do F800
@author Henrique Pereira
@since 14/06/2016
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsF800() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF800	:= {}

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} clsF550()
@description Método que limpa variáveis do F550
@author Erick G. Dias
@since 02/01/2015
@version 11.90
/*/
//-------------------------------------------------------------------

METHOD clsF550() Class EFDCBLOCOF

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegF550	:= {}
Self:aRegF560	:= {}
Self:aRegF559	:= {}
Self:aRegF569	:= {}

Return
 
