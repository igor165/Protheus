#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCO1();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCO1()
@description Classe que terá as informações específicas para geração dos 
			   registros do bloco 1 no SPED Contribuições. São os complementos 
			   da escrituração, que terá saldo de créditos e retenções,
			   detalhamento da receita e informações de processo referenciado.
			   

@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCO1 FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS DA CLASSE
//-----------------------------------------------------

Data cNumProc		as String		READONLY		//Número do processo administrativo ou judicial
Data cIdJur		as String		READONLY		//Identificação da seção jurídica
Data cIdVara		as String		READONLY		//Identificação da vara
Data cNatAcao		as String		READONLY		//Identificação da ação Jurídica ou administrativa
Data cDescr		as String		READONLY		//descrição resumida da ação judicial ou ação administrativa
Data cOriCrd		as String		READONLY		//Origem do crédito
Data cCnpj			as String		READONLY		//CNPJ da pessoa jurídica cendente do crédito ou CNPJ do estabelecimento
Data cCodCrd		as String		READONLY		//Código do Crédito tabela 4.3.6
Data cNatRet		as String		READONLY		//Natureza da Retenção de Fonte
Data cPerRet		as String		READONLY		//Preríodo do recebimento e da retenção (MM/AAAA)
Data cMesAno		as String		READONLY		//Mês / ano do recebimento e da retenção (MM/AAAA)
Data cModelo		as String		READONLY		//Código do modelo do documento
Data cSerie		as String		READONLY		//Série do documento
Data cSitDoc		as String		READONLY		//Código da situação do documento
Data cCstPis		as String		READONLY		//CST PIS
Data cCstCof		as String		READONLY		//CST COFINS
Data cCFOP			as String		READONLY		//CFOP 
Data cInfComp		as String		READONLY		//Informação complementar
Data cContaCtb	as String		READONLY		//Conta Contábil
Data cQtdNf		as String		READONLY		//Quantidade total de documentos emitido
Data nTotApur		as Integer		READONLY		//Valor do crédito apurado
Data nCrdExt		as Integer		READONLY		//Valor do Crédito extemporâneo apurado
Data nCrdApu		as Integer		READONLY		//Valor Total do Crédito Apurado
Data nCrdAnt		as Integer		READONLY		//Valor do Crédito anterior utilizado mediante desconto
Data nVlRes		as Integer		READONLY		//Valor do Crédito utilizado mediante ressarcimento
Data nVlCom		as Integer		READONLY		//Valor do Crédito utilizado mediante compensação
Data nVlDisp		as Integer		READONLY		//Saldo de crédito disponível no período
Data nVlDesc		as Integer		READONLY		//Valor do crédito descontado no período
Data nVlPedRes	as Integer		READONLY		//Valor do crédito objeto de pedido de ressarcimento
Data nVlPedCom	as Integer		READONLY		//Valor do crédito objeto de pedido de compensação
Data nVlTranf		as Integer		READONLY		//Valor do crédito transfedio através de cisão, fusão ou incorporação
Data nVlUtOut		as Integer		READONLY		//Valor do crédito utilizado por outras formas
Data nSldCrd		as Integer		READONLY		//Saldo de crédito a transportar para próximos períodos
Data nTotRet		as Integer		READONLY		//Valor total da retenção
Data nRetDed		as Integer		READONLY		//Valor da retenção deduzida
Data nRetRes		as Integer		READONLY		//Valor da retenção utilizada mediante pedido de ressarcimento
Data nRetCom		as Integer		READONLY		//Valor da retenção utilizada mediante pedido de compensação
Data nSldRet		as Integer		READONLY		//Saldo de Retenção
Data nVlRec		as Integer		READONLY		//Valor total da receita
Data dDtDecisao	as Date		READONLY		//data da decisão da ação
Data dPerApu		as Date		READONLY		//Período da apuração
Data cIndAj
Data nVlTot
Data nVlCST01
Data nVlCST02
Data nVlCST03
Data nVlCST04
Data nVlCST05
Data nVlCST06
Data nVlCST07
Data nVlCST08
Data nVlCST09
Data nVlCST49
Data nVlCST99
Data cIndAprop
Data cRecibo

//1011
Data cRegRef
Data cCstPisS
Data cCstCofS
Data nBasPisS
Data nBasCofS
Data nAlqPisS
Data nAlqCofS
Data nValPisS
Data nValCofS

//1800
Data cIdEmpre		as String		READONLY		//Identificação do empreenimento optante pelo RET
Data nVlReceb		as Integer		READONLY		//Valor das Receitas recebidas
Data nRecFin		as Integer		READONLY		//Receitas Financeiras submetidas ao RET
Data dDtRecol		as Date		READONLY		//Data do recolhimento unificado
Data cCodRec		as Integer		READONLY		//Código da Receita
Data cTrib		    as String		READONLY		//Código da Receita

//-------------------------------------------------------------
//ARRAY DOS REGISTROS DO BLOCO 1
//-------------------------------------------------------------
Data aReg1010		as Array		READONLY	
Data aReg1011		as Array		READONLY	
Data aReg1020		as Array		READONLY
Data aReg1050		as Array		READONLY
Data aReg1100		as Array		READONLY
Data aReg1300		as Array		READONLY
Data aReg1500		as Array		READONLY
Data aReg1700		as Array		READONLY
Data aReg1800		as Array		READONLY	
Data aReg1900		as Array		READONLY
Data aReg1809		as Array		READONLY
Data aReg1001		as Array		READONLY
Data aReg1990		as Array		READONLY
Data aExigSusp		as Array		READONLY
		
//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()
Method Add1010()
Method Add1011()
Method Add1020()
Method Add1050()
Method Add1100()
Method Add1500()
Method Add1300()
Method Add1700()
Method Add11001500()
Method Add13001700()
Method Add1800()
Method Add1900()
Method AddProcRef(cReg)
METHOD Add1001(cIndMovto)
METHOD Add1990(nQtde)

METHOD cls1100()
METHOD cls1010()
METHOD cls1011()
METHOD cls1020()
METHOD cls1300()
METHOD cls1500()
METHOD cls1700()
METHOD cls1800()


Method setNumProc( cNumProc)	
Method setIdJur( cIdJur)
Method setIdVara( cIdVara)
Method setNatAcao( cNatAcao)
Method setDescr( cDescr)
Method setOriCrd( cOriCrd)
Method setCnpj( cCnpj) 
Method setCodCrd( cCodCrd)
Method setNatRet( cNatRet)
Method setPerRet( cPerRet)
Method setMesAno( cMesAno)
Method setModelo( cModelo)
Method setSerie( cSerie)
Method setSitDoc( cSitDoc)
Method setCstPis( cCstPis)
Method setCstCof( cCstCof)
Method setCFOP( cCFOP)
Method setInfComp( cInfComp)
Method setConta( cContaCtb) 
Method setQtdNf( cQtdNf) 
Method setTotApur( nTotApur)
Method setCrdExt( nCrdExt)
Method setCrdApu( nCrdApu)
Method setCrdAnt( nCrdAnt)
Method setVlRes( nVlRes) 
Method setVlCom( nVlCom) 
Method setVlDisp( nVlDisp) 
Method setVlDesc( nVlDesc)
Method setVPedRes( nVlPedRes)
Method setVPedCom( nVlPedCom)
Method setVlTranf( nVlTranf) 
Method setVlUtOut( nVlUtOut)
Method setSldCrd( nSldCrd)
Method setTotRet( nTotRet)
Method setRetDed( nRetDed)
Method setRetRes( nRetRes)
Method setRetCom( nRetCom)
Method setSldRet( nSldRet)
Method setVlRec( nVlRec)
Method setDecisao( dDtDecisao) 
Method setPerApu( dPerApu)
Method setIdEmpre( cIdEmpre)
Method setVlReceb( nVlReceb)
Method setRecFin( nRecFin) 
Method setDtRecol( dDtRecol)
Method setCodRec( cCodRec)
Method setTrib( cTrib)

Method setIndAj(cIndAj)
Method setVlTot(nVlTot)
Method setVlCSt01(nVlCST01)
Method setVlCSt02(nVlCST02)
Method setVlCSt03(nVlCST03)
Method setVlCSt04(nVlCST04)
Method setVlCSt05(nVlCST05)
Method setVlCSt06(nVlCST06)
Method setVlCSt07(nVlCST07)
Method setVlCSt08(nVlCST08)
Method setVlCSt09(nVlCST09)
Method setVlCSt49(nVlCST49)
Method setVlCSt99(nVlCST99)
Method setIndAprop(cIndAprop)
Method setRecibo(cRecibo)

Method setRegRef(value)
Method setCstPisS(value)
Method setCstCofS(value)
Method setBasPisS(value)
Method setBasCofS(value)
Method setAlqPisS(value)
Method setAlqCofS(value)
Method setValPisS(value)
Method setValCofS(value)

Method get1010()
Method get1011()
Method get1020()
Method get1050()

Method get1100()
Method get1500()
Method get1300()
Method get1700()
Method get1800()
Method get1900()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCO1
Self:cJob	:= '00'
Self:Clear()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
Método que inicializa as proriedades da classe 

@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Clear(lArray) Class EFDCBLOCO1

Default lArray	:= .T.

Self:cNumProc		:= ''		//Número do processo administrativo ou judicial
Self:cIdJur		:= ''		//Identificação da seção jurídica
Self:cIdVara		:= ''		//Identificação da vara
Self:cNatAcao		:= ''		//Identificação da ação Jurídica ou administrativa
Self:cDescr		:= ''		//descrição resumida da ação judicial ou ação administrativa
Self:cOriCrd		:= ''		//Origem do crédito
Self:cCnpj			:= ''		//CNPJ da pessoa jurídica cendente do crédito ou CNPJ do estabelecimento
Self:cCodCrd		:= ''		//Código do Crédito tabela 4.3.6
Self:cNatRet		:= ''		//Natureza da Retenção de Fonte
Self:cPerRet		:= ''		//Preríodo do recebimento e da retenção (MM/AAAA)
Self:cMesAno		:= ''		//Ano /Mês do recebimento e da retenção (MM/AAAA)
Self:cModelo		:= ''		//Código do modelo do documento
Self:cSerie		:= ''		//Série do documento
Self:cSitDoc		:= ''		//Código da situação do documento
Self:cCstPis		:= ''		//CST PIS
Self:cCstCof		:= ''		//CST COFINS
Self:cCFOP			:= ''		//CFOP 
Self:cInfComp		:= ''		//Informação complementar
Self:cContaCtb	:= ''		//Conta Contábil
Self:cQtdNf		:= ''		//Quantidade total de documentos emitido
Self:nTotApur		:= 0		//Valor do crédito apurado
Self:nCrdExt		:= 0		//Valor do Crédito extemporâneo apurado
Self:nCrdApu		:= 0		//Valor Total do Crédito Apurado
Self:nCrdAnt		:= 0		//Valor do Crédito anterior utilizado mediante desconto
Self:nVlRes		:= 0		//Valor do Crédito utilizado mediante ressarcimento
Self:nVlCom		:= 0		//Valor do Crédito utilizado mediante compensação
Self:nVlDisp		:= 0		//Saldo de crédito disponível no período
Self:nVlDesc		:= 0		//Valor do crédito descontado no período
Self:nVlPedRes	:= 0		//Valor do crédito objeto de pedido de ressarcimento
Self:nVlPedCom	:= 0		//Valor do crédito objeto de pedido de compensação
Self:nVlTranf		:= 0		//Valor do crédito transfedio através de cisão, fusão ou incorporação
Self:nVlUtOut		:= 0		//Valor do crédito utilizado por outras formas
Self:nSldCrd		:= 0		//Saldo de crédito a transportar para próximos períodos
Self:nTotRet		:= 0		//Valor total da retenção
Self:nRetDed		:= 0		//Valor da retenção deduzida
Self:nRetRes		:= 0		//Valor da retenção utilizada mediante pedido de ressarcimento
Self:nRetCom		:= 0		//Valor da retenção utilizada mediante pedido de compensação
Self:nSldRet		:= 0		//Saldo de Retenção
Self:nVlRec		:= 0		//Valor total da receita
Self:dDtDecisao	:= CTod("  /  /    ")		//Self:da decisão da ação
Self:dPerApu		:= CTod("  /  /    ")		//Período da apuração
Self:cIdEmpre		:= ''		//Identificação do empreenimento optante pelo RET
Self:nVlReceb		:= 0		//Valor das Receitas recebidas
Self:nRecFin		:= 0		//Receitas Financeiras submetidas ao RET
Self:dDtRecol		:= CTod("  /  /    ")		//Self:do recolhimento unificado
Self:cCodRec		:= ""		//Código da Receita
Self:cTrib			:= ""
Self:cIndAj		:= ""
Self:nVlTot		:= 0
Self:nVlCST01 	:= 0
Self:nVlCST02 	:= 0
Self:nVlCST03 	:= 0
Self:nVlCST04 	:= 0
Self:nVlCST05 	:= 0
Self:nVlCST06 	:= 0
Self:nVlCST07 	:= 0
Self:nVlCST08 	:= 0
Self:nVlCST09 	:= 0
Self:nVlCST49 	:= 0
Self:nVlCST99 	:= 0
Self:cIndAprop 	:= ""
Self:cRecibo	:= ""
Self:cRegRef	:= ""
Self:cCstPisS	:= ""
Self:cCstCofS	:= ""
Self:nBasPisS	:= 0
Self:nBasCofS	:= 0
Self:nAlqPisS	:= 0
Self:nAlqCofS	:= 0
Self:nValPisS	:= 0
Self:nValCofS	:= 0

IF lArray
	Self:aReg1010		:= {}	
	Self:aReg1011		:= {}
	Self:aReg1020		:= {}
	Self:aReg1050		:= {}
	Self:aReg1100		:= {}
	Self:aReg1300		:= {}
	Self:aReg1500		:= {}
	Self:aReg1700		:= {}
	Self:aReg1800		:= {}	
	Self:aReg1900		:= {}
	Self:aReg1809		:= {}
	Self:aReg1001		:= {}
	Self:aReg1990		:= {}
	Self:aExigSusp		:= {}
EndIF

Return

Method setNumProc( cNumProc) Class EFDCBLOCO1
	Self:cNumProc := cNumProc
Return
Method setIdJur( cIdJur) Class EFDCBLOCO1
	Self:cIdJur := cIdJur
Return
Method setIdVara( cIdVara) Class EFDCBLOCO1
	Self:cIdVara := cIdVara
Return
Method setNatAcao( cNatAcao) Class EFDCBLOCO1
	Self:cNatAcao := cNatAcao
Return
Method setDescr( cDescr) Class EFDCBLOCO1
	Self:cDescr := cDescr
Return
Method setOriCrd( cOriCrd) Class EFDCBLOCO1
	Self:cOriCrd := cOriCrd
Return
Method setCnpj( cCnpj) Class EFDCBLOCO1
	Self:cCnpj := cCnpj
Return
Method setCodCrd( cCodCrd) Class EFDCBLOCO1
	Self:cCodCrd := cCodCrd
Return
Method setNatRet( cNatRet) Class EFDCBLOCO1
	Self:cNatRet := cNatRet
Return
Method setPerRet( cPerRet) Class EFDCBLOCO1
	Self:cPerRet := cPerRet
Return
Method setMesAno( cMesAno) Class EFDCBLOCO1
	Self:cMesAno := cMesAno
Return
Method setModelo( cModelo) Class EFDCBLOCO1
	Self:cModelo := cModelo
Return
Method setSerie( cSerie) Class EFDCBLOCO1
	Self:cSerie := cSerie
Return
Method setSitDoc( cSitDoc) Class EFDCBLOCO1
	Self:cSitDoc := cSitDoc
Return
Method setCstPis( cCstPis) Class EFDCBLOCO1
	Self:cCstPis := cCstPis
Return
Method setCstCof( cCstCof) Class EFDCBLOCO1
	Self:cCstCof := cCstCof
Return
Method setCFOP( cCFOP) Class EFDCBLOCO1
	Self:cCFOP := cCFOP
Return
Method setInfComp( cInfComp) Class EFDCBLOCO1
	Self:cInfComp := cInfComp
Return
Method setConta( cContaCtb) Class EFDCBLOCO1
	Self:cContaCtb := cContaCtb
Return
Method setQtdNf( cQtdNf) Class EFDCBLOCO1
	Self:cQtdNf := cQtdNf
Return
Method setTotApur( nTotApur) Class EFDCBLOCO1
	Self:nTotApur := nTotApur
Return
Method setCrdExt( nCrdExt) Class EFDCBLOCO1
	Self:nCrdExt := nCrdExt
Return
Method setCrdApu( nCrdApu) Class EFDCBLOCO1
	Self:nCrdApu := nCrdApu
Return
Method setCrdAnt( nCrdAnt) Class EFDCBLOCO1
	Self:nCrdAnt := nCrdAnt
Return
Method setVlRes( nVlRes) Class EFDCBLOCO1
	Self:nVlRes := nVlRes
Return
Method setVlCom( nVlCom) Class EFDCBLOCO1
	Self:nVlCom := nVlCom
Return
Method setVlDisp( nVlDisp) Class EFDCBLOCO1
	Self:nVlDisp := nVlDisp
Return
Method setVlDesc( nVlDesc) Class EFDCBLOCO1
	Self:nVlDesc := nVlDesc
Return
Method setVPedRes( nVlPedRes) Class EFDCBLOCO1
	Self:nVlPedRes := nVlPedRes
Return
Method setVPedCom( nVlPedCom) Class EFDCBLOCO1
	Self:nVlPedCom := nVlPedCom
Return
Method setVlTranf( nVlTranf) Class EFDCBLOCO1
	Self:nVlTranf := nVlTranf
Return
Method setVlUtOut( nVlUtOut) Class EFDCBLOCO1
	Self:nVlUtOut := nVlUtOut
Return
Method setSldCrd( nSldCrd) Class EFDCBLOCO1
	Self:nSldCrd := nSldCrd
Return
Method setTotRet( nTotRet) Class EFDCBLOCO1
	Self:nTotRet := nTotRet
Return
Method setRetDed( nRetDed) Class EFDCBLOCO1
	Self:nRetDed := nRetDed
Return
Method setRetRes( nRetRes) Class EFDCBLOCO1
	Self:nRetRes := nRetRes
Return
Method setRetCom( nRetCom) Class EFDCBLOCO1
	Self:nRetCom := nRetCom
Return
Method setSldRet( nSldRet) Class EFDCBLOCO1
	Self:nSldRet := nSldRet
Return
Method setVlRec( nVlRec) Class EFDCBLOCO1
	Self:nVlRec := nVlRec
Return
Method setDecisao( dDtDecisao) Class EFDCBLOCO1
	Self:dDtDecisao := IIF(Empty(dDtDecisao), '', dDtDecisao) // Se Data Decisão vazia "  /  /    " logo o registro no registro 1010 no campo 07 DT_SENT_JUD devera ser levado Vazio('')
Return
Method setPerApu( dPerApu) Class EFDCBLOCO1
	Self:dPerApu := dPerApu
Return
Method setIdEmpre( cIdEmpre) Class EFDCBLOCO1
	Self:cIdEmpre := cIdEmpre
Return
Method setVlReceb( nVlReceb) Class EFDCBLOCO1
	Self:nVlReceb := nVlReceb
Return
Method setRecFin( nRecFin) Class EFDCBLOCO1
	Self:nRecFin := nRecFin
Return
Method setDtRecol( dDtRecol) Class EFDCBLOCO1
	Self:dDtRecol := dDtRecol
Return
Method setCodRec( cCodRec) Class EFDCBLOCO1
	Self:cCodRec := cCodRec
Return

Method setTrib( cTrib) Class EFDCBLOCO1
	Self:cTrib := cTrib
Return

Method setIndAj(cIndAj) Class EFDCBLOCO1
	Self:cIndAj := cIndAj
Return

Method setVlTot(nVlTot) Class EFDCBLOCO1
	Self:nVlTot := nVlTot
Return

Method setVlCSt01(nVlCST01) Class EFDCBLOCO1
	Self:nVlCST01 := nVlCST01
Return

Method setVlCSt02(nVlCST02) Class EFDCBLOCO1
	Self:nVlCST02 := nVlCST02
Return

Method setVlCSt03(nVlCST03) Class EFDCBLOCO1
	Self:nVlCST03 := nVlCST03
Return

Method setVlCSt04(nVlCST04) Class EFDCBLOCO1
	Self:nVlCST04 := nVlCST04
Return

Method setVlCSt05(nVlCST05) Class EFDCBLOCO1
	Self:nVlCST05 := nVlCST05
Return

Method setVlCSt06(nVlCST06) Class EFDCBLOCO1
	Self:nVlCST06 := nVlCST06
Return

Method setVlCSt07(nVlCST07) Class EFDCBLOCO1
	Self:nVlCST07 := nVlCST07
Return

Method setVlCSt08(nVlCST08) Class EFDCBLOCO1
	Self:nVlCST08 := nVlCST08
Return

Method setVlCSt09(nVlCST09) Class EFDCBLOCO1
	Self:nVlCST09 := nVlCST09
Return

Method setVlCSt49(nVlCST49) Class EFDCBLOCO1
	Self:nVlCST49 := nVlCST49
Return

Method setVlCSt99(nVlCST99) Class EFDCBLOCO1
	Self:nVlCST99 := nVlCST99
Return

Method setIndAprop(cIndAprop) Class EFDCBLOCO1
	Self:cIndAprop := cIndAprop
Return

Method setRecibo(cRecibo) Class EFDCBLOCO1
	Self:cRecibo := cRecibo
Return

Method setRegRef(value) Class EFDCBLOCO1
	Self:cRegRef := value
Return

Method setCstPisS(value) Class EFDCBLOCO1
	Self:cCstPisS := value
Return

Method setCstCofS(value) Class EFDCBLOCO1
	Self:cCstCofS := value
Return

Method setBasPisS(value) Class EFDCBLOCO1
	Self:nBasPisS := value
Return

Method setBasCofS(value) Class EFDCBLOCO1
	Self:nBasCofS := value
Return

Method setAlqPisS(value) Class EFDCBLOCO1
	Self:nAlqPisS := value
Return

Method setAlqCofS(value) Class EFDCBLOCO1
	Self:nAlqCofS := value
Return

Method setValPisS(value) Class EFDCBLOCO1
	Self:nValPisS := value
Return

Method setValCofS(value) Class EFDCBLOCO1
	Self:nValCofS := value
Return

Method get1010(lMT) Class EFDCBLOCO1

Local nX 	:= 0
Local cDescr	:= ""
Default lMT	:= .F.

If !lMT
	//Ordena o array antes de obter os valores da exigibilidade suspensa do 1011
	ASORT(Self:aExigSusp,,,{|x,y|x[1]<y[1]})

	//Atualiza a descrição do registro 1010 conforme valor da exigibilidade suspensa
	For nX:= 1 to len(Self:aReg1010)
		//Somente atualiza se o processo for de exigibilidade suspensa
		IF Self:aReg1010[nX][6] $ "12/13/14/15/16/17/19"
			//Atualizo aqui a descrição do registo 1010 com os valores da exigibilidade suspensa do processo, que estão detalhados no registro 1011
			cDescr	:= GetDesc1010(Self:aReg1010[nX][1],Self:aExigSusp)
			Self:aReg1010[nX][7] := Iif(!Empty(cDescr), cDescr, Self:aReg1010[nX][7])
		EndIf
	Next nX
EndIF

Return Self:aReg1010

Method get1011() Class EFDCBLOCO1
Return Self:aReg1011

Method get1020() Class EFDCBLOCO1
Return Self:aReg1020

Method get1050() Class EFDCBLOCO1
Return Self:aReg1050

Method get1100() Class EFDCBLOCO1
Return Self:aReg1100

Method get1500() Class EFDCBLOCO1
Return Self:aReg1500

Method get1300() Class EFDCBLOCO1
Return Self:aReg1300

Method get1700() Class EFDCBLOCO1
Return Self:aReg1700

Method get1800() Class EFDCBLOCO1
Return Self:aReg1800

Method get1900() Class EFDCBLOCO1
Return Self:aReg1900

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1010()
@description Método que inclui novo registro 1010, considerando as informações
			   já passadas para objeto. Este registro terá informações de complemento
			   dos processos referenciados nos demais bloco da EFD Contribuições.
			   Aqui serão os detalhes das ações judiciais.
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1010() Class EFDCBLOCO1

Local nPos		:= 0

//-------------------------------------------------------------------
//Somente irá adicionar informação se não exisitr, caso já existir,
//a informação não será incluída, pois registro é em comum
//para todos os registros de processos referenciados da EFD
//-------------------------------------------------------------------
nPos := aScan (Self:aReg1010, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
								aX[3]==Self:cNumProc .AND. ;
								aX[4]==Self:cIdJur  .AND. ;
								aX[5]==Self:cIdVara  .AND. ;
								aX[6]==Self:cNatAcao .AND. ;
								aX[8]==Self:dDtDecisao})
If nPos == 0	
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '1010')
	aAdd (Self:aReg1010, {})
	nPos := Len(Self:aReg1010)	
	aAdd (Self:aReg1010[nPos], Self:cGrupoReg)  		//RELACIONAMENTO
	aAdd (Self:aReg1010[nPos], '1010')			   	//01 - REG
	aAdd (Self:aReg1010[nPos], Self:cNumProc)		//02 - NUM_PROC
	aAdd (Self:aReg1010[nPos], Self:cIdJur)		//03 - IND_SEC_JUD
	aAdd (Self:aReg1010[nPos], Self:cIdVara)		//04 - IND_VARA
	aAdd (Self:aReg1010[nPos], Self:cNatAcao)		//05 - IND_NAT_ACAO
	aAdd (Self:aReg1010[nPos], Self:cDescr)		//06 - DESC_DEC_JUDs
	aAdd (Self:aReg1010[nPos], Self:dDtDecisao) 	//07 - DT_SENT_JUD 
Else
	Self:cGrupoReg	:= Self:aReg1010[nPos][1]
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1011()
@description Método que adiciona novo registro 1011. Este registro terá 
		     informações do detalhamento das Contribuições com Exigibilidade Suspensa
@author Erick G. Dias
@since 08/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
METHOD Add1011() Class EFDCBLOCO1

Local nPos		:= 0
Local nPosExi	:= 0

//Verifica se já existe registro 1011 para as informações enviadas para a classe
nPos := aScan(Self:aReg1011, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;  //Relacionamento
								   aX[3]  == Self:cRegRef    .And. ; //Registro referenciado
								   aX[4]  == Self:cnChaveNfe .And. ; //Chave da nota
								   aX[5]  == Self:cnCodPart  .And. ; // código do participante
								   aX[6]  == Self:ciCodItem  .And. ; // código do produto
								   aX[9]  == Self:ciCSTPis   .And. ; // cst de pis
								   cValToChar(aX[11][1]) == cValToChar(Self:niAlqPis) .And.; // Alíquota de PIS
								   aX[13] == Self:ciCSTCof   .And. ;  // CST de COFINS
								   cValToChar(aX[15][1]) == cValToChar(Self:niAlqCof) .And.; // Alíquota de COFINS
								   aX[25] == Self:cContaCtb .And. ; // Conta Contábil 
								   aX[26] == Self:ciCCusto  }) //Centro de Custo	

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, "1011")
	aAdd(Self:aReg1011,{})
	nPos := Len(Self:aReg1011)
	aAdd(Self:areg1011[nPos], Self:cGrupoReg)
	aAdd(Self:aReg1011[nPos], '1011')//01-REG
	aAdd(Self:aReg1011[nPos], Self:cRegRef)//02-REG_REF
	aAdd(Self:aReg1011[nPos], Self:cnChaveNfe)//03-CHAVE_DOC
	aAdd(Self:aReg1011[nPos], Self:cnCodPart)//04-COD_PART
	aAdd(Self:aReg1011[nPos], Self:ciCodItem)//05-COD_ITEM
	aAdd(Self:aReg1011[nPos], Self:dnEmissao)//06-DT_OPER
	//aAdd(Self:aReg1011[nPos], Self:niValItem)//07-VL_OPER	
	aAdd(Self:aReg1011[nPos], 0)//07-VL_OPER	// Atualizado 1 vez por Item
	aAdd(Self:aReg1011[nPos], Self:ciCSTPis)//08-CST_PIS
	aAdd(Self:aReg1011[nPos], {0,4})//09-VL_BC_PIS	
	aAdd(Self:aReg1011[nPos], {Self:niAlqPis,4})//10-ALIQ_PIS
	aAdd(Self:aReg1011[nPos], 0)//11-VL_PIS
	aAdd(Self:aReg1011[nPos], Self:ciCSTCof )//12-CST_COFINS
	aAdd(Self:aReg1011[nPos], {0,4})//13-VL_BC_COFINS
	aAdd(Self:aReg1011[nPos],  {Self:niAlqCof,4} )//14-ALIQ_COFINS
	aAdd(Self:aReg1011[nPos], 0)//15-VL_COFINS
	aAdd(Self:aReg1011[nPos], Self:cCstPisS)//16-CST_PIS_SUSP
	aAdd(Self:aReg1011[nPos], {0,4})//17-VL_BC_PIS_SUSP
	aAdd(Self:aReg1011[nPos], {0,4})//18-ALIQ_PIS_SUSP
	aAdd(Self:aReg1011[nPos], 0)//19-VL_PIS_SUSP
	aAdd(Self:aReg1011[nPos], Self:cCstCofS)//20-CST_COFINS_SUSP
	aAdd(Self:aReg1011[nPos], {0,4})//21-VL_BC_COFINS_SUSP
	aAdd(Self:aReg1011[nPos], {0,4})//22-ALIQ_COFINS_SUSP
	aAdd(Self:aReg1011[nPos], 0)//23-VL_COFINS_SUSP
	aAdd(Self:aReg1011[nPos], Self:cContaCtb )//24-COD_CTA 
	aAdd(Self:aReg1011[nPos], Self:ciCCusto)//25-COD_CCUS
	aAdd(Self:aReg1011[nPos], Self:cnInfCmp)//26-DESC_DOC_OPER

EndIF	

//Aqui criei o registro que terá o valor total de PIS e COFINS da exigibilidade suspensa totalizadas por processo e código de receita da DCTF
nPosExi := aScan(Self:aExigSusp, {|aX| Alltrim(aX[1])  == Alltrim(Self:cRelac) .AND. Alltrim(aX[2])== Alltrim(Self:cCodRec) }) //Chave de relacionamento entre 1010 e 1011
If nPosExi == 0	
	aAdd(Self:aExigSusp,{})
	nPosExi := Len(Self:aExigSusp)
	aAdd(Self:aExigSusp[nPosExi], Self:cRelac) //Relacionamento 
	aAdd(Self:aExigSusp[nPosExi], Self:cCodRec) //Código de receita
	aAdd(Self:aExigSusp[nPosExi], 0) //Valor
EndIF

If Self:cTrib == "7"
	//Processo informações do PIS
	Self:areg1011[nPos][8]	+= Self:niValItem //07-VL_OPER // Atualizado 1 vez por Item
	Self:areg1011[nPos][9]		:= Self:ciCSTPis //08-CST_PIS 
	Self:areg1011[nPos][10][1]	+= Self:niBasePis //09-VL_BC_PIS	
	Self:areg1011[nPos][11][1]	:= Self:niAlqPis //10-ALIQ_PIS
	Self:areg1011[nPos][12]	+= Self:niValPis //11-VL_PIS
	
	If Self:cCstPisS $ "04/05/07/08/09/49"
		//Suspensão integral, logo o valor e alíquota no 1011 será zerado.			
		
		//Aqui devo acumular o valor por código de receita e processo, para ser utilizado na descrição no registro 1010 pai do 1011
		Self:aExigSusp[nPosExi][3] += Self:nValPisS
	ElseIf Self:cCstPisS $ "06"
		//Aqui teremos somente a base de cálculo preenchida
		Self:areg1011[nPos][18][1]	+= Self:nBasPisS //17-VL_BC_PIS_SUSP
		//Aqui devo acumular o valor por código de receita e processo, para ser utilizado na descrição no registro 1010 pai do 1011
		Self:aExigSusp[nPosExi][3] += Self:nValPisS
	Else
		//Para os demais CST gera base, alíquota e valor
		Self:areg1011[nPos][18][1]	+=Self:nBasPisS //17-VL_BC_PIS_SUSP
		Self:areg1011[nPos][19][1]	:= Self:nAlqPisS //18-ALIQ_PIS_SUSP
		Self:areg1011[nPos][20]	+= Self:nValPisS //19-VL_PIS_SUSP
		
		//Aqui devo acumular o valor por código de receita e processo, para ser utilizado na descrição no registro 1010 pai do 1011
		Self:aExigSusp[nPosExi][3] += (Self:niValPis - Self:nValPisS) 
	EndIF	

ElseIf Self:cTrib == "8"
	//Processo informações da COFINS
	Self:areg1011[nPos][13] :=  Self:ciCSTCof //12-CST_COFINS
	Self:areg1011[nPos][14][1] +=  Self:niBaseCof //13-VL_BC_COFINS
	Self:areg1011[nPos][15][1] :=  Self:niAlqCof //14-ALIQ_COFINS
	Self:areg1011[nPos][16] +=  Self:niValCof //15-VL_COFINS	
	
	If Self:cCstCofS $ "04/05/07/08/09/49"
		//Suspensão integral, logo o valor e alíquota no 1011 será zerado.			
		//Aqui devo acumular o valor por código de receita e processo, para ser utilizado na descrição no registro 1010 pai do 1011
		Self:aExigSusp[nPosExi][3] +=   Self:nValCofS
	ElseIf Self:cCstCofS $ "06"
		//Aqui teremos somente a base de cálculo preenchida
		Self:areg1011[nPos][22][1] +=  Self:nBasCofS //21-VL_BC_COFINS_SUSP
		
		//Aqui devo acumular o valor por código de receita e processo, para ser utilizado na descrição no registro 1010 pai do 1011
		Self:aExigSusp[nPosExi][3] += Self:nValCofS
	Else
		Self:areg1011[nPos][22][1] +=  Self:nBasCofS //21-VL_BC_COFINS_SUSP
		Self:areg1011[nPos][23][1] :=  Self:nAlqCofS //22-ALIQ_COFINS_SUSP
		Self:areg1011[nPos][24] +=  Self:nValCofS //23-VL_COFINS_SUSP
	
		//Aqui devo acumular o valor por código de receita e processo, para ser utilizado na descrição no registro 1010 pai do 1011
		Self:aExigSusp[nPosExi][3] += ( Self:niValCof -  Self:nValCofS	)
	EndIF	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1020()
@description Método que inclui novo registro 1020, considerando as informações
			   já passadas para objeto. Este registro terá informações de complemento
			   dos processos referenciados nos demais bloco da EFD Contribuições.
			   Aqui serão os detalhes das ações administrativas.
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1020() Class EFDCBLOCO1

Local nPos		:= 0

//-------------------------------------------------------------------
//Somente irá adicionar informação se não exisitr, caso já existir,
//a informação não será incluída, pois registro é em comum
//para todos os registros de processos referenciados da EFD
//-------------------------------------------------------------------
nPos := aScan (Self:aReg1020, {|aX| aX[1]== Self:cRelac 	.AND. ;  
								aX[3]==Self:cNumProc .AND. ;
								aX[4]==Self:cNatAcao  .AND. ;
								aX[5]==Self:dDtDecisao})	
If nPos == 0		
	aAdd (Self:aReg1020, {})
	nPos := Len(Self:aReg1020)	
	aAdd (Self:aReg1020[nPos], Self:cRelac)  		//RELACIONAMENTO
	aAdd (Self:aReg1020[nPos], '1020')				   	//01 - REG
	aAdd (Self:aReg1020[nPos], Self:cNumProc)			//02 - NUM_PROC
	aAdd (Self:aReg1020[nPos], Self:cNatAcao)			//03 - IND_NAT_ACAO
	aAdd (Self:aReg1020[nPos], Self:dDtDecisao)     	//04 - DT_DEC_ADM
EndIf  

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1050()

Método para gerar informações do registo 1050....ainda não sabemos
critérios para geração, por hora este método apenas gera um registro
hipotético, para testarmos no evento na Serpro, quando soubermos
as regras de validaçõe e geração o registro será de fato implementado

@author Erick G. Dias
@since 01/11/2018
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1050() Class EFDCBLOCO1

Local nPos		:= 0

nPos := aScan (Self:aReg1050, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;  
								aX[4]==Self:cIndAj .AND. ;
								aX[5]==Self:cCnpj  .AND. ;
								aX[19]==Self:cRecibo})	
If nPos == 0		
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, "1050")
	aAdd (Self:aReg1050, {})
	nPos := Len(Self:aReg1050)	
	aAdd (Self:aReg1050[nPos], Self:cGrupoReg) 		//RELACIONAMENTO
	aAdd (Self:aReg1050[nPos], '1050')				//01 - REG
	aAdd (Self:aReg1050[nPos], Self:dPerApu)		//02 - DT_REF
	aAdd (Self:aReg1050[nPos], Self:cIndAj)			//03 - IND_AJ_BC
	aAdd (Self:aReg1050[nPos], Self:cCnpj)			//04 - CNPJ
	aAdd (Self:aReg1050[nPos], Self:nVlTot)			//05 - VL_AJ_TOT
	aAdd (Self:aReg1050[nPos], Self:nVlCST01)		//06 - VL_AJ_CST01
	aAdd (Self:aReg1050[nPos], Self:nVlCST02)		//07 - VL_AJ_CST02
	aAdd (Self:aReg1050[nPos], Self:nVlCST03)		//08 - VL_AJ_CST03
	aAdd (Self:aReg1050[nPos], Self:nVlCST04)		//09 - VL_AJ_CST04
	aAdd (Self:aReg1050[nPos], Self:nVlCST05)		//10 - VL_AJ_CST05
	aAdd (Self:aReg1050[nPos], Self:nVlCST06)		//11 - VL_AJ_CST06
	aAdd (Self:aReg1050[nPos], Self:nVlCST07)		//12 - VL_AJ_CST07
	aAdd (Self:aReg1050[nPos], Self:nVlCST08)		//13 - VL_AJ_CST08
	aAdd (Self:aReg1050[nPos], Self:nVlCST09)		//14 - VL_AJ_CST09
	aAdd (Self:aReg1050[nPos], Self:nVlCST49)		//15 - VL_AJ_CST49
	aAdd (Self:aReg1050[nPos], Self:nVlCST99)		//16 - VL_AJ_CST99
	aAdd (Self:aReg1050[nPos], Self:cIndAprop)		//17 - IND_APROP
	aAdd (Self:aReg1050[nPos], Self:cRecibo)		//18 - NUM_REC
	aAdd (Self:aReg1050[nPos], Self:cInfComp)		//19 - INFO_COMPL
Else
	Self:aReg1050[nPos][6]	+= Self:nVlTot
	Self:aReg1050[nPos][7]  += Self:nVlCST01
	Self:aReg1050[nPos][8]  += Self:nVlCST02
	Self:aReg1050[nPos][9]  += Self:nVlCST03
	Self:aReg1050[nPos][10] += Self:nVlCST04
	Self:aReg1050[nPos][11] += Self:nVlCST05
	Self:aReg1050[nPos][12] += Self:nVlCST06
	Self:aReg1050[nPos][13] += Self:nVlCST07
	Self:aReg1050[nPos][14] += Self:nVlCST08
	Self:aReg1050[nPos][15] += Self:nVlCST09
	Self:aReg1050[nPos][16] += Self:nVlCST49
	Self:aReg1050[nPos][17] += Self:nVlCST99

EndIf  

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1100()
@description Método que irá gerar registro 1100 através do método Add11001500

@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1100() Class EFDCBLOCO1

Self:Add11001500('1100', Self:aReg1100)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1500()
@description Método que irá gerar registro 1500 através do método Add11001500

@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1500() Class EFDCBLOCO1

Self:Add11001500('1500', Self:aReg1500)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add11001500()
@description Método que inclui novo registro 1100 e 1500, considerando as informações
			   já passadas para objeto. Estes registros tratam do saldo de crédito de PIS
			   e COFINS, com valores a transportar para próximos períodos, bem como
			   valores de períodos anteriores utilizados no período atual. Ambos registros
			   possuem mesma estrutura, por este motivo serão tratados no mesmo método.
@param cReg,String,Tem o conteúdo do registro que deverá ser gerado
@param aReg,Array,Array do registro 1100 ou 1500 que deverá ser gravada informação
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add11001500(cReg, aReg) Class EFDCBLOCO1

Local nPos		:= 0

nPos := aScan (aReg, {|aX| aX[1]== Self:cRelac 	.AND. ;
    						  aX[3]==Self:dPerApu .AND.;
							  ax[4] == Self:cOriCrd  .AND. ;
							  ax[5] == Self:cCnpj .AND. ;
							  ax[6] == Self:cCodCrd})

If nPos ==0 
	aAdd(aReg, {})
	nPos := Len(aReg)	
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd (aReg[nPos], Self:cGrupoReg)		//Relacionamento
	aAdd (aReg[nPos], cReg)				//01 - REG
	aAdd (aReg[nPos], Self:dPerApu)		//02 - PER_APU_CRED
	aAdd (aReg[nPos], Self:cOriCrd)		//03 - ORIG_CRED
	aAdd (aReg[nPos], Self:cCnpj)		//04 - CNPJ_SUC
	aAdd (aReg[nPos], Self:cCodCrd)		//05 - COD_CRED
	aAdd (aReg[nPos], Self:nTotApur)	//06 - VL_CRED_APU
	aAdd (aReg[nPos], Self:nCrdExt)		//07 - VL_CRED_EXT_APU	
	aAdd (aReg[nPos], Self:nCrdApu)		//08 - VL_TOT_CRED_APU
	aAdd (aReg[nPos], Self:nCrdAnt)		//09 - VL_CRED_DESC_PA_ANT
	aAdd (aReg[nPos], Self:nVlRes)		//10 - VL_CRED_PER_PA_ANT
	aAdd (aReg[nPos], Self:nVlCom)		//11 - VL_CRED_DCOMP_PA_ANT	
	aAdd (aReg[nPos], Self:nVlDisp)		//12 - SD_CRED_DISP_EFD
	aAdd (aReg[nPos], Self:nVlDesc)		//13 - VL_CRED_DESC_EFD	
	aAdd (aReg[nPos], Self:nVlPedRes)	//14 - VL_CRED_PER_EFD
	aAdd (aReg[nPos], Self:nVlPedCom)	//15 - VL_CRED_DCOMP_EFD
	aAdd (aReg[nPos], Self:nVlTranf)	//16 - VL_CRED_TRANS
	aAdd (aReg[nPos], Self:nVlUtOut)	//17 - VL_CRED_OUT
	aAdd (aReg[nPos], Self:nSldCrd)		//18 - SLD_CRED_FIM
Else
	aReg[nPos][7]		+= Self:nTotApur		//06 - VL_CRED_APU
	aReg[nPos][8]		+= Self:nCrdExt		//07 - VL_CRED_EXT_APU	
	aReg[nPos][9]		+= Self:nCrdApu		//08 - VL_TOT_CRED_APU
	aReg[nPos][10]		+= Self:nCrdAnt		//09 - VL_CRED_DESC_PA_ANT
	aReg[nPos][11]	+= Self:nVlRes		//10 - VL_CRED_PER_PA_ANT
	aReg[nPos][12]	+= Self:nVlCom		//11 - VL_CRED_DCOMP_PA_ANT	
	aReg[nPos][13]	+= Self:nVlDisp		//12 - SD_CRED_DISP_EFD
	aReg[nPos][14]	+= Self:nVlDesc		//13 - VL_CRED_DESC_EFD	
	aReg[nPos][15] 	+= Self:nVlPedRes		//14 - VL_CRED_PER_EFD
	aReg[nPos][16] 	+= Self:nVlPedCom		//15 - VL_CRED_DCOMP_EFD
	aReg[nPos][17] 	+= Self:nVlTranf		//16 - VL_CRED_TRANS
	aReg[nPos][18] 	+= Self:nVlUtOut		//17 - VL_CRED_OUT
	aReg[nPos][19] 	+= Self:nSldCrd		//18 - SLD_CRED_FIM

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1300()
@description Método que irá gerar registro 1300 através do método Add13001700
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1300() Class EFDCBLOCO1

Self:Add13001700('1300', Self:aReg1300)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1700()
@description Método que irá gerar registro 1700 através do método Add13001700
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1700() Class EFDCBLOCO1

Self:Add13001700('1700', Self:aReg1700)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add13001700()
@description Método que inclui novo registro 1300 e 1700, considerando as informações
			   já passadas para objeto. Estes registros tratam do saldo de retenção na fonte
			    de PIS e COFINS, com valores a transportar para próximos períodos, bem como
			   valores de períodos anteriores utilizados no período atual. Ambos registros
			   possuem mesma estrutura, por este motivo serão tratados no mesmo método.
@param cReg,String,Tem o conteúdo do registro que deverá ser gerado
@param aReg,Array,Array do registro 1300 ou 1700 que deverá ser gravada informação
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add13001700(cReg, aReg) Class EFDCBLOCO1

Local nPos	:= 0
nPos := aScan (aReg, {|aX| aX[1]== Self:cRelac 	.AND. ;
							  aX[3] ==Self:cNatRet  .AND.;
						      ax[4] == Self:cPerRet })
If nPos ==0
	aAdd(aReg, {})
	nPos := Len(aReg)
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, cReg)
	aAdd (aReg[nPos],  Self:cGrupoReg)		//Relacionamento
	aAdd (aReg[nPos], cReg)				//01 - REG
	aAdd (aReg[nPos], Self:cNatRet)		//02 - IND_NAT_RET
	aAdd (aReg[nPos], Self:cMesAno )	//03 - PR_REC_RET
	aAdd (aReg[nPos], Self:nTotRet)		//04 - VL_RET_APU	
	aAdd (aReg[nPos], Self:nRetDed) 	//05 - VL_RET_DED
	aAdd (aReg[nPos], Self:nRetRes)		//06 - VL_RET_PER
	aAdd (aReg[nPos], Self:nRetCom)		//07 - VL_RET_DCOMP
	aAdd (aReg[nPos], Self:nSldRet)		//08 - SLD_RET    
Else    
	aReg[nPos][5] += Self:nTotRet	 //04 - VL_RET_APU	
	aReg[nPos][6] += Self:nRetDed	 //05 - VL_RET_DED
	aReg[nPos][7] += Self:nRetRes	 //06 - VL_RET_PER
	aReg[nPos][8] += Self:nRetCom	 //07 - VL_RET_DCOMP
    aReg[nPos][9] += Self:nSldRet   //08 - SLD_RET     
	 
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1800()
@description Método que inclui o registro 1800, que trata dos valores de
			   incoporação Imobiliária - RET
@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1800() Class EFDCBLOCO1

Local nPos	:= 0

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '1800')
aAdd(Self:aReg1800, {})
nPos := Len(Self:aReg1800)
aAdd (Self:aReg1800[nPos], Self:cGrupoReg)			//Relacionamento
aAdd (Self:aReg1800[nPos], '1800')					//01-Registro
aAdd (Self:aReg1800[nPos], Self:cIdEmpre)			//02-INC_IMOB
aAdd (Self:aReg1800[nPos], Self:nVlReceb)			//03-REC_RECEB_RET
aAdd (Self:aReg1800[nPos], Self:nRecFin)			//04-REC_FIN_RET
aAdd (Self:aReg1800[nPos], Self:niBasePis)		//05-BC_RET
aAdd (Self:aReg1800[nPos], Self:niAlqPis)			//06-ALIQ_RET
aAdd (Self:aReg1800[nPos], Self:niValPis)			//07-VL_REC_UNI
aAdd (Self:aReg1800[nPos], Self:dDtRecol)			//08-DT_REC_UNI
aAdd (Self:aReg1800[nPos], Self:cCodRec)			//09-COD_REC

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Add1900()
@description Método que inclui novo registro 1900, considerando as informações
			   já passadas para objeto. Este registro irá demonstrar detalhamento 
			   das receitas, para os contribuintes enquadrados no lucro presumido,
			   gerando apuração no regime de caixa ou competência.
@author Erick G. Dias
@since 23/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1900(lAgrp1900) Class EFDCBLOCO1

Local nPos	:= 0
Default lAgrp1900	:= .F.

lAgrp1900 := (lAgrp1900 .and. !Self:cModelo$'01|1B|04|06|55|59')

If lAgrp1900 
	nPos := aScan (Self:aReg1900, {|aX| aX[3]==Self:cCnpj .AND. ;
															 aX[4]==Self:cModelo .And. ;
															 aX[7]==Self:cSitDoc })
		
Else														 
	nPos := aScan (Self:aReg1900, {|aX| aX[3]==Self:cCnpj .AND. ;
													 aX[4]==Self:cModelo .AND. ;
													 aX[5]==Self:cSerie .AND. ;
													 aX[7]==Self:cSitDoc .AND. ;
													 aX[10]==Self:ciCSTPis .AND. ;
										    		 aX[11]==Self:ciCSTCof .AND. ;
										    		 aX[12]==Self:ciCFOP .AND. ;
										    		 aX[13]==Self:cInfComp .AND. ;							    		 
										    		 aX[14]==Self:cContaCtb})
Endif	    
	
If nPos == 0
	aAdd(Self:aReg1900, {})
	nPos := Len(Self:aReg1900)
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, '1900')
	aAdd (Self:aReg1900[nPos], Self:cGrupoReg)				//01-Registro
	aAdd (Self:aReg1900[nPos], '1900')				//01-Registro
	aAdd (Self:aReg1900[nPos], Self:cCnpj)			//02-CNPJ
	aAdd (Self:aReg1900[nPos], Self:cModelo)   	//03-COD_MOD
	aAdd (Self:aReg1900[nPos], iif(lAgrp1900,'',Self:cSerie))		//04-SER
	aAdd (Self:aReg1900[nPos], '')   				//05-SUB_SER
	aAdd (Self:aReg1900[nPos], Self:cSitDoc)   	//06-COD_SIT
	aAdd (Self:aReg1900[nPos], Self:nVlRec)    	//07-VL_TOT_REC
	aAdd (Self:aReg1900[nPos], Self:cQtdNf)   	//08-QUANT_DOC
	aAdd (Self:aReg1900[nPos], iif(lAgrp1900,'',Self:ciCSTPis))   	//09-CST_PIS
	aAdd (Self:aReg1900[nPos], iif(lAgrp1900,'',Self:ciCSTCof))  	//10-CST_COFINS
	aAdd (Self:aReg1900[nPos], iif(lAgrp1900,'',Self:ciCFOP))  		//11-CFOP
	aAdd (Self:aReg1900[nPos], iif(lAgrp1900,'',Self:cInfComp))  	//12-INF_COMPL
	aAdd (Self:aReg1900[nPos], iif(lAgrp1900,'',Self:cContaCtb))  	//13-COD_CTA
Else
	Self:aReg1900[nPos][8]	+= Self:nVlRec	   //07-VL_TOT_REC	
	//A informação de quantidade de documentos será apenas atualizada, pois é um campo caractere, porém que necessita ser alterado.
	//Caso a informação não precise ser alterada não deverá ser passada informação através do set da quantidade da nota fiscal.	
	Self:aReg1900[nPos][9]	:= cValtoChar(val(Self:aReg1900[nPos][9]) + val(Self:cQtdNf)) //08-QUANT_DOC	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProcRef()
@description Método que inclui novo registros I199, I299 e  I399.
			   Todos relacionados com processo referenciado.			   			  
@author Erick G. Dias
@since14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddProcRef(cReg) Class EFDCBLOCO1

If cReg == '1809'	
	Self:ProcRef('1809',@Self:aReg1809)
EndIF
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1001(cIndMovto) Class EFDCBLOCO1

Self:AbreBloco('1001',@Self:aReg1001,cIndMovto)

Return Self:aReg1001

//-------------------------------------------------------------------
/*/{Protheus.doc} Add1990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Add1990(nQtde) Class EFDCBLOCO1

Self:FechaBloco('1990',@Self:aReg1990, nQtde) 

Return Self:aReg1990


//-------------------------------------------------------------------
/*/{Protheus.doc} cls1100()
@description Método que limpa variáveis do 1100
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD cls1100() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1100	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cls1010()
@description Método que limpa variáveis do 1010
@author Mauro A. Gonçalves
@since 13/18/2015
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD cls1010() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1010	:= {}

Return

METHOD cls1011() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1011	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cls1020()
@description Método que limpa variáveis do 1020
@author Mauro A. Gonçalves
@since 13/18/2015
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD cls1020() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1020	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cls1300()
@description Método que limpa variáveis do 1300
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD cls1300() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1300	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cls1500()
@description Método que limpa variáveis do 1100
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD cls1500() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1500	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cls1700()
@description Método que limpa variáveis do 1100
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD cls1700() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1700	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cls1800()
@description Método que limpa variáveis do 1300
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD cls1800() Class EFDCBLOCO1

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aReg1800	:= {}

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesc1010()
Função que obtem o total dos valores da exigibilidae suspensa do processo
para compor o campo de descrição do registro 1010
@author Erick G. Dias
@since 28/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function GetDesc1010(cChavePai,aExigSusp)

Local cDesc1010	:= ""
Local nX		:= 0
Local nPos		:= 0

//Obtem a posição do registro 1010 conforme chave do registro pai 1010
nPos := aScan(aExigSusp, {|aX| Substr(aX[1],1,Len(cChavePai))== cChavePai })

//Percorre o array com valores de PIS e COFINS com exigibilidade suspensa e monta a descrição 
If nPos > 0
	For nX	:= nPos to Len(aExigSusp)		
		If Substr(aExigSusp[nX][1],1,Len(cChavePai)) == cChavePai
			//Obter o código da receita e valor			
			If!Empty(aExigSusp[nX][2])
				cDesc1010 += aExigSusp[nX][2] + "=R$" + Alltrim(TRANSFORM(aExigSusp[nX][3] ,"@E 999,99,999,999.99")) + " "
			EndIF
		Else
			//Como o array está ordenada eu posso sair do loop quando se tratar de informações de outro processo
			Exit
		EndIf
	Next nX
EndIF

Return cDesc1010
