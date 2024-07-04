#Include 'Protheus.ch'
#Include 'totvs.ch'


Function FISA105(); RETURN
    
    /*CLASSes do bloco 5*/ 

//-------------------------------------------------------------------
/*/{Protheus.doc} BLOCO5
 
Classe de Geração do Bloco 5
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------       
CLASS BLOCO5 FROM CAT83
    
    /*ATRIBUTOS REFERENTE A BLOCO5 DAS FICHAS*/
    Data cReg			as String		 READONLY				/*Registro correpondente*/
    Data cCodItem		as String		 READONLY				/*Produto, Serviço, Energia, Insumo, Material ou prod em elaboração*/
    
    /*Abertura*/
    Data nQtdIni		as Integer		 READONLY				/*Saldo Inicial de quantidade do item*/
    Data nCustIni		as Integer		 READONLY				/*Saldo Inicial do valor de custo do item*/
    Data nICMSIni		as Integer		 READONLY				/*Saldo Inicial do valor de ICMS do item*/
    Data nQtdFim		as Integer		 READONLY				/*Saldo Final de quantidade do item*/
    Data nCustFim		as Integer		 READONLY				/*Saldo Final do valor de custo do item*/
    Data nICMSFim		as Integer		 READONLY				/*Saldo Final do valor de ICMS do item*/
    Data nCustUnt		as Integer		 READONLY				/*Custo Unitário do produto*/
    Data nICMSUnt		as Integer		 READONLY				/*Valor unitário de ICMS*/
    Data nQtdPer		as Integer		 READONLY				/*Quantidade no periodo*/
    
    /*Movimentação*/
    Data nNumLan		as Integer     READONLY
    Data dDtMov		as Date        READONLY
    Data cHist		as String      READONLY
    Data nTpDoc		as Integer     READONLY
    Data cSerie		as String      READONLY
    Data cNumDoc		as String      READONLY
    Data nCFOP		as Integer     READONLY
    Data cNumDI		as Integer     READONLY
    Data cCodPar		as String      READONLY
    Data nCodLan		as Integer     READONLY
    Data nIndMov		as Integer     READONLY
    Data cCodProd	   as String 		 READONLY
    Data cProdMov    as String      READONLY
    Data nQuant		as Integer 	 READONLY
    Data nCusto		as Integer 	 READONLY
    Data nValICMS		as Integer 	 READONLY
    Data nPercRat		as Integer   	 READONLY
    Data nValOTri		as Integer 	 READONLY
    Data cCodRem		as String 		 READONLY
    Data cCodDes		as String 		 READONLY
    Data cUFInic		as String 		 READONLY
    Data cUFDest		as String 		 READONLY
    Data cCodTom		as String 		 READONLY
    Data nAliq		as Integer 	 READONLY
    Data nPerCO		as Integer		 READONLY		/*Percentual de Crédito Outorgado relativo ao item PERC_CRDOUT*/
    Data nValCO		as Integer		 READONLY		/*Valor de Crédito Outorgado relativo ao item VALOR_CRDOUT*/
    Data nValDesp		as Integer		 READONLY		/*Valor de Crédito - Despesas Operacionais VALOR_DESP*/
    Data nQtdRes		as Integer		 READONLY		/*Quantidade do material resultante QTD_MAT_RES*/
    Data nValSRes		as Integer		 READONLY		/*Valor de saída do material resultante VLR_MAT_RES*/
    Data nOrdem		as Integer		 READONLY		/*Número da Ordem*/
    Data nQTDMatRes	as Integer		 READONLY		/*Quantidade de Material resultante*/
    Data nValMatRes	as Integer		 READONLY		/*Valor de Saída do Material resultante*/
    Data nKm         as Integer     READONLY             //Distância percorrida
    Data nEnqleg     as Integer     READONLY             //Código do Enquadramento Legal conforme registro 0300
    Data nVprege     as Integer     READONLY
    Data nVprest     as Integer     READONLY             //Valor da Prestação
    Data nIcmdeb     as Integer     READONLY             //Valor do ICMS debitado pelo transportador na prestação
    Data nIndrat     as Integer     READONLY             //Índice de Rateio
    Data nUcusto     as Integer     READONLY             //Valor do custo de cada serviço de transporte prestado.
    Data nUicms      as Integer     READONLY             //Valor do ICMS referente ao custo de cada serviço de transporte prestado
    Data nCredAc     as Integer     READONLY             //Valor do Crédito Acumulado gerado na prestação
    Data nVpreng     as Integer     READONLY             //Nas prestações não geradoras de crédito acumulado, indicar oValor Total da Prestação.
    Data nIcmst      as Integer     READONLY             //Indique o valor do ICMS devido pelo contribuinte substituto para fins de cálculo do Crédito Outorgado (Transportadora com opção regular).
    Data nVcrout     as Integer     READONLY             //Valor do Crédito Outorgado relativo à prestação própria.
    Data nCroust     as Integer     READONLY             //Valor do Crédito Outorgado relativo à prestação cujo pagamento do imposto está atribuído ao tomador do serviço (substituição tributária).
    Data nVeicul     as Integer     READONLY              //Código de IdentIFicação do principal Veículo Rodoviário Transportador conforme registro 5725.
    Data nIcmsde     as Integer     READONLY              //Valor do ICMS devido na prestação própria
    
    /*Atributos Referente a IPI e outros Tributos na Entrada*/
    Data nValIpi    as Integer      READONLY			/*Valor do IPI quando recuperavel*/
    Data nValTri    as Integer      READONLY			/*Valor de Outros tributos e contribuições não-cumulativos*/
    
    /*Atributos Referente a Apuração de Custo das Fichas*/
    Data cProdAcab  as String       READONLY		/*Produto – Acabado*/
    Data cProdIns   as String       READONLY		/*Produto – Insumo */
    Data cUnidad    as String       READONLY		/*Unidade */
    Data nQtdConcl  as Integer      READONLY		/*Quantidade de produto conCLWída no período */
    Data nQtdInsUt  as Integer      READONLY		/*Quantidade do insumo utilizada */
    Data nQtInsUtUn as Integer      READONLY		/*Quantidade do insumo utilizada por unidade de produto */
    Data nCusUntIns as Integer      READONLY		/*Custo Unitário do insumo */
    Data nCustTotUn as Integer      READONLY		/*Custo Total do insumo por unidade de produto */
    Data nVUntICMIn as Integer      READONLY		/*Valor Unitário do ICMS do insumo */
    Data nVTotInsUn as Integer      READONLY		/*Valor Total do ICMS do insumo por unidade de produto */
    Data nPerdaNorm as Integer      READONLY		/*Perda Normal*/
    Data nGanhoNorm as Integer      READONLY		/*Ganho Normal*/
    Data cCoProd    as String       READONLY      /*Código do co-produto, conforme Registro 0200*/
    Data nQtdCoPr   as Integer      READONLY      /*Quantidade de Co-Produto resultante do Insumo conjunto no período.*/
    Data nPrcMed    as Integer      READONLY      /*Preço Médio de Saída do Co-Produto*/
    Data nVlPrjS    as Integer      READONLY      /*Valor Projetado das Saídas*/
    Data nPercAlc   as Integer      READONLY      /*Percentual de alocação do custo e ICMS do insumo-conjunto para o co-produto obtido na coluna 5 da Ficha 4B*/
    
    /*Atrubutos Referente a Devolução de Saída*/
    Data dDtSai     as Date         READONLY		/*Data da emissão do documento fiscal que acobertou a operação original do item devolvido*/
    Data nTipDocDev as Integer      READONLY		/*Tipo do documento conforme a coluna Código chave da tabela 4.2 ou campo 02 do registro 0400*/
    Data cSerieDev  as String       READONLY		/*Série do documento que acobertou a operação original*/
    Data cDocDev    as String       READONLY		/*Número do documento que acobertou a operação original*/
    
    /*Atributos referente a operações de crédito acumulado*/
    Data nCodLeg    as Integer		 READONLY		/*Código do Enquadramento Legal*/
    Data nVlOpIt    as Integer		 READONLY		/*Valor Total da Operação relativo ao Item*/
    Data nCredA     as Integer		 READONLY		/*Credito acumulado Gerado na Operação com o Item*/
    Data nBCIt      as Integer		 READONLY		/*Base de Cálculo da Operação de saída relativa ao item*/
    Data nAlqIt     as Integer		 READONLY		/*Alíquota de ICMS da Operação de saída relativa ao Item*/
    Data nICMDb     as Integer		 READONLY		/*Icms debitado na operação de saída do item*/
    Data nICMDev    as Integer		 READONLY		/*Icms devido na operação de saída relativo ao item*/
    Data nDecEx     as Integer		 READONLY		/*Número da Declaração para Despacho*/
    Data nCompOp    as Integer		 READONLY		/*Comprovação de Operação*/
    Data nVlCrICM   as Integer		 READONLY		/*Valor do Crédito de ICMS*/
    
    /*Atributos Exportação Indireta Comprovada*/
    Data dPeriod    as Date         READONLY		/*Período*/
    Data cProd      as String       READONLY		/*Produto (Mercadoria)*/
    Data nNLanc     as Integer      READONLY		/*Número do Lançamento*/
    Data cDoc       as String       READONLY		/*Número do Documento Fiscal de Remessa*/
    Data cSerRem    as String       READONLY		/*Série do Documento Fiscal de Remessa*/
    Data dDtExp     as Date         READONLY		/*Data do Documento Fiscal do Exportador*/
    Data cDocExp    as String       READONLY		/*Número do Documento Fiscal do Exportador*/
    Data cSerExp    as String       READONLY		/*Série do Documento Fiscal do Exportador*/
    Data cDeclaEx   as String       READONLY		/*	Número da Declaração para Despacho de Exportação do Exportador*/
    
    /*Inventário por material componente*/
    Data cPrdInv    as String       READONLY
    Data cInsInv    as String       READONLY
    Data nQTDIn     as Integer      READONLY
    Data nCust      as Integer      READONLY
    Data nICMIns    as Integer      READONLY
    
    /*Atrubutos referente ai Reg 5725 - Cadastro de Veículos Transportador Rodoviário*/
    Data cCodVeic   as Integer      READONLY
    Data nCNPJ      as Integer      READONLY
    Data cPlc       as String       READONLY
    Data cUFVeic    as String       READONLY
    Data cMunc      as String       READONLY
    Data cRenav     as String       READONLY
    Data cMarc      as String       READONLY
    Data cModel     as String       READONLY
    Data nAno       as Integer      READONLY
    Data nRend      as Integer      READONLY
    
    /*Arrays dos registros*/
    Data aReg       as Array        READONLY
    Data aReg5010   as Array        READONLY
    Data aReg5015   as Array		 READONLY
    Data aReg5020   as Array		 READONLY
    Data aReg5060   as Array		 READONLY
    Data aReg5065   as Array		 READONLY
    Data aReg5070   as Array		 READONLY
    Data aReg5080   as Array		 READONLY
    Data aReg5085   as Array		 READONLY
    Data aReg5090   as Array		 READONLY
    Data aReg5100   as Array		 READONLY
    Data aReg5105   as Array		 READONLY
    Data aReg5110   as Array		 READONLY
    Data aReg5115   as Array		 READONLY
    Data aReg5150   as Array		 READONLY
    Data aReg5155   as Array		 READONLY
    Data aReg5160   as Array		 READONLY
    Data aReg5165   as Array		 READONLY
    Data aReg5170   as Array		 READONLY
    Data aReg5175   as Array		 READONLY
    Data aReg5180   as Array		 READONLY
    Data aReg5185   as Array		 READONLY
    Data aReg5190   as Array		 READONLY
    Data aReg5195   as Array		 READONLY
    Data aReg5210   as Array		 READONLY
    Data aReg5215   as Array		 READONLY
    Data aReg5230   as Array		 READONLY
    Data aReg5235   as Array		 READONLY
    Data aReg5240   as Array		 READONLY
    Data aReg5260   as Array		 READONLY
    Data aReg5265   as Array		 READONLY
    Data aReg5270   as Array		 READONLY
    Data aReg5275   as Array		 READONLY
    Data aReg5310   as Array		 READONLY
    Data aReg5315   as Array		 READONLY
    Data aReg5320   as Array		 READONLY
    Data aReg5325   as Array		 READONLY
    Data aReg5330   as Array		 READONLY
    Data aReg5335   as Array		 READONLY
    Data aReg5340   as Array		 READONLY
    Data aReg5350   as Array		 READONLY
    Data aReg5360   as Array		 READONLY
    Data aReg5365   as Array		 READONLY
    Data aReg5370   as Array		 READONLY
    Data aReg5375   as Array		 READONLY
    Data aReg5380   as Array		 READONLY
    Data aReg5385   as Array		 READONLY
    Data aReg5390   as Array		 READONLY
    Data aReg5395   as Array		 READONLY
    Data aReg5400   as Array		 READONLY
    Data aReg5410   as Array		 READONLY
    Data aReg5415   as Array		 READONLY
    Data aReg5420   as Array		 READONLY
    Data aReg5425   as Array		 READONLY
    Data aReg5430   as Array		 READONLY
    Data aReg5435   as Array		 READONLY
    Data aReg5440   as Array		 READONLY
    Data aReg5550   as Array		 READONLY
    Data aReg5555   as Array		 READONLY
    Data aReg5590   as Array		 READONLY
    Data aReg5595   as Array		 READONLY
    Data aReg5720   as Array		 READONLY
    Data aReg5725   as Array		 READONLY
    Data aReg5730   as Array		 READONLY
    
    METHOD New() CONSTRUCTOR
    METHOD	SetcReg(cReg)
    METHOD	SetcCodItem( cCodItem)
    
    /*Abertura*/
    METHOD	SetnQtdIni(nQtdIni)
    METHOD	SetnCustIni(nCustIni)
    METHOD	SetnICMSIni(nICMSIni)
    METHOD	SetnQtdFim(nQtdFim)
    METHOD	SetnCustFim(nCustFim)
    METHOD	SetnICMSFim(nICMSFim)
    METHOD	SetnCustUnt(nCustUnit)
    METHOD	SetnICMSUnt(nICMSUnit)
    METHOD SetnQtdPer(nQtdPer)
    
    
    /*Movimentação*/
    METHOD	SetnNumLan(nNumLan)
    METHOD	SetdDtMov(dDtMov)
    METHOD	SetcHist(cHist)
    METHOD	SetnTpDoc(nTpDoc)
    METHOD	SetcSerie(cSerie)
    METHOD	SetcNumDoc(cNumDoc)
    METHOD	SetnCFOP(nCFOP)
    METHOD	SetcNumDI(cNumDI)
    METHOD	SetcCodPar(cCodPar)
    METHOD	SetnCodLan(nCodLan)
    METHOD	SetnIndMov(nIndMov)
    METHOD	SetcCodProd(cCodProd)
    METHOD SetcProdMov(cProdMov)
    METHOD	SetnQuant(nQuant)
    METHOD	SetnCusto(nCusto)
    METHOD	SetnValICMS(nValICMS)
    METHOD	SetnPercRat(nPercRat)
    METHOD	SetnValOTri(nValOTri)
    METHOD	SetcCodRem(cCodRem)
    METHOD	SetcCodDes(cCodDes)
    METHOD	SetcUFInic(cUFInic)
    METHOD	SetcUFDest(cUFDest)
    METHOD	SetcCodTom(cCodTom)
    METHOD	SetnAliq(nAliq)
    METHOD	SetnPerCO(nPerCO)
    METHOD	SetnValCO(nValCO)
    METHOD	SetnValDesp(nValDesp)
    METHOD	SetnQtdRes(nQtdRes)
    METHOD	SetnValSRes(nValSRes)
    METHOD	SetnOrdem(nOrdem)
    METHOD	SetnQTDMatRes(nQTDMatRes)
    METHOD	SetnValMatRes(nValMatRes)
    
    METHOD SetnKm(nKm)
    METHOD SetnEnqleg(nEnqleg)
    METHOD SetnVprege(nVprege)
    METHOD SetnVprest(nVprest)
    METHOD SetnIcmdeb(nIcmdeb)
    METHOD SetnIndrat(nIndrat)
    METHOD SetnUcusto(nUcusto)
    METHOD SetnUicms(nUicms)
    METHOD SetnCredAc(nCredAc)
    METHOD SetnIcmsde(nIcmsde)
    METHOD SetnVpreng(nVpreng)
    METHOD SetnIcmst(nIcmst)
    METHOD SetnVcrout(nVcrout)
    METHOD SetnCroust(nCroust)
    METHOD SetnVeicul(nVeicul)
    
    /*Métodos Referente a IPI e Outros Tributos na Entrada*/
    METHOD	SetnValIpi(nValIpi)
    METHOD	SetnValTri(nValTri)
    
    /*Métodos Referente a Apuração de Custo das Fichas*/
    METHOD SetcProdAcab(cProdAcab)				/**/
    METHOD SetcProdIns(cProdIns)				/*Código do Insumo conforme registro 0200*/
    METHOD SetcUnidad(cUnidad)					/**/
    METHOD SetnQtdConcl(nQtdConcl)				/**/
    METHOD SetnQtdInsUt(nQtdInsUt)				/**/
    METHOD SetnQtInsUtUn(nQtInsUtUn)			/**/
    METHOD SetnCusUntIns(nCusUntIns)			/**/
    METHOD SetnCustTotUn(nCustTotUn)			/**/
    METHOD SetnVUntICMIn(nVUntICMIn)			/**/
    METHOD SetnVTotInsUn(nVTotInsUn)			/**/
    METHOD SetnPerdaNorm(nPerdaNorm)			/**/
    METHOD SetnGanhoNorm(nGanhoNorm)			/**/
    METHOD SetcCoProd(cCoProd)
    METHOD SetnQtdCoPr(nQtdCoPr)
    METHOD SetnPrcMed(nPrcMed)
    METHOD SetnVlPrjS(nVlPrjS)
    METHOD SetnPercAlc(nPercAlc)
    
    /*Métodos Referente a Devolução de Saída*/
    METHOD	SetdDtSai(dDtSai)						/*Data da emissão do documento fiscal que acobertou a operação original do item devolvido*/
    METHOD	SetnTipDocDev(nTipDocDev)			/*Tipo do documento conforme a coluna Código chave da tabela 4.2 ou campo 02 do registro 0400*/
    METHOD	SetcSerieDev(cSerieDev)  			/*Série do documento que acobertou a operação original*/
    METHOD	SetcDocDev(cDocDev)					/*Número do documento que acobertou a operação original*/
    
    
    /*Métodos referente a operações de crédito acumulado*/
    METHOD	SetnCodLeg(nCodLeg) 					/*Código do Enquadramento Legal*/
    METHOD	SetnVlOpIt(nVlOpIt) 					/*Valor Total da Operação relativo ao Item*/
    METHOD	SetnCredA(nCredA) 					/*Credito acumulado Gerado na Operação com o Item*/
    METHOD	SetnBCIt(nBCIt)						/*Base de Cálculo da Operação de saída relativa ao item*/
    METHOD	SetnAlqIt(nAlqIt)						/*Alíquota de ICMS da Operação de saída relativa ao Item*/
    METHOD	SetnICMDbi(nICMDbi) 				   /*Icms debitado na operação de saída do item*/
    METHOD	SetnICMDev(nICMDev) 					/*Icms devido na operação de saída relativo ao item*/
    METHOD	SetnDecEx(nDecEx)  					/*Número da Declaração para Despacho*/
    METHOD	SetnCompOp(nCompOp) 					/*Comprovação de Operação*/
    METHOD	SetnVlCrICM(nVlCrICM)				/*Valor do Crédito de ICMS*/
    
    
    /*Métodos Exportação Indireta Comprovada*/
    METHOD	SetdPeriod(dPeriod)					/*Período*/
    METHOD	SetcProd(cProd)						/*Produto (Mercadoria)*/
    METHOD	SetnNLanc(nNLanc)						/*Número do Lançamento*/
    METHOD	SetcDoc(nDoc)							/*Número do Documento Fiscal de Remessa*/
    METHOD	SetcSerRem(cSerRem)					/*Série do Documento Fiscal de Remessa*/
    METHOD	SetdDtExp(dDtExp)						/*Data do Documento Fiscal do Exportador*/
    METHOD	SetcDocExp(cDocExp)					/*Número do Documento Fiscal do Exportador*/
    METHOD	SetcSerExp(cSerExp)					/*Série do Documento Fiscal do Exportador*/
    METHOD	SetcDeclaEx(cDeclaEx)				/*Número da Declaração para Despacho de Exportação do Exportador*/
    
    /*Inventário por material componente*/
    METHOD  SetcPrdInv(cPrdInv)
    METHOD  SetcInsInv(cInsInv)
    METHOD  SetnQTDIn(nQTDIn)
    METHOD  SetnCust(nCust)
    METHOD  SetnICMIns(nICMIns)
    
    /*Métodos referente ai Reg 5725 - Cadastro de Veículos Transportador Rodoviário*/
    METHOD	SetcCodVeic(cCodVeic)				/*Código de IndentIFicação do Veículo Transportador*/
    METHOD	SetnCNPJ(nCNPJ)						/*CNPJ do Proprietário*/
    METHOD	SetcPlc(cPlc)							/*Placa do Veículo*/
    METHOD	SetcUFVeic(cUFVeic)					/*Unidade de Federação de Registro do Veículo*/
    METHOD	SetcMunc(cMunc)						/*Município*/
    METHOD	SetcRenav(cRenav)						/*Número do Renavan*/
    METHOD	SetcMarc(cMarc)						/*Marca do Veículo*/
    METHOD	SetcModel(cModel)						/*Modelo do Veículo*/
    METHOD	SetnAno(nAno)							/*Ano de Fabricação*/
    METHOD	SetnRend(nRend)						/*Rendimento do Combustível*/
    
    /*Método dos Registros de Abertura*/
    METHOD AddAbrt()
    /*Método dos Registros de Movimentação de Itens das Fichas*/
    METHOD AddMov(cReg)
    /*Método dos registros de Valor de IPI e Outros Tributos na Entrada */
    METHOD AddIpiOut(cReg)
    /*Método dos Registros de Apuração e Custos*/
    METHOD AddApurCus(cReg)
    /*Métodos referente a operações de crédito acumulado*/
    METHOD AddOpCrdAc(cReg)
    /*Método referente a Exportação Indireta Comprovada*/
    METHOD AddExpInd(cReg)
    /*Método referente as operações geradoras apuradas nas fichas 6A/6B*/
    METHOD AddOp6A6B(cReg)
    /*Método referente as operações geradoras apuradas nas fichas 6C/6D*/
    METHOD AddOp6C6D(cReg)
    /*Método referente a Operação não geradora de crédito acumulado - FICHA6F*/
    METHOD AddNGer(cReg)
    /*Inventário por material componente*/
    METHOD AddInv(cReg)
    /*Método referente ai Reg 5725 - Cadastro de Veículos Transportador Rodoviário*/
    METHOD AddVeiculo(cReg)
    /*Métodos Referente a Devolução de Saída*/
    METHOD AddDevSai(cReg)
    /*Limpa os Arrays dos Registros*/
    METHOD Clear(nReg)
    
ENDCLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} New
 
Método que inicializa/limpa todos os atributos da CLASSe
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD New() CLASS BLOCO5
    
    Self:cReg           := ''
    /*Abertura*/
    Self:cCodItem		   := ''
    Self:nQtdIni		   := 0
    Self:nCustIni		   := 0
    Self:nICMSIni		   := 0
    Self:nQtdFim        := 0
    Self:nCustFim		   := 0
    Self:nICMSFim		   := 0
    Self:nCustUnt		   := 0
    Self:nICMSUnt		   := 0
    Self:nQtdPer		   := 0
    
    /*Movimentação*/
    Self:nNumLan        := 0
    Self:dDtMov         := CTod("  /  /    ")
    Self:cHist          := ''
    Self:nTpDoc         := 0
    Self:cSerie         := ''
    Self:cNumDoc        := 0
    Self:nCFOP          := 0
    Self:cNumDI         := ''
    Self:cCodPar        := ''
    Self:nCodLan        := 0
    Self:nIndMov        := 0
    Self:cCodProd       := ''
    Self:cProdMov        := ''
    Self:nQuant         := 0
    Self:nCusto         := 0
    Self:nValICMS       := 0
    Self:nPercRat       := 0
    Self:nValOTri       := 0
    Self:cCodRem        := ''
    Self:cCodDes        := ''
    Self:cUFInic        := ''
    Self:cUFDest        := ''
    Self:cCodTom        := ''
    Self:nAliq          := 0
    Self:nPerCO         := 0
    Self:nValCO         := 0
    Self:nValDesp       := 0
    Self:nQtdRes        := 0
    Self:nValSRes       := 0
    Self:nOrdem         := 0
    Self:nQTDMatRes     := 0
    Self:nValMatRes     := 0
    Self:nKm            := 0
    Self:nEnqleg        := 0
    Self:nVprege        := 0
    Self:nVprest        := 0
    Self:nIcmdeb        := 0
    Self:nIndrat        := 0
    Self:nUcusto        := 0
    Self:nUicms         := 0
    Self:nCredAc        := 0
    Self:nIcmsde        := 0
    Self:nVpreng        := 0
    Self:nIcmst         := 0
    Self:nVcrout        := 0
    Self:nCroust        := 0
    Self:nVeicul        := 0
    
    /*IPI e Outros Tributos na Entrada*/
    Self:nValIpi	:= 0
    Self:nValTri	:= 0
    
    /*Apuração do Custo*/
    Self:cProdAcab      := ''
    Self:cProdIns       := ''
    Self:cUnidad        := ''
    Self:nQtdConcl      := 0
    Self:nQtdInsUt      := 0
    Self:nQtInsUtUn     := 0
    Self:nCusUntIns     := 0
    Self:nCustTotUn     := 0
    Self:nVUntICMIn     := 0
    Self:nVTotInsUn     := 0
    Self:nPerdaNorm     := 0
    Self:nGanhoNorm     := 0
    Self:cCoProd        := ''
    Self:nQtdCoPr       := 0
    Self:nPrcMed        := 0
    Self:nVlPrjS        := 0
    Self:nPercAlc       := 0
    
    /*Devolução de Saída*/
    Self:dDtSai		   := CTod("  /  /    ")
    Self:nTipDocDev     := 0
    Self:cSerieDev      := ''
    Self:cDocDev        := ''
    
    /*Operações de crédito acumulado*/
    Self:nCodLeg		  := 0
    Self:nVlOpIt		  := 0
    Self:nCredA		  := 0
    Self:nBCIt		  := 0
    Self:nAlqIt		  := 0
    Self:nICMDeb		  := 0
    Self:nICMDev		  := 0
    Self:nDecEx        := 0
    Self:nCompOp		  := 0
    Self:nVlCrICM		  := 0
    
    /*Exportação Indireta Comprovada*/
    Self:dPeriod		  := CTod("  /  /    ")
    Self:cProd		  := ''
    Self:nNLanc		  := 0
    Self:cDoc			  := ''
    Self:cSerRem		  := ''
    Self:dDtExp		  := ''
    Self:cDocExp		  := ''
    Self:cSerExp		  := ''
    Self:cDeclaEx		  := ''
    
    /*Inventário por material componente*/
    Self:cPrdInv        := ''
    Self:cInsInv        := ''
    Self:nQTDIn         := 0
    Self:nCust          := 0
    Self:nICMIns        := 0
    
    /*Cadastro de Veículos Transportador Rodoviário*/
    Self:cCodVeic       := ''
    Self:nCNPJ          := 0
    Self:cPlc           := ''
    Self:cUFVeic        := ''
    Self:cMunc          := ''
    Self:cRenav         := ''
    Self:cMarc          := ''
    Self:cModel         := ''
    Self:nAno           := 0
    Self:nRend          := 0
    
    /*Arrays dos registros*/
    Self:aReg   		  := {}
    Self:aReg5010		  := {}
    Self:aReg5015		  := {}
    Self:aReg5020		  := {}
    Self:aReg5060		  := {}
    Self:aReg5065		  := {}
    Self:aReg5070		  := {}
    Self:aReg5080		  := {}
    Self:aReg5085		  := {}
    Self:aReg5090		  := {}
    Self:aReg5100		  := {}
    Self:aReg5105		  := {}
    Self:aReg5110		  := {}
    Self:aReg5115		  := {}
    Self:aReg5150		  := {}
    Self:aReg5155		  := {}
    Self:aReg5160		  := {}
    Self:aReg5165		  := {}
    Self:aReg5170		  := {}
    Self:aReg5175		  := {}
    Self:aReg5180		  := {}
    Self:aReg5185		  := {}
    Self:aReg5190		  := {}
    Self:aReg5195		  := {}
    Self:aReg5210		  := {}
    Self:aReg5215		  := {}
    Self:aReg5230		  := {}
    Self:aReg5235		  := {}
    Self:aReg5240		  := {}
    Self:aReg5260		  := {}
    Self:aReg5265		  := {}
    Self:aReg5270		  := {}
    Self:aReg5275		  := {}
    Self:aReg5310		  := {}
    Self:aReg5315		  := {}
    Self:aReg5320		  := {}
    Self:aReg5325		  := {}
    Self:aReg5330		  := {}
    Self:aReg5335		  := {}
    Self:aReg5340		  := {}
    Self:aReg5350		  := {}
    Self:aReg5360		  := {}
    Self:aReg5365		  := {}
    Self:aReg5370		  := {}
    Self:aReg5375		  := {}
    Self:aReg5380		  := {}
    Self:aReg5385		  := {}
    Self:aReg5390		  := {}
    Self:aReg5395		  := {}
    Self:aReg5400		  := {}
    Self:aReg5410		  := {}
    Self:aReg5415		  := {}
    Self:aReg5420		  := {}
    Self:aReg5425		  := {}
    Self:aReg5430		  := {}
    Self:aReg5435		  := {}
    Self:aReg5440		  := {}
    Self:aReg5550		  := {}
    Self:aReg5555		  := {}
    Self:aReg5590		  := {}
    Self:aReg5595		  := {}
    Self:aReg5720		  := {}
    Self:aReg5725		  := {}
    Self:aReg5730		  := {}
    Self:ClearCat83()
    
RETURN

/*Métodos Set*/
METHOD SetcReg( cReg) CLASS BLOCO5
    Self:cReg := cReg
RETURN

/*Abertura*/
METHOD SetcCodItem(cCodItem) CLASS BLOCO5
    Self:cCodItem := cCodItem
RETURN

METHOD SetnQtdIni( nQtdIni) CLASS BLOCO5
    Self:nQtdIni := nQtdIni
RETURN

METHOD SetnCustIni( nCustIni) CLASS BLOCO5
    Self:nCustIni := nCustIni
RETURN

METHOD SetnICMSIni( nICMSIni) CLASS BLOCO5
    Self:nICMSIni := nICMSIni
RETURN

METHOD SetnQtdFim( nQtdFim) CLASS BLOCO5
    Self:nQtdFim := nQtdFim
RETURN

METHOD SetnCustFim( nCustFim) CLASS BLOCO5
    Self:nCustFim := nCustFim
RETURN

METHOD SetnICMSFim( nICMSFim) CLASS BLOCO5
    Self:nICMSFim := nICMSFim
RETURN

METHOD SetnCustUnt( nCustUnt) CLASS BLOCO5
    Self:nCustUnt := nCustUnt
RETURN

METHOD SetnICMSUnt( nICMSUnt) CLASS BLOCO5
    Self:nICMSUnt := nICMSUnt
RETURN

METHOD SetnQtdPer( nQtdPer) CLASS BLOCO5
    Self:nQtdPer := nQtdPer
RETURN

/*Movimentação*/
METHOD	SetnNumLan(nNumLan) 	 CLASS BLOCO5
    Self:nNumLan := nNumLan
RETURN
METHOD	SetdDtMov(dDtMov)	     CLASS BLOCO5
    Self:dDtMov := dDtMov
RETURN
METHOD	SetcHist(cHist)		 CLASS BLOCO5
    Self:cHist := cHist
RETURN
METHOD	SetnTpDoc(nTpDoc)		 CLASS BLOCO5
    Self:nTpDoc := nTpDoc
RETURN
METHOD	SetcSerie(cSerie)		 CLASS BLOCO5
    Self:cSerie := cSerie
RETURN
METHOD	SetcNumDoc(cNumDoc)	 CLASS BLOCO5
    Self:cNumDoc := cNumDoc
RETURN
METHOD	SetnCFOP(nCFOP)		 CLASS BLOCO5
    Self:nCFOP := nCFOP
RETURN
METHOD	SetcNumDI(cNumDI)		 CLASS BLOCO5
    Self:cNumDI := cNumDI
RETURN
METHOD	SetcCodPar(cCodPar)	 CLASS BLOCO5
    Self:cCodPar := cCodPar
RETURN
METHOD	SetnCodLan(nCodLan)	 CLASS BLOCO5
    Self:nCodLan := nCodLan
RETURN
METHOD	SetnIndMov(nIndMov)	 CLASS BLOCO5
    Self:nIndMov := nIndMov
RETURN
METHOD	SetcCodProd(cCodProd)	 CLASS BLOCO5
    Self:cCodProd := cCodProd
RETURN
METHOD  SetcProdMov(cProdMov)    CLASS BLOCO5
    Self:cProdMov := cProdMov
RETURN
METHOD	SetnQuant(nQuant)		 CLASS BLOCO5
    Self:nQuant := nQuant
RETURN
METHOD	SetnCusto(nCusto)		 CLASS BLOCO5
    Self:nCusto := nCusto
RETURN
METHOD	SetnValICMS(nValICMS) CLASS BLOCO5
    Self:nValICMS := nValICMS
RETURN
METHOD	SetnPercRat(nPercRat) CLASS BLOCO5
    Self:nPercRat := nPercRat
RETURN
METHOD	SetnValOTri(nValOTri) CLASS BLOCO5
    Self:nValOTri := nValOTri
RETURN
METHOD	SetcCodRem(cCodRem)	 CLASS BLOCO5
    Self:cCodRem := cCodRem
RETURN
METHOD	SetcCodDes(cCodDes)   CLASS BLOCO5
    Self:cCodDes := cCodDes
RETURN
METHOD	SetcUFInic(cUFInic)	 CLASS BLOCO5
    Self:cUFInic := cUFInic
RETURN
METHOD	SetcUFDest(cUFDest)	 CLASS BLOCO5
    Self:cUFDest := cUFDest
RETURN
METHOD	SetcCodTom(cCodTom)	 CLASS BLOCO5
    Self:cCodTom := cCodTom
RETURN
METHOD	SetnAliq(nAliq)	     CLASS BLOCO5
    Self:nAliq := nAliq
RETURN
METHOD	SetnPerCO(nPerCO)CLASS BLOCO5
    Self:nPerCO := nPerCO
RETURN
METHOD	SetnValCO(nValCO)CLASS BLOCO5
    Self:nValCO := nValCO
RETURN
METHOD	SetnValDesp(nValDesp)CLASS BLOCO5
    Self:nValDesp := nValDesp
RETURN
METHOD	SetnQtdRes(nQtdRes)CLASS BLOCO5
    Self:nQtdRes := nQtdRes
RETURN
METHOD	SetnValSRes(nValSRes)CLASS BLOCO5
    Self:nValSRes := nValSRes
RETURN
METHOD	SetnOrdem(nOrdem)CLASS BLOCO5
    Self:nOrdem := nOrdem
RETURN

METHOD	SetnQTDMatRes(nQTDMatRes) CLASS BLOCO5
    Self:nQTDMatRes := nQTDMatRes
RETURN

METHOD	SetnValMatRes(nValMatRes) CLASS BLOCO5
    Self:nValMatRes := nValMatRes
RETURN

METHOD SetnKm(nKm) CLASS BLOCO5
    Self:nKm := nKm
RETURN
METHOD SetnEnqleg(nEnqleg) CLASS BLOCO5
    Self:nEnqleg := nEnqleg
RETURN
METHOD SetnVprege(nVprege) CLASS BLOCO5
    Self:nVprege := nVprege
RETURN
METHOD SetnVprest(nVprest) CLASS BLOCO5
    Self:nVprest := nVprest
RETURN
METHOD SetnIcmdeb(nIcmdeb) CLASS BLOCO5
    Self:nIcmdeb := nIcmdeb
RETURN
METHOD SetnIndrat(nIndrat) CLASS BLOCO5
    Self:nIndrat := nIndrat
RETURN
METHOD SetnUcusto(nUcusto) CLASS BLOCO5
    Self:nUcusto := nUcusto
RETURN
METHOD SetnUicms(nUicms) CLASS BLOCO5
    Self:nUicms := nUicms
RETURN
METHOD SetnCredac(nCredac) CLASS BLOCO5
    Self:nCredac := nCredac
RETURN
METHOD SetnIcmsde(nIcmsde) CLASS BLOCO5
    Self:nIcmsde := nIcmsde
RETURN
METHOD SetnVpreng(nVpreng) CLASS BLOCO5
    Self:nVpreng := nVpreng
RETURN
METHOD SetnIcmst(nIcmst) CLASS BLOCO5
    Self:nIcmst := nIcmst
RETURN
METHOD SetnVcrout(nVcrout) CLASS BLOCO5
    Self:nVcrout := nVcrout
RETURN
METHOD SetnCroust(nCroust) CLASS BLOCO5
    Self:nCroust := nCroust
RETURN
METHOD SetnVeicul(nVeicul) CLASS BLOCO5
    Self:nVeicul := nVeicul
RETURN

/*Métodos Referente a IPI e outros Tributos na Entrada*/
METHOD	SetnValIpi(nValIpi) CLASS BLOCO5
    Self:nValIpi := nValIpi
RETURN
METHOD	SetnValTri(nValTri) CLASS BLOCO5
    Self:nValTri := nValTri
RETURN

/*Métodos Referente a Apuração de Custo das Fichas*/
METHOD	SetcProdAcab(cProdAcab)CLASS BLOCO5
    Self:cProdAcab := cProdAcab
RETURN
METHOD	SetcProdIns(cProdIns)CLASS BLOCO5
    Self:cProdIns := cProdIns
RETURN
METHOD	SetcUnidad(cUnidad)CLASS BLOCO5
    Self:cUnidad := cUnidad
RETURN
METHOD	SetnQtdConcl(nQtdConcl)CLASS BLOCO5
    Self:nQtdConcl := nQtdConcl
RETURN
METHOD	SetnQtdInsUt(nQtdInsUt)CLASS BLOCO5
    Self:nQtdInsUt := nQtdInsUt
RETURN
METHOD	SetnQtInsUtUn(nQtInsUtUn)CLASS BLOCO5
    Self:nQtInsUtUn := nQtInsUtUn
RETURN
METHOD	SetnCusUntIns(nCusUntIns)CLASS BLOCO5
    Self:nCusUntIns := nCusUntIns
RETURN
METHOD	SetnCustTotUn(nCustTotUn)CLASS BLOCO5
    Self:nCustTotUn := nCustTotUn
RETURN
METHOD	SetnVUntICMIn(nVUntICMIn)CLASS BLOCO5
    Self:nVUntICMIn := nVUntICMIn
RETURN
METHOD	SetnVTotInsUn(nVTotInsUn)CLASS BLOCO5
    Self:nVTotInsUn := nVTotInsUn
RETURN
METHOD	SetnPerdaNorm(nPerdaNorm)CLASS BLOCO5
    Self:nPerdaNorm := nPerdaNorm
RETURN
METHOD	SetnGanhoNorm(nGanhoNorm)CLASS BLOCO5
    Self:nGanhoNorm := nGanhoNorm
RETURN
METHOD SetcCoProd(cCoProd)CLASS BLOCO5
    Self:cCoProd := cCoProd
RETURN
METHOD SetnQtdCoPr(nQtdCoPr)CLASS BLOCO5
    Self:nQtdCoPr := nQtdCoPr
RETURN
METHOD SetnPrcMed(nPrcMed)CLASS BLOCO5
    Self:nPrcMed := nPrcMed
RETURN
METHOD SetnVlPrjS(nVlPrjS)CLASS BLOCO5
    Self:nVlPrjS := nVlPrjS
RETURN
METHOD SetnPercAlc(nPercAlc)CLASS BLOCO5
    Self:nPercAlc := nPercAlc
RETURN
/*Métodos Referente a Devolução de Saída*/
METHOD	SetdDtSai(dDtSai)	CLASS BLOCO5
    Self:dDtSai := dDtSai
RETURN
METHOD	SetnTipDocDev(nTipDocDev)CLASS BLOCO5
    Self:nTipDocDev := nTipDocDev
RETURN
METHOD	SetcSerieDev(cSerieDev)  CLASS BLOCO5
    Self:cSerieDev := cSerieDev
RETURN
METHOD	SetcDocDev(cDocDev)	CLASS BLOCO5
    Self:cDocDev := cDocDev
RETURN

/*Métodos referente a operações de crédito acumulado*/
METHOD	SetnCodLeg(nCodLeg) 	CLASS BLOCO5
    Self:nCodLeg := nCodLeg
RETURN
METHOD	SetnVlOpIt(nVlOpIt) 	CLASS BLOCO5
    Self:nVlOpIt := nVlOpIt
RETURN
METHOD	SetnCredA(nCredA) 	CLASS BLOCO5
    Self:nCredA := nCredA
RETURN
METHOD	SetnBCIt(nBCIt)			CLASS BLOCO5
    Self:nBCIt := nBCIt
RETURN
METHOD	SetnAlqIt(nAlqIt)			CLASS BLOCO5
    Self:nAlqIt := nAlqIt
RETURN
METHOD	SetnICMDbi(nICMDbi) 		CLASS BLOCO5
    Self:nICMDbi := nICMDbi
RETURN
METHOD	SetnICMDev(nICMDev)	CLASS BLOCO5
    Self:nICMDev := nICMDev
RETURN
METHOD	SetnDecEx(nDecEx) 	CLASS BLOCO5
    Self:nDecEx := nDecEx
RETURN
METHOD	SetnCompOp(nCompOp)	CLASS BLOCO5
    Self:nCompOp := nCompOp
RETURN
METHOD	SetnVlCrICM(nVlCrICM)	CLASS BLOCO5
    Self:nVlCrICM := nVlCrICM
RETURN


/*Métodos Exportação Indireta Comprovada*/
METHOD	SetdPeriod(dPeriod)		CLASS BLOCO5
    Self:dPeriod := dPeriod
RETURN
METHOD	SetcProd(cProd)			CLASS BLOCO5
    Self:cProd := cProd
RETURN
METHOD	SetnNLanc(nNLanc)			CLASS BLOCO5
    Self:nNLanc := nNLanc
RETURN
METHOD	SetcDoc(nDoc)			CLASS BLOCO5
    Self:nDoc := nDoc
RETURN
METHOD	SetcSerRem(cSerRem)	CLASS BLOCO5
    Self:cSerRem := cSerRem
RETURN
METHOD	SetdDtExp(dDtExp)		CLASS BLOCO5
    Self:dDtExp := dDtExp
RETURN
METHOD	SetcDocExp(cDocExp)		CLASS BLOCO5
    Self:cDocExp := cDocExp
RETURN
METHOD	SetcSerExp(cSerExp)	CLASS BLOCO5
    Self:cSerExp := cSerExp
RETURN
METHOD	SetcDeclaEx(cDeclaEx)	CLASS BLOCO5
    Self:cDeclaEx := cDeclaEx
RETURN

/*Inventário por material componente*/
METHOD  SetcPrdInv(cPrdInv) CLASS BLOCO5
    Self:cPrdInv := cPrdInv
RETURN
METHOD  SetcInsInv(cInsInv) CLASS BLOCO5
    Self:cInsInv := cInsInv
RETURN
METHOD  SetnQTDIn(nQTDIn) CLASS BLOCO5
    Self:nQTDIn := nQTDIn
RETURN
METHOD  SetnCust(nCust) CLASS BLOCO5
    Self:nCust := nCust
RETURN
METHOD  SetnICMIns(nICMIns) CLASS BLOCO5
    Self:nICMIns := nICMIns
RETURN

/*Métodos referente ao Reg 5725 - Cadastro de Veículos Transportador Rodoviário*/
METHOD	SetcCodVeic(cCodVeic) CLASS BLOCO5
    Self:cCodVeic := cCodVeic
RETURN
METHOD	SetnCNPJ(nCNPJ) CLASS BLOCO5
    Self:nCNPJ := nCNPJ
RETURN
METHOD	SetcPlc(cPlc) CLASS BLOCO5
    Self:cPlc := cPlc
RETURN
METHOD	SetcUFVeic(cUFVeic) CLASS BLOCO5
    Self:cUFVeic := cUFVeic
RETURN
METHOD	SetcMunc(cMunc) CLASS BLOCO5
    Self:cMunc := cMunc
RETURN
METHOD	SetcRenav(cRenav) CLASS BLOCO5
    Self:cRenav := cRenav
RETURN
METHOD	SetcMarc(cMarc) CLASS BLOCO5
    Self:cMarc := cMarc
RETURN
METHOD	SetcModel(cModel) CLASS BLOCO5
    Self:cModel := cModel
RETURN
METHOD	SetnAno(nAno) CLASS BLOCO5
    Self:nAno := nAno
RETURN
METHOD	SetnRend(nRend) CLASS BLOCO5
    Self:nRend := nRend
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} AddAbrt
 
Método que gera os registros de abertura
Registros: 5010,5060,5080,5100,5110,5150,5165,5180,5190,5210,5230,5260,**5265**,5310,5360,5410,5550,5590
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------  
METHOD AddAbrt(cReg) CLASS BLOCO5
    Local nPos	:= 0
    Local aReg := {}
    Local aReg := {}
    Local nTamQTDI  := TAMSX3("CDU_QTDINI")[2]
    Local nTamQTDF  := TAMSX3("CDU_QTDFIM")[2]
    Local nTamQTD   := TAMSX3("F04_QTDE")[2]
    Local nICMUn    := TAMSX3("F04_FATORI")[2]
    Local nCustUn   := TAMSX3("F04_FATORC")[2]

    IF cReg == "5010"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5010')
        aAdd(Self:aReg5010,{})
        nPos :=	Len (Self:aReg5010)
        aAdd (Self:aReg5010[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5010[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5010[nPos], Self:cCodItem)		    //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5010[nPos],{Self:nQtdIni,nTamQTDI,'P'})     //Saldo Inicial de quantidade do item
        aAdd (Self:aReg5010[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5010[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5010[nPos],{Self:nQtdFim,nTamQTDF,'P'})     //Saldo Final de quantidade do Item
        aAdd (Self:aReg5010[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5010[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5010
    ELSEIF cReg == "5060"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5060')
        aAdd(Self:aReg5060,{})
        nPos :=	Len (Self:aReg5060)
        aAdd (Self:aReg5060[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5060[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5060[nPos], Self:cCodItem)           //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5060[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5060[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5060[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5060[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5060
    ELSEIF cReg == "5080"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5080')
        aAdd(Self:aReg5080,{})
        nPos :=	Len (Self:aReg5080)
        aAdd (Self:aReg5080[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5080[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5080[nPos], Self:cCodItem)           //Codigo da Energia Elétrica conforme registro 0200
        aReg := Self:aReg5080
    ELSEIF cReg == "5100"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5100')
        aAdd(Self:aReg5100,{})
        nPos :=	Len (Self:aReg5100)
        aAdd (Self:aReg5100[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5100[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5100[nPos], Self:cCodItem)           //Codigo do Serviço de Telecomunicações conforme registro 0200
        aAdd (Self:aReg5100[nPos], Self:nCustUnt)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5100[nPos], Self:nICMSUnt)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5100
    ELSEIF cReg == "5110"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5110')
        aAdd(Self:aReg5110,{})
        nPos :=	Len (Self:aReg5110)
        aAdd (Self:aReg5110[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5110[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5110[nPos], Self:cCodItem)           //Codigo da Ficha 1E conforme registro 0200
        aReg := Self:aReg5110
    ELSEIF cReg == "5150"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5150')
        aAdd(Self:aReg5150,{})
        nPos :=	Len (Self:aReg5150)
        aAdd (Self:aReg5150[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5150[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5150[nPos], Self:cCodItem)           //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5150[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5150[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5150[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5150[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aAdd (Self:aReg5150[nPos],{Self:nQtdPer, nTamQTD,'P'})    //Quantidade de Produto concluído e transferido no período
        aAdd (Self:aReg5150[nPos],{Self:nCustUnt,nCustUn,'P'})    //Custo Unitário do produto concluído e transferido no período
        aAdd (Self:aReg5150[nPos],{Self:nICMSUnt,nICMUn,'P'})    //Valor Unitário do ICMS do produto concluído e transferido no período
        aReg := Self:aReg5150
    ELSEIF cReg == "5165"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5165')
        aAdd(Self:aReg5165,{})
        nPos :=	Len (Self:aReg5165)
        aAdd (Self:aReg5165[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5165[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5165[nPos], Self:cCodItem)           //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5165[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5165[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5165[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5165[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aAdd (Self:aReg5165[nPos],{Self:nQtdPer, nTamQTD,'P'})    //Quantidade de Produto concluído e transferido no período
        aAdd (Self:aReg5165[nPos],{Self:nCustUnt,nCustUn,'P'})    //Custo Unitário do produto concluído e transferido no período
        aAdd (Self:aReg5165[nPos],{Self:nICMSUnt,nICMUn,'P'})    //Valor Unitário do ICMS do produto concluído e transferido no período
        aReg := Self:aReg5165
    ELSEIF cReg == "5180"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5180')
        aAdd(Self:aReg5180,{})
        nPos :=	Len (Self:aReg5180)
        aAdd (Self:aReg5180[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5180[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5180[nPos], Self:cCodItem)           //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5180[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5180[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5180[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5180[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5180
    ELSEIF cReg == "5190"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5190')
        aAdd(Self:aReg5190,{})
        nPos :=	Len (Self:aReg5190)
        aAdd (Self:aReg5190[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5190[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5190[nPos], Self:cCodItem)           //Codigo da Ficha 2D conforme registri 0200
        aAdd (Self:aReg5190[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5190[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5190
    ELSEIF cReg == "5210"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5210')
        aAdd(Self:aReg5210,{})
        nPos :=	Len (Self:aReg5210)
        aAdd (Self:aReg5210[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5210[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5210[nPos], Self:cCodItem)           //Codigo da Ficha 2E conforme registro 0200
        aReg := Self:aReg5210
    ELSEIF cReg == "5230"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5230')
        aAdd(Self:aReg5230,{})
        nPos :=	Len (Self:aReg5230)
        aAdd (Self:aReg5230[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5230[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5230[nPos], Self:cCodItem)           //Codigo do insumo conjunto conforme registro 0200
        aReg := Self:aReg5230
    ELSEIF cReg == "5260"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5260')
        aAdd(Self:aReg5260,{})
        nPos :=	Len (Self:aReg5260)
        aAdd (Self:aReg5260[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5260[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5260[nPos], Self:cCodItem)           //Codigo do processo produtivo conforme registro 0200
        aAdd (Self:aReg5260[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5260[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5260[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5260[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5260
    ELSEIF cReg == "5265"  
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5265')
        aAdd(Self:aReg5265,{})
        nPos := Len (Self:aReg5265)
        aAdd (Self:aReg5265[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5265[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5265[nPos], Self:cCodItem)           //Codigo do processo produtivo conforme registro 0200
        aAdd (Self:aReg5265[nPos],{Self:nQtdPer, nTamQTD,'P'})    //Quantidade de Produto concluído e transferido no período
        aAdd (Self:aReg5265[nPos],{Self:nCustUnt,nCustUn,'P'})    //Custo Unitário do produto concluído e transferido no período
        aAdd (Self:aReg5265[nPos],{Self:nICMSUnt,nICMUn,'P'})    //Valor Unitário do ICMS do produto concluído e transferido no período
        aReg := Self:aReg5265
    ELSEIF cReg == "5310"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5310')
        aAdd(Self:aReg5310,{})
        nPos :=	Len (Self:aReg5310)
        aAdd (Self:aReg5310[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5310[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5310[nPos], Self:cCodItem)           //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5310[nPos],{Self:nQtdIni,nTamQTDI,'P'})     //Saldo Inicial de quantidade do item
        aAdd (Self:aReg5310[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5310[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5310[nPos],{Self:nQtdFim,nTamQTDF,'P'})     //Saldo Final de quantidade do Item
        aAdd (Self:aReg5310[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5310[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5310
    ELSEIF cReg == "5360"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5360')
        aAdd(Self:aReg5360,{})
        nPos :=	Len (Self:aReg5360)
        aAdd (Self:aReg5360[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5360[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5360[nPos], Self:cCodItem)           //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5360[nPos],{Self:nQtdIni,nTamQTDI,'P'})     //Saldo Inicial de quantidade do item
        aAdd (Self:aReg5360[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5360[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5360[nPos],{Self:nQtdFim,nTamQTDF,'P'})     //Saldo Final de quantidade do Item
        aAdd (Self:aReg5360[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5360[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5360
    ELSEIF cReg == "5410"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5410')
        aAdd(Self:aReg5410,{})
        nPos :=	Len (Self:aReg5410)
        aAdd (Self:aReg5410[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5410[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5410[nPos], Self:cCodItem)           //Codigo do Item conforme registro 0200
        aAdd (Self:aReg5410[nPos],{Self:nQtdIni,nTamQTDI,'P'})     //Saldo Inicial de quantidade do item
        aAdd (Self:aReg5410[nPos], Self:nCustIni)           //Saldo Inicial do Valor de Custo do Item
        aAdd (Self:aReg5410[nPos], Self:nICMSIni)           //Saldo Inicial do Valor de ICMS do Item
        aAdd (Self:aReg5410[nPos],{Self:nQtdFim,nTamQTDF,'P'})		//Saldo Final de quantidade do Item
        aAdd (Self:aReg5410[nPos], Self:nCustFim)           //Saldo Final do Valor de Custo do Item
        aAdd (Self:aReg5410[nPos], Self:nICMSFim)           //Saldo Final do Valor de ICMS do Item
        aReg := Self:aReg5410
    ELSEIF cReg == "5550"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5550')
        aAdd(Self:aReg5550,{})
        nPos :=	Len (Self:aReg5550)
        aAdd (Self:aReg5550[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5550[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5550[nPos], Self:cCodItem)           //Codigo do do Material resultante
        aAdd (Self:aReg5550[nPos],{Self:nQtdIni,nTamQTDI,'P'})     //Saldo Inicial de quantidade do material resultante
        aAdd (Self:aReg5550[nPos],{Self:nQtdFim,nTamQTDF,'P'})     //Saldo Final de quantidade do material resultante
        aReg := Self:aReg5550
    ENDIF
RETURN (aReg)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddMov
 
Método que gera os registros de Movimentação
Registros: 5015,5065,5085,5105,5115,5175,5185,5195,5215,5240,5275,5315,5365,5415,5555
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD AddMov(cReg) CLASS BLOCO5
    Local aReg := {}
    Local nTamCust := TAMSX3("CLR_CUSTO")[2]
    Local nTamICM  := TAMSX3("CLR_ICMS")[2]
    Local nTamQTD  := TAMSX3("CLR_QTDE")[2]
    Local nTamRat  := TAMSX3("CLR_PERRAT")[2]
    
    
    IF cReg == "5015"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5015')
        aAdd(Self:aReg5015,{})
        nPos :=	Len (Self:aReg5015)
        aAdd (Self:aReg5015[nPos], Self:cGrupoReg)              //Chave
        aAdd (Self:aReg5015[nPos], cReg)                        //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5015[nPos], Self:nNumLan)                //Número do lançamento
        aAdd (Self:aReg5015[nPos], Self:dDtMov)                 //Data de movimentação
        aAdd (Self:aReg5015[nPos], Self:cHist)                  //Histórico
        aAdd (Self:aReg5015[nPos], Self:nTpDoc)                 //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5015[nPos], Self:cSerie)                 //Série do Documento
        aAdd (Self:aReg5015[nPos], Self:cNumDoc)                //Número do documento
        aAdd (Self:aReg5015[nPos], Self:nCFOP)                  //CFOP da Operação
        aAdd (Self:aReg5015[nPos], Self:cNumDI)                 //Número da DI ou DSI
        aAdd (Self:aReg5015[nPos], Self:cCodPar)                //Código do Participante, conforme registro 0150
        aAdd (Self:aReg5015[nPos], Self:nCodLan)                //Código de lançamento
        aAdd (Self:aReg5015[nPos], Self:nIndMov)                //Indicador de movimento
        aAdd (Self:aReg5015[nPos], Self:cCodItem)               //Código do Item movimentado
        aAdd (Self:aReg5015[nPos],{Self:nQuant, nTamQTD,'P'})   //Quantidade do item
        aAdd (Self:aReg5015[nPos],{Self:nCusto, nTamCust,'P'})  //Custo do item
        aAdd (Self:aReg5015[nPos],{Self:nValICMS,nTamICM,'P'})  //Valor do ICMS
        aReg := Self:aReg5015
    ELSEIF 	cReg == "5065"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5065')
        aAdd(Self:aReg5065,{})
        nPos :=	Len (Self:aReg5065)
        aAdd (Self:aReg5065[nPos], Self:cGrupoReg)              //Chave
        aAdd (Self:aReg5065[nPos], cReg)                        //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5065[nPos], Self:nNumLan)                //Número do lançamento
        aAdd (Self:aReg5065[nPos], Self:dDtMov)                 //Data de movimentação
        aAdd (Self:aReg5065[nPos], Self:cHist)                  //Histórico
        aAdd (Self:aReg5065[nPos], Self:nTpDoc)                 //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5065[nPos], Self:cSerie)                 //Série do Documento
        aAdd (Self:aReg5065[nPos], Self:cNumDoc)                //Número do documento
        aAdd (Self:aReg5065[nPos], Self:nCFOP)                  //CFOP da Operação
        aAdd (Self:aReg5065[nPos], Self:cCodPar)                //Código do Participante, conforme registro 0150
        aAdd (Self:aReg5065[nPos], Self:nCodLan)                //Código de lançamento
        aAdd (Self:aReg5065[nPos], Self:nIndMov)                //Indicador de movimento
        aAdd (Self:aReg5065[nPos], Self:cProdMov)               //Código do Item movimentado
        aAdd (Self:aReg5065[nPos],{Self:nCusto,  nTamCust,'P'})        //Custo do item
        aAdd (Self:aReg5065[nPos],{Self:nValICMS,nTamICM,'P'})        //Valor do ICMS
        aReg := Self:aReg5065
    ELSEIF 	cReg == "5085"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5085')
        aAdd(Self:aReg5085,{})
        nPos :=	Len (Self:aReg5085)
        aAdd (Self:aReg5085[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5085[nPos], cReg)						//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5085[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5085[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5085[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5085[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5085[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5085[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5085[nPos], Self:nCFOP)				//CFOP da Operação
        aAdd (Self:aReg5085[nPos], Self:cCodPar)				//Código do Participante, conforme registro 0150
        aAdd (Self:aReg5085[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5085[nPos], Self:nIndMov)				//Indicador de movimento
        aAdd (Self:aReg5085[nPos], Self:cCodItem)           //Código do Item movimentado
        aAdd (Self:aReg5085[nPos],{Self:nQuant,  nTamQTD,'P'})	//Quantidade do item
        aAdd (Self:aReg5085[nPos],{Self:nCusto,  nTamCust,'P'})//Custo do item
        aAdd (Self:aReg5085[nPos],{Self:nValICMS,nTamICM,'P'})	//Valor do ICMS
        aAdd (Self:aReg5085[nPos],{Self:nPercRat,nTamRat,'P'})	//Percentual de rateio da Ficha 4A
        aReg := Self:aReg5085
    ELSEIF cReg == "5105"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5105')
        aAdd(Self:aReg5105,{})
        nPos :=	Len (Self:aReg5105)
        aAdd (Self:aReg5105[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5105[nPos], cReg)						//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5105[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5105[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5105[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5105[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5105[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5105[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5105[nPos], Self:nCFOP)				//CFOP da Operação
        aAdd (Self:aReg5105[nPos], Self:cCodPar)				//Código do Participante, conforme registro 0150
        aAdd (Self:aReg5105[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5105[nPos],{Self:nCusto,  nTamCust,'P'})//Custo do item
        aAdd (Self:aReg5105[nPos],{Self:nValTri, nTamICM,'P'})	//Valor de Outros tributos e Contribuições não cumulativos
        aAdd (Self:aReg5105[nPos],{Self:nValICMS,nTamICM,'P'})	//Valor do ICMS
        aReg := Self:aReg5105
    ELSEIF cReg == "5115"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5115')
        aAdd(Self:aReg5115,{})
        nPos :=	Len (Self:aReg5115)
        aAdd (Self:aReg5115[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5115[nPos], cReg)						//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5115[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5115[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5115[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5115[nPos], Self:nCFOP)				//CFOP da Operação
        aAdd (Self:aReg5115[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5115[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5115[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5115[nPos], Self:cCodRem)				//Código do Remetente conforme registro 0150
        aAdd (Self:aReg5115[nPos], Self:cCodDes)				//Código do Destinatário conforme registro 0150
        aAdd (Self:aReg5115[nPos], Self:cUFInic)				//UF de Inicio do serviço de Transporte
        aAdd (Self:aReg5115[nPos], Self:cUFDest)				//UF de Destino do serviço de Transporte
        aAdd (Self:aReg5115[nPos], Self:cCodTom)				//Código do Tomador do serviço de transporte conforme registro 0150
        aAdd (Self:aReg5115[nPos], Self:nAliq)				//Alíquota de ICMS aplicavel na Prestação
        aAdd (Self:aReg5115[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5115[nPos], Self:nCusto)				//Custo do item
        aAdd (Self:aReg5115[nPos], Self:nValICMS)			//Valor do ICMS
        aReg := Self:aReg5115
    ELSEIF cReg == "5160"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5160')
        aAdd(Self:aReg5160,{})
        nPos :=	Len (Self:aReg5160)
        aAdd (Self:aReg5160[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5160[nPos], Self:cReg)					//Texto Fixo contendo o número o registro
        aAdd (Self:aReg5160[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5160[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5160[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5160[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5160[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5160[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5160[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5160[nPos], Self:nIndMov)				//Indicador de movimento
        aAdd (Self:aReg5160[nPos], Self:cProdMov)           //Código do Item movimentado
        aAdd (Self:aReg5160[nPos],{Self:nQuant,  nTamQTD,'P'})	//Quantidade do item
        aAdd (Self:aReg5160[nPos],{Self:nCusto,  nTamCust,'P'})	//Custo do item
        aAdd (Self:aReg5160[nPos],{Self:nValICMS,nTamICM,'P'})	//Valor do ICMS
        aReg := Self:aReg5160
    ELSEIF cReg == "5175"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5175')
        aAdd(Self:aReg5175,{})
        nPos :=	Len (Self:aReg5175)
        aAdd (Self:aReg5175[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5175[nPos], Self:cReg)					//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5175[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5175[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5175[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5175[nPos], Self:nCFOP)				//CFOP da Operação
        aAdd (Self:aReg5175[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5175[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5175[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5175[nPos], Self:cCodPar)				//Código do Participante, conforme registro 0150
        aAdd (Self:aReg5175[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5175[nPos], Self:nIndMov)				//Indicador de movimento
        aAdd (Self:aReg5175[nPos], Self:cProdMov)           //Código do Item movimentado
        aAdd (Self:aReg5175[nPos],{Self:nQuant,  nTamQTD,'P'})	//Quantidade do item
        aAdd (Self:aReg5175[nPos],{Self:nCusto,  nTamCust,'P'})//Custo do item
        aAdd (Self:aReg5175[nPos],{Self:nValICMS,nTamICM,'P'})	//Valor do ICMS
        aReg := Self:aReg5175
    ELSEIF cReg == "5185"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5185')
        aAdd(Self:aReg5185,{})
        nPos :=	Len (Self:aReg5185)
        aAdd (Self:aReg5185[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5185[nPos], Self:cReg)               //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5185[nPos], Self:nNumLan)            //Número do lançamento
        aAdd (Self:aReg5185[nPos], Self:dDtMov)             //Data de movimentação
        aAdd (Self:aReg5185[nPos], Self:cHist)              //Histórico
        aAdd (Self:aReg5185[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5185[nPos], Self:cSerie)             //Série do Documento
        aAdd (Self:aReg5185[nPos], Self:cNumDoc)            //Número do documento
        aAdd (Self:aReg5185[nPos], Self:nCodLan)            //Código de lançamento
        aAdd (Self:aReg5185[nPos], Self:nIndMov)            //Indicador de movimento
        aAdd (Self:aReg5185[nPos], Self:cProdMov)           //Código do Item movimentado
        aAdd (Self:aReg5185[nPos],{Self:nQuant,  nTamQTD,'P'})    //Quantidade do item
        aAdd (Self:aReg5185[nPos],{Self:nCusto,  nTamCust,'P'})    //Custo do item
        aAdd (Self:aReg5185[nPos],{Self:nValICMS,nTamICM,'P'})    //Valor do ICMS
        aReg := Self:aReg5185
    ELSEIF cReg == "5195"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5195')
        aAdd(Self:aReg5195,{})
        nPos :=	Len (Self:aReg5195)
        aAdd (Self:aReg5195[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5195[nPos], Self:cReg)	               //Texto Fixo contendo o número o registro
        aAdd (Self:aReg5195[nPos], Self:nNumLan)            //Número do lançamento
        aAdd (Self:aReg5195[nPos], Self:dDtMov)             //Data de movimentação
        aAdd (Self:aReg5195[nPos], Self:cHist)              //Histórico
        aAdd (Self:aReg5195[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5195[nPos], Self:cSerie)             //Série do Documento
        aAdd (Self:aReg5195[nPos], Self:cNumDoc)            //Número do documento
        aAdd (Self:aReg5195[nPos], Self:nCodLan)            //Código de lançamento
        aAdd (Self:aReg5195[nPos], Self:cProdMov)           //Código do Item movimentado
        aAdd (Self:aReg5195[nPos], Self:nQuant)             //Quantidade do item
        aAdd (Self:aReg5195[nPos], Self:nCusto)             //Custo do item
        aAdd (Self:aReg5195[nPos], Self:nValICMS)           //Valor do ICMS
        aReg := Self:aReg5195
    ELSEIF cReg == "5215"

        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5215')
        aAdd(Self:aReg5215,{})
        nPos :=	Len (Self:aReg5215)
        aAdd (Self:aReg5215[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5215[nPos], Self:cReg)               //Texto Fixo contendo o número o registro
        aAdd (Self:aReg5215[nPos], Self:nNumLan)            //Número do lançamento
        aAdd (Self:aReg5215[nPos], Self:dDtMov)             //Data de movimentação
        aAdd (Self:aReg5215[nPos], Self:cHist)              //Histórico
        aAdd (Self:aReg5215[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5215[nPos], Self:cSerie)             //Série do Documento
        aAdd (Self:aReg5215[nPos], Self:cNumDoc)            //Número do documento
        aAdd (Self:aReg5215[nPos], Self:nCodLan)            //Código de lançamento
        aAdd (Self:aReg5215[nPos], Self:nIndMov)            //Indicador de movimento
        aAdd (Self:aReg5215[nPos], Self:cProdMov)           //Código do Item movimentado
        aAdd (Self:aReg5215[nPos],{Self:nQuant, nTamQTD,'P'})    //Quantidade do item 
        aAdd (Self:aReg5215[nPos],{Self:nCusto, nTamCust,'P'})    //Custo do item
        aAdd (Self:aReg5215[nPos],{Self:nValICMS,nTamICM,'P'})    //Valor do ICMS
        aAdd (Self:aReg5215[nPos],{Self:nPercRat,nTamRat,'P'})    //Percentual de Rateio da ficha 4C
        aReg := Self:aReg5215
    ELSEIF cReg == "5240"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5240')
        aAdd(Self:aReg5240,{})
        nPos :=	Len (Self:aReg5240)
        aAdd (Self:aReg5240[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5240[nPos], Self:cReg)	              //Texto Fixo contendo o número o registro
        aAdd (Self:aReg5240[nPos], Self:nNumLan)            //Número do lançamento
        aAdd (Self:aReg5240[nPos], Self:dDtMov)             //Data de movimentação
        aAdd (Self:aReg5240[nPos], Self:cHist)              //Histórico
        aAdd (Self:aReg5240[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5240[nPos], Self:cSerie)             //Série do Documento
        aAdd (Self:aReg5240[nPos], Self:cNumDoc)            //Número do documento
        aAdd (Self:aReg5240[nPos], Self:nCodLan)            //Código de lançamento
        aAdd (Self:aReg5240[nPos], Self:nIndMov)            //Indicador de movimento
        aAdd (Self:aReg5240[nPos], IIF (Self:nIndMov=='0', Self:cProdMov,Self:cCodItem)) //Código do Item movimentado
        aAdd (Self:aReg5240[nPos],{Self:nQuant,  nTamQTD,'P'})    //Quantidade do item
        aAdd (Self:aReg5240[nPos],{Self:nCusto,  nTamCust,'P'})    //Custo do item
        aAdd (Self:aReg5240[nPos],{Self:nValICMS,nTamICM,'P'})    //Valor do ICMS
        aReg := Self:aReg5240
    ELSEIF cReg == "5275"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5275')
        aAdd(Self:aReg5275,{})
        nPos :=	Len (Self:aReg5275)
        aAdd (Self:aReg5275[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5275[nPos], Self:cReg)	              //Texto Fixo contendo o número o registro
        aAdd (Self:aReg5275[nPos], Self:nNumLan)            //Número do lançamento
        aAdd (Self:aReg5275[nPos], Self:dDtMov)             //Data de movimentação
        aAdd (Self:aReg5275[nPos], Self:cHist)              //Histórico
        aAdd (Self:aReg5275[nPos], Self:nCFOP)              //CFOP da Operação
        aAdd (Self:aReg5275[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5275[nPos], Self:cSerie)             //Série do Documento
        aAdd (Self:aReg5275[nPos], Self:cNumDoc)            //Número do documento
        aAdd (Self:aReg5275[nPos], Self:cCodPar)            //Código do Participante, conforme registro 0150
        aAdd (Self:aReg5275[nPos], Self:nCodLan)            //Código de lançamento
        aAdd (Self:aReg5275[nPos], Self:nIndMov)            //Indicador de movimento
        aAdd (Self:aReg5275[nPos], Self:cProdMov)           //Código do Item movimentado
        aAdd (Self:aReg5275[nPos],{Self:nQuant,  nTamQTD,'P'})    //Quantidade do item
        aAdd (Self:aReg5275[nPos],{Self:nCusto,  nTamCust,'P'})    //Custo do item
        aAdd (Self:aReg5275[nPos],{Self:nValICMS,nTamICM,'P'})    //Valor do ICMS
        aReg := Self:aReg5275
    ELSEIF cReg == "5315"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5315')
        aAdd(Self:aReg5315,{})
        nPos :=	Len (Self:aReg5315)
        aAdd (Self:aReg5315[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5315[nPos], Self:cReg)					//Texto Fixo contendo o número o registro
        aAdd (Self:aReg5315[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5315[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5315[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5315[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5315[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5315[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5315[nPos], Self:nCFOP)              //CFOP da Operação
        aAdd (Self:aReg5315[nPos], Self:cCodPar)				//Código do Participante
        aAdd (Self:aReg5315[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5315[nPos], Self:nIndMov)				//Indicador de movimento
        aAdd (Self:aReg5315[nPos],{Self:nQuant,  nTamQTD,'P'})	//Quantidade do item
        aAdd (Self:aReg5315[nPos],{Self:nCusto,  nTamCust,'P'})	//Custo do item
        aAdd (Self:aReg5315[nPos],{Self:nValICMS,nTamICM,'P'})	//Valor do ICMS
        aAdd (Self:aReg5315[nPos], Self:nPerCO)				//Percentual de Crédito Outorgado relativo ao item
        aAdd (Self:aReg5315[nPos], Self:nValCO)				//Valor do Crédito Outorgado relativo ao item
        aAdd (Self:aReg5315[nPos], Self:nValDesp)			//Valor do Crédito -Despesas Operacionais
        aReg := Self:aReg5315
    ELSEIF cReg == "5365"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5365')
        
        aAdd(Self:aReg5365,{})
        nPos :=	Len (Self:aReg5365)
        aAdd (Self:aReg5365[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5365[nPos], Self:cReg)					//Texto Fixo contendo o número o registro
        aAdd (Self:aReg5365[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5365[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5365[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5365[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5365[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5365[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5365[nPos], Self:nCFOP)				//CFOP da Operação
        aAdd (Self:aReg5365[nPos], Self:cNumDI)				//Número da DI ou DSI
        aAdd (Self:aReg5365[nPos], Self:cCodPar)				//Código do Participante, conforme registro 0150
        aAdd (Self:aReg5365[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5365[nPos], Self:nIndMov)				//Indicador de movimento
        aAdd (Self:aReg5365[nPos],{Self:nQuant,  nTamQTD,'P'})	//Quantidade do item
        aAdd (Self:aReg5365[nPos],{Self:nCusto,  nTamCust,'P'})	//Custo do item
        aAdd (Self:aReg5365[nPos],{Self:nValICMS,nTamICM,'P'})	//Valor do ICMS
        aAdd (Self:aReg5365[nPos], Self:nPerCO)				//Percentual de Crédito Outorgado relativo ao item
        aAdd (Self:aReg5365[nPos], Self:nValCO)				//Valor do Crédito Outorgado relativo ao item
        aAdd (Self:aReg5365[nPos], Self:nValDesp)			//Valor do Crédito -Despesas Operacionais
        aReg := Self:aReg5365
    ELSEIF cReg == "5415"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5415')
        aAdd(Self:aReg5415,{})
        nPos :=	Len (Self:aReg5415)
        aAdd (Self:aReg5415[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5415[nPos], Self:cReg)					//Texto Fixo contendo o número o registro
        aAdd (Self:aReg5415[nPos], Self:nNumLan)				//Número do lançamento
        aAdd (Self:aReg5415[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5415[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5415[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5415[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5415[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5415[nPos], Self:nCFOP)				//CFOP da Operação
        aAdd (Self:aReg5415[nPos], Self:cCodPar)				//Código do Participante, conforme registro 0150
        aAdd (Self:aReg5415[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5415[nPos], Self:nIndMov)				//Indicador de movimento
        aAdd (Self:aReg5415[nPos],{Self:nQuant,  nTamQTD,'P'})	//Quantidade do item
        aAdd (Self:aReg5415[nPos],{Self:nCusto,  nTamCust,'P'})	//Custo do item
        aAdd (Self:aReg5415[nPos],{Self:nValICMS,nTamICM,'P'})	//Valor do ICMS
        aAdd (Self:aReg5415[nPos], Self:nPerCO)				//Percentual de Crédito Outorgado relativo ao item
        aAdd (Self:aReg5415[nPos], Self:nValCO)				//Valor do Crédito Outorgado relativo ao item
        aAdd (Self:aReg5415[nPos], Self:nValDesp)			//Valor do Crédito -Despesas Operacionais
        aReg := Self:aReg5415
    ELSEIF cReg == "5555"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5555')
        aAdd(Self:aReg5555,{})
        nPos :=	Len (Self:aReg5555)
        aAdd (Self:aReg5555[nPos], Self:cGrupoReg)			//Chave
        aAdd (Self:aReg5555[nPos], Self:cReg)					//Texto Fixo contendo o número o registro
        aAdd (Self:aReg5555[nPos], Self:nNumLan)				//Número da ordem -PENDENTE-
        aAdd (Self:aReg5555[nPos], Self:dDtMov)				//Data de movimentação
        aAdd (Self:aReg5555[nPos], Self:cHist)				//Histórico
        aAdd (Self:aReg5555[nPos], Self:nTpDoc)				//Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5555[nPos], Self:cSerie)				//Série do Documento
        aAdd (Self:aReg5555[nPos], Self:cNumDoc)				//Número do documento
        aAdd (Self:aReg5555[nPos], Self:nCFOP)				//CFOP da Operação
        aAdd (Self:aReg5555[nPos], Self:cCodPar)				//Código do Participante, conforme registro 0150
        aAdd (Self:aReg5555[nPos], Self:nCodLan)				//Código de lançamento
        aAdd (Self:aReg5555[nPos], Self:cProdMov)           //Código do Item movimentado
        aAdd (Self:aReg5555[nPos],{Self:nQTDMatRes,nTamQTD,'P'})	//Quantidade de Material resultante
        aAdd (Self:aReg5555[nPos], Self:nValMatRes)			//Valor de Saída do Material resultante
        aReg := Self:aReg5555
    ELSEIF  cReg == "5720"
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5720')
        aAdd(Self:aReg5720,{})
        nPos := Len (Self:aReg5720)
        aAdd (Self:aReg5720[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5720[nPos], Self:cReg)               //Texto Fixo contendo o número o registro
        aAdd (Self:aReg5720[nPos], Self:nOrdem)             //Número de Ordem
        aAdd (Self:aReg5720[nPos], Self:dDtMov)             //Data da Prestação
        aAdd (Self:aReg5720[nPos], Self:cHist)              //Histórico
        aAdd (Self:aReg5720[nPos], Self:nCFOP)              //CFOP da Operação
        aAdd (Self:aReg5720[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5720[nPos], Self:cSerie)             //Série do Documento
        aAdd (Self:aReg5720[nPos], Self:cNumDoc)            //Número do documento fiscal.
        aAdd (Self:aReg5720[nPos], Self:cCodRem)            //Código do remetente conforme registro 0150.
        aAdd (Self:aReg5720[nPos], Self:cCodDes)            //Código do destinatário conforme registro 0150.
        aAdd (Self:aReg5720[nPos], Self:cUFInic)            //UF de início do serviço de transporte.
        aAdd (Self:aReg5720[nPos], Self:cUFDest)            //UF de destino da mercadoria.
        aAdd (Self:aReg5720[nPos], Self:cCodTom)            //Código do tomador do serviço de transporte conforme registro 0150.
        aAdd (Self:aReg5720[nPos], Self:nAliq)              //Alíquota do ICMS aplicável à prestação.
        aAdd (Self:aReg5720[nPos], Self:nVpreng)            //Nas prestações não geradoras de crédito acumulado, indicar oValor Total da Prestação.
        aAdd (Self:aReg5720[nPos], Self:nIcmdeb)            //Nas prestações não geradoras de crédito acumulado, indicar oValor do ICMS Debitado.
        aAdd (Self:aReg5720[nPos], Self:nVprege)            //Nas prestações geradoras de crédito acumulado, indicar o ValorTotal da Prestação.
        aAdd (Self:aReg5720[nPos], Self:nIcmst)             //Indique o valor do ICMS devido pelo contribuinte substituto para fins de cálculo do Crédito Outorgado (Transportadora com opção regular).
        aAdd (Self:aReg5720[nPos], Self:nVcrout)            //Valor do Crédito Outorgado relativo à prestação própria.
        aAdd (Self:aReg5720[nPos], Self:nCroust)            //Valor do Crédito Outorgado relativo à prestação cujo pagamento do imposto está atribuído ao tomador do serviço (substituição tributária).
        aAdd (Self:aReg5720[nPos], Self:nCredac)            //Valor do Crédito Acumulado gerado na prestação.
        aAdd (Self:aReg5720[nPos], Self:nIcmsde)            //Valor do ICMS devido na prestação própria
        aReg := Self:aReg5720
    ELSEIF  cReg == "5730"
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5730')
        aAdd(Self:aReg5730,{})
        nPos := Len (Self:aReg5730)
        aAdd (Self:aReg5730[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5730[nPos], Self:cReg)               //Texto Fixo contendo o número o registro
        aAdd (Self:aReg5730[nPos], Self:nOrdem)             //Número de Ordem
        aAdd (Self:aReg5730[nPos], Self:dDtMov)             //Data da Prestação
        aAdd (Self:aReg5730[nPos], Self:cHist)              //Histórico
        aAdd (Self:aReg5730[nPos], Self:nCFOP)              //CFOP da Operação
        aAdd (Self:aReg5730[nPos], Self:nTpDoc)             //Tipo do documento conforme a coluna Código chave da tabela 4.
        aAdd (Self:aReg5730[nPos], Self:cSerie)             //Série do Documento
        aAdd (Self:aReg5730[nPos], Self:cNumDoc)            //Número do documento
        aAdd (Self:aReg5730[nPos], Self:cCodRem)            //Código do Remetente conforme registro 0150
        aAdd (Self:aReg5730[nPos], Self:cCodDes)            //Código do Destinatário conforme registro 0150
        aAdd (Self:aReg5730[nPos], Self:cUFInic)            //UF de Inicio do serviço de Transporte
        aAdd (Self:aReg5730[nPos], Self:cUFDest)            //UF de Destino do serviço de Transporte
        aAdd (Self:aReg5730[nPos], Self:cCodTom)            //Código do Tomador do serviço de transporte conforme registro 0150
        aAdd (Self:aReg5730[nPos], Self:nVeicul)            //Código de IdentIFicação do principal Veículo Rodoviário Transportador conforme registro 5725.
        aAdd (Self:aReg5730[nPos], Self:nKm)                //Distância percorrida
        aAdd (Self:aReg5730[nPos], Self:nEnqleg)            //Código do Enquadramento Legal conforme registro 0300
        aAdd (Self:aReg5730[nPos], Self:nAliq)              //Alíquota de ICMS aplicavel na Prestação
        aAdd (Self:aReg5730[nPos], Self:nVprest)            //Valor da Prestação
        aAdd (Self:aReg5730[nPos], Self:nIcmdeb)            //Valor do ICMS debitado pelo transportador na prestação
        aAdd (Self:aReg5730[nPos],{Self:nIndrat,nTamRat,'P'}) //Índice de Rateio
        aAdd (Self:aReg5730[nPos],{Self:nUcusto,nTamCust,'P'})//Valor do custo de cada serviço de transporte prestado.
        aAdd (Self:aReg5730[nPos],{Self:nUicms, nTamICM,'P'}) //Valor do ICMS referente ao custo de cada serviço de transporte prestado
        aAdd (Self:aReg5730[nPos], Self:nCredac)            //Valor do Crédito Acumulado gerado na prestação
        aAdd (Self:aReg5730[nPos], Self:nIcmsde)            //Valor do ICMS devido na prestação própria
        aReg := Self:aReg5730
        
    ENDIF
RETURN (aReg)



//-------------------------------------------------------------------
/*/{Protheus.doc} AddIpiOut
 
Método que gera os registros de informações de IPI e Outros Tributos na entrada
Registros: 5020,5070,5090,5370
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD AddIpiOut(cReg) CLASS BLOCO5
    //5020,5070,5090,5370,
    Local aReg := {}
    Local nTamIPI := TAMSX3("CLR_IPI")[2]
    Local nTamOUT  := TAMSX3("CLR_OUTROS")[2]

    
    IF cReg == "5020"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5020')
        aAdd(Self:aReg5020,{})
        nPos :=	Len (Self:aReg5020)
        aAdd (Self:aReg5020[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5020[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5020[nPos],{Self:nValIpi,nTamIPI,'P'})     //Valor do IPI quando recuperavel
        aAdd (Self:aReg5020[nPos],{Self:nValTri,nTamOUT,'P'})     //Valor de Outros Tributos e Contribuições não-cumulativos
        aReg := Self:aReg5020
    ELSEIF cReg == "5070"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5070')
        aAdd(Self:aReg5070,{})
        nPos :=	Len (Self:aReg5070)
        aAdd (Self:aReg5070[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5070[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5070[nPos],{Self:nValIpi,nTamIPI,'P'})     //Valor do IPI quando recuperavel
        aAdd (Self:aReg5070[nPos],{Self:nValTri,nTamOUT,'P'})     //Valor de outros tributos e contribuições não-cumulativos
        aReg := Self:aReg5070
    ELSEIF cReg == "5090"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5090')
        aAdd(Self:aReg5090,{})
        nPos :=	Len (Self:aReg5090)
        aAdd (Self:aReg5090[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5090[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5090[nPos],{Self:nValTri,nTamOUT,'P'})     //Valor de outros tributos e contribuições não-cumulativos
        aReg := Self:aReg5090
    ELSEIF cReg == "5370"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5370')
        aAdd(Self:aReg5370,{})
        nPos :=	Len (Self:aReg5370)
        aAdd (Self:aReg5370[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5370[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5370[nPos],{Self:nValIpi,nTamIPI,'P'})     //Valor do IPI quando recuperavel
        aAdd (Self:aReg5370[nPos],{Self:nValTri,nTamOUT,'P'})	    //Valor de outros tributos e contribuições não-cumulativos
        aReg := Self:aReg5370
    ENDIF
RETURN (aReg)





//-------------------------------------------------------------------
/*/{Protheus.doc} AddApurCus
 
Método que gera os registros de Apuração e Custos
Registros: 5155, 5170, 5235, 5270
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD AddApurCus(cReg) CLASS BLOCO5
    Local aReg := {}
    Local nTamQtdUt     :=  TAMSX3("CLU_QTDINS")[2]
    Local nTamCustUn    :=  TAMSX3("CLU_UNTCUS")[2]
    Local nTamICmUn     :=  TAMSX3("CLU_UNTICM")[2]
    Local nTamPer       :=  TAMSX3("CLU_PERDA")[2]
    Local nTamGan       :=  TAMSX3("CLU_GANHO")[2]
    Local nTamQtdCP     :=  TAMSX3("CLT_QTDE")[2] 
    Local nTamPrcMed    :=  TAMSX3("CLT_PRCUNI")[2] 
    Local nTamVlPrjS    :=  TAMSX3("CLT_VLPRJS")[2] 
    Local nTamPerAlc    :=  TAMSX3("CLT_PEATIC")[2] 

    IF cReg == "5155"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5155')
        aAdd(Self:aReg5155,{})
        nPos :=	Len (Self:aReg5155)
        aAdd (Self:aReg5155[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5155[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5155[nPos], Self:cProdIns)           //Código do Insumo conforme registro 0200
        aAdd (Self:aReg5155[nPos],{Self:nQtdInsUt, nTamQtdUt,'P'})  //Quantidade de Insumo Utilizada
        aAdd (Self:aReg5155[nPos],{Self:nCusUntIns,nTamCustUn,'P'})  //Custo Unitário do Insumo por Unidade de produto
        aAdd (Self:aReg5155[nPos],{Self:nVUntICMIn,nTamICmUn,'P'})  //Valor Unitário do ICMS do Insumo por Unidade de produto
        aAdd (Self:aReg5155[nPos],{Self:nPerdaNorm,nTamPer,'P'})  //Quantidade de Perda Normal no Processo Produtivo
        aAdd (Self:aReg5155[nPos],{Self:nGanhoNorm,nTamGan,'P'})  //Quantidade de Ganho Normal no Processo Produtivo
        aReg := Self:aReg5155
    ELSEIF cReg == "5170"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5170')
        aAdd(Self:aReg5170,{})
        nPos :=	Len (Self:aReg5170)
        aAdd (Self:aReg5170[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5170[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5170[nPos], Self:cProdIns)           //Código do Insumo conforme registro 0200
        aAdd (Self:aReg5170[nPos],{Self:nQtdInsUt, nTamQtdUt,'P'})  //Quantidade de Insumo Utilizada
        aAdd (Self:aReg5170[nPos],{Self:nCusUntIns,nTamCustUn,'P'})  //Custo Unitário do Insumo por Unidade de produto
        aAdd (Self:aReg5170[nPos],{Self:nVUntICMIn,nTamICmUn,'P'})  //Valor Unitário do ICMS do Insumo por Unidade de produto
        aAdd (Self:aReg5170[nPos],{Self:nPerdaNorm,nTamPer,'P'})  //Quantidade de Perda Normal no Processo Produtivo
        aAdd (Self:aReg5170[nPos],{Self:nGanhoNorm,nTamGan,'P'})  //Quantidade de Ganho Normal no Processo Produtivo
        aReg := Self:aReg5170
    ELSEIF cReg == "5235"
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5235')
        aAdd(Self:aReg5235,{})
        nPos := Len (Self:aReg5235)
        aAdd (Self:aReg5235[nPos], Self:cGrupoReg)          //Chave
        aAdd (Self:aReg5235[nPos], cReg)                    //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5235[nPos],Self:cCoProd)     //Código do co-produto, conforme Registro 0200
        aAdd (Self:aReg5235[nPos],{Self:nQtdCoPr,nTamQtdCP,'P'})     //Quantidade de Co-Produto resultante do Insumo conjunto no período.
        aAdd (Self:aReg5235[nPos],{Self:nPrcMed, nTamQtdCP,'P'})     //Preço Médio de Saída do Co-Produt
        aAdd (Self:aReg5235[nPos],{Self:nVlPrjS, nTamVlPrjS,'P'})     //Valor Projetado das Saída
        aAdd (Self:aReg5235[nPos],{Self:nPercAlc,nTamPerAlc,'P'})    //Percentual de alocação do custo e ICMS do insumo-conjunto para o co-produto obtido na coluna 5 da Ficha 4B
        aReg := Self:aReg5235
    ELSEIF cReg == "5270"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5270')
        aAdd(Self:aReg5270,{})
        nPos :=	Len (Self:aReg5270)
        aAdd (Self:aReg5270[nPos],Self:cGrupoReg)	      //Chave
        aAdd (Self:aReg5270[nPos],cReg)				       //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5270[nPos],Self:cProdIns)		       //Código do Insumo conforme registro 0200
        aAdd (Self:aReg5270[nPos],{Self:nQtdInsUt, nTamQtdUt,'P'})	//Quantidade de Insumo Utilizada
        aAdd (Self:aReg5270[nPos],{Self:nCusUntIns,nTamCustUn,'P'})	//Custo Unitário do Insumo por Unidade do co-produto
        aAdd (Self:aReg5270[nPos],{Self:nVUntICMIn,nTamICmUn,'P'})	//Valor Unitário do ICMS do Insumo por Unidade o co-pproduto
        aAdd (Self:aReg5270[nPos],{Self:nPerdaNorm,nTamPer,'P'})	//Quantidade de Perda Normal no Processo Produtivo
        aAdd (Self:aReg5270[nPos],{Self:nGanhoNorm,nTamGan,'P'})	//Quantidade de Ganho Normal no Processo Produtivo
        aReg := Self:aReg5270
    ENDIF
    
RETURN (aReg)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddDevSai
 
Método que gera os registros referente a Devolução de Saída
Registros: 5320, 5375, 5420
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD AddDevSai(cReg) CLASS BLOCO5
    Local aReg := {}
    
    IF cReg == "5320"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5320')
        aAdd(Self:aReg5320,{})
        nPos :=	Len (Self:aReg5320)
        aAdd (Self:aReg5320[nPos],Self:cGrupoReg)		//Chave
        aAdd (Self:aReg5320[nPos],cReg)					//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5320[nPos],Self:dDtSai)			//Data da emissão do documento fiscal que acobertou a operação original do item devolvido
        aAdd (Self:aReg5320[nPos],Self:nTipDocDev)      //Tipo do documento conforme a coluna Código chave da tabela 4.2 ou campo 02 do registro 0400
        aAdd (Self:aReg5320[nPos],Self:cSerieDev)		//Série do documento que acobertou a operação original
        aAdd (Self:aReg5320[nPos],Self:cDocDev)	       //Número do documento que acobertou a operação original
        aReg := Self:aReg5320
    ELSEIF cReg == "5375"
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5375')
        aAdd(Self:aReg5375,{})
        nPos := Len (Self:aReg5375)
        aAdd (Self:aReg5375[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5375[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5375[nPos],Self:dDtSai)          //Data da emissão do documento fiscal que acobertou a operação original do item devolvido
        aAdd (Self:aReg5375[nPos],Self:nTipDocDev)      //Tipo do documento conforme a coluna Código chave da tabela 4.2 ou campo 02 do registro 0400
        aAdd (Self:aReg5375[nPos],Self:cSerieDev)       //Série do documento que acobertou a operação original
        aAdd (Self:aReg5375[nPos],Self:cDocDev)         //Número do documento que acobertou a operação original
        aReg := Self:aReg5375
    ELSEIF cReg == "5420"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5420')
        aAdd(Self:aReg5420,{})
        nPos :=	Len (Self:aReg5420)
        aAdd (Self:aReg5420[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5420[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5420[nPos],Self:dDtSai)          //Data da emissão do documento fiscal que acobertou a operação original do item devolvido
        aAdd (Self:aReg5420[nPos],Self:nTipDocDev)      //Tipo do documento conforme a coluna Código chave da tabela 4.2 ou campo 02 do registro 0400
        aAdd (Self:aReg5420[nPos],Self:cSerieDev)       //Série do documento que acobertou a operação original
        aAdd (Self:aReg5420[nPos],Self:cDocDev)         //Número do documento que acobertou a operação original
        aReg := Self:aReg5420
    ENDIF
RETURN (aReg)


//-------------------------------------------------------------------
/*/{Protheus.doc} AddOpCrdAc
 
Método referente as operações geradoras de crédito acumulado
Registros: 5325, 5380,5425
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD AddOpCrdAc(cReg) CLASS BLOCO5
    Local aReg := {}
    
    IF cReg == "5325"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5325')
        aAdd(Self:aReg5325,{})
        nPos :=	Len (Self:aReg5325)
        aAdd (Self:aReg5325[nPos],Self:cGrupoReg)   //Chave
        aAdd (Self:aReg5325[nPos],cReg)             //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5325[nPos],Self:nCodLeg)		//Código do Enquadramento Legal
        aAdd (Self:aReg5325[nPos],Self:nVlOpIt)		//Valor Total da Operação relativo ao Item
        aAdd (Self:aReg5325[nPos],Self:nCredAc)		//Credito acumulado Gerado na Operação com o Item
        aReg := Self:aReg5325
    ELSEIF 	cReg == "5380"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5380')
        aAdd(Self:aReg5380,{})
        nPos :=	Len (Self:aReg5380)
        aAdd (Self:aReg5380[nPos],Self:cGrupoReg)   //Chave
        aAdd (Self:aReg5380[nPos],cReg)             //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5380[nPos],Self:nCodLeg)		//Código do Enquadramento Legal
        aAdd (Self:aReg5380[nPos],Self:nVlOpIt)		//Valor Total da Operação relativo ao Item
        aAdd (Self:aReg5380[nPos],Self:nCredAc)		//Credito acumulado Gerado na Operação com o Item
        aReg := Self:aReg5380
    ELSEIF 	cReg == "5425"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5425')
        aAdd(Self:aReg5425,{})
        nPos :=	Len (Self:aReg5425)
        aAdd (Self:aReg5425[nPos],Self:cGrupoReg)   //Chave
        aAdd (Self:aReg5425[nPos],cReg)             //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5425[nPos],Self:nCodLeg)     //Código do Enquadramento Legal
        aAdd (Self:aReg5425[nPos],Self:nVlOpIt)     //Valor Total da Operação relativo ao Item
        aAdd (Self:aReg5425[nPos],Self:nCredAc)     //Credito acumulado Gerado na Operação com o Item
        aReg := Self:aReg5425
    ENDIF
RETURN (aReg)



//-------------------------------------------------------------------
/*/{Protheus.doc} AddOp6A6B
 
Método referente as operações geradoras apuradas nas fichas 6A/6B
Registros: 5330, 5385,5430
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD AddOp6A6B(cReg) CLASS BLOCO5
    Local aReg := {}
    
    IF  cReg == "5330"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5330')
        aAdd(Self:aReg5330,{})
        nPos :=	Len (Self:aReg5330)
        aAdd (Self:aReg5330[nPos],Self:cGrupoReg)		//Chave
        aAdd (Self:aReg5330[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5330[nPos],Self:nBCIt)           //Base de Cálculo da Operação de saída relativa ao item
        aAdd (Self:aReg5330[nPos],Self:nAlqIt)          //Alíquota de ICMS da Operação de saída relativa ao Item
        aAdd (Self:aReg5330[nPos],Self:nICMDeb)         //Icms debitado na operação de saída do item
        aReg := Self:aReg5330
    ELSEIF 	cReg == "5385"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5385')
        aAdd(Self:aReg5385,{})
        nPos :=	Len (Self:aReg5385)
        aAdd (Self:aReg5385[nPos],Self:cGrupoReg)		//Chave
        aAdd (Self:aReg5385[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5385[nPos],Self:nBCIt)           //Base de Cálculo da Operação de saída relativa ao item
        aAdd (Self:aReg5385[nPos],Self:nAlqIt)			//Alíquota de ICMS da Operação de saída relativa ao Item
        aAdd (Self:aReg5385[nPos],Self:nICMDeb)         //Icms debitado na operação de saída do item
        aReg := Self:aReg5385
    ELSEIF 	cReg == "5430"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5430')
        aAdd(Self:aReg5430,{})
        nPos :=	Len (Self:aReg5430)
        aAdd (Self:aReg5430[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5430[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5430[nPos],Self:nBCIt)           //Base de Cálculo da Operação de saída relativa ao item
        aAdd (Self:aReg5430[nPos],Self:nAlqIt)			//Alíquota de ICMS da Operação de saída relativa ao Item
        aAdd (Self:aReg5430[nPos],Self:nICMDeb)         //Icms debitado na operação de saída do item
        aReg := Self:aReg5430
    ENDIF
RETURN (aReg)



//-------------------------------------------------------------------
/*/{Protheus.doc} AddOp6C6D
 
Método referente as operações geradoras apuradas nas fichas 6C/6D
Registros: 5335, 5390,5435
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
METHOD AddOp6C6D(cReg) CLASS BLOCO5
    Local aReg := {}
    
    IF 	cReg == "5335"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5335')
        aAdd(Self:aReg5335,{})
        nPos :=	Len (Self:aReg5335)
        aAdd (Self:aReg5335[nPos],Self:cGrupoReg)		//Chave
        aAdd (Self:aReg5335[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5335[nPos],Self:nDecEx)          //Número da Declaração para Despacho
        aAdd (Self:aReg5335[nPos],Self:nCompOp)         //Comprovação de Operação
        aAdd (Self:aReg5335[nPos],Self:nVlCrICM)        //Valor do Crédito de ICMS
        aReg := Self:aReg5335
    ELSEIF 	cReg == "5390"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5390')
        aAdd(Self:aReg5390,{})
        nPos :=	Len (Self:aReg5390)
        aAdd (Self:aReg5390[nPos],Self:cGrupoReg)		//Chave
        aAdd (Self:aReg5390[nPos],cReg)					//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5390[nPos],Self:nDecEx)			//Número da Declaração para Despacho
        aAdd (Self:aReg5390[nPos],Self:nCompOp)         //Comprovação de Operação
        aAdd (Self:aReg5390[nPos],Self:nVlCrICM)        //Valor do Crédito de ICMS
        aReg := Self:aReg5390
    ELSEIF 	cReg == "5435"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5435')
        aAdd(Self:aReg5435,{})
        nPos :=	Len (Self:aReg5435)
        aAdd (Self:aReg5435[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5435[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5435[nPos],Self:nDecEx)          //Número da Declaração para Despacho
        aAdd (Self:aReg5435[nPos],Self:nCompOp)         //Comprovação de Operação
        aAdd (Self:aReg5435[nPos],Self:nVlCrICM)        //Valor do Crédito de ICMS
        aReg := Self:aReg5435
    ENDIF
RETURN (aReg)


//-------------------------------------------------------------------
/*/{Protheus.doc} AddExpInd
 
Método referente dados de Exportação Indireta Comprovada FICHA 5H
Registros: 5340, 5395
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------
METHOD AddExpInd(cReg) CLASS BLOCO5
    Local aReg := {}
    
    IF cReg == "5340"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5340')
        aAdd(Self:aReg5340,{})
        nPos :=	Len (Self:aReg5340)
        aAdd (Self:aReg5340[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5340[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5340[nPos],Self:dDtExp)          //Data do Documento Fiscal do Exportador
        aAdd (Self:aReg5340[nPos],Self:cDocExp)         //Número do Documento Fiscal do Exportador
        aAdd (Self:aReg5340[nPos],Self:cSerExp)         //Série do Documento Fiscal do Exportador
        aAdd (Self:aReg5340[nPos],Self:cDeclaEx)        //Número da Declaração para Despacho de Exportação do Exportador
        aReg := Self:aReg5340
    ELSEIF cReg == "5395"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5395')
        aAdd(Self:aReg5395,{})
        nPos :=	Len (Self:aReg5395)
        aAdd (Self:aReg5395[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5395[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5395[nPos],Self:dDtExp)          //Data do Documento Fiscal do Exportador
        aAdd (Self:aReg5395[nPos],Self:cDocExp)         //Número do Documento Fiscal do Exportador
        aAdd (Self:aReg5395[nPos],Self:cSerExp)         //Série do Documento Fiscal do Exportador
        aAdd (Self:aReg5395[nPos],Self:cDeclaEx)        //Número da Declaração para Despacho de Exportação do Exportador
        aReg := Self:aReg5395
    ENDIF
    
RETURN (aReg)


//-------------------------------------------------------------------
/*/{Protheus.doc} AddNGer
 
Método referente a Operação não geradora de crédito acumulado - FICHA6F
Registros: 5350,5400, 5440
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------
METHOD AddNGer(cReg) CLASS BLOCO5
    Local aReg := {}
    
    IF 	cReg == "5350"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5350')
        aAdd(Self:aReg5350,{})
        nPos :=	Len (Self:aReg5350)
        aAdd (Self:aReg5350[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5350[nPos],cReg)					//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5350[nPos],Self:nVlOpIt)         //Valor Total da Operação relativo ao Item
        aAdd (Self:aReg5350[nPos],Self:nBCIt)           //Base de Cálculo da Operação de saída relativa ao item
        aAdd (Self:aReg5350[nPos],Self:nAlqIt)			//Alíquota de ICMS da Operação de saída relativa ao Item
        aAdd (Self:aReg5350[nPos],Self:nICMDeb)         //Icms debitado na operação de saída do item
        aAdd (Self:aReg5350[nPos],Self:nICMDev)         //Icms devido na operação de saída relativo ao item
        aAdd (Self:aReg5350[nPos],Self:nVlCrICM)        //Valor do Crédito de ICMS
        aReg := Self:aReg5350
    ELSEIF 	cReg == "5400"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5400')
        aAdd(Self:aReg5400,{})
        nPos :=	Len (Self:aReg5400)
        aAdd (Self:aReg5400[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5400[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5400[nPos],Self:nVlOpIt)         //Valor Total da Operação relativo ao Item
        aAdd (Self:aReg5400[nPos],Self:nBCIt)           //Base de Cálculo da OperaADção de saída relativa ao item
        aAdd (Self:aReg5400[nPos],Self:nAlqIt)          //Alíquota de ICMS da Operação de saída relativa ao Item
        aAdd (Self:aReg5400[nPos],Self:nICMDeb)         //Icms debitado na operação de saída do item
        aAdd (Self:aReg5400[nPos],Self:nICMDev)		   //Icms devido na operação de saída relativo ao item
        aAdd (Self:aReg5400[nPos],Self:nVlCrICM)		   //Valor do Crédito de ICMS
        aReg := Self:aReg5400
    ELSEIF     cReg == "5440"
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5440')
        aAdd(Self:aReg5440,{})
        nPos := Len (Self:aReg5440)
        aAdd (Self:aReg5440[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5440[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5440[nPos],Self:nVlOpIt)         //Valor Total da Operação relativo ao Item
        aAdd (Self:aReg5440[nPos],Self:nBCIt)           //Base de Cálculo da Operação de saída relativa ao item
        aAdd (Self:aReg5440[nPos],Self:nAlqIt)          //Alíquota de ICMS da Operação de saída relativa ao Item
        aAdd (Self:aReg5440[nPos],Self:nICMDeb)         //Icms debitado na operação de saída do item
        aAdd (Self:aReg5440[nPos],Self:nICMDev)         //Icms devido na operação de saída relativo ao item
        aAdd (Self:aReg5440[nPos],Self:nVlCrICM)        //Valor do Crédito de ICMS
        aReg := Self:aReg5440
    ENDIF
RETURN (aReg)



//-------------------------------------------------------------------
/*/{Protheus.doc} AddVeiculo
 
Método referente a geração  do Registro 5725
Registros: 5725
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------
METHOD AddVeiculo(cReg) CLASS BLOCO5
    Local aReg := {}
    Local nTamRend  := TAMSX3("CLX_RCOMB")[2]

    IF cReg == "5725"
        Self:cGrupoReg		:= SeqCat83(@Self:aNumeracao,Self:cRelac, '5725')
        aAdd(Self:aReg5725,{})
        nPos :=	Len (Self:aReg5725)
        aAdd (Self:aReg5725[nPos], Self:cGrupoReg)		//Chave
        aAdd (Self:aReg5725[nPos], cReg)					//Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5725[nPos], Self:cCodVeic)		//Código de IndentIFicação do Veículo Transportador
        aAdd (Self:aReg5725[nPos], Self:nCNPJ)			//CNPJ do Proprietário
        aAdd (Self:aReg5725[nPos], Self:cPlc)				//Placa do Veículo
        aAdd (Self:aReg5725[nPos], Self:cUFVeic)			//Unidade de Federação de Registro do Veículo
        aAdd (Self:aReg5725[nPos], Self:cMunc)			//Município
        aAdd (Self:aReg5725[nPos], Self:cRenav)			//Número do Renavan
        aAdd (Self:aReg5725[nPos], Self:cMarc)			//Marca do Veículo
        aAdd (Self:aReg5725[nPos], Self:cModel)			//Modelo do Veículo
        aAdd (Self:aReg5725[nPos], Self:nAno)				//Ano de Fabricação
        aAdd (Self:aReg5725[nPos],{Self:nRend,nTamRend,'P'})	//Rendimento do Combustível
        aReg := Self:aReg5725
    ENDIF
RETURN (aReg)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddInv
 
Método referente a geração  do Registro de Inventário
Registros: 5590,5595
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------
METHOD AddInv(cReg) CLASS BLOCO5
    Local aReg := {}
    Local nTamCust := TAMSX3("CLV_VALCUS")[2]
    Local nTamICM  := TAMSX3("CLV_VALICM")[2]
    Local nTamQTD  := TAMSX3("CLV_QUANT")[2]
    
    IF cReg == "5590"
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5590')
        aAdd(Self:aReg5590,{})
        nPos := Len (Self:aReg5590)
        aAdd (Self:aReg5590[nPos], Self:cGrupoReg)      //Chave
        aAdd (Self:aReg5590[nPos], Self:cReg)           //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5590[nPos], Self:cPrdInv)         //Codigo do produto em elaboração conforme registro 0200
        aReg := Self:aReg5590
    ELSEIF cReg == "5595"
        Self:cGrupoReg      := SeqCat83(@Self:aNumeracao,Self:cRelac, '5595')
        aAdd(Self:aReg5595,{})
        nPos := Len (Self:aReg5595)
        aAdd (Self:aReg5595[nPos],Self:cGrupoReg)       //Chave
        aAdd (Self:aReg5595[nPos],cReg)                 //Texto Fixo contendo o número do Registro
        aAdd (Self:aReg5595[nPos],Self:cInsInv)         //Código do Insumo conforme registro 0200
        aAdd (Self:aReg5595[nPos],{Self:nQTDIn, nTamQTD,'P'}) //Quantidade do Insumo Utilizado
        aAdd (Self:aReg5595[nPos],{Self:nCust,  nTamCust,'P'}) //Custo do Insumo
        aAdd (Self:aReg5595[nPos],{Self:nICMIns,nTamICM,'P'}) //Valor do ICMS do Insumo
        aReg := Self:aReg5595
        

    ENDIF    
RETURN (aReg)



//-------------------------------------------------------------------
/*/{Protheus.doc} Clear
 
Métodos que Limpa o array dos registros
            
@author Graziele Paro
@since 10/07/2015

/*/
//------------------------------------------------------------------
METHOD Clear(nReg) CLASS BLOCO5
    Local aReg:= {}
    
    IF nReg == "5010"
        aReg:= Self:aReg5010:= {}
    ELSEIF nReg == "5015"
        aReg:= Self:aReg5015:= {}
    ELSEIF nReg == "5020"
        aReg:= Self:aReg5020:= {}
    ELSEIF nReg == "5060"
        aReg:= Self:aReg5060:= {}
    ELSEIF nReg == "5065"
        aReg:= Self:aReg5065:= {}
    ELSEIF nReg == "5070"
        aReg:= Self:aReg5070:= {}
    ELSEIF nReg == "5080"
        aReg:= Self:aReg5080:= {}
    ELSEIF nReg == "5085"
        aReg:= Self:aReg5085:= {}
    ELSEIF nReg == "5090"
        aReg:= Self:aReg5090:= {}
    ELSEIF nReg == "5100"
        aReg:= Self:aReg5100:= {}
    ELSEIF nReg == "5105"
        aReg:= Self:aReg5105:= {}
    ELSEIF nReg == "5110"
        aReg:= Self:aReg5110:= {}
    ELSEIF nReg == "5115"
        aReg:= Self:aReg5115:= {}
    ELSEIF nReg == "5150"
        aReg:= Self:aReg5150:= {}
    ELSEIF nReg == "5155"
        aReg:= Self:aReg5155:= {}
    ELSEIF nReg == "5160"
        aReg:= Self:aReg5160:= {}
    ELSEIF nReg == "5165"
        aReg:= Self:aReg5165:= {}
    ELSEIF nReg == "5170"
        aReg:= Self:aReg5170:= {}
    ELSEIF nReg == "5175"
        aReg:= Self:aReg5175:= {}
    ELSEIF nReg == "5180"
        aReg:= Self:aReg5180:= {}
    ELSEIF nReg == "5185"
        aReg:= Self:aReg5185:= {}
    ELSEIF nReg == "5190"
        aReg:= Self:aReg5190:= {}
    ELSEIF nReg == "5195"
        aReg:= Self:aReg5195:= {}
    ELSEIF nReg == "5210"
        aReg:= Self:aReg5210:= {}
    ELSEIF nReg == "5215"
        aReg:= Self:aReg5215:= {}
    ELSEIF nReg == "5230"
        aReg:= Self:aReg5230:= {}
    ELSEIF nReg == "5235"
        aReg:= Self:aReg5235:= {}
    ELSEIF nReg == "5240"
        aReg:= Self:aReg5240:= {}
    ELSEIF nReg == "5260"
        aReg:= Self:aReg5260:= {}
    ELSEIF nReg == "5265"
        aReg:= Self:aReg5265:= {}
    ELSEIF nReg == "5270"
        aReg:= Self:aReg5270:= {}
    ELSEIF nReg == "5275"
        aReg:= Self:aReg5275:= {}
    ELSEIF nReg == "5310"
        aReg:= Self:aReg5310:= {}
    ELSEIF nReg == "5315"
        aReg:= Self:aReg5315:= {}
    ELSEIF nReg == "5320"
        aReg:= Self:aReg5320:= {}
    ELSEIF nReg == "5325"
        aReg:= Self:aReg5325:= {}
    ELSEIF nReg == "5330"
        aReg:= Self:aReg5330:= {}
    ELSEIF nReg == "5335"
        aReg:= Self:aReg5335:= {}
    ELSEIF nReg == "5340"
        aReg:= Self:aReg5340:= {}
    ELSEIF nReg == "5350"
        aReg:= Self:aReg5350:= {}
    ELSEIF nReg == "5360"
        aReg:= Self:aReg5360:= {}
    ELSEIF nReg == "5365"
        aReg:= Self:aReg5365:= {}
    ELSEIF nReg == "5370"
        aReg:= Self:aReg5370:= {}
    ELSEIF nReg == "5375"
        aReg:= Self:aReg5375:= {}
    ELSEIF nReg == "5380"
        aReg:= Self:aReg5380:= {}
    ELSEIF nReg == "5385"
        aReg:= Self:aReg5385:= {}
    ELSEIF nReg == "5390"
        aReg:= Self:aReg5390:= {}
    ELSEIF nReg == "5395"
        aReg:= Self:aReg5395:= {}
    ELSEIF nReg == "5400"
        aReg:= Self:aReg5400:= {}
    ELSEIF nReg == "5410"
        aReg:= Self:aReg5410:= {}
    ELSEIF nReg == "5415"
        aReg:= Self:aReg5415:= {}
    ELSEIF nReg == "5420"
        aReg:= Self:aReg5420:= {}
    ELSEIF nReg == "5425"
        aReg:= Self:aReg5425:= {}
    ELSEIF nReg == "5430"
        aReg:= Self:aReg5430:= {}
    ELSEIF nReg == "5435"
        aReg:= Self:aReg5435:= {}
    ELSEIF nReg == "5440"
        aReg:= Self:aReg5440:= {}
    ELSEIF nReg == "5550"
        aReg:= Self:aReg5550:= {}
    ELSEIF nReg == "5555"
        aReg:= Self:aReg5555:= {}
    ELSEIF nReg == "5590"
        aReg:= Self:aReg5590:= {}
    ELSEIF nReg == "5595"
        aReg:= Self:aReg5595:= {}
    ELSEIF nReg == "5720"
        aReg:= Self:aReg5720:= {}
    ELSEIF nReg == "5725"
        aReg:= Self:aReg5725:= {}
    ELSEIF nReg == "5730"
        aReg:= Self:aReg5730:= {}
    ENDIF
RETURN aReg


