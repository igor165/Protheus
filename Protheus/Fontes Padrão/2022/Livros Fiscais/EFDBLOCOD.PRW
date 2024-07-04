#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCOD();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCOD()
@description Classe que terá as informações específicas para geração dos 
			   registros do bloco D no SPED Contribuições. Esta classe
			   herda as propriedades e métodos da classe NOTAEFD, então aqui
			   teremos somente as propriedades pertinentes ao bloco D, bem
			   como os método para gravação dos registros, respeitando formatos
			   e hierarquia. 

@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCOD FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO DO DOCUMENTO FISCAL
//-----------------------------------------------------

Data dnDtAqui		as Date		READONLY		//Data de aquisição do Serviço
Data cnTpCt		as String		READONLY		//TIpo de Conhecimento de Transporte
Data cnChvCte		as String		READONLY		//Chave do conhecimento de transporte eletrônico.
Data cnIndFrt		as String		READONLY		//Indicador do frete
Data cnCodMun		as String		READONLY		//Código do município
Data cnTpRec		as String		READONLY		//Indicador do Tipo da Receita
Data cnCodCla		as String		READONLY		//Código da classificação do item de serviço
Data nnVlServ		as Integer		READONLY		//Valor do Serviço
Data nnBasIcms	as Integer		READONLY		//Base de cálculo do ICMS
Data nnValIcms	as Integer		READONLY		//Valor do ICMS
Data nnValNTrib	as Integer		READONLY		//Valor não tributado do ICMS
Data nnVlTerc		as Integer		READONLY		//Valor cobrado por terceiros
Data nnDespesa	as Integer		READONLY		//Valor da despesas acessórias
Data lBuild     As Boolean              

//-------------------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO AO ITEM DO DOCUMENTO FISCAL
//-------------------------------------------------------------
Data ciINFrt		as String		READONLY		//Indicador da NAtureza do Frete

//-------------------------------------------------------------
//ATRIBUTOS ESPECÍFICOS PARA REGISTROS DE CUPOM FISCAL
//-------------------------------------------------------------
Data cModEcf		as String		HIDDEN		//Modelo do equipamento emissor de ECF
Data cSerEcf		as String		HIDDEN		//Número de série do equipamento ECF
Data cNumEcf		as String		HIDDEN		//Número do caixa ECF
Data cCro			as String		HIDDEN		//Posição do contador de reinício da operação
Data cCrZ			as String		HIDDEN		//Posição do contador da redução Z
Data cNumCont		as String		HIDDEN		//Número de contador final
Data nVlGrade		as Integer		HIDDEN		//Valor total da grade
Data nVlBrut		as Integer		HIDDEN		//Valor da Venda Bruta
Data dDtRedZ		as Date		HIDDEN		//Dia da redução Z
Data niPisQtde	as Integer		READONLY		//Base de cálculo em quantidade de PIS
Data niPautPis	as Integer		READONLY		//Valor da Pauta de PIS/Alíquota em reais
Data niCofQtde	as Integer		READONLY		//Base de cálculo em quantidade de COFINS
Data niPautcof	as Integer		READONLY		//Valor da Pauta de COFINS/Alíquota em reais

//-------------------------
//ARRAYS GERADOS DO BLOCO D
//-------------------------
Data aRegD100		as Array		READONLY		//Array com informações do registro A100
Data aRegD101		as Array		READONLY		//Array com informações do registro A120
Data aRegD105		as Array		READONLY		//Array com informações do registro A170
Data aRegD200		as Array		READONLY		//Array com informações do registro A170
Data aRegD201		as Array		READONLY		//Array com informações do registro A170
Data aRegD205		as Array		READONLY		//Array com informações do registro A170
Data aRegD300		as Array		READONLY		//Array com informações do registro A170
Data aRegD350		as Array		READONLY		//Array com informações do registro A170
Data aRegD500		as Array		READONLY		//Array com informações do registro A170
Data aRegD501		as Array		READONLY		//Array com informações do registro A170
Data aRegD505		as Array		READONLY		//Array com informações do registro A170
Data aRegD600		as Array		READONLY		//Array com informações do registro A170
Data aRegD601		as Array		READONLY		//Array com informações do registro A170
Data aRegD605		as Array		READONLY		//Array com informações do registro A170
Data aRegD111		as Array		READONLY		//Array com informações do registro D111
Data aRegD209		as Array		READONLY		//Array com informações do registro D209
Data aRegD309		as Array		READONLY		//Array com informações do registro D309
Data aRegD359		as Array		READONLY		//Array com informações do registro D359
Data aRegD509		as Array		READONLY		//Array com informações do registro D509
Data aRegD609		as Array		READONLY		//Array com informações do registro D609
Data aRegD001		as Array		READONLY		//Array com informações do registro D001
Data aRegD990		as Array		READONLY		//Array com informações do registro D990
Data aQtdD600		as Array		READONLY		//Array com informações do registro D990
Data aNfD600		as Array		READONLY		//Array com informações do registro D990

Data oHashD101
Data oHashD105
Data oHashD200
Data oHashD201
Data oHashD205
Data oHashD501
Data oHashD505
Data oHashD600
Data oHashD601
Data oHashD605
Data oHashQtD6
Data oJsonQtD6

//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()
Method AddD100()
Method AddD101()
Method AddD105()
Method AddD10X()
Method AddD200()
Method AddD201()
Method AddD205()
Method AddD20X()
Method AddD300()
Method AddD350(lAgrupa)
Method AddD500()
Method AddD501()
Method AddD505()
Method AddD50X()
Method AddD600()
Method AddD601()
Method AddD605()
Method AddD60X()
Method AddProcRef()
Method AddD001(cIndMovto)
Method AddD990(nQtde)

Method setDtAqui( dnDtAqui) 
Method setTpCt( cnTpCt) 
Method setChvCte( cnChvCte) 
Method setIndFrt( cnIndFrt) 
Method setCodMun( cnCodMun) 
Method setTpRec( cnTpRec) 
Method setCodCla( cnCodCla) 
Method setVlServ( nnVlServ) 
Method setBasIcms( nnBasIcms) 
Method setValIcms( nnValIcms) 
Method setVlNTrib( nnValNTrib) 
Method setVlTerc( nnVlTerc) 
Method setDespesa( nnDespesa) 
Method setINFrt( ciINFrt) 
Method setModEcf( cModEcf) 
Method setSerEcf( cSerEcf) 
Method setNumEcf( cNumEcf) 
Method setCro( cCro) 
Method setCrZ( cCrZ) 
Method setNumCont( cNumCont) 
Method setVlGrade( nVlGrade) 
Method setVlBrut( nVlBrut) 
Method setDtRedZ( dDtRedZ) 
Method setPisQtde( niPisQtde) 
Method setPautPis( niPautPis) 
Method setCofQtde( niCofQtde) 
Method setPautcof( niPautcof)
Method QtdNfD600( cChaveNf , cGrupoReg )

Method getD100()
Method getD101()
Method getD105()
Method getD200()
Method getD201()
Method getD205()
Method getD300()
Method getD350()
Method getD500()
Method getD501()
Method getD505()
Method getD600()
Method getD601()
Method getD605()

Method getD111()
Method getD209()
Method getD309()
Method getD359()
Method getD509()
Method getD609()

Method clsD100()
Method clsD200()
Method clsD300()
Method clsD350()
Method clsD500()
Method clsD600()


ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
@description Método construtor da classe 

@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCOD
Self:lBuild   := GetBuild() >= "7.00.131227A"
Self:cJob	:= '00'
Self:Clear(.T.)
Self:ClsNotaEfd(.T.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear(lArray)
@description Método que inicializa as propriedades da classe

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method Clear(lArray) Class EFDCBLOCOD
Local cNew	:= "HMNew()"

Default lArray	:= .T. //Indica se deverá limpar array também

Self:dnDtAqui		:= CTod("  /  /    ")		//Self:de aquisição do Serviço
Self:cnTpCt			:= ''		//TIpo de Conhecimento de Transporte
Self:cnChvCte		:= ''		//Chave do conhecimento de transporte eletrônico.
Self:cnIndFrt		:= ''		//Indicador do frete
Self:cnCodMun		:= ''		//Código do município
Self:cnTpRec		:= ''		//Indicador do Tipo da Receita
Self:cnCodCla		:= ''		//Código da classificação do item de serviço
Self:nnVlServ		:= 0		//Valor do Serviço
Self:nnBasIcms		:= 0		//Base de cálculo do ICMS
Self:nnValIcms		:= 0		//Valor do ICMS
Self:nnValNTrib		:= 0		//Valor não tributado do ICMS
Self:nnVlTerc		:= 0		//Valor cobrado por terceiros
Self:nnDespesa		:= 0		//Valor da despesas acessórias
Self:ciINFrt		:= ''		//Indicador da NAtureza do Frete
Self:cModEcf		:= ''		//Modelo do equipamento emissor de ECF
Self:cSerEcf		:= ''		//Número de série do equipamento ECF
Self:cNumEcf		:= ''		//Número do caixa ECF
Self:cCro			:= ''		//Posição do contador de reinício da operação
Self:cCrZ			:= ''		//Posição do contador da redução Z
Self:cNumCont		:= ''		//Número de contador final
Self:nVlGrade		:= 0		//Valor total da grade
Self:nVlBrut		:= 0		//Valor da Venda Bruta
Self:dDtRedZ		:= CTod("  /  /    ")		//Dia da redução Z
Self:niPautPis		:= 0		//Alíquota do PIS/PASEP (em reais)
Self:niPautCof		:= 0		//Alíquota da COFINS (em reais)
Self:oJSonQtD6		:= JsonObject():New()

IF lArray
	Self:aRegD100		:= {}		//Array com informações do registro A100
	Self:aRegD101		:= {}		//Array com informações do registro A120
	Self:aRegD105		:= {}		//Array com informações do registro A170
	Self:aRegD200		:= {}		//Array com informações do registro A170
	Self:aRegD201		:= {}		//Array com informações do registro A170
	Self:aRegD205		:= {}		//Array com informações do registro A170
	Self:aRegD300		:= {}		//Array com informações do registro A170
	Self:aRegD350		:= {}		//Array com informações do registro A170
	Self:aRegD500		:= {}		//Array com informações do registro A170
	Self:aRegD501		:= {}		//Array com informações do registro A170
	Self:aRegD505		:= {}		//Array com informações do registro A170
	Self:aRegD600		:= {}		//Array com informações do registro A170
	Self:aRegD601		:= {}		//Array com informações do registro A170
	Self:aRegD605		:= {}		//Array com informações do registro A170
	Self:aRegD111		:= {}		
	Self:aRegD209		:= {}		
	Self:aRegD309		:= {}		
	Self:aRegD359		:= {}		
	Self:aRegD509		:= {}		
	Self:aRegD609		:= {}		
	Self:aRegD001		:= {}
	Self:aRegD990		:= {}
	Self:aQtdD600		:= {}
	Self:aNfD600 		:= {}

	IF Self:lBuild
		Self:oHashD101 := &cNew
		Self:oHashD105 := &cNew
		Self:oHashD200 := &cNew
		Self:oHashD201 := &cNew
		Self:oHashD205 := &cNew
		Self:oHashD501 := &cNew
		Self:oHashD505 := &cNew
		Self:oHashD600 := &cNew
		Self:oHashD601 := &cNew
		Self:oHashD605 := &cNew
		Self:oHashQtD6 := &cNew

	Endif
EndIF

Return


Method setDtAqui( dnDtAqui) Class EFDCBLOCOD
	Self:dnDtAqui := dnDtAqui
Return
Method setTpCt( cnTpCt) Class EFDCBLOCOD
	Self:cnTpCt := cnTpCt
Return
Method setChvCte( cnChvCte) Class EFDCBLOCOD
	Self:cnChvCte := cnChvCte
Return
Method setIndFrt( cnIndFrt) Class EFDCBLOCOD
	Self:cnIndFrt := cnIndFrt
Return
Method setCodMun( cnCodMun) Class EFDCBLOCOD
	Self:cnCodMun := cnCodMun
Return
Method setTpRec( cnTpRec) Class EFDCBLOCOD
	Self:cnTpRec := cnTpRec
Return
Method setCodCla( cnCodCla) Class EFDCBLOCOD
	Self:cnCodCla := cnCodCla
Return
Method setVlServ( nnVlServ, lAcum) Class EFDCBLOCOD
	Default lAcum := .F.
	If lAcum
		Self:nnVlServ += nnVlServ
	Else
		Self:nnVlServ := nnVlServ	
	EndIF
Return
Method setBasIcms( nnBasIcms, lAcum) Class EFDCBLOCOD
	Default lAcum := .F.
	If lAcum
		Self:nnBasIcms += nnBasIcms
	Else
		Self:nnBasIcms := nnBasIcms
	EndiF
Return
Method setValIcms( nnValIcms,lAcum) Class EFDCBLOCOD
	Default lAcum := .F.
	If lAcum
		Self:nnValIcms += nnValIcms
	Else
		Self:nnValIcms := nnValIcms	
	EndIF
Return
Method setVlNTrib( nnValNTrib, lAcum) Class EFDCBLOCOD
	Default lAcum := .F.
	If lAcum
		Self:nnValNTrib += nnValNTrib
	Else
		Self:nnValNTrib := nnValNTrib	
	EndIF
Return
Method setVlTerc( nnVlTerc,lAcum) Class EFDCBLOCOD
	Default lAcum := .F.
	If lAcum
		Self:nnVlTerc += nnVlTerc
	Else
		Self:nnVlTerc := nnVlTerc	
	EndIF
Return
Method setDespesa( nnDespesa,lAcum) Class EFDCBLOCOD
	Default lAcum := .F.
	If lAcum
		Self:nnDespesa += nnDespesa
	Else
		Self:nnDespesa := nnDespesa	
	EndIF
Return
Method setINFrt( ciINFrt) Class EFDCBLOCOD
	Self:ciINFrt := ciINFrt
Return
Method setModEcf( cModEcf) Class EFDCBLOCOD
	Self:cModEcf := cModEcf
Return
Method setSerEcf( cSerEcf) Class EFDCBLOCOD
	Self:cSerEcf := cSerEcf
Return
Method setNumEcf( cNumEcf) Class EFDCBLOCOD
	Self:cNumEcf := cNumEcf
Return
Method setCro( cCro) Class EFDCBLOCOD
	Self:cCro := cCro
Return
Method setCrZ( cCrZ) Class EFDCBLOCOD
	Self:cCrZ := cCrZ
Return
Method setNumCont( cNumCont) Class EFDCBLOCOD
	Self:cNumCont := cNumCont
Return
Method setVlGrade( nVlGrade) Class EFDCBLOCOD
	Self:nVlGrade := nVlGrade
Return
Method setVlBrut( nVlBrut) Class EFDCBLOCOD
	Self:nVlBrut := nVlBrut
Return
Method setDtRedZ( dDtRedZ) Class EFDCBLOCOD
	Self:dDtRedZ := dDtRedZ
Return
Method setPisQtde( niPisQtde) Class EFDCBLOCOD
	Self:niPisQtde := niPisQtde
Return
Method setPautPis( niPautPis) Class EFDCBLOCOD
	Self:niPautPis := niPautPis
Return
Method setCofQtde( niCofQtde) Class EFDCBLOCOD
	Self:niCofQtde := niCofQtde
Return
Method setPautcof( niPautcof) Class EFDCBLOCOD
	Self:niPautcof := niPautcof
Return

Method getD100() Class EFDCBLOCOD
Return	self:aRegD100

Method getD101() Class EFDCBLOCOD
Return	self:aRegD101

Method getD105() Class EFDCBLOCOD
Return	self:aRegD105


Method getD200() Class EFDCBLOCOD
Return	self:aRegD200

Method getD201() Class EFDCBLOCOD
Return	self:aRegD201

Method getD205() Class EFDCBLOCOD
Return	self:aRegD205

Method getD500() Class EFDCBLOCOD
Return	self:aRegD500

Method getD501() Class EFDCBLOCOD
Return	self:aRegD501

Method getD505() Class EFDCBLOCOD
Return	self:aRegD505

Method getD600() Class EFDCBLOCOD
Return	self:aRegD600

Method getD601() Class EFDCBLOCOD
Return	self:aRegD601

Method getD605() Class EFDCBLOCOD
Return	self:aRegD605

Method getD300() Class EFDCBLOCOD
Return	self:aRegD300

Method getD350() Class EFDCBLOCOD
Return	self:aRegD350



Method getD111() Class EFDCBLOCOD
Return	self:aRegD111


Method getD209() Class EFDCBLOCOD
Return	self:aRegD209

Method getD309() Class EFDCBLOCOD
Return	self:aRegD309

Method getD359() Class EFDCBLOCOD
Return	self:aRegD359

Method getD509() Class EFDCBLOCOD
Return	self:aRegD509

Method getD609() Class EFDCBLOCOD
Return	self:aRegD609


//-------------------------------------------------------------------
/*/{Protheus.doc} AddD100()
@description Método que inclui novo registro D100. Operações de aquisição
			   de transportes modelo 07, 08, 8B, 09, 10, 11, 26, 27 e 57
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD100(lNew, nPosAcum) Class EFDCBLOCOD

Local nPos	:=	0

Default lNew	:= .T.
Default nPosAcum 	:= 0

IF lNew
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'D100')
	aAdd(Self:aRegD100, {})
	nPos := Len(Self:aRegD100)
	aAdd (Self:aRegD100[nPos], Self:cGrupoReg) 							//01-RELACIONAMENTO
	aAdd (Self:aRegD100[nPos], 'D100')									//01 - REG		
	aAdd (Self:aRegD100[nPos], '0')										//02 - IND_OPER
	aAdd (Self:aRegD100[nPos], Self:cnIndEmit)						//03 - IND_EMIT
	aAdd (Self:aRegD100[nPos], Self:cnCodPart)						//04 - COD_PART
	aAdd (Self:aRegD100[nPos], Self:cnModelo)							//05 - COD_MOD
	aAdd (Self:aRegD100[nPos], Self:cnSitDoc)							//06 - COD_SIT
	aAdd (Self:aRegD100[nPos], Self:cnSerie)							//07 - SER
	aAdd (Self:aRegD100[nPos], '')										//08 - SUB
	aAdd (Self:aRegD100[nPos], Self:cnNumNf)							//09 - NUM_DOC
	aAdd (Self:aRegD100[nPos], Self:cnChvCte)							//10 - CHV_CTE
	aAdd (Self:aRegD100[nPos], Self:dnEmissao)						//11 - DT_DOC
	aAdd (Self:aRegD100[nPos], Self:dnDtAqui)							//12 - DT_A_P
	aAdd (Self:aRegD100[nPos], Self:cnTpCt)							//13 - TP_CT-e
	aAdd (Self:aRegD100[nPos], '')										//14 - CHV_CTE_REF
	aAdd (Self:aRegD100[nPos], Self:nnValorNf)						//15 - VL_DOC
	aAdd (Self:aRegD100[nPos], Self:nnValDesc)						//16 - VL_DESC
	aAdd (Self:aRegD100[nPos], Self:cnIndFrt)							//17 - IND_FRT
	aAdd (Self:aRegD100[nPos], Self:nnVlServ )						//18 - VL_SERV
	aAdd (Self:aRegD100[nPos], Self:nnBasIcms )						//19 - VL_BC_ICMS
	aAdd (Self:aRegD100[nPos], Self:nnValIcms )						//20 - VL_ICMS
	aAdd (Self:aRegD100[nPos], Self:nnValNTrib )						//21 - VL_NT
	aAdd (Self:aRegD100[nPos], Self:cnInfCmp)							//22 - COD_INF
	aAdd (Self:aRegD100[nPos], Self:ciContaCtb)						//23 - COD_CTA	
Else
	nPos	:= nPosAcum
	Self:aRegD100[nPos][16] += Self:nnValorNf							//15 - VL_DOC
	Self:aRegD100[nPos][17] += Self:nnValDesc							//16 - VL_DESC	
	Self:aRegD100[nPos][19] += Self:nnVlServ 							//18 - VL_SERV
	Self:aRegD100[nPos][20] += Self:nnBasIcms 						//19 - VL_BC_ICMS
	Self:aRegD100[nPos][21] += Self:nnValIcms 						//20 - VL_ICMS
	Self:aRegD100[nPos][22] += Self:nnValNTrib 						//21 - VL_NT
EndIF


Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD101()
@description Método para chamar AddD10X para gerar registro D101
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD101() Class EFDCBLOCOD

Self:AddD10X('D101',@Self:aRegD101,@Self:oHashD101)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD105()
@description Método para chamar AddD10X para gerar registro D105
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD105() Class EFDCBLOCOD

Self:AddD10X('D105',@Self:aRegD105,@Self:oHashD105)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD10X()
@description Método que inclui novo registro D101 e D105, considerando as informações
			   já passadas para objeto. Estes registros são filhos do registro D100,
			   aqui serão gerados tanto registro D101 quanto C105, dependendo das
			   informações passadas por parâmetro.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,,É o array pertinten ao registro gerado, D101 ou D105
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD10X(cReg,aReg,oHash) Class EFDCBLOCOD

Local nPos			:= 0
Local nValTrib		:= 0
Local nBaseTrib		:= 0
Local nAlqTrib		:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib		:= ''
Local lPauta		:= .F.

Local cChave     	:= ''
//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'D101'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	nPautaTrib		:= Self:niPautPis
	nBsQtdTRib		:= Self:niPisQtde
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'D105'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	nPautaTrib		:= Self:niPautCof
	nBsQtdTRib		:= Self:niCofQtde
	cCstTrib		:= Self:ciCSTCof	
EndIF

cChave     	:= Self:cRelac + Self:ciINFrt +cCstTrib +Self:ciCodBcc+ cValToChar(nAlqTrib) + Self:ciContaCtb

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else
//Verifica se registro já está gravado.
	nPos := aScan (aReg, {|aX|  aX[1]== Self:cRelac 	.AND. ; 
								aX[3]==Self:ciINFrt 		.AND. ;
								aX[5]==cCstTrib 			.AND.  ;
								aX[6]==Self:ciCodBcc 	.AND.;
								aX[8][1]==nAlqTrib 		.AND. ;
								aX[10]==Self:ciContaCtb})
Endif
If nPos == 0	
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cRelac) 	//01-RELACIONAMENTO
	aAdd (aReg[nPos], cReg)				//01 - REG		
	aAdd (aReg[nPos], Self:ciINFrt)		//02 - IND_NAT_FRT
	aAdd (aReg[nPos], Self:niValItem)	//03 - VL_ITEM
	aAdd (aReg[nPos], cCstTrib)			//04 - CST_PIS
	aAdd (aReg[nPos], Self:ciCodBcc)	//05 - NAT_BC_CRED
	aAdd (aReg[nPos], nBaseTrib)		//06 - VL_BC_PIS
	aAdd (aReg[nPos], {nAlqTrib,4})		//07 - ALIQ_PIS
	aAdd (aReg[nPos], nValTrib)			//08 - VL_PIS
	aAdd (aReg[nPos], Self:ciContaCtb)	//09 - COD_CTA

	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	//Acumula os valores
	aReg[nPos][4]+= Self:niValItem		//03 - VL_ITEM
	aReg[nPos][7]+= nBaseTrib			//06 - VL_BC_PIS
	aReg[nPos][9]+= nValTrib				//08 -  VL_PIS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD200()
@description Método que inclui novo registro D200. Operações de prestação de serviço
			   de transportes modelo 07, 08, 8B, 09, 10, 11, 26, 27 e 57
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD200(cNFIni, cNFFim) Class EFDCBLOCOD

Local nPos	:=	0
Local nNumIni	:= ''
Local nNumFim	:= ''
Local cChave    := Self:cRelac +;
				   Self:cnModelo +;
				   Self:cnSitDoc +;
				   Self:cnSerie +;
				   Self:ciCFOP +;
				   cValtochar(Self:dnEmissao)
				   

Default cNFIni	:= ''
Default cNFFim	:= ''

IF !EmpTy(cNFIni)
	nNumIni	:= cNFIni
Else
	nNumIni	:= Self:cnNumNf
EndIF

If !Empty(cNFFim)
	nNumFim	:= cNFFim
Else
	nNumFim	:= Self:cnNumNf
EndIF

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(Self:oHashD200,cChave)
Else
	nPos := aScan(Self:aRegD200, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
										aX[3]==Self:cnModelo .AND. ;
									    aX[4]==Self:cnSitDoc .AND. ;
									    aX[5]== Self:cnSerie.AND.;
							  	  		aX[9]==Self:ciCFOP .And. ;
							  	  		aX[10] == Self:dnEmissao})
Endif

IF nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'D200')
	aAdd(Self:aRegD200, {})
	nPos := Len(Self:aRegD200)
	aAdd (Self:aRegD200[nPos], Self:cGrupoReg)  											//RELACIONAMENTO
	aAdd (Self:aRegD200[nPos], 'D200')													//01 - REG
	aAdd (Self:aRegD200[nPos], Self:cnModelo)											//02 - COD_MOD
	aAdd (Self:aRegD200[nPos], Self:cnSitDoc)											//03 - COD_SIT      	
	aAdd (Self:aRegD200[nPos], Self:cnSerie)											//04 - SER
	aAdd (Self:aRegD200[nPos], '')														//05 - SUB
	aAdd (Self:aRegD200[nPos], nNumIni)												//06 - NUM_DOC_INI
	aAdd (Self:aRegD200[nPos], nNumFim)												//07 - NUM_DOC_FIM
	aAdd (Self:aRegD200[nPos], Self:ciCFOP)											//08 - CFOP
	aAdd (Self:aRegD200[nPos], Self:dnEmissao)		   								//09 - DT_REF
	aAdd (Self:aRegD200[nPos], IIf (!Self:cnSitDoc $'02#03',Self:nnValorNf,'0'))	//10 - VL_DOC
	aAdd (Self:aRegD200[nPos], Self:nnValDesc)										//11 - VL_DESC
	If Self:lBuild
		Self:AddHash(Self:oHashD200,cChave,nPos)
	EndIF
Else
	Self:cGrupoReg	:= Self:aRegD200[nPos][1]
	//Acumula os valores
	Self:aRegD200[nPos][11] += IIf (!Self:cnSitDoc$'02#03', Self:nnValorNf, '0')	//10 - VL_DOC
	Self:aRegD200[nPos][12] += Self:nnValDesc											//11 - VL_DESC	
	
	//Verifica número de nota inicial
	If val(nNumIni) < val(Self:aRegD200[nPos][7]) 								  	
		Self:aRegD200[nPos][7] := nNumIni										//06 - NUM_DOC_INI
	EndIF	
	
	//Verifica número de nota final
	IF val(nNumFim)> val(Self:aRegD200[nPos][8])   	
		Self:aRegD200[nPos][8]:=	 nNumFim											//07 - NUM_DOC_FIM
	EndIF	
EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD201()
@description Método para chamar AddD20X para gerar registro D201
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD201() Class EFDCBLOCOD

Self:AddD20X('D201',@Self:aRegD201,@Self:oHashD201)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD205()
@description Método para chamar AddD20X para gerar registro D205
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD205() Class EFDCBLOCOD

Self:AddD20X('D205',@Self:aRegD205,@Self:oHashD205)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} AddD20X()
@description Método que inclui novo registro D201 e D205, considerando as informações
			   já passadas para objeto. Estes registros são filhos do registro D200,
			   aqui serão gerados tanto registro D201 quanto D205, dependendo das
			   informações passadas por parâmetro.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,,É o array pertinten ao registro gerado, D201 ou D205
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD20X(cReg,aReg,oHash) Class EFDCBLOCOD

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local cChave    := ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'D201'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'D205'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	cCstTrib		:= Self:ciCSTCof	
EndIF

cChave    := Self:cRelac + cCstTrib +cValToChar(nAlqTrib) + Self:ciContaCtb

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else
	nPos := aScan (aReg, {|aX| aX[1]== Self:cRelac 	.AND. ;  
							  aX[3]==cCstTrib 			.AND. ;
							  aX[6][1]==nAlqTrib 		.AND. ;
							  aX[8]==Self:ciContaCtb })
Endif
If nPos == 0	
	aAdd(aReg, {})
	nPos := Len(aReg)		
	aAdd (aReg[nPos], Self:cRelac)  	//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)				//01 - REG		
	aAdd (aReg[nPos], cCstTrib)			//02 - CST_PIS
	aAdd (aReg[nPos], Self:niValItem)	//03 - VL_ITEM	
	aAdd (aReg[nPos], nBaseTrib)		//04 - VL_BC_PIS
	aAdd (aReg[nPos], {nAlqTrib,4})		//05 - ALIQ_PIS
	aAdd (aReg[nPos], nValTrib)			//06 - VL_PIS
	aAdd (aReg[nPos], Self:ciContaCtb)	//07 - COD_CTA
	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF
Else
	aReg[nPos][4]+= Self:niValItem		//03 - VL_ITEM
	aReg[nPos][5]+= nBaseTrib			//04 - VL_BC_PIS
	aReg[nPos][7]+= nValTrib				//06 -  VL_PIS
EndIF	

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddD300(cNFIni, cNFFim)
@description Método que inclui novo registro D300. Operações de resumo 
			   de bilhetes de passagens modelos 13, 14, 15, 16 e 18
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD300(cNFIni, cNFFim) Class EFDCBLOCOD

Local nPos	:= 0

Default cNFIni	:= ''
Default cNFFim	:= ''

IF !EmpTy(cNFIni)
	nNumIni	:= cNFIni
Else
	nNumIni	:= Right(AllTrim(Self:cnNumNf),6)
EndIF

If !Empty(cNFFim)
	nNumFim	:= cNFFim
Else
	nNumFim	:= Right(AllTrim(Self:cnNumNf),6)	
EndIF
nPos := aScan (Self:aRegD300, {|aX| SubStr(aX[1],1,Len(Self:cRelac))== Self:cRelac .AND. ;   
										 aX[3] == Self:cnModelo 		.AND. ;
										 aX[4] == Self:cnSerie   	.AND. ;
										 Val(aX[7]) == Val(nNumFim)  - 1 .And.;
								     aX[8] == Self:ciCFOP 		.AND. ;
								     aX[12]== Self:ciCSTPis 		.AND. ;
								     aX[14][1]== Self:niAlqPis 		.AND. ;
								     aX[16]== Self:ciCSTCof 		.AND. ;
								     aX[18][1]== Self:niAlqCof 		.AND. ;
								     aX[20]== Self:ciContaCtb  	.AND. ;
									   aX[9] == Self:dnEntrada })
If nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'D300')
	aAdd(Self:aRegD300, {})
	nPos	:=	Len (Self:aRegD300)
	aAdd (Self:aRegD300[nPos], Self:cGrupoReg)  						//RELACIONAMENTO
	aAdd (Self:aRegD300[nPos], 'D300')								//01 - REG
	aAdd (Self:aRegD300[nPos], Self:cnModelo)						//02 - COD_MOD
	aAdd (Self:aRegD300[nPos], Self:cnSerie)						//03 - SER
	aAdd (Self:aRegD300[nPos], '')				   					//04 - SUB
	aAdd (Self:aRegD300[nPos], nNumIni)							//05 - NUM_DOC_INI
	aAdd (Self:aRegD300[nPos], nNumFim)							//06 - NUM_DOC_FIN
	aAdd (Self:aRegD300[nPos], Self:ciCFOP)						//07 - CFOP
	aAdd (Self:aRegD300[nPos], Self:dnEntrada)					//08 - DT_REF
	aAdd (Self:aRegD300[nPos], Self:niValItem)					//09 - VL_DOC
	aAdd (Self:aRegD300[nPos], Self:niValDesc)					//10 - VL_DESC	
	aAdd (Self:aRegD300[nPos], Self:ciCSTPis)						//11 - CST_PIS
	aAdd (Self:aRegD300[nPos], Self:niBasePis)					//12 - BL_BC_PIS
	aAdd (Self:aRegD300[nPos], {Self:niAlqPis,4})					//13 - ALIQ_PIS
	aAdd (Self:aRegD300[nPos], Self:niValPis)						//14 - VL_PIS
	aAdd (Self:aRegD300[nPos], Self:ciCSTCof)						//15 - CST_COFINS
	aAdd (Self:aRegD300[nPos], Self:niBaseCof)		 			//16 - VL_BC_COFINS
	aAdd (Self:aRegD300[nPos], {Self:niAlqCof,4})					//17 - ALIQ_COFINS
	aAdd (Self:aRegD300[nPos], Self:niValCof)						//18 - VL_COFINS
	aAdd (Self:aRegD300[nPos], Self:ciContaCtb)					//19 - COD_CTA
Else
	//Acumula os valores
	Self:cGrupoReg	:=  Self:aRegD300[nPos][1]

	IF !EmpTy(cNFIni)
		nNumIni	:= cNFIni
	Else
		nNumIni	:= Right(AllTrim(Self:cnNumNf),6)
	EndIF
	
	If !Empty(Self:aRegD300[nPos][6]) 
		nNumFim := Right(AllTrim(Self:cnNumNf),6)
	Else
		nNumFim := cNFFim
	Endif

	Self:aRegD300[nPos][10]  += Self:niValItem						//09 - VL_DOC
	Self:aRegD300[nPos][11] += Self:niValDesc						//10 - VL_DESC
	Self:aRegD300[nPos][13] += Self:niBasePis				   		//12 - BL_BC_PIS
	Self:aRegD300[nPos][15] += Self:niValPis			   			//14 - VL_PIS	
	Self:aRegD300[nPos][17] += Self:niBaseCof						//16 - VL_BC_COFINS
	Self:aRegD300[nPos][19] += Self:niValCof			   			//18 - VL_COFINS
	
	If val(Right(AllTrim(nNumIni),6)) < Val(Self:aRegD300[nPos][6])  	
		Self:aRegD300[nPos][6] := Right(AllTrim(nNumIni),6)	//05 - NUM_DOC_INI 
	EndIF
	
	IF val(Right(AllTrim(nNumFim),6)) > Val(Self:aRegD300[nPos][7])   	
		Self:aRegD300[nPos][7]:=	 Right(AllTrim(nNumFim),6)		 //06 - NUM_DOC_FIM
	EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD350()
@description Método que inclui novo registro D350. Resumo diário de 
			   cupom fiscla emitido por ecf, referente as operações
			   de serviço de transportes.
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD350(lAgrupa) Class EFDCBLOCOD

Local nPos	:= 0
Local lPauta :=  IIf(!Empty(Self:niPautPis), Self:niPautPis > 0, .F.)

DEFAULT lAgrupa := .F.

If lAgrupa
	nPos := aScan(Self:aRegD350, {|aX| SubStr(aX[1], 1, Len(Self:cRelac)) == Self:cRelac .And.;
									   	aX[3] == Self:cnModelo .And.;
									   	aX[4] == Self:cModEcf .And.;
									   	aX[5] == Self:cSerEcf .And.;
									   	aX[6] == Self:dnEmissao .And.;
									   	aX[7] == Self:cCro .And.;
									   	aX[8] == Self:cCrZ .And. ;
									   	aX[12] == Self:ciCSTPis .And.;
									   	aX[14, 1] == Self:niAlqPis .And.;
									   	aX[16, 1] == Self:niPautPis .And.;
									   	aX[18] == Self:ciCSTCof .And.;
									   	aX[20, 1] == Self:niAlqCof .And.;
									   	aX[22, 1] == Self:niPautCof})
EndIf

If nPos == 0

	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'D350')
	aAdd(Self:aRegD350, {})
	nPos	:=	Len (Self:aRegD350)
	aAdd (Self:aRegD350[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
	aAdd (Self:aRegD350[nPos], 'D350')					//01 - REG
	aAdd (Self:aRegD350[nPos], Self:cnModelo)			//02 - COD_MOD
	aAdd (Self:aRegD350[nPos], Self:cModEcf)			//03 - ECF_MOD
	aAdd (Self:aRegD350[nPos], Self:cSerEcf)			//04 - ECF_FAB
	aAdd (Self:aRegD350[nPos], Self:dnEmissao)			//05 - DT_DOC
	aAdd (Self:aRegD350[nPos], Self:cCro)				//06 - CRO
	aAdd (Self:aRegD350[nPos], Self:cCrZ)				//07 - CRZ
	aAdd (Self:aRegD350[nPos], Self:cNumCont)			//08 - NUM_COO_FIN
	aAdd (Self:aRegD350[nPos], Self:nVlGrade)			//09 - GT_FIN
	aAdd (Self:aRegD350[nPos], Self:nVlBrut)			//10 - VL_BRT
	aAdd (Self:aRegD350[nPos], Self:ciCSTPis)			//11 - CST_PIS
	aAdd (Self:aRegD350[nPos], Self:niBasePis)			//12 - VL_BC_PIS
	aAdd (Self:aRegD350[nPos], {Self:niAlqPis,4})		//13 - ALIQ_PIS
	aAdd (Self:aRegD350[nPos], Self:niPisQtde)			//14 - QUANT_BC_PIS
	aAdd (Self:aRegD350[nPos], {Self:niPautPis,4})		//15 - ALIQ_PIS_QUANT
	aAdd (Self:aRegD350[nPos], Self:niValPis)			//16 - VL_PIS
	aAdd (Self:aRegD350[nPos], Self:ciCSTCof)			//17 - CST_COFINS
	aAdd (Self:aRegD350[nPos], Self:niBaseCof)			//18 - VL_BC_COFINS
	aAdd (Self:aRegD350[nPos], {Self:niAlqCof,4})		//19 - ALIQ_COFINS
	aAdd (Self:aRegD350[nPos], Self:niCofQtde)			//20 - QUANT_BC_COFINS
	aAdd (Self:aRegD350[nPos], {Self:niPautCof,4})		//21 - QALIQ_COFINS_QUANT
	aAdd (Self:aRegD350[nPos], Self:niValCof)			//22 - VL_COFINS
	aAdd (Self:aRegD350[nPos], Self:ciContaCtb)			//23 - COD_CTA

Else

	Self:aRegD350[nPos, 11] += Self:nVlBrut

	If lPauta 
		Self:aRegD350[nPos, 15] += Self:niPisQtde		//14 - QUANT_BC_PIS
		Self:aRegD350[nPos, 21] += Self:niCofQtde		//20 - QUANT_BC_COFIN
	Else
		Self:aRegD350[nPos, 13] += Self:niBasePis		//12 - VL_BC_PIS
		Self:aRegD350[nPos, 19] += Self:niBaseCof		//18 - VL_BC_COFINS
	EndIf

	Self:aRegD350[nPos, 17] += Self:niValPis			//16 - VL_PIS
	Self:aRegD350[nPos, 23] += Self:niValCof			//22 - VL_COFINS

EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AddD500()
@description Método que inclui novo registro D00. Operações de aquisição de
			   serviço de telecomunicação e telecomunicação modelos 21 e 22.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD500(lNew, nPosAcum) Class EFDCBLOCOD

Local nPos	:= 0

Default lNew	:= .T.
Default nPosAcum := 0

If lNew	
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'D500')
	aAdd(Self:aRegD500, {})
	nPos := Len(Self:aRegD500)
	aAdd (Self:aRegD500[nPos], Self:cGrupoReg)  				//RELACIONAMENTO
	aAdd (Self:aRegD500[nPos], 'D500')							//01 - REG		
	aAdd (Self:aRegD500[nPos], '0')								//02 - IND_OPER
	aAdd (Self:aRegD500[nPos], Self:cnIndEmit)				//03 - IND_EMIT
	aAdd (Self:aRegD500[nPos], Self:cnCodPart)				//04 - COD_PART
	aAdd (Self:aRegD500[nPos], Self:cnModelo)					//05 - COD_MOD
	aAdd (Self:aRegD500[nPos], Self:cnSitDoc)					//06 - COD_SIT
	aAdd (Self:aRegD500[nPos], Self:cnSerie)					//07 - SER
	aAdd (Self:aRegD500[nPos], Self:cnSubSerie)					//08 - SUB  
	aAdd (Self:aRegD500[nPos], Self:cnNumNf)					//09 - NUM_DOC
	aAdd (Self:aRegD500[nPos], Self:dnEmissao)				//10 - DT_DOC
	aAdd (Self:aRegD500[nPos], Self:dnEntrada)				//11 - DT_A_P
	aAdd (Self:aRegD500[nPos], Self:nnValorNf)				//12 - VL_DOC
	aAdd (Self:aRegD500[nPos], Self:nnValDesc)				//13 - VL_DESC
	aAdd (Self:aRegD500[nPos], Self:nnVlServ)					//14 - VL_SERV
	aAdd (Self:aRegD500[nPos], Self:nnValNTrib)				//15 - VL_SERV_NT
	aAdd (Self:aRegD500[nPos], Self:nnVlTerc)					//16 - VL_TERC
	aAdd (Self:aRegD500[nPos], Self:nnDespesa) 	   			//17 - VL_DA
	aAdd (Self:aRegD500[nPos], Self:nnBasIcms) 				//18 - VL_BC_ICMS
	aAdd (Self:aRegD500[nPos], Self:nnValIcms) 				//19 - VL_ICMS
	aAdd (Self:aRegD500[nPos], Self:cnInfCmp)					//20 - COD_INF
	aAdd (Self:aRegD500[nPos], Self:nnValPis)					//21 - VL_PIS
	aAdd (Self:aRegD500[nPos], Self:nnValCof)					//22 - VL_COFINS
Else
	nPos	:= nPosAcum
	
	Self:aRegD500[nPos][13] += Self:nnValorNf					//12 - VL_DOC
	Self:aRegD500[nPos][14] += Self:nnValDesc					//13 - VL_DESC
	Self:aRegD500[nPos][15] += Self:nnVlServ					//14 - VL_SERV
	Self:aRegD500[nPos][16] += Self:nnValNTrib				//15 - VL_SERV_NT
	Self:aRegD500[nPos][17] += Self:nnVlTerc					//16 - VL_TERC
	Self:aRegD500[nPos][18] += Self:nnDespesa 	   			//17 - VL_DA
	Self:aRegD500[nPos][19] += Self:nnBasIcms 				//18 - VL_BC_ICMS
	Self:aRegD500[nPos][20] += Self:nnValIcms 				//19 - VL_ICMS	
	Self:aRegD500[nPos][22] += Self:nnValPis					//21 - VL_PIS
	Self:aRegD500[nPos][23] += Self:nnValCof					//22 - VL_COFINS	
	
EndIF


Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD501()
@description Método para chamar AddD20X para gerar registro D501
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD501() Class EFDCBLOCOD

Self:AddD50X('D501',@Self:aRegD501,@Self:oHashD501)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD505()
@description Método para chamar AddD20X para gerar registro D505
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD505() Class EFDCBLOCOD

Self:AddD50X('D505',@Self:aRegD505,@Self:oHashD505)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD50X()
@description Método que inclui novo registro D501 e D505, considerando as informações
			   já passadas para objeto. Estes registros são filhos do registro D500,
			   aqui serão gerados tanto registro D501 quanto D505, dependendo das
			   informações passadas por parâmetro.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,,É o array pertinten ao registro gerado, D501 ou D505
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD50X(cReg,aReg,oHash) Class EFDCBLOCOD

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local cChave    := ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'D501'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'D505'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	cCstTrib		:= Self:ciCSTCof	
EndIF

cChave :=  Self:cRelac + cCstTrib + cValToChar(nAlqTrib) + Self:ciContaCtb

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else
	nPos := aScan (aReg, {|aX|  aX[1]== Self:cRelac 		.AND. ; 
							    aX[3]==cCstTrib 				.AND. ;
							    aX[7][1]==nAlqTrib			.AND. ;
							    aX[9]==Self:ciContaCtb })
Endif
IF nPos ==0	
	aAdd(aReg, {})
	nPos := Len(aReg)
	aAdd (aReg[nPos], Self:cRelac)  		//RELACIONAMENTO
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
	aReg[nPos][4]+= Self:niValItem			//03 - VL_ITEM
	aReg[nPos][6]+= nBaseTrib				//05 - VL_BC_PIS
	aReg[nPos][8]+= nValTrib				 	//07 -  VL_PIS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD600()
@description Método que inclui novo registro D00. Operações de aquisição de
			   serviço de telecomunicação e telecomunicação modelos 21 e 22.
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD600(nQtdCon, cChaveNf) Class EFDCBLOCOD

Local nPos			:= 0
Local cQtdCon		:= ''
Local cChave        := Self:cRelac +;
					   Self:cnModelo +;
					   Self:cnCodMun +;
					   Self:cnSerie +;
					   Self:cnTpRec

Default  nQtdCon	:= 0

If nQtdCon == 0
	cQtdCon	:= '1'
Else
	cQtdCon	:= cValToChar(nQtdCon)
EndIf

//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan.
If Self:lBuild
	nPos := Self:FindHash(Self:oHashD600,cChave)
Else
	nPos := aScan (Self:aRegD600, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
									aX[3]==Self:cnModelo .AND.;
								   aX[4]==Self:cnCodMun .AND. ;
								   aX[5]==Self:cnSerie .AND.;
								   aX[7]==Self:cnTpRec})
Endif

If nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'D600')

	If Self:lBuild .and. !Empty(cChaveNF)
		Self:oJsonQtD6[cChaveNf] := 1
		cQtdCon := "1"
	ElseIf !Empty(cChaveNf)
		//Processa quantidade de documento processada no registro D600
		cQtdCon	:= cValtoChar ( Self:QtdNfD600( cChaveNf , Self:cGrupoReg ) )
	EndIF

	aAdd(Self:aRegD600, {})
	nPos 	:= Len(Self:aRegD600)
	nPosRet := nPos
	aAdd (Self:aRegD600[nPos], Self:cGrupoReg)  				//RELACIONAMENTO
	aAdd (Self:aRegD600[nPos], 'D600')						//01 - REG
	aAdd (Self:aRegD600[nPos], Self:cnModelo)				//02 - COD_MOD
	aAdd (Self:aRegD600[nPos], Self:cnCodMun)				//03 - COD_MUN
	aAdd (Self:aRegD600[nPos], Self:cnSerie)	   			//04 - SER
	aAdd (Self:aRegD600[nPos], '')							//05 - SUB
	aAdd (Self:aRegD600[nPos], Self:cnTpRec)				//06 - IND_REC
	aAdd (Self:aRegD600[nPos], cQtdCon)					//07 - QTD_CONS
	aAdd (Self:aRegD600[nPos], Self:dnDtDe)				//08 - DT_DOC_INI
	aAdd (Self:aRegD600[nPos], Self:dnDtAte)				//09 - DT_DOC_FIN
	aAdd (Self:aRegD600[nPos], Self:nnValorNf)	   		//10 - VL_DOC
	aAdd (Self:aRegD600[nPos], Self:nnValDesc)			//11 - VL_DESC
	aAdd (Self:aRegD600[nPos], Self:nnVlServ)				//12 - VL_SERV
	aAdd (Self:aRegD600[nPos], Self:nnValNTrib)			//13 - VL_SERV_NT		
	aAdd (Self:aRegD600[nPos], Self:nnVlTerc)				//14 - VL_TERC
	aAdd (Self:aRegD600[nPos], Self:nnDespesa)		  	//15 - VL_DA
	aAdd (Self:aRegD600[nPos], Self:nnBasIcms)			//16 - VL_BC_ICMS
	aAdd (Self:aRegD600[nPos], Self:nnValIcms) 	   		//17 - VL_ICMS
	aAdd (Self:aRegD600[nPos], Self:nnValPis)				//18 - VL_PIS
	aAdd (Self:aRegD600[nPos], Self:nnValCof) 			//19 - VL_COFINS	
	If Self:lBuild
		Self:AddHash(Self:oHashD600,cChave,nPos)
	EndIF
	
Else
	Self:cGrupoReg	:= Self:aRegD600[nPos][1]
	//Acumula os valores aqui
	If Self:lBuild .and. !empty(cChaveNF)
		cQtdCon := Self:aRegD600[nPos][8]

		If Self:oJsonQtD6[cChaveNf] == NIL
			cQtdCon	:= cvaltochar(val(Self:aRegD600[nPos][8] ) += 1 )
			Self:oJsonQtD6[cChaveNf] := cQtdCon
		Endif
		
	Elseif !Empty(cChaveNf)
		//Processa quantidade de documento processada no registro D600
		cQtdCon	:= cValtoChar ( Self:QtdNfD600( cChaveNf , Self:cGrupoReg ) )
	Else
		//Aqui irei somar pois está sendo processado pela Thread Agrupadora
		cQtdCon	:= cvaltochar(val(Self:aRegD600[nPos][8] ) += nQtdCon )	
	EndIF
	
	Self:aRegD600[nPos][8] := cQtdCon						//07 - QTD_CONS 
	Self:aRegD600[nPos][11]+= Self:nnValorNf				//10 - VL_DOC
	Self:aRegD600[nPos][12]+= Self:nnValDesc				//11 - VL_DESC
	Self:aRegD600[nPos][13]+= Self:nnVlServ				//12 - VL_SERV		
	Self:aRegD600[nPos][15]+= Self:nnVlTerc				//14 - VL_TERCC		
	Self:aRegD600[nPos][16]+= Self:nnDespesa				//15 - VL_DA			
	Self:aRegD600[nPos][17]+= Self:nnBasIcms				//16 - VL_BC_ICMS
	Self:aRegD600[nPos][18]+= Self:nnValIcms 	   			//17 - VL_ICMS
	Self:aRegD600[nPos][19]+= Self:nnValPis 				//18 - VL_PIS
	Self:aRegD600[nPos][20]+= Self:nnValCof				//19 - VL_COFINS	

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD601()
@description Método para chamar AddD20X para gerar registro D601
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD601() Class EFDCBLOCOD

Self:AddD60X('D601',@Self:aRegD601,@Self:oHashD601)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD605()
@description Método para chamar AddD20X para gerar registro D605
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD605() Class EFDCBLOCOD

Self:AddD60X('D605',@Self:aRegD605,@Self:oHashD605)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD60X()
@description Método que inclui novo registro D601 e D605, considerando as informações
			   já passadas para objeto. Estes registros são filhos do registro D600,
			   aqui serão gerados tanto registro D601 quanto D605, dependendo das
			   informações passadas por parâmetro.
@param	cReg,String,Contém a informação de qual registro será gerado
@param	aReg,,É o array pertinten ao registro gerado, D601 ou D605
@author Erick G. Dias
@since 20/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD60X(cReg,aReg,oHash) Class EFDCBLOCOD

Local nPos			:= 0
Local nValTrib	:= 0
Local nBaseTrib	:= 0
Local nAlqTrib	:= 0
Local nPautaTrib	:= 0
Local nBsQtdTRib	:= 0
Local cCstTrib	:= ''
Local cChave    := ''

//Verifica se está gerando PIS ou COFINS para preencher as variáveis	
If cReg == 'D601'
	nValTrib		:= Self:niValPis
	nBaseTrib		:= Self:niBasePis
	nAlqTrib		:= Self:niAlqPis
	cCstTrib		:= Self:ciCSTPis
ElseIF cReg == 'D605'
	nValTrib		:= Self:niValCof
	nBaseTrib		:= Self:niBaseCof
	nAlqTrib		:= Self:niAlqCof
	cCstTrib		:= Self:ciCSTCof	
EndIF

cChave    := Self:cRelac + Self:cnCodCla + cCstTrib + cValToChar(nAlqTrib) + Self:ciContaCtb
//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
If Self:lBuild
	nPos := Self:FindHash(oHash,cChave)
Else
	nPos := aScan (aReg, {|aX|     aX[1]== Self:cRelac 		.AND. ; 
									aX[3]==Self:cnCodCla 			.AND. ;
									aX[6]==cCstTrib 				.AND.;
									aX[8][1]== nAlqTrib 				.AND.;
									aX[10]==Self:ciContaCtb })
Endif

IF nPos == 0	
	aAdd(aReg, {})
	nPos := Len(aReg)	
	aAdd (aReg[nPos], Self:cRelac)  			//RELACIONAMENTO
	aAdd (aReg[nPos], cReg)						//01 - REG		
	aAdd (aReg[nPos], Self:cnCodCla)			//02 - COD_CLASS		
	aAdd (aReg[nPos], Self:niValItem)			//03 - VL_ITEM
	aAdd (aReg[nPos], Self:niValDesc)			//04 - VL_DESC	
	aAdd (aReg[nPos], cCstTrib)					//05 - CST_PIS
	aAdd (aReg[nPos], nBaseTrib)				//06 - VL_BC_PIS
	aAdd (aReg[nPos], {nAlqTrib,4})				//07 - ALIQ_PIS
	aAdd (aReg[nPos], nValTrib)	   				//08 - VL_PIS
	aAdd (aReg[nPos], Self:ciContaCtb )		//09 - COD_CTA	
	If Self:lBuild
		Self:AddHash(oHash,cChave,nPos)
	EndIF	
Else
	aReg[nPos][4]+= Self:niValItem			 	//03 - VL_ITEM
	aReg[nPos][5]+= Self:niValDesc			   	//04 - VL_DESC
	aReg[nPos][7]+= nBaseTrib				   	//06 - VL_BC_PIS
	aReg[nPos][9]+= nValTrib						//08 -  VL_PIS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProcRef()
@description Método que inclui novo registros D111, D209, D309,
			   D359, D509 e D609, todos de Processo referenciado.
			   Utiliza método herdado da classe NOTAEFD
@author Erick G. Dias
@since14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddProcRef(cReg) Class EFDCBLOCOD

Do Case
	Case cReg == 'D111'	
		Self:ProcRef('D111',@Self:aRegD111)
	Case cReg == 'D209'
		Self:ProcRef('D209',@Self:aRegD209)
	Case cReg == 'D309'
		Self:ProcRef('D309',@Self:aRegD309)
	Case cReg == 'D359'
		Self:ProcRef('D359',@Self:aRegD359)	
	Case cReg == 'D509'
		Self:ProcRef('D509',@Self:aRegD509)
	Case cReg == 'D609'
		Self:ProcRef('D609',@Self:aRegD609)	
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD001(cIndMovto) Class EFDCBLOCOD

Self:AbreBloco('D001',@Self:aRegD001,cIndMovto)

Return Self:aRegD001

//-------------------------------------------------------------------
/*/{Protheus.doc} AddD990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddD990(nQtde) Class EFDCBLOCOD

Self:FechaBloco('D990',@Self:aRegD990, nQtde) 

Return Self:aRegD990

//-------------------------------------------------------------------
/*/{Protheus.doc} clsD100()
@description Método para limpar variáveis utilizadas no registro D100
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsD100() Class EFDCBLOCOD
Local cNew := "HMNew()"

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegD100	:= {}
Self:aRegD101	:= {}
Self:aRegD105	:= {}
Self:aRegD111	:= {}

IF Self:lBuild
	FreeObj(Self:oHashD101)
	Self:oHashD101 := nil

	Self:oHashD101 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashD105)
	Self:oHashD105 := nil

	Self:oHashD105 := &cNew
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} clsD200()
@description Método para limpar variáveis utilizadas no registro D200
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsD200() Class EFDCBLOCOD
Local cNew	:= "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegD200		:= {}
Self:aRegD201		:= {}
Self:aRegD205		:= {}
Self:aRegD209		:= {}

IF Self:lBuild
	FreeObj(Self:oHashD200)
	Self:oHashD200 := nil

	Self:oHashD200 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashD201)
	Self:oHashD201 := nil

	Self:oHashD201 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashD205)
	Self:oHashD205 := nil

	Self:oHashD205 := &cNew
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsD500()
@description Método para limpar variáveis utilizadas no registro D2D50000
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsD500() Class EFDCBLOCOD
Local cNew	:= "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegD500		:= {}
Self:aRegD501		:= {}
Self:aRegD505		:= {}
Self:aRegD509		:= {}

IF Self:lBuild
	FreeObj(Self:oHashD501)
	Self:oHashD501 := nil

	Self:oHashD501 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashD505)
	Self:oHashD505 := nil

	Self:oHashD505 := &cNew
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsD600()
@description Método para limpar variáveis utilizadas no registro D2D50000
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsD600() Class EFDCBLOCOD
Local cNew	:= "HMNew()"
Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegD600	:= {}
Self:aRegD601	:= {}
Self:aRegD605	:= {}
Self:aRegD609	:= {}
Self:aQtdD600	:= {}
Self:aNfD600 	:= {}

IF Self:lBuild
	FreeObj(Self:oHashD600)
	Self:oHashD600 := nil

	Self:oHashD600 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashD601)
	Self:oHashD601 := nil

	Self:oHashD601 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashD605)
	Self:oHashD605 := nil

	Self:oHashD605 := &cNew
Endif

IF Self:lBuild
	FreeObj(Self:oHashQtD6)
	Self:oHashQtD6 := nil

	Self:oHashQtD6 := &cNew

	FreeObj(Self:oJsonQtD6)
	Self:oJsonQtD6 := nil

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsD300()
@description Método para limpar variáveis utilizadas no registro D300
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsD300() Class EFDCBLOCOD

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegD300		:= {}
Self:aRegD309		:= {}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clsD350()
@description Método para limpar variáveis utilizadas no registro D350
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsD350() Class EFDCBLOCOD

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegD350	:= {}
Self:aRegD359	:= {}

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} QtdNfD600()
@description Método para controlar número de quantidade de documentos consolidados no registro D600
@author Erick G. Dias
@since 17/01/2018
@version 12.1.17
/*/
//------------------------------------------------------------------- 
Method QtdNfD600(cChaveNf, cGrupoReg) Class EFDCBLOCOD

Local nPosQtd	:= 0
Local cChave    := ''

//Verifico se esta nota já gerou algum D600
IF aScan(Self:aNfD600, {|aX| aX[1] == cChaveNf .AND. aX[2] == cGrupoReg } ) == 0
	
	//Se não gerou então será adicionada no array de notas do D600
	aAdd(Self:aNfD600 , {cChaveNf,Self:cGrupoReg})
	cChave := cGrupoReg
	//Somente irá tratar HashMap caso build seja maior ou igual a 7.00.131227A, caso contrário irá tratar com aScan
	If Self:lBuild
		nPosQtd := Self:FindHash(Self:oHashQtD6,cChave)
	Else
		//Verifica se para este D600 já existe contegem de notas, se não exisit será criado
		nPosQtd	:=  aScan(Self:aQtdD600, {|aX| aX[1] == cGrupoReg } )
	EndIf
	IF nPosQtd == 0		
		aAdd(Self:aQtdD600, {})
		nPosQtd := Len(Self:aQtdD600)		
		aAdd (Self:aQtdD600[nPosQtd], cGrupoReg) //Grupo do D600 
		aAdd (Self:aQtdD600[nPosQtd], 1) //Quantidade de documentos utilizados para este D600	

		If Self:lBuild
			Self:AddHash(Self:oHashQtD6,cChave,nPosQtd)
		EndIF	
	Else
		Self:aQtdD600[nPosQtd][2] += 1
	EndIf
	
Else
	
	//Se já existe nota então apenas irá posicionar no array para retornar a quantidade.
	nPosQtd	:=  aScan(Self:aQtdD600, {|aX| aX[1] == cGrupoReg } )
	
EndIF


Return Self:aQtdD600[nPosQtd][2]
 