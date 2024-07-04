#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWEBSRV.CH" 
#INCLUDE "AUTODEF.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "LOJXFUNI.CH"
#INCLUDE "FILEIO.CH"

#DEFINE _PICTURE		16                                                  // Picture
#DEFINE __FORMATEF	"CC;CD"

Static lMvLjPdvPa   := LjxBGetPaf()[2]	// Indica se e pdv
Static aFilRet      := {}                                                  	// Filiais da retaguarda
Static cCodfilial   := ""													// Codigo Filial p retorno						
Static aBrowseCar 	:= {}                                          			// Array browser Contas a Receber - CAR 
Static aBrowseCap 	:= {}                                         			// Array browser Contas a Pagar   - CAP 
Static oBrowseCar  	:= Nil													// Objeto Browse Contas a Receber - CAR
Static oBrowseCap  	:= Nil										   			// Objeto Browse Contas a Pagar   - CAP

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณLJVERINCNCCณ Autor ณ Vendas Cliente       ณ Data ณ26/11/10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Metodo Gera Ncc para desconto na proxima compra  		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExpL1:= LJGerTitNV()                               		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ															  ณฑฑ
ฑฑณ          ณ 															  ณฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno	 ณ ExpL1 = .T.             									  ณฑฑ
ฑฑณ          ณ                                     						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ 		 													  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LJSelIncTit( aInfoComp	,cTabTit)  

Local lRet		 	:=	.T.														// Retorno da funcao
Local lMVLJPDVPA	:=	LjxBGetPaf()[2] 		// Indica PDV ativo 
Local nX 			:=	0														// Contador de For
Local cSerEst		:=	LjGetStation("LG_SERIE")								// Serie do cadastro de estacao
Local dDatValid     :=	""                                                      // Data de Validade da Regra de Desconto
Local dL1EmisNf     :=	""                                                      // Data Emissao da NF
Local cL1Oper       :=	""                     									// Operador
Local cL1Cliente    :=	"" 														// Cliente
Local cL1Doc		:=  ""     													// Numero do documento
Local cL1Serie      := 	""             											// Numero de Serie
Local nValorNcc     :=	0                                                   	// Valor total dos Descontos
Local cL1Loja       :=	""        												// Loja 
Local nTotalTit		:=	0	    												// Valor total do Titulo com os Descontos Proporcionais.
Local nValTotIt		:=	0                                                       // Total da soma dos valores dos itens. 
Local nVlrTotVen	:=	0                										// Valor Total Real da Venda.
Local nVlrTotIte    :=	0														// Valor da soma dos itens.
Local nPorcProIt    :=	0														// Valor Porcentagem Proporcional do Item.
Local aMDJ          :=	{}                                                      // Array com Itens da Ncc que nใo criou.
Local aItProDesc    :=	{} 														// Array com Itens e informa็oes de descontos

Local oSvc																		// Objeto do WebService

Default aInfoComp	:=  {}
Default	cTabTit		:=	"SL1"


If cTabTit == "SL1"
	cL1Doc   	:= If(Empty(SL1->L1_DOC),SL1->L1_DOCPED,SL1->L1_DOC)
	cL1Serie 	:= If(Empty(SL1->L1_SERIE),SL1->L1_SERPED,SL1->L1_SERIE)
	cL1Oper     := (SL1->L1_OPERADO)
	cL1Cliente  := (SL1->L1_CLIENTE)
	cL1Loja		:= (SL1->L1_LOJA)
	dDatValid   := (aInfoComp[1][4])
	dL1EmisNf   := (SL1->L1_EMISNF)
	nVlrTotVen  := (SL1->L1_VLRTOT) - (SL1->L1_DESCONT + SL1->L1_CREDITO)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	Rotina que roda o array e soma todos os descontos	ณ
	//ณ				dos Itens Lan็ados na Venda				ณ
	//ณ	nTotalTit := Soma dos descontos dos itens no Array	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 To Len(aInfoComp)
		nVlrTotIte := nVlrTotIte + aInfoComp[nX][2]
	Next nX
	If !(nVlrTotIte == nVlrTotVen)
		For nX := 1 To Len(aInfoComp)
			nPorcProIt	:= (aInfoComp[nX][2]/nVlrTotIte)
	    	nValTotIt	:= (nVlrTotVen*nPorcProIt)
		    nValTotIt	:= (nValTotIt*(aInfoComp[nX][3]/100))
		    nTotalTit	:= (nTotalTit+nValTotIt)
		Next nX                           
	Else
		nTotalTit := nVlrTotIte
    EndIf
ElseIf cTabTit == "MDJ" 
	cL1Doc   	:= MDJ->MDJ_DOC
	cL1Serie 	:= MDJ->MDJ_SERIE
	cL1Oper     := MDJ->MDJ_OPERAD
	cL1Cliente  := MDJ->MDJ_CLIENT
	cL1Loja		:= MDJ->MDJ_LOJA
	dDatValid   := MDJ->MDJ_EMIS
	dL1EmisNf   := dDataBase
	nValorNcc   := MDJ->MDJ_CREDIT
EndIf


If lMVLJPDVPA .OR. nModulo == 23   
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณChama o Method INCNVTIT para que seja realizada a   ณ
	//ณ          inclusao da NCC COM WEBSERVICE            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicia conexao com o WebService para inclusao de NCCs ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oSvc := WSWSINCLUNCC():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autentica็ใo do Web Service
	oSvc :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/WSINCLUNCC.apw"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	Passa para o WebService as variaveis necessarias para realizar a baixa ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oSvc:ccL1Doc 		:= cL1Doc
	oSvc:ccL1Serie 		:= cL1Serie
	oSvc:ccL1Oper 		:= cL1Oper
	oSvc:ddL1EmisNf		:= dL1EmisNf
	oSvc:ccL1Cliente	:= cL1Cliente
	oSvc:ccL1Loja		:= cL1Loja
	oSvc:ccSerEst		:= cSerEst
	oSvc:ccEmpPdv		:= cEmpAnt	
	oSvc:ccFilPdv		:= cFilAnt	
	oSvc:ddDatValid     := dDatValid
	oSvc:nnValorNcc     := nTotalTit
	oSvc:llMvLjPdvPa	:= lMvLjPdvPa
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ                  EXECULTA METHOD INCNVTIT              ณ
	//ณ       "STR0001""Aguarde...Gerando Nova NCC..."		   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LJMsgRun( STR0001,, { || lRet := oSvc:INCNVTIT() } )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Tratamento de Erro para Grava็ใo do Titulo.ณ
	//ณ        Caso nใo tenha incluido o Titulo.   ณ
	//ณ Salva os dados do Titulo na Tabela [ MDJ ].ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If !lRet
		cSvcError := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
		EndIf
		MsgStop(STR0002,STR0003)	//"Sem comunicacao com o WebService!"+"Atencao"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApresenta mensagem de erro na consulta WebServiceณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Len(aInfoComp) > 0 .AND. cTabTit == "SL1"
			// Grava as NCCs para uma baixa automatica posteriormente
			Aadd(aMDJ,{"MDJ_FILIAL"  	,xFilial("MDJ")	})
			Aadd(aMDJ,{"MDJ_DOC"  	 	,cL1Doc})
			Aadd(aMDJ,{"MDJ_SERIE"   	,cL1Serie})
			Aadd(aMDJ,{"MDJ_CLIENT" 	,cL1Cliente})
			Aadd(aMDJ,{"MDJ_LOJA"  	 	,cL1Loja})
			Aadd(aMDJ,{"MDJ_OPERAD" 	,cL1Oper})
			Aadd(aMDJ,{"MDJ_EMIS"   	,dL1EmisNf})
			Aadd(aMDJ,{"MDJ_DTVAL"   	,dDatValid})
			Aadd(aMDJ,{"MDJ_NCCUSA"  	,Frt060Ret("NCC_USADA")})
			Aadd(aMDJ,{"MDJ_NCCGER" 	,Frt060Ret("NCC_GERADA")})
			Aadd(aMDJ,{"MDJ_CREDIT"  	,nTotalTit})
			Aadd(aMDJ,{"MDJ_NUMORC" 	,SL1->L1_NUM})
			Aadd(aMDJ,{"MDJ_OPER"  		,"I"})
			Aadd(aMDJ,{"MDJ_SITUA" 		,"NP"})
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Faz a gravacao nas tabelas de NCC pendentes para serem ณ
			//ณ baixadas posteriormente                                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   			Frt060GrvNcc( aMDJ , Nil , 3)
	    ElseIf !lRet .AND. cTabTit == "MDJ" 
	    	aMDJ := {} // Apaga Array com as infos.
	    EndIf
	EndIf
Else	
	//ณChamada da Funcao LJGerTitNV para que seja utilizada	 ณ
	//ณdiretamente SEM WEBSERVICE.                           ณ
	lRet	:= LJGerTitNV(	cL1Doc		,	cL1Serie	,	cL1Oper	,	dDatValid,;
							nTotalTit 	,	cL1Cliente	,	cL1Loja ,	cSerEst  ,;
							dL1EmisNf)

EndIf 
  
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณLJGerTitNV ณ Autor ณ Vendas Cliente       ณ Data ณ 26/11/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gera Titulo para desconto na proxima compra				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExpL1:= LJGerTitNV()                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณnValorNcc,												  ณฑฑ
ฑฑณ          ณ 															  ณฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno	 ณ ExpL1 = .T.             									  ณฑฑ
ฑฑณ          ณ                                     						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ 		 													  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LJGerTitNV(	cL1Doc		,cL1Serie	,cL1Oper	,dDatValid	,;
	 					nValorNcc 	,cL1Cliente	,cL1Loja	,cSerEst	,;
	 					dL1EmisNf	, cOper		, aItensMDK)

Local cParcela 		:= SuperGetMV("MV_1DUP")		// Parcela a gerar
Local aVetor        := {}                   		// Array com dados para gerar NCC.
Local lRet 			:= .T.                  		// Retorno
Local lNewMDK		:= .F.
Local lLjMExeParam	:= ExistFunc("LjMExeParam")
Local cErro			:= ""
Local cTipo			:= ""
Local cNatureza		:= ""
Local cMV_SIMB1		:= AllTrim(SuperGetMV( "MV_SIMB1" ))
Local nNumMoeda		:= 0

Default cSerEst		:= LjGetStation("LG_SERIE")
Default cOper		:= "I"
Default aItensMDK	:= {}

Private lMsErroAuto := .F.							// Tratamento de erro de rotina automatica
Private lMsHelpAuto := .T.							// Tratamento de erro de rotina automatica

DbSelectArea("SE1")
SE1->(DbSetOrder(1))
While SE1->(DbSeek(xFilial("SE1") + cSerEst + cL1Doc + cParcela + "NCC"))
	cParcela := CHR(ASC(cParcela)+1)
End	

If cOper == "I"	 					
	aAdd(aVetor,{"E1_PREFIXO"	,cSerEst											,Nil}) 
	aAdd(aVetor,{"E1_NUM"	  	,cL1Doc 											,Nil}) 
	aAdd(aVetor,{"E1_PARCELA" 	,cParcela											,Nil}) 
	aAdd(aVetor,{"E1_NATUREZ" 	,&(SuperGetMV("MV_NATNCC"))							,Nil}) 
	aAdd(aVetor,{"E1_TIPO" 		,"NCC"												,Nil}) 
	aAdd(aVetor,{"E1_EMISSAO"	,dDatabase											,Nil}) 
	aAdd(aVetor,{"E1_VALOR"		,nValorNcc											,Nil}) 
	aAdd(aVetor,{"E1_VENCTO"	,dDatValid											,Nil}) 
	aAdd(aVetor,{"E1_VENCREA"	,DataValida(dDatValid,.T.)							,Nil}) 
	aAdd(aVetor,{"E1_VENCORI"	,dDatValid											,Nil}) 
	aAdd(aVetor,{"E1_SALDO"		,nValorNcc											,Nil}) 
	aAdd(aVetor,{"E1_VLCRUZ"	,xMoeda(nValorNcc,1,1,nValorNcc)	            	,Nil}) 
	aAdd(aVetor,{"E1_CLIENTE"	,cL1Cliente											,Nil}) 
	aAdd(aVetor,{"E1_LOJA"		,cL1Loja   											,Nil}) 
	If cPaisLoc <> "BRA"
		DbSelectArea("SA6")
		SA6->(DbSetOrder(1))
		If SA6->(DbSeek( xFilial("SA6") + cL1Oper + "." + "NCC" ))
			aAdd(aVetor,{"E1_MOEDA"		,Max(SA6->A6_MOEDA,1)						,Nil }) 
		Else
			aAdd(aVetor,{"E1_MOEDA"		,1											,Nil }) 
		EndIf
	Else
		aAdd(aVetor,{"E1_MOEDA"		,1												,Nil }) 
	EndIf
	aAdd(aVetor,{"E1_STATUS"		,If(nValorNcc > 0.01,"A","B")					,Nil }) 				
	aAdd(aVetor,{"E1_SITUACA"		,"0"											,Nil }) 
	aAdd(aVetor,{"E1_ORIGEM"		,"FRTA010"										,Nil }) 
	aAdd(aVetor,{"E1_MULTNAT"		,"2"											,Nil }) 
	aAdd(aVetor,{"E1_FLUXO"			,"N"											,Nil }) 
	aAdd(aVetor,{"E1_BASCOM1"		,xMoeda(nValorNcc,1,1,nValorNcc)				,Nil }) 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInclui via rotina automaticaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)           	
	
	DbSelectArea("SE1")                            
	SE1->(DbSetOrder(2)) //E1+FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(DbSeek(xFilial("SE1") + cL1Cliente + cL1Loja + cSerEst + cL1Doc + cParcela + "NCC"))
		RecLock("SE1",.F.)
		REPLACE SE1->E1_HIST With xFilial("SE1")+ ;
		cSerEst 	+ ;
		cL1Doc	 	+ ;
		cParcela 	+ ;
		"NCC"
		
		RecLock('SE1',.F.)
		SE1->E1_PORTADO 	:= cL1Oper
		SE1->E1_AGEDEP 		:= "."
		SE1->(MsUnlock()) 				
		MsUnLock()
	EndIf
ElseIf cOper == "R"	// Recarga de Celular
	LjGrvLog(Nil,"Inicio Grava็ใo da Recarga de Celular na retaguarda - via MDJ/MDK - Num Doc:" + cL1Doc)	
	LjGrvLog(Nil,"Recarga Cel. - aItensMDK:" , aItensMDK )
	lNewMDK :=  Len(aItensMDK) > 0 .And. Len(aItensMDK[1]) > 11
	cTipo	:= IIf(Len(aItensMDK) > 0 .And. Len(aItensMDK[1]) >= 11 ,AllTrim(aItensMDK[1][11]),"")
	LjGrvLog(Nil,"Recarga Cel. - cTipo: " + cTipo )
	aAdd(aVetor,{"E1_PREFIXO"	,cSerEst											,Nil}) 
	aAdd(aVetor,{"E1_NUM"	  	,cL1Doc 											,Nil}) 
	aAdd(aVetor,{"E1_PARCELA" 	,cParcela											,Nil}) 	 
	aAdd(aVetor,{"E1_EMISSAO"	,dDatabase											,Nil}) 
	aAdd(aVetor,{"E1_VALOR"		,nValorNcc											,Nil}) 
	aAdd(aVetor,{"E1_VENCTO"	,dL1EmisNf											,Nil}) 
	aAdd(aVetor,{"E1_VENCREA"	,DataValida(dDatValid,.T.)							,Nil}) 
	aAdd(aVetor,{"E1_VENCORI"	,dL1EmisNf											,Nil})  
	aAdd(aVetor,{"E1_VLCRUZ"	,xMoeda(nValorNcc,1,1,nValorNcc)            		,Nil}) 
	aAdd(aVetor,{"E1_CLIENTE"	,cL1Cliente											,Nil}) 
	aAdd(aVetor,{"E1_LOJA"		,cL1Loja   											,Nil})
	aAdd(aVetor,{"E1_ORIGEM"	,"FRTA010"											,Nil}) 
	aAdd(aVetor,{"E1_SALDO"		,0													,Nil})
	aAdd(aVetor,{"E1_FLUXO"		,"S"												,Nil})
	aAdd(aVetor,{"E1_NUMNOTA"  	,cL1Doc 											,Nil})
	aAdd(aVetor,{"E1_HIST"		,"RECARGA DE CELULAR"								,Nil})
	aAdd(aVetor,{"E1_PORTADO"	,cL1Oper											,Nil})
	aAdd(aVetor,{"E1_VALLIQ"	,nValorNcc											,Nil})
	
	//caso os fontes estejam atualizados traz a nova forma de grava็ใo, traz somente uma linha MDK 
	If lNewMDK
		LjGrvLog(Nil,"Campos da MDK Localizados para grava็ใo da SE1 de recarga",aItensMDK)
		
		If (cTipo $ __FORMATEF + ";CH")
			aAdd( aVetor, { "E1_STATUS" , "A"	,Nil}) //Titulo gerado como aberto
		Else
			If SE1->(ColumnPos("E1_RELATO")) > 0
				aAdd(aVetor,{"E1_RELATO", "2", Nil}) //Valor padrao (X3_RELACAO)
			EndIf
		EndIf
		
		If cTipo $ __FORMATEF
			aAdd( aVetor, {"E1_VLRREAL"	, aItensMDK[1][6], Nil} ) //valor do cartใo sem a taxa (inserida no PDV, no valor do titulo [E1_VALOR])
			aAdd( aVetor, {"E1_DOCTEF"	, aItensMDK[1][14], Nil} )
			If SE1->(ColumnPos("E1_NSUTEF")) > 0
				aAdd( aVetor, {"E1_NSUTEF"	, aItensMDK[1][13], Nil} )
			EndIf
		EndIf
		
		If cTipo $ "CH"
			aAdd( aVetor, { "E1_BCOCHQ"	,aItensMDK[1][15]	,Nil} )
			aAdd( aVetor, { "E1_AGECHQ" ,aItensMDK[1][16]	,Nil} )
			aAdd( aVetor, { "E1_CTACHQ"	,aItensMDK[1][17]	,Nil} )
		EndIf
		
		cNatureza	:= aItensMDK[1][12]
		nNumMoeda	:= aItensMDK[1][8]
	Else
		If !Empty(cTipo)
			If cTipo $ __FORMATEF
				If cTipo == "CC"				
					cNatureza := "MV_NATCART"
				Else
					cNatureza := "MV_NATTEF"
				EndIf
				
				cNatureza := Iif(lLjMExeParam , LjMExeParam(cNatureza) , SuperGetMV(cNatureza))
			ElseIf cTipo == "CH"
				cNatureza := "MV_NATCHEQ"
				cNatureza := Iif(lLjMExeParam , LjMExeParam(cNatureza) , SuperGetMV(cNatureza))
			ElseIf Empty(AllTrim(cNatureza))
				cNatureza := SuperGetMv("MV_NATRC",,"")
			EndIf
		Else
			cTipo := cMV_SIMB1
		EndIf
		
		If cTipo == cMV_SIMB1
			cNatureza :=  &(SuperGetMV("MV_NATDINH"))
		EndIf
		
		nNumMoeda := 1
		If Len(aItensMDK[1]) >= 6
			aAdd( aVetor, {"E1_VLRREAL"	, aItensMDK[1][6], Nil} ) //valor do cartใo sem a taxa (inserida no PDV, no valor do titulo [E1_VALOR])			
		EndIf
	EndIf
	
	aAdd(aVetor,{"E1_MOEDA"		,nNumMoeda,Nil})
	aAdd(aVetor,{"E1_NATUREZ"	,cNatureza,Nil})
	aAdd(aVetor,{"E1_TIPO"		,cTipo, Nil})
	
	LjGrvLog(Nil,"Gera็ใo da SE1 - Antes da ExecAuto - FINA040",aVetor)
	MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)
	LjGrvLog(Nil,"Gera็ใo da SE1 - Depois da ExecAuto - FINA040")
	
	If !lMsErroAuto
		LjGrvLog(Nil, "Sucesso na grava็ใo da SE1 de recarga")
		SE1->(MsUnLock())
		MsUnLock()
		LjGrvLog(Nil, "Finaliza็ใo da grava็ใo da SE1 de recarga")
		
		If ExistFunc("WLj010FimGrv") //Envia pra finaliza็ใo caso seja titulo em dinheiro e deva ser baixado
			lRet := WLj010FimGrv("LOJXFUNI",AllTrim(SE1->E1_TIPO),"",SE1->E1_HIST)
		Else			
			If AllTrim(SE1->E1_TIPO) == cMV_SIMB1
				RecLock('SE1',.F.)
				REPLACE SE1->E1_BAIXA	WITH dDatabase	
				REPLACE SE1->E1_MOVIMEN	WITH dDatabase
				REPLACE SE1->E1_STATUS	WITH "B"
				SE1->(MsUnlock())
			EndIf
		EndIf
	EndIf
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApresenta mensagem de erro caso a rotina automatica nao seja executada.ณ
//ณDesfaz a transacao                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If  lMsErroAuto
	cErro := MostraErro()
	Conout(cErro)
	LjGrvLog(Nil,cErro)
	DisarmTransaction()
	lRet 	   := .F.
    aLogRotAut := GetAutoGrLog()                                   
	If Len(aLogRotAut) > 0 .AND. ValType(aLogRotAut[1]) == "C"
		Conout("WSINCLUNCC - Erro WS: " + aLogRotAut[1])			       
	EndIf
EndIf                                         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera a Variavel de Valor do Titulo 						  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nValorNCC := 0

Return lRet				
				 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXESTOQUEบAutor  ณ Vendas Cliente     บ Data ณ  26/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para consulta de estoque por Filial                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบRetorno   ณ Nil														  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja/FrontLoja		                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  
*/ 

Function LJXEstoque()
				
Local oEstoque	    := Nil								// Obj. dialog Estoque
Local lContinua     := .T.								// Define se continua a execucao da funcao 
Local oSvc	    	:= Nil								// Objeto para WebService
Local lRet 			:= .F. 								// Retorno do WebService
Local cFilBkp	   	:= cFilAnt							// Guarda a filial atual

Local aProdEst		:= {}		 						// Array de retorno da funcao de consulta estoque 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o ambiente e online ou offline para saber seณ
//ณfaz consulta local ou atraves do web service            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
If (nModulo == 12 .AND. lMvLjPdvPa) .OR. nModulo == 23 
   	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicia conexao com o WebService para ver se esta ativo  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oSvc      := WSLOJESTOQUE():New()                 
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autentica็ใo do Web Service
	oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/LOJESTOQUE.apw"
	
	lRet := oSvc:VlLink("") 
   	
   	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se a consulta WebService foi executada com sucessoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(lRet) == "L" .AND. lRet 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe o WS estver ativo alimenta variavelณ
		//ณbBloco para fazer consulta ao WS      ณ		
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	               
		If oSvc:lVLLINKRESULT 
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Chama tela para filtrar filial, produto e Local e posicionar estoqueณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	   		aProdEst := LJXFilEst(.F.)
		Endif				 
	Else 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMostra mensagem de erroณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cSvcError := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
		Else
			MsgStop(STR0015,STR0003) //"Verifique a configuracao de Web Service no cadastro de Estacao - SLG" ##### "Atencao" 			
		Endif
	Endif
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Chama tela para filtrar filial, produto e Local e posicionar estoqueณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
	aProdEst := LJXFilEst(.T.)
Endif 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVolta o valor da variavel cFilAnt guardado no inicioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilAnt := cFilBkp

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se o Array de estoque nใo for vazio ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู      
If(Len(aProdEst) > 0) .AND. ValType(aProdEst[1][1]) <> "L"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Desabilita as teclas de atalho                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If nModulo == 12 
    	Lj7SetKeys(.F.)
    Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Mostra dados do Produto.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If nModulo == 12 
   		DEFINE MSDIALOG oEstoque FROM 10, 16 TO 29, 73.5 TITLE STR0004 STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgVA
	Else
		DEFINE MSDIALOG oEstoque FROM 10, 16 TO 29, 73.5 TITLE STR0004 STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDefault()
	Endif
	    
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณ Dados  ณ
	//ภฤฤฤฤฤฤฤฤู
	@  8, 2 TO	43, 198 OF oEstoque PIXEL
	@ 51, 2 TO	70, 198 OF oEstoque PIXEL
	@ 76, 2 TO 135, 198 OF oEstoque PIXEL
	
	@ 2,    2 SAY STR0005 	            SIZE	90, 7 OF oEstoque PIXEL  // Dados do Produto: 
	@ 16,   4 SAY STR0006 				SIZE	21, 7 OF oEstoque PIXEL  // Filial
	@ 15,  22 MSGET aProdEst[1][1]     	SIZE	18, 9 OF oEstoque PIXEL When .F.  
	@ 16,  60 SAY STR0007 				SIZE	21, 7 OF oEstoque PIXEL  // Cขdigo
	@ 15,  85 MSGET aProdEst[1][2]     	SIZE	63, 9 OF oEstoque PIXEL When .F.  
	@ 16, 153 SAY STR0008 			    SIZE	25, 7 OF oEstoque PIXEL  // Unidade
	@ 15, 179 MSGET aProdEst[1][4]     	SIZE	14, 9 OF oEstoque PIXEL When .F.
	@ 30,   4 SAY STR0009  				SIZE	18, 7 OF oEstoque PIXEL  // Grupo
	@ 29,  22 MSGET aProdEst[1][5]    	SIZE	18, 9 OF oEstoque PIXEL When .F.		
	@ 30,  50 SAY STR0010 			    SIZE	32, 7 OF oEstoque PIXEL // Descricao
	@ 29,  85 MSGET aProdEst[1][6]     	SIZE   110, 9 OF oEstoque PIXEL When .F.
	@ 40, 335 TO 40, 335 OF oEstoque PIXEL
	@ 44,   3 SAY STR0011 + aProdEst[1][3] SIZE	 90, 7 OF oEstoque PIXEL // "Estoque - Armazem "
	
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณ Saldo  ณ
	//ภฤฤฤฤฤฤฤฤู
	@ 57,   4 SAY STR0012	 SIZE 21, 7 OF oEstoque PIXEL  // Inicial
	@ 56,  25 MSGET aProdEst[1][7] Picture PesqPict("SB9","B9_QINI") SIZE 60, 9 OF oEstoque PIXEL When .F.
	@ 57,  99 SAY STR0013 SIZE 18, 7 OF oEstoque PIXEL  // Atual
	@ 56, 117 MSGET aProdEst[1][8] Picture PesqPict("SB2","B2_QATU") SIZE 60, 9 OF oEstoque PIXEL When .F.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Precos	 ณ
	//ภฤฤฤฤฤฤฤฤฤฤู
	@ 69,  3 SAY STR0014  SIZE 90, 7 OF oEstoque PIXEL // Precos de Venda:
	@ 82,  6 SAY "1 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 93,  6 SAY "2 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 103, 6 SAY "3 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 122, 6 SAY "5 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 83, 93 SAY "6 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 103,93 SAY "8 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 93, 93 SAY "7 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 112,93 SAY "9 -"    SIZE 11, 7 OF oEstoque PIXEL
	@ 112, 6 SAY "4 -"    SIZE 11, 7 OF oEstoque PIXEL		

	@ 82,  18 MSGET aProdEst[1][9]  Picture PesqPict("SB0","B0_PRV1",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 91,  18 MSGET aProdEst[1][10] Picture PesqPict("SB0","B0_PRV2",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 101, 18 MSGET aProdEst[1][11] Picture PesqPict("SB0","B0_PRV3",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 111, 18 MSGET aProdEst[1][12] Picture PesqPict("SB0","B0_PRV4",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 121, 18 MSGET aProdEst[1][13] Picture PesqPict("SB0","B0_PRV5",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 82, 106 MSGET aProdEst[1][14] Picture PesqPict("SB0","B0_PRV6",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 91, 106 MSGET aProdEst[1][15] Picture PesqPict("SB0","B0_PRV7",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 101,106 MSGET aProdEst[1][16] Picture PesqPict("SB0","B0_PRV8",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.
	@ 111,106 MSGET aProdEst[1][17] Picture PesqPict("SB0","B0_PRV9",_PICTURE,1) SIZE 70, 9 OF oEstoque PIXEL When .F.		
	DEFINE SBUTTON FROM 010,200 TYPE 1 ACTION oEstoque:End() ENABLE OF oEstoque
	
	ACTIVATE MSDIALOG oEstoque CENTERED
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Habilita as teclas de atalho                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If nModulo == 12 
    	Lj7SetKeys(.T.)
    Endif
ElseIf(Len(aProdEst) > 0) .AND. ValType(aProdEst[1][1]) == "L"
	Aviso( STR0003, STR0016, {STR0017} ) //"Atencao" ### "Dados informado, nao encontrado." ### "Ok"
EndIf
	
Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXFilEst บAutor  ณ  Vendas Clientes   บ Data ณ  26/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra filial, Produto e Local para consulta de estoque    บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe	 ณ LJXFilEst(ExpL1)                 				     	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ ExpL1 - Ambiente online (.T.) ou Offline (.F.)             บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบRetorno   ณ ExpA1 - Retorno Array com dados da consulta de estoque     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 										         
Function LJXFilEst(lOnline)				    

Local oProduto			:= Nil								// Objeto para digitar o codigo do Produto
Local oDescProd 	    := Nil 								// Objeto para mostrar descricao do Produto 
Local oFil 	    		:= Nil 								// Objeto para mostrar codigo da filial
Local oLocalProd   		:= Nil 								// Objeto para mostrar armazem do produto
Local aProdEst			:= {}                      			// Array de retorno com consulta de stoque
Local bBloco 			:= {|| Nil}							// Bloco de codigo a executar no botao Ok
Local cFilBkp	   		:= cFilAnt							// Guarda a filial atual 
Local cFil 				:= Space(FWGETTAMFILIAL)			// Codigo da Filial
Local cProduto  		:= Space(TamSX3("B1_COD")[1])  	// Codigo do Produto 
Local cLocalProd  		:= Space(TamSX3("B1_LOCPAD")[1])  	// Codigo do Local
Local cDescProd 		:= Space(TamSX3("B1_DESC")[1])     // Descricao do Produto 
Local nPosProd			:= 0                                // Posicao do codigo do produto
Local nPosDtLocal  		:= 0								// Posicao do local (armazem)

DEFAULT lOnline  		:= .T.							  	// Indica se o ambiente e online

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for modulo Sigaloja e tiver produtos na aColsณ
//ณja mostra na tela de consulta o ultimo lancado  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nModulo == 12 .or. nModulo == 05
	nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do codigo do produto
	nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOCAL"})				// Posicao do local (armazem)
	If !Empty(aCols[n][nPosProd]) .AND. Len(aColsDet) >= n  
		cFil 		:= xFilial()
		cProduto 	:= aCols[n][nPosProd]
		cLocalProd	:= aColsDet[n][nPosDtLocal]		
		cDescProd 	:= Subst(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"),1,30) // Descricao do Produto
	Endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o ambiente e online ou offline para saber seณ
//ณfaz consulta local ou atraves do web service            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
If lOnline
	bBloco := {|| cFilAnt := cFilBkp, aProdEst := LJXPosEst(cFil, cProduto, cLocalProd)}
Else 
	bBloco := {|| cFilAnt := cFilBkp, aProdEst := LJXWSCsEtq(cFil, cProduto, cLocalProd)}
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBusca as filiais via WebService para consultaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aFilRet := {}
	aFilRet := LJXWSCsFil()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta tela de consulta ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
DEFINE MSDIALOG oWindEtq FROM 47,130 TO 200,550 TITLE STR0004 PIXEL OF GetWndDefault() //"Consulta Estoque"
   
	//ฺฤฤฤฤฤฤฟ
	//ณFilialณ
	//ภฤฤฤฤฤฤู
 	@ 04, 05 TO 28, 56 LABEL STR0006 OF oWindEtq PIXEL   //"Filial"											      	            

    @ 13, 10 MSGET oFil VAR cFil F3 IIf(lOnline,"XM0","XM0RET") Picture PesqPict("SB2","B2_FILIAL") SIZE 40,10  OF oWindEtq PIXEL Valid IIf(Empty(cFil),cFil := xFilial("SB2"), cFilAnt := cFil)  	 	      
	//ฺฤฤฤฤฤฤฤฟ
	//ณProdutoณ
	//ภฤฤฤฤฤฤฤู    
	@ 04, 58 TO 28, 156 LABEL STR0018 OF oWindEtq PIXEL   //"Produto" 
		      	            
 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe for modulo Sigaloja usa consulta e validacoes ณ
	//ณdiferentes do frontloja						    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	If nModulo == 12 .or. nModulo == 05
	   	@ 13, 63 MSGET oProduto VAR cProduto F3 "SB1" Picture PesqPict("SB1","B1_COD") SIZE 90,10  OF oWindEtq PIXEL Valid !Empty(cProduto) .AND. ExistCpo("SB1",cProduto) 	 	      	            
		oProduto:cSx1Hlp:="B1_COD"	
 		oProduto:bLostFocus := { ||	cDescProd := Subst(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"),1,30),;
		 						cLocalProd := Subst(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_LOCPAD"),1,30),; 	
 								oWindEtq:Refresh() }
	Else 
	   	@ 13, 63 MSGET oProduto VAR cProduto F3 "FRT" Picture PesqPict("SBI","BI_COD") SIZE 90,10  OF oWindEtq PIXEL Valid !Empty(cProduto) .AND. ExistCpo("SBI",cProduto) 	 	      	            
		oProduto:cSx1Hlp:="BI_COD"	
 		oProduto:bLostFocus := { ||	cDescProd := Subst(Posicione("SBI",1,xFilial("SBI")+cProduto,"BI_DESC"),1,30),;
		 						cLocalProd := Subst(Posicione("SBI",1,xFilial("SBI")+cProduto,"BI_LOCPAD"),1,30),; 	
 								oWindEtq:Refresh() }
	Endif
   	
    //ฺฤฤฤฤฤฤฤฟ
	//ณArmazemณ
	//ภฤฤฤฤฤฤฤู
  	@ 04, 158 TO 28, 206 LABEL STR0019 OF oWindEtq PIXEL   //"Armazem" 
	@ 13, 163 MSGET oLocalProd VAR cLocalProd Picture PesqPict("SB1","B1_LOCPAD") SIZE 40,10  OF oWindEtq PIXEL  	 	  

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDescricao do Produtoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 30, 05 TO 54, 206 LABEL STR0020 OF oWindEtq PIXEL	  //"Descricao do Produto" 		
 	@ 39, 10  MSGET oDescProd VAR cDescProd SIZE   193, 10 OF oWindEtq WHEN .F. PIXEL   
 	 
	DEFINE SBUTTON FROM 062,150 TYPE 1 ACTION (oWindEtq:End(), Eval(bBloco)) ENABLE OF oWindEtq //"Ok"
	DEFINE SBUTTON FROM 062,180 TYPE 2 ACTION (oWindEtq:End(), cFilAnt := cFilBkp) ENABLE OF oWindEtq //"Cancelar" 
    @ 06,01 BUTTON STR0075 SIZE 030,10 OF oWindEtq ACTION (LOJA7034(cFil,cProduto,cLocalProd ),oWindEtq:End(),cFilAnt := cFilBkp)

ACTIVATE MSDIALOG oWindEtq CENTER  

Return(aProdEst)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXWSCsEtqบAutor  ณ  Vendas Clientes   บ Data ณ  26/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta estoque por filial atraves do web Service         บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑณSintaxe	 ณ LJXWSCsEtq(ExpC1,ExpC2,ExpC3)                           	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametro ณ ExpC1 - Codigo da Filial                                   บฑฑ 
ฑฑบ          ณ ExpC2 - Codigo do Produto                                  บฑฑ 
ฑฑบ          ณ ExpC3 - Codigo do Local                                    บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบRetorno   ณ ExpA1 - Retorno Array com dados da consulta de estoque     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/										         
Function LJXWSCsEtq(cFil, cProduto, cLocalProd)				    

Local oSvc	    	:= Nil		// Objeto para WebService
Local lRet 			:= .F. 		// Retorno do WebService
Local aProdEst		:= {}     	// Array de retorno com consulta de stoque

DEFAULT cFil  		:= ""		// Codigo da Filial
DEFAULT cProduto  	:= ""  		// Codigo do Produto 
DEFAULT cLocalProd	:= ""     	// Codigo do Local

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicia conexao com o WebService para consulta de estoqueณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSvc      := WSLOJESTOQUE():New()                 
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autentica็ใo do Web Service
oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/LOJESTOQUE.apw"

//"Aguarde...Verificando estoque..."
LJMsgRun(STR0021,, { || lRet := oSvc:ConEstoque(cEmpAnt,cFilAnt , cFil, cProduto, cLocalProd) } ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a consulta WebService foi executada com sucessoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorna array com o estoque do produtoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ) > 0  
		aAdd( aProdEst, {	oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:cCFIL  	,;		//01 - Filial	
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:cCPRODUTO	,;      //02 - Codigo do produto
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:cCLOCALPROD	,;      //03 - Local do produto				 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:cCUNIDADE	,;      //04 - Unidade de medida do Produto	
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:cCGRUPO		,;      //05 - Grupo do produto
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:cCDESCRI	,;      //06 - Descricao do produto 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNINICIAL	,;      //07 - Quantidade inicial do produto	
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNATUAL		,;      //08 - Saldo atual do produto 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO1	,;      //09 - Preco 1 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO2	,;      //10 - Preco 2 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO3	,;      //11 - Preco 3 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO4	,;      //12 - Preco 4 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO5	,;      //13 - Preco 5 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO6	,;      //14 - Preco 6 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO7	,;      //15 - Preco 7 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO8	,;      //16 - Preco 8 
						oSvc:oWSCONESTOQUERESULT:oWSWSRETETQ[1]:nNPRECO9	})      //17 - Preco 9 
	Endif						 
Else 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMostra mensagem de erroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cSvcError := GetWSCError()
	If Left(cSvcError,9) == "WSCERR048"
		cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
		cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
		Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
	Else
		//"A consulta de estoque nao foi realizada. A venda prosseguira normalmente."
		//"Sem comunicacao com o WebService (Consulta de Estoque)!"
		MsgStop(STR0022,STR0023)
	Endif
Endif		

Return(aProdEst)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXPosEst   บAutorณVendas Clientes     บ Data ณ  26/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona estoque por Produto,Filial,Local e retorna array  บฑฑ 
ฑฑบ          ณpara ser usado na apresentacao da tela					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpA1 := LJXPosEst( ExpA1, ExpN1, ExpC2 ) 		          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da Filial a consultar estoque                บฑฑ
ฑฑบ          ณExpC2 - Codigo do Produto a consultar estoque    	  		  บฑฑ
ฑฑบ          ณExpC3 - Codigo do Local a consultar estoque                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Array com informacoes do estoque do produto		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function LJXPosEst(cFil, cProduto, cLocalProd)

Local aProdEst		:= {}		 	// Array de retorno da funcao com informacoes do estoque do produto
Local lContinua 	:= .T. 			// Retorno
Local nSaldoIni		:= 0			// Saldo inicial
Local nSaldoAtu		:= 0			// Saldo atual
Local cTabPad		:= ""			// Tabela Preco Padrao
Local aPrecos		:= {0,0,0,0,0,0,0,0,0} 			 // Array de Precos
Local lCenVenda		:= SuperGetMv("MV_LJCNVDA",,.F.) // Indica se existe integracao com cenario de vendas
                                            
DEFAULT cFil	 	:= ""        	// Codigo da Filial
DEFAULT cProduto	:= ""    	 	// Codigo do Produto
DEFAULT cLocalProd	:= ""    	 	// Codigo do Local

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz posicionamento do estoque do produtoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
If SB1->(DbSeek(FWxFilial("SB1",cFil) + cProduto,.T.))
	If lCenVenda //Cenario de Venda
		cTabPad := Pad(SuperGetMv("MV_TABPAD"), TamSx3("DA0_CODTAB")[1])
		
		DA0->(DbSetOrder(1)) //DA0_FILIAL+DA0_CODTAB	
		If DA0->(DbSeek(FWxFilial("DA0",cFil) + cTabPad))
			DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
			If DA1->(DbSeek(DA0->DA0_FILIAL + DA0->DA0_CODTAB + cProduto))
				aPrecos[1] := DA1->DA1_PRCVEN			
			EndIf			
		EndIf
	Else		
		SB0->(DbSetOrder(1)) //B0_FILIAL+B0_COD
		If SB0->(DbSeek(FWxFilial("SB0",cFil) + cProduto,.T.))
			aPrecos[1] := SB0->B0_PRV1
			aPrecos[2] := SB0->B0_PRV2
			aPrecos[3] := SB0->B0_PRV3
			aPrecos[4] := SB0->B0_PRV4
			aPrecos[5] := SB0->B0_PRV5
			aPrecos[6] := SB0->B0_PRV6
			aPrecos[7] := SB0->B0_PRV7
			aPrecos[8] := SB0->B0_PRV8
			aPrecos[9] := SB0->B0_PRV9 		
		EndIf
	EndIf
				
	SB9->(DbSetOrder(1)) //B9_FILIAL+B9_COD+B9_LOCAL
	If SB9->(DbSeek(FWxFilial("SB9",cFil) + cProduto + cLocalProd,.T.))
		nSaldoIni := SB9->B9_QINI		
	EndIf
		
	SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL  
	If SB2->(DbSeek(FWxFilial("SB2",cFil) + cProduto + cLocalProd,.T.))
		nSaldoAtu := SaldoSb2()		
	EndIf
	
	Aadd(aProdEst, {SB1->B1_FILIAL	,;	//01 - Filial
					SB1->B1_COD		,;	//02 - Codigo do produto
					cLocalProd  	,;	//03 - Local do produto				 
					SB1->B1_UM		,;	//04 - Unidade de medida do Produto				 
					SB1->B1_GRUPO	,;	//05 - Grupo do produto
					SB1->B1_DESC	,;	//06 - Descricao do produto 
					nSaldoIni		,;	//07 - Quantidade inicial do produto				
					nSaldoAtu		,;	//08 - Saldo atual do produto 
					aPrecos[1]		,;	//09 - Preco 1 
					aPrecos[2]		,;	//10 - Preco 2 
					aPrecos[3]		,;	//11 - Preco 3 
					aPrecos[4]		,;	//12 - Preco 4 
					aPrecos[5]		,;	//13 - Preco 5 
					aPrecos[6]		,;	//14 - Preco 6 
					aPrecos[7]		,;	//15 - Preco 7 
					aPrecos[8]		,;	//16 - Preco 8 
					aPrecos[9]		})	//17 - Preco 9  
Else
	Aadd(aProdEst,{.F.})						
EndIf

Return (aProdEst) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ LJXPesqFil ณAutorณ Vendas Clientes       ณ Data ณ28/02/2011ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑณDescrio ณMonta uma consulta do tipo F3 especifica  para a consulta deณฑฑ
ฑฑณ          ณFiliais via WebService					                  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpL1 - Retorna .T. caso tenha selecionado algun item	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJXPesqFil()

Local oDlgCons	  := Nil  							// Objeto Tela
Local oListBox    := Nil                           	// Objeto Listbox com as opcoes
Local nPosLbx     := 0								// Posicao do Listbox
Local nPos        := 0								// Contador          
Local aItens      := {}								// Array dos itens
Local lRet        := .F.							// Retorno da funcao

CursorWait()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdd o valor da variavel aFilRet que foi  carregada ณ
//ณna retaguarda atraves do WebService                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aItens := aFilRet
              
CursorArrow()      

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa o valor da variavel staticaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCodfilial := Space(FWGETTAMFILIAL)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao encontrou filiais nao mostra tela de consultaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aItens) <= 0 
	MsgStop(STR0024,STR0003) //"Filiais nao encontradas"###"Atencao"
	Return(lRet)
Endif

DEFINE MSDIALOG oDlgCons FROM 0,0 TO 230,440 TITLE STR0025 PIXEL	// "Consulta Filiais"

	@ 05,05 LISTBOX oListBox VAR nPosLbx FIELDS HEADER STR0007, STR0006, STR0026 SIZE 180,100 OF oDlgCons PIXEL NOSCROLL	// "Codigo", "Filial", "Municipio"
	oListBox:SetArray(aItens)
    oListBox:bLine:={|| {	aItens[oListBox:nAt,1],;
						    aItens[oListBox:nAt,2],;
						   	aItens[oListBox:nAt,3]}}

    oListBox:BlDblClick := {||(lRet:= .T.,nPos:= oListBox:nAt, oDlgCons:End())}
	oListBox:Refresh()
                                       
    DEFINE SBUTTON FROM 05,190 TYPE 1  ENABLE OF oDlgCons ACTION (lRet:= .T.,nPos:= oListBox:nAt,oDlgCons:End()) // Ok

    DEFINE SBUTTON FROM 20,190 TYPE 2  ENABLE OF oDlgCons ACTION (lRet:= .F.,oDlgCons:End()) // Cancelar
    
ACTIVATE MSDIALOG oDlgCons CENTERED

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona no item selecionado na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet   
	cCodfilial := aItens[nPos][1]
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXGetFil   บAutorณVendas Clientes     บ Data ณ  26/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona e retorna array com filiais						  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ ExpA1 := LJXGetFil	 	       							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Array com informacoes das filiais				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function LJXGetFil()

Local aFil			:= {}		 	// Array de retorno da funcao com informacoes das filiais

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz posicionamento das filiais ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SM0")
DbSetOrder(1)      
dbGotop()
While (!Eof())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarregas as Filiaisณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd(aFil, {SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_CIDENT } )	
	SM0->(DbSkip())
End
dbGotop()

Return (aFil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXWSCsFilบAutor  ณ  Vendas Clientes   บ Data ณ  26/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta estoque por filial atraves do web Service         บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑณSintaxe	 ณ LJXWSCsFil()					                           	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบRetorno   ณ ExpA1 - Retorno Array com dados da consulta de estoque     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/										         
Function LJXWSCsFil()				    

Local oSvc	    	:= Nil		// Objeto para WebService
Local lRet 			:= .F. 		// Retorno do WebService
Local aFil			:= {}     	// Array de retorno com consulta de stoque   
Local nX			:= 0		// Controle de laco

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicia conexao com o WebService ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSvc      := WSLOJESTOQUE():New()                 
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autentica็ใo do Web Service
oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/LOJESTOQUE.apw"

//"Aguarde...Verificando Filiais..."
LJMsgRun(STR0027,, { || lRet := oSvc:ConFiliais(cEmpAnt,cFilAnt) } ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a consulta WebService foi executada com sucessoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorna array com as filiais ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(oSvc:oWSCONFILIAISRESULT:oWSWSRETFIL) > 0 
		For nX := 1 To Len(oSvc:oWSCONFILIAISRESULT:oWSWSRETFIL) 
			aAdd( aFil, {	oSvc:oWSCONFILIAISRESULT:oWSWSRETFIL[nX]:cCCODFIL  	,;		//01 - Codigo da Filial		
						   	oSvc:oWSCONFILIAISRESULT:oWSWSRETFIL[nX]:cCNAMEFIL	,;      //02 - Nome Filial
							oSvc:oWSCONFILIAISRESULT:oWSWSRETFIL[nX]:CCCIDENT  	})      //03 - Codigo municipio
		Next nX											
	Endif						 
Else 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMostra mensagem de erroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cSvcError := GetWSCError()
	If Left(cSvcError,9) == "WSCERR048"
		cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
		cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
		Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
	Else
		//"A consulta de estoque nao foi realizada. A venda prosseguira normalmente."
		//"Sem comunicacao com o WebService!"
		MsgStop(STR0022,STR0028)
	Endif
Endif		

Return(aFil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXRetFil บAutor  ณ Vendas Cliente     บ Data ณ  26/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retorno da variavel statica cCodfilial          บฑฑ
ฑฑบ          ณque foi selecionada no metodo LJXPesqFil()          		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบRetorno   ณ ExpC1 - Retorno codigo da filial selecionada na busca	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja/FrontLoja		                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  
*/ 
Function LJXRetFil()

Return(cCodfilial) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXBxAdmFi  บAutorณVendas Clientes     บ Data ณ  18/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela para realizar baixa automatica dos titulos do    บฑฑ 
ฑฑบ          ณContas a Receber vinculados com os do Contas a Pagar		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLJXBxAdmFi()										          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Nil									                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil														  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function LJXBxAdmFi()   

Local oDlg          := Nil           								//Objeto tela
Local oPanelU		:= Nil           								//Objeto panel Superior
Local oGrpFin		:= Nil           								//Objeto grupo Adm. Financeira   
Local oSayCod		:= Nil           								//Objeto label codigo
Local oGetCod       := Nil                                          //Objeto get Codigo
Local cGetCod 		:= Space(TamSX3("AE_COD")[1])			     	//Codigo Adm. Financeiras
Local oSayDesc		:= Nil           								//Objeto label descricao
Local oGetDesc      := Nil											//Objeto get Descricao
Local cGetDesc 		:= Space(TamSX3("AE_DESC")[1])				    //Descricao Adm. financeira
Local oButton1		:= Nil           								//Objeto botao pesquisar
Local oPanelC		:= Nil           								//Objeto panel Central 
Local oGrpTit		:= Nil           								//Objeto grupo Titulos
Local oGrpCar		:= Nil           								//Objeto grupo CAR
Local oGrpCap		:= Nil           								//Objeto grupo CAP
Local oOk 			:= LoadBitmap( GetResources(), "LBOK") 			//Objeto de selecao marcado
Local oNo 			:= LoadBitmap( GetResources(), "LBNO")			//Objeto de selecao desmarcado 
Local uParam20 		:=.F.    										//Compatibilidade.
Local lPixel    	:=.T.    										//Considera as coordenadas passadas em pixels.
Local uParam24  	:=.F.    										//Compatibilidade.             
Local oCbxMotBx 	:= Nil											//Objeto Combo motivo da Baixa
Local cMotBx    	:= ""                                           //Motivo da Baixa
Local oGetAgenc 	:= Nil                                          //Objeto Get Agencia
Local cGetAgenc 	:= Space(TamSX3("A6_AGENCIA")[1])              //Agencia
Local oGetBanco 	:= Nil											//Objeto Get Banco
Local cGetBanco 	:= Space(TamSX3("A6_COD")[1])                  //Banco
Local oGetConta 	:= Nil											//Objeto Get Conta
Local cGetConta 	:= Space(TamSX3("A6_NUMCON")[1])               //Conta
Local oSayAgenc 	:= Nil											//Objeto label Agencia
Local oSayBanco 	:= Nil											//Objeto label Banco
Local oSayConta 	:= Nil											//Objeto label Conta
Local oSayMotBx 	:= Nil											//Objeto label Motivo Baixa
Local aHeadCar  	:= {}   										//Titulo dos campos no cabecalho. 
Local aHeadCap  	:= {}  											//Titulo dos campos no cabecalho.      
Local aColSizCar 	:= {}  		 									//Largura das colunas. 
Local aColSizCap 	:= {}  		 									//Largura das colunas.
Local oPanelD		:= Nil           								//Objeto panel inferior 
Local oGrpBx		:= Nil           								//Objeto grupo Baixa
Local oButton2		:= Nil           								//Objeto botao baixar
Local oButton3		:= Nil           								//Objeto botao cancelar
Local bLDblClick 	:= {|| }							    		//Bloco de codigo do duplo clique do objeto.
Local oCheckBo1     := Nil                                         	//Objeto checkBox
Local lCheckBo1 	:= .F.											//Variavel p CheckBox
Local aMotBx        := ReadMotBx()                                 	//Array com motivos de baixa
Local aDescMotbx    := {}                                          	//Array com a descricao dos motivos de baixa
Local nI			:= 0                                            //Variavel auxiliar do contador
Local cCxLoja       := SuperGetMv("MV_CXLOJA")                     	//Guarda caixa geral da loja(Banco, Agencia, Conta)
Local aBanco        := {}                                          	//Array com os dados do caixa geral da loja

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta cabecalho e tamanhos da Gridณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadCar  	:={"",STR0036,STR0037,STR0038,STR0039,STR0040,STR0041,STR0042,STR0043} 			//"Prefixo"###"Numero"###"Parcela"###"Tipo"###"Cliente"###"Loja"###"Venc."###"Valor" 		 
aHeadCap  	:={"",STR0036,STR0037,STR0038,STR0039,STR0056,STR0041,STR0042,STR0043} 			//"Prefixo"###"Numero"###"Parcela"###"Tipo"###"Fornec."###"Loja"###"Venc."###"Valor"
aColSizCar	:={25,30,30,25,20,40,20,40,70} 		 	 										//Determina Largura das colunas. 
aColSizCap	:={25,30,30,25,20,40,20,40,70} 		 											//Determina Largura das colunas.

  	DEFINE MSDIALOG oDlg TITLE STR0044 FROM 000, 000  TO 550, 810 COLORS 0, 16777215 PIXEL		//"Baixa Administradora Financeira"

	oPanelD := TPanel():New(237,000,/*cText*/,oDlg,;
							/*oFont*/,/*lCentered*/,/*uParam7*/,/*nClrText*/,;
							/*nClrBack*/,405,037,/*lLowered*/,;
							/*lRaised*/)
	
	oPanelC := TPanel():New(030,000,/*cText*/,oDlg,;
							/*oFont*/,/*lCentered*/,/*uParam7*/,/*nClrText*/,;
							/*nClrBack*/,405,208,/*lLowered*/,;
							/*lRaised*/)  
							
	oPanelU := TPanel():New(000,000,/*cText*/,oDlg,;
							/*oFont*/,/*lCentered*/,/*uParam7*/,/*nClrText*/,;
							/*nClrBack*/,405,030,/*lLowered*/,;
							/*lRaised*/)    
	//ฺฤฤฤฤฤฟ
	//ณGroupณ
	//ภฤฤฤฤฤู 
    @ 000, 004 GROUP oGrpBX  TO 033, 357 PROMPT STR0057 OF oPanelD COLOR 0, 16777215 PIXEL 		//" Dados Baixa "
    @ 000, 004 GROUP oGrpTit TO 207, 400 PROMPT STR0058 OF oPanelC COLOR 0, 16777215 PIXEL 		//" Titulos "
    @ 008, 010 GROUP oGrpCar TO 196, 201 PROMPT STR0049 OF oGrpTit COLOR 0, 16777215 PIXEL  	//" Contas a Receber "                
    @ 008, 203 GROUP oGrpCap TO 196, 394 PROMPT STR0050 OF oGrpTit COLOR 0, 16777215 PIXEL  	//" Contas a Pagar "        
 	@ 002, 004 GROUP oGrpFin TO 029, 399 PROMPT STR0048 OF oPanelU COLOR 0, 16777215 PIXEL		//" Administradora Financeira "   
 	
 	//ฺฤฤฤฟ
	//ณGetณ
	//ภฤฤฤู
    @ 011, 041 MSGET oGetCod VAR cGetCod F3 "SAE" Picture PesqPict("SAE","AE_COD") SIZE 050, 010 OF oPanelU COLORS 0, 16777215 PIXEL ;
    	Valid !Empty(cGetCod) .AND. ExistCpo("SAE",cGetCod)                                                //"Codigo Admistradora"
	oGetCod:cSx1Hlp:="AE_COD"	
	oGetCod:bLostFocus := { ||	cGetDesc := Subst(Posicione("SAE",1,xFilial("SAE")+cGetCod,"AE_DESC"),1,30),oDlg:Refresh() }

	@ 011, 162 MSGET oGetDesc VAR cGetDesc WHEN .F. SIZE 158, 010 OF oPanelU COLORS 0, 16777215 PIXEL		//"Descricao Admistradora"
 	
	//ฺฤฤฤฟ
	//ณSayณ   
	//ภฤฤฤู
    @ 013, 012 SAY oSayCod  PROMPT STR0007 SIZE 027, 010 OF oPanelU COLORS 0, 16777215 PIXEL   			   	//"Codigo"
    @ 013, 119 SAY oSayDesc PROMPT STR0010 SIZE 042, 010 OF oPanelU COLORS 0, 16777215 PIXEL    			//"Descricao"   
    
  	//ฺฤฤฤฤฤฤฟ
	//ณButtonณ										
	//ภฤฤฤฤฤฤู
    @ 009, 339 BUTTON oButton1 PROMPT STR0052 SIZE 056, 014 OF oPanelU PIXEL ACTION	Eval({ || LjMsgRun(STR0053,,LJXFillTit(cGetCod))}) 	//"Pesquisar"###"Aguarde Buscando Titulos..."  
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLimpa os arrays para inicializacaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aBrowseCar := {} 
	aBrowseCap := {}   	
	Aadd(aBrowseCar,{.F.,"","","","","","","",""} )
	Aadd(aBrowseCap,{.F.,"","","","","","","",""} )  
	        
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณContas a Receberณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oBrowseCar := TCBrowse():New(016,017,178,176,/*bLine*/,aHeadCar,aColSizCar,;
								oGrpCar,/*cField*/,/*uValue1*/,/*uValue2*/,/*bChange*/,bLDblClick,;
								/*bRClick*/,/*oFont*/,/*oCursor*/,/*nClrFore*/,/*nClrBack*/,/*cMsg*/,;
								uParam20,/*cAlias*/,lPixel,/*bWhen*/,uParam24,/*bValid*/,/*lHScroll*/,/*lVScroll*/)
    
    If(Len(aBrowseCar) > 0)
	    oBrowseCar:SetArray(aBrowseCar) 
	    oBrowseCar:bLine := {|| { 	If(aBrowseCar[oBrowseCar:nAT,1],oOk,oNo),;
			                   		aBrowseCar[oBrowseCar:nAt,2],;
			      					aBrowseCar[oBrowseCar:nAt,3],;
		      						aBrowseCar[oBrowseCar:nAt,4],;
		      						aBrowseCar[oBrowseCar:nAt,5],;    
		      						aBrowseCar[oBrowseCar:nAt,6],;
			      					aBrowseCar[oBrowseCar:nAt,7],;
		      						aBrowseCar[oBrowseCar:nAt,8],;
		      						aBrowseCar[oBrowseCar:nAt,9]}}        
	Endif     	 									 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEvento do Duplo Cliqueณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    oBrowseCar:bLDblClick := {|| aBrowseCar[oBrowseCar:nAt,1] := !aBrowseCar[oBrowseCar:nAt,1],;
						    	aBrowseCap[oBrowseCar:nAt,1] := aBrowseCar[oBrowseCar:nAt,1],;
      							oBrowseCar:DrawSelect(),;
      							oBrowseCar:Refresh(),oBrowseCap:Refresh()}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณContas a Pagarณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 	oBrowseCap := TCBrowse():New(016,210,178,176,/*bLine*/,aHeadCap,aColSizCap,;
								oGrpCap,/*cField*/,/*uValue1*/,/*uValue2*/,/*bChange*/,bLDblClick,;
								/*bRClick*/,/*oFont*/,/*oCursor*/,/*nClrFore*/,/*nClrBack*/,/*cMsg*/,;
								uParam20,/*cAlias*/,lPixel,/*bWhen*/,uParam24,/*bValid*/,/*lHScroll*/,/*lVScroll*/)

    If(Len(aBrowseCap) > 0)
	    oBrowseCap:SetArray(aBrowseCap) 
	    oBrowseCap:bLine := {|| { 	If(aBrowseCap[oBrowseCap:nAT,1],oOk,oNo),;
				                   	aBrowseCap[oBrowseCap:nAt,2],;
		      						aBrowseCap[oBrowseCap:nAt,3],;
		      						aBrowseCap[oBrowseCap:nAt,4],;
		      						aBrowseCap[oBrowseCap:nAt,5],;
		      						aBrowseCap[oBrowseCap:nAt,6],;
		      						aBrowseCap[oBrowseCap:nAt,7],;
		      						aBrowseCap[oBrowseCap:nAt,8],;
		      						aBrowseCap[oBrowseCap:nAt,9]}}       
	Endif  						
      				
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEvento do Duplo Cliqueณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    oBrowseCap:bLDblClick := {|| aBrowseCap[oBrowseCap:nAt,1] := !aBrowseCap[oBrowseCap:nAt,1],;
    							aBrowseCar[oBrowseCap:nAt,1] := aBrowseCap[oBrowseCap:nAt,1],;
      							oBrowseCap:DrawSelect(),;
      							oBrowseCap:Refresh(),oBrowseCar:Refresh()}
     
    //ฺฤฤฤฤฤฟ
	//ณCheckณ
	//ภฤฤฤฤฤู   
    @ 198, 308 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT STR0051 SIZE 080, 008 OF oGrpTit COLORS 0, 16777215 PIXEL ;		//"Marcar/Desmarcar Todos"
    	ON CLICK( aEval( aBrowseCar, {|x| x[1] := lCheckBo1,oBrowseCar:Refresh()}),; 
    	aEval( aBrowseCap, {|x| x[1] := lCheckBo1,oBrowseCap:Refresh()}) )	  
   
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAlimenta array com a descricao dos motivos de baixa para usar no combobox ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI := 1 to len( aMotBx )
	  If Substr(aMotBx[nI],34,01) == "A" .or. Substr(aMotBx[nI],34,01) =="R"
	    AADD( aDescMotbx,Substr(aMotBx[nI],07,10))
	  Endif
	Next nI   
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa o valor do Chekboxณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aDescMotbx) > 0
		cMotBx := aDescMotbx[1]
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณComboboxณ 	
	//ภฤฤฤฤฤฤฤฤู	
    @ 018, 022 MSCOMBOBOX oCbxMotBx VAR cMotBx ITEMS aDescMotbx SIZE 065, 010 OF oPanelD COLORS 0, 16777215 PIXEL
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa com valor default o Caixa Geral da loja ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aBanco := StrTokArr(cCxLoja,"/")
	If Len(aBanco) == 3
	  SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	  If SA6->(DbSeek(xFilial("SA6")+aBanco[1]+aBanco[2]+aBanco[3]))
	    cGetBanco := aBanco[1]
	    cGetAgenc := aBanco[2]
	    cGetConta := aBanco[3]
	  Endif 
	Endif 
    
   	//ฺฤฤฤฟ
	//ณGetณ
	//ภฤฤฤู    
    @ 017, 102 MSGET oGetBanco VAR cGetBanco F3 "SA6" Picture PesqPict("SA6","A6_COD") SIZE 065, 010 OF oPanelD COLORS 0, 16777215 PIXEL ;
	   	Valid !Empty(cGetBanco) .AND. CarregaSa6(@cGetBanco,,,.T.)    									//Banco                                        
		oGetCod:cSx1Hlp:="A6_COD"	
    
    @ 017, 188 MSGET oGetAgenc VAR cGetAgenc Picture PesqPict("SA6","A6_AGENCIA") SIZE 065, 010 OF oPanelD COLORS 0, 16777215 PIXEL ;
	   	Valid !Empty(cGetAgenc) .AND. CarregaSa6(@cGetBanco,@cGetAgenc,,.T.)                          //Agencia       
		oGetCod:cSx1Hlp:="A6_AGENCIA"	
		    
    @ 017, 270 MSGET oGetConta VAR cGetConta Picture PesqPict("SA6","A6_NUMCON") SIZE 065, 010 OF oPanelD COLORS 0, 16777215 PIXEL ;
   	   	Valid !Empty(cGetConta) .AND. If(CarregaSa6(@cGetBanco,@cGetAgenc,@cGetConta,.T.,,.T.),.T.,oGetBanco:SetFocus()) //Conta       
		oGetCod:cSx1Hlp:="A6_NUMCON"	
    
    //ฺฤฤฤฟ
	//ณSayณ   
	//ภฤฤฤู 
    @ 008, 022 SAY oSayMotBx PROMPT STR0059 SIZE 056, 008 OF oPanelD COLORS 0, 16777215 PIXEL     //"Motivo Baixa"
    @ 007, 103 SAY oSayBanco PROMPT STR0060 SIZE 046, 010 OF oPanelD COLORS 0, 16777215 PIXEL     //"Banco"
    @ 007, 190 SAY oSayAgenc PROMPT STR0061 SIZE 051, 008 OF oPanelD COLORS 0, 16777215 PIXEL     //"Agencia"
    @ 007, 270 SAY oSayConta PROMPT STR0062 SIZE 025, 007 OF oPanelD COLORS 0, 16777215 PIXEL     //"Conta"
    
  	//ฺฤฤฤฤฤฤฟ
	//ณButtonณ										
	//ภฤฤฤฤฤฤู   
    @ 003, 360 BUTTON oButton2 PROMPT STR0045 SIZE 037, 012 OF oPanelD PIXEL ;                     				//"Baixar"
    	ACTION	Eval({ || LjMsgRun(STR0046,,LJXBaixTit({cMotBx,cGetBanco,cGetAgenc,cGetConta}))}) 				//"Aguarde Baixando Titulos..."
    	
    @ 019, 360 BUTTON oButton3 PROMPT STR0047 SIZE 037, 012 OF oPanelD PIXEL ACTION Eval( {|| oDlg:End()}) 	//"Cancelar"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAlinhamento dos Panels, Nao mudar a ordenณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    oPanelU:Align := CONTROL_ALIGN_TOP
    oPanelD:Align := CONTROL_ALIGN_BOTTOM
    oPanelC:Align := CONTROL_ALIGN_ALLCLIENT
    
  	ACTIVATE MSDIALOG oDlg CENTERED   	

Return (Nil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXFillTit  บAutorณVendas Clientes     บ Data ณ  18/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega na tela os titulos do Contas a Receber e contas a   บฑฑ 
ฑฑบ          ณPagar	da Administradora financeira do parametro			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLJXFillTit(ExpC1)									          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Codigo da Administradora Financeira                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil														  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function LJXFillTit(cAdmFin)  

Local oOk 			:= LoadBitmap( GetResources(), "LBOK") 			//Objeto de selecao marcado
Local oNo 			:= LoadBitmap( GetResources(), "LBNO")			//Objeto de selecao desmarcado

Default cAdmFin 	:= ""											//Codigo Adm. Financeira

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa os Arrays para realizar consulta ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aBrowseCar := {} 
aBrowseCap := {}   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca titulos a Receber vinculados com os a Pagar ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cAdmFin)
	DbSelectArea("SE1")
	DbSetOrder(2) //E1_FILIAL+E1_CLIENTE      
	If DbSeek(xFilial("SE1")+cAdmFin,.T.) 
		While (SE1->(!Eof()) .AND. AllTrim(SE1->E1_CLIENTE) == AllTrim(cAdmFin))
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณBusca somente titulos em abertos ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SE1->E1_STATUS = "A" 			
				DbSelectArea("SE2")
				DbSetOrder(1) //E2_FILIAL+E2_PREFIXO
				If DbSeek(xFilial("SE2")+SE1->E1_PREFIXO,.T.)
					While (SE2->(!Eof()) .AND. AllTrim(SE2->E2_FORNECE) == AllTrim(cAdmFin))  
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณBusca titulos em abertos relacionados atraves do campo ณ
						//ณhistorico(E2_HIST) com a mesma sequencia de parcela    ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If SE2->E2_SALDO > 0 .AND. AllTrim(SE2->E2_HIST) == AllTrim(SE1->E1_NUM) .AND. AllTrim(SE2->E2_PARCELA) == AllTrim(SE1->E1_PARCELA)   
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณCarraga array do Contas a Receberณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							Aadd(aBrowseCar,{ .F.				,;
											SE1->E1_PREFIXO		,; 
											SE1->E1_NUM			,; 
											SE1->E1_PARCELA		,; 
											SE1->E1_TIPO		,; 
											SE1->E1_CLIENTE		,; 
											SE1->E1_LOJA		,;	
											SE1->E1_VENCREA		,;
											Transform(SE1->E1_VALOR, PesqPict("SE1","E1_VALOR")) }) 
											
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณCarraga array do Contas a Pagar  ณ	
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู										
							Aadd(aBrowseCap,{ .F.				,;
											SE2->E2_PREFIXO		,; 
											SE2->E2_NUM			,; 
											SE2->E2_PARCELA		,; 
											SE2->E2_TIPO		,; 
											SE2->E2_FORNECE		,; 
											SE2->E2_LOJA		,;	
											SE2->E2_VENCREA		,;
											Transform(SE2->E2_VALOR, PesqPict("SE2","E2_VALOR")) })
						Endif
						SE2->(DbSkip())
					End	
				Endif	
			Endif			   
			SE1->(DbSkip())     
		End
	Endif 
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe alguns dos Arrays estiver vazio Limpa os dois  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aBrowseCar) <= 0 .OR. Len(aBrowseCap) <= 0 
	aBrowseCar := {} 
	aBrowseCap := {}
	Aadd(aBrowseCar,{.F.,"","","","","","","",""} )
	Aadd(aBrowseCap,{.F.,"","","","","","","",""} )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ se nao tem administradora, nao mostra mensagem   ณ
	//ณ pois a funcao foi chamada para limpar as grids   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cAdmFin) 
		MsgAlert(STR0054)	//"Nao encontrou titulos para esta Administradora"	
	Endif	
Endif 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o array para a grid   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If(Len(aBrowseCar) > 0)
    oBrowseCar:SetArray(aBrowseCar) 
    oBrowseCar:bLine := {|| { If(aBrowseCar[oBrowseCar:nAT,1],oOk,oNo),;
	                   		aBrowseCar[oBrowseCar:nAt,2],;
	      					aBrowseCar[oBrowseCar:nAt,3],;
      						aBrowseCar[oBrowseCar:nAt,4],;
      						aBrowseCar[oBrowseCar:nAt,5],;    
      						aBrowseCar[oBrowseCar:nAt,6],;
	      					aBrowseCar[oBrowseCar:nAt,7],;
      						aBrowseCar[oBrowseCar:nAt,8],;
      						aBrowseCar[oBrowseCar:nAt,9]}} 
Endif    	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o array para a grid   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If(Len(aBrowseCap) > 0)
    oBrowseCap:SetArray(aBrowseCap) 
    oBrowseCap:bLine := {|| { If(aBrowseCap[oBrowseCap:nAT,1],oOk,oNo),;
		                   	aBrowseCap[oBrowseCap:nAt,2],;
      						aBrowseCap[oBrowseCap:nAt,3],;
      						aBrowseCap[oBrowseCap:nAt,4],;
      						aBrowseCap[oBrowseCap:nAt,5],;
      						aBrowseCap[oBrowseCap:nAt,6],;
      						aBrowseCap[oBrowseCap:nAt,7],;
      						aBrowseCap[oBrowseCap:nAt,8],;
      						aBrowseCap[oBrowseCap:nAt,9]}}     
Endif 	               

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXBaixTit  บAutorณVendas Clientes     บ Data ณ  18/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza baixa automatica dos titulos do Contas a Receber    บฑฑ 
ฑฑบ          ณvinculados com os do Contas a Pagar		  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLJXBaixTit(ExpA1)									          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1 - Array de Dados para realizar a Baixa contendo:     บฑฑ
ฑฑบ          ณ 		[1] - Motivo da Baixa		                          บฑฑ
ฑฑบ          ณ 		[2] - Banco		                		              บฑฑ
ฑฑบ          ณ 		[3] - Agencia		              			          บฑฑ
ฑฑบ          ณ 		[4] - Conta				                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil														  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function LJXBaixTit(aDadosBx)

Local nX 		:= 0    	    // Variavel auxiliar
Local aBaixaCar := {}       	// Array de Baixa do Contas a Receber
Local aBaixaCaP := {}		 	// Array de Baixa do Contas a Pagar    

PRIVATE lMsErroAuto	:= .F.		// Determina se houve algum tipo de erro durante a execucao do ExecAuto

Default aDadosBx := {}		    // Dados para realizar a Baixa

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe os dados da baixa estiverem  ณ
//ณvazios retorna sem fazer a baixaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Len(aDadosBx) > 0
	Return (Nil)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlimenta o array do Contas a Receber e faz a baixa ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aBrowseCar) > 0
	For nX := 1 to Len(aBrowseCar)		  
		If (!Empty(aBrowseCar[nX][2]) .AND. aBrowseCar[nX][1])	
			AADD( aBaixaCar, { "E1_PREFIXO" 	, aBrowseCar[nX][2]		, Nil } )	// 01
			AADD( aBaixaCar, { "E1_NUM"     	, aBrowseCar[nX][3]		, Nil } )	// 02
			AADD( aBaixaCar, { "E1_PARCELA" 	, aBrowseCar[nX][4]		, Nil } )	// 03
			AADD( aBaixaCar, { "E1_TIPO"    	, aBrowseCar[nX][5]		, Nil } )	// 04
			AADD( aBaixaCar, { "E1_CLIENTE"		, aBrowseCar[nX][6]		, Nil } )	// 05
			AADD( aBaixaCar, { "E1_LOJA"    	, aBrowseCar[nX][7]		, Nil } )	// 06
			AADD( aBaixaCar, { "AUTMOTBX"  		, aDadosBx[1]			, Nil } )	// 07
			AADD( aBaixaCar, { "AUTBANCO"  		, aDadosBx[2]			, Nil } )	// 08
			AADD( aBaixaCar, { "AUTAGENCIA"  	, aDadosBx[3]   		, Nil } )	// 09
			AADD( aBaixaCar, { "AUTCONTA"  		, aDadosBx[4]			, Nil } )	// 10
			AADD( aBaixaCar, { "AUTDTBAIXA"		, dDataBase				, Nil } )	// 11
			AADD( aBaixaCar, { "AUTHIST"   		, STR0055				, Nil } )	// 12 //"Baixa Aut. Adm/Fin."
			AADD( aBaixaCar, { "AUTDESCONT" 	, 0						, Nil } )	// 13
			AADD( aBaixaCar, { "AUTMULTA"	 	, 0						, Nil } )	// 14
			AADD( aBaixaCar, { "AUTJUROS"		, 0						, Nil } )	// 15
			AADD( aBaixaCar, { "AUTOUTGAS" 		, 0						, Nil } )	// 16
			AADD( aBaixaCar, { "AUTVLRPG"  		, 0        				, Nil } )	// 17
			AADD( aBaixaCar, { "AUTVLRME"  		, 0						, Nil } )	// 18
			AADD( aBaixaCar, { "AUTCHEQUE"  	, ""					, Nil } )	// 19
	          
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณExecuta rotina automatica do Contas a Receber ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lRet := MSExecAuto({|x,y| Fina070(x,y)},aBaixaCar,3)  
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se houveram erros durante a execucao da rotina automatica.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			Endif 		

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณLimpa Array de Baixa do Contas a Receberณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aBaixaCar := {}       
		Endif
	Next nX 
Endif					

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlimenta o array do Contas a Pagar e faz a baixa   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aBrowseCap) > 0
	For nX := 1 to Len(aBrowseCap)        
		If (!Empty(aBrowseCap[nX][2]) .AND. aBrowseCap[nX][1])
			AADD( aBaixaCap, { "E2_PREFIXO" 	, aBrowseCap[nX][2]		, Nil } )	// 01
			AADD( aBaixaCap, { "E2_NUM"     	, aBrowseCap[nX][3]		, Nil } )	// 02
			AADD( aBaixaCap, { "E2_PARCELA" 	, aBrowseCap[nX][4]		, Nil } )	// 03
			AADD( aBaixaCap, { "E2_TIPO"    	, aBrowseCap[nX][5]		, Nil } )	// 04
			AADD( aBaixaCap, { "E2_FORNECE"		, aBrowseCap[nX][6]		, Nil } )	// 05
			AADD( aBaixaCap, { "E2_LOJA"    	, aBrowseCap[nX][7]		, Nil } )	// 06
			AADD( aBaixaCap, { "AUTMOTBX"  		, aDadosBx[1]			, Nil } )	// 07
			AADD( aBaixaCap, { "AUTBANCO"  		, aDadosBx[2]			, Nil } )  	// 08
			AADD( aBaixaCap, { "AUTAGENCIA"  	, aDadosBx[3]			, Nil } )	// 09
			AADD( aBaixaCap, { "AUTCONTA"  		, aDadosBx[4]			, Nil } )	// 10
			AADD( aBaixaCap, { "AUTDTBAIXA"		, dDataBase				, Nil } )	// 11
			AADD( aBaixaCap, { "AUTHIST"   		, STR0055				, Nil } )	// 12 //"Baixa Aut. Adm/Fin."
			AADD( aBaixaCap, { "AUTDESCONT" 	, 0						, Nil } )	// 13
			AADD( aBaixaCap, { "AUTMULTA"	 	, 0						, Nil } )	// 14
			AADD( aBaixaCap, { "AUTJUROS" 		, 0						, Nil } )	// 15
			AADD( aBaixaCap, { "AUTOUTGAS" 		, 0						, Nil } )	// 16
			AADD( aBaixaCap, { "AUTVLRPG"  		, 0        				, Nil } )	// 17
			AADD( aBaixaCap, { "AUTVLRME"  		, 0						, Nil } )	// 18
			AADD( aBaixaCap, { "AUTCHEQUE"  	, ""					, Nil } )	// 19
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณExecuta rotina automatica do Contas a Pagar   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู            
			lRet :=	MSExecAuto({|x,y| Fina080(x,y)},aBaixaCap,3)
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se houveram erros durante a execucao da rotina automatica.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			Endif
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณLimpa Array de Baixa do Contas a pagar  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aBaixaCap := {}   
		Endif		
	Next nX 
Endif  
   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa tela chamando funcao de carregar titulos masณ
//ณsem passar a adminsitradora   					 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
LJXFillTit()          

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe executou sem erro mostra msg de confirmacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lMsErroAuto
	MsgAlert(STR0063)	//"Titulos Baixados com Sucesso."
Endif

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxSiglaFo  บAutorณVendas CRM			 บ Data ณ  23/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a descri็ใo (SIGLA)do combo box do campo FP_ESPECIE บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI          					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpL1 := LjxSiglaFo(ExpC1)								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da Especie do formulario   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpC1 - Sigla da especie (Igual das tabelas 05 e 42 doo SX5)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Function LjxSiglaFo (cCodigo)                                       

Local aSX3Box	:= {}	//Array de Opcoes do Combo Box
Local cRet  	:= ""  	//Retorno
Local nPos		:= 0   	//Posicao do array    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5 - Controle de Formulariosณ
//ณPaises: Chile / Colombia  - F1CHI     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"
Default cCodigo	:= ""

If !lLocR5
	Return cRet
Endif 

If !Empty(Posicione("SX3", 2, "FP_ESPECIE", "X3CBox()" ))
	aSX3Box	:= RetSx3Box( Posicione("SX3", 2, "FP_ESPECIE", "X3CBox()" ),,, 1 )
	
	nPos := Ascan(aSX3BOX,{|x| x[2]== Rtrim(cCodigo)})
	If nPos > 0 
		cRet:= aSX3Box[nPos,3]
	Endif
Endif

If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXVldFo 	  บAutorณVendas CRM			 บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica status e validade do controle de formulario		  บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI        					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpL1:=LJXVldFo(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,@ExpN7) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Filial de Uso									      บฑฑ
ฑฑบ			 ณExpC2 - Serie				 		               			  บฑฑ
ฑฑบ			 ณExpC3 - Numero da Resolucao								  บฑฑ
ฑฑบ			 ณExpC4 - Numero Inicial do formulario	   					  บฑฑ
ฑฑบ			 ณExpC5 - Numero Final do formulario	   					  บฑฑ
ฑฑบ			 ณExpC6 - Especie do formulario	     				    	  บฑฑ
ฑฑบ			 ณExpn7 - RECNO do formulario (SFP)	  						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Indica se o formulario eh valido	 				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Function LJXVldFo (cFilUso	,cSerie		,cCai		,cNumIni,;
					cNumFim	,cEspecie	,_nRecnoFo)

Local aArea 		:= GetArea()
Local lRet			:= .F.  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5 - Controle de Formulariosณ
//ณPaises: Chile / Colombia  - F1CHI     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lLocR5		:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL" 

DEFAULT cFilUso 	:= ""
DEFAULT cSerie 		:= ""
DEFAULT cCai 		:= ""
DEFAULT cNumIni 	:= ""
DEFAULT cNumFim		:= ""
DEFAULT cEspecie	:= "" 
DEFAULT _nRecnoFo 	:= 0


If !lLocR5
	Return .F.
Endif 

DbSelectArea("SFP")
DbSetOrder(3)         
If DbSeek(xFilial("SFP")+cFilUso+cSerie+cCai+cNumIni+cNumFim+cEspecie)
	If SFP->FP_ATIVO == "1"
		If dDataBase <= SFP->FP_DTAVAL
			_nRecnoFo:=SFP->(Recno())				
	    	lRet := .T.                                                      	
		EndIf	
	EndIf
EndIf               

SFP->(DbCloseArea())
RestArea(aArea)

Return lRet                                                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxTelaEsp  บAutorณVendas CRM			 บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria a  tela que o usuario informara o formulario da venda. บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI          					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpL1 :=LjxTelaEsp(@ExpC1,@ExpC2,ExpA3,@ExpC4,@ExpN5,@ExpL6)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Sigla da Especie do formulario     				  บฑฑ
ฑฑบ			 ณExpC2 - Numero do documento 		               			  บฑฑ
ฑฑบ			 ณExpA3 - Lista das especies reservadas para estacao (SL6xSFP)บฑฑ
ฑฑบ			 ณExpC4 - Serie do formulario							      บฑฑ
ฑฑบ			 ณExpN5 - RECNO do formulario (SFP)	  					      บฑฑ
ฑฑบ			 ณExpL6 - Indica se esta sendo executada na importacao	      บฑฑ
ฑฑบ			 ณ		  orcamento no FRONTLOJA						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Retorna Botao OK da Tela							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function LjxTelaEsp(_cSigEspFo,_cDocFo,aEspecie,_cSerieFo,;
							_nRecnoFo,lImport)
					
Local aRet		:= {}
Local lRet 		:= .F.                              //Retorno
Local nTimeout	:=	SuperGetMV("MV_NOTAOUT")		//Time Out para escolha da serie da nota fiscal
Local lTimeOut	:=	.F.								//Controle de Time Out
Local oEspecie,oSerie,oNumNota,oDlgEspecie			//Objetos da tela
Local cCodEspFo := ""								//Codigo da especie do documento utilizado na venda, escolhido pelo usuario
Local cSigEspFo := SPACE(TamSx3("X5_CHAVE")[1])	//Especie do documento utilizado na venda, escolhido pelo usuario
Local cSerieFo	:= SPACE(TamSx3("FP_SERIE")[1])	//Serie que sera utilizada para o tipo de documento escolhido
Local cDocFo	:= SPACE(TamSx3("F2_DOC")[1])		//Nota referente a serie escolhida
Local cProg   	:= FunName()  
Local nPosRec	:= 0 
Local nRecnoFo	:= 0 
Local aAreaSL1	:= SL1->(GetArea())  
Local lLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"	

DEFAULT _cSigEspFo	:= ""
DEFAULT _cDocFo		:= ""
DEFAULT aEspecie	:= {}
DEFAULT _cSerieFo	:= ""
DEFAULT _nRecnoFo	:= 0  
DEFAULT lImport		:= .F.


If !lLocR5
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOBTER DADOS DA ULTIMA VENDAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SL1")
SL1->(DbGoBottom ())

If !Empty(SL1->L1_SERIE) .AND. !Empty(SL1->L1_DOC)
	nRecnoFo := LjxRecnoFo (SL1->L1_SERIE)	
	
	LjxDadosFo(nRecnoFo,@cCodEspFo,@cSigEspFo)
	
	If nRecnoFo > 0 .AND. cCodEspFo$"1|2|3|4"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetornar a especie/serie/numero+1 do documento da ultima   ณ
		//ณvenda se ela for:  1-FCT ; 2-FCX ; 3-BLT ; 4-BLX           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If !Empty(SL1->L1_SERIE)		
			cSerieFo := SL1->L1_SERIE		
		ElseIf !Empty(SL1->L1_SERPED)		  
			cSerieFo := SL1->L1_SERPED				
		EndIf
		
		DbSelectArea("SX5")
   		DbSetOrder(1)
  		DbSeek(xFilial()+"01"+cSerieFo)
   		cDocFo := AllTrim(X5Descri())
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerificar se a serie da ultima venda esta reservada para a estacaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SL6")
		DbSetOrder (1)
		If !DbSeek(xFilial("SL6")+cSerieFo+cEstacao)
			cSigEspFo:= SPACE(TamSx3("X5_CHAVE")[1])
			cSerieFo:= SPACE(TamSx3("FP_SERIE")[1])
			cDocFo := SPACE(TamSx3("F2_DOC")[1]) 
		EndIf
		SL6->(DbCloseArea())
	Else
		cSigEspFo:= SPACE(TamSx3("X5_CHAVE")[1])
		cSerieFo:= SPACE(TamSx3("FP_SERIE")[1])
		cDocFo := SPACE(TamSx3("F2_DOC")[1])  	
	EndIf	
	
EndIf


SL1->(RestArea(aAreaSL1))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTAGEM DA TELAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgEspecie TITLE STR0029 From 10,30 To 17,62; 
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF If(cProg == "LOJA701",oDlgVA,oDlgEspecie)//"Dados do Formulแrio"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               


@ 1, 2 TO 36, 125 OF oDlgEspecie PIXEL

//ESPECIE
@ 5, 5 SAY STR0030 SIZE 25, 7 OF oDlgEspecie PIXEL //"Esp้cie"

If Len(aEspecie) > 1
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe houver mais de uma especie reservada, ณ
	//ณ(SL6 x SFP)permitir pesquisa pelo do F3  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 15, 5 MSGET cSigEspFo PICTURE PesqPict("SFP","FP_ESPECIE") VALID (LjxVldEsp(cSigEspFo,@cSerieFo) .AND. LjxVldNota(cSerieFo,@cDocFo)) F3 "SL6RES" SIZE 8, 10 OF oDlgEspecie PIXEL
		
Else 
	cSigEspFo:= LjxSiglaFo(aEspecie [1][1])	
	cSerieFo:= aEspecie [1][2]
	LjxVldNota(cSerieFo,@cDocFo)
	@ 15, 5 MSGET cSigEspFo  PICTURE PesqPict("SFP","FP_ESPECIE") SIZE 8, 10 OF oDlgEspecie PIXEL //READONLY
Endif

//SERIE
@ 5, 40 SAY STR0031 SIZE 20, 7 OF oDlgEspecie PIXEL //"S้rie"
@ 15,40 MSGET oSerie VAR cSerieFo PICTURE PesqPict("SFP","FP_SERIE") SIZE 12, 10 OF oDlgEspecie PIXEL READONLY

//NUMERO DO DOCUMENTO                            
@ 5, 70 SAY STR0032 SIZE 40, 7 OF oDlgEspecie PIXEL //"N๚mero"
@ 15,70 MSGET oNumNota VAR cDocFo PICTURE PesqPict("SF2","F2_DOC");
VALID LjxDZera(@cDocFo) SIZE 50, 10 OF oDlgEspecie PIXEL READONLY
                                                              
//VENDA MANUAL
If LjProfile(28)
	@ 28, 35 SAY STR0074 SIZE 50, 7 OF oDlgEspecie PIXEL //VENDA MANUAL
EndIf

DEFINE SBUTTON FROM 38,08 TYPE 1 ACTION (lRet := .T.,oDlgEspecie:End()) ENABLE OF oDlgEspecie

DEFINE SBUTTON FROM 38,38 TYPE 2 ACTION (lRet := .F.,oDlgEspecie:End()) ENABLE OF oDlgEspecie   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVeriricar se o usuario tem permissao p/ avancar a numeracao do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oBtAvancar:=tButton():New(39,68,STR0033,oDlgEspecie,{||(IIf (!Empty(cDocFo),LjxNextNum(@cDocFo),Nil))},54,10,,,,.T.)//"Pr๓ximo"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    

ACTIVATE MSDIALOG oDlgEspecie CENTERED        

If lRet
	_cSigEspFo:=Rtrim(cSigEspFo) 
	_cDocFo:=Rtrim(cDocFo)
	_cSerieFo:=cSerieFo
	
	nPosRec := aScan(aEspecie, { |x| AllTrim(x[02]) == cSerieFo })
	If nPosRec > 0 
		_nRecnoFo:= aEspecie[nPosRec][3]
	EndIf              
	
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxVldEsp   บAutorณVendas CRM			 บ Data ณ  21/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar se a especie do formulario pode ser utilizada junto บฑฑ
ฑฑบ		     ณcom a determinada s้rie que deve estar reservada p/ esta็ใo.บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI          					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpL1 := LjxVldEsp (ExpC1,ExpC2)				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Especie								              บฑฑ
ฑฑบ			 ณExpC2 - Serie						               			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Indica se a serie eh valida.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function LjxVldEsp(cEspecie,cSerie)
Local lRet := .T.							//Retorno da funcao
Local aArea:=  GetArea()					//Area 
Local nPosIni 	:= 0
Local cCombo  	:= ""
Local lLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"	

DEFAULT cEspecie:= ""
DEFAULT cSerie	:= ""

If !lLocR5
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca posicao da descricao da especie da nota no combo da tabela SFP (1=FCT;2=FCT;3=BLT;4=BLX;5=GDP;6=NDC;7=NDI;8=NCC;9=NCI;A=NCX)   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->(dbSetOrder(2))
SX3->(dbSeek("FP_ESPECIE"))
nPosIni := At(AllTrim(cEspecie),AllTrim(SX3->X3_CBOXSPA))
cCombo := Substr(AllTrim(SX3->X3_CBOXSPA),nPosIni-2,1)


DbSelectArea("SL6")
DbSetOrder(4)
If DbSeek(xFilial()+cEstacao+cCombo)
	cSerie:=SL6->L6_SERIE
	lRet:=.T.
Else
	lRet:=.F.
EndIf   

RestArea(aArea)	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxVldNota  บAutorณVendas CRM			 บ Data ณ  22/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar numeracao do formulario 						      บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI          					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpL1 := LjxVldNota(ExpC1,ExpC2)				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Serie									              บฑฑ
ฑฑบ			 ณExpC2 - Numero do documento fiscal               			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Indica se o numero do documento eh valido.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function LjxVldNota( cSerie, cNumNota)
Local lRet := .T.													//Retorno da funcao
Local aArea:=   GetArea()											//Area 
Local lNotaManual  := IIf(Type("lNFManual")#"U",lNFManual,.F.)		//Nota manual
Local lLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"	

DEFAULT cSerie 		:= ""
DEFAULT cNumNota 	:= ""

If !lLocR5
	Return .F.
EndIf

If !lNotaManual
	DbSelectArea("SX5")
   	DbSetOrder(1)
   	If !DbSeek(xFilial()+"01"+cSerie)   	
		Help(" ",1,"LJ010SERIE")
	   	lRet:=.F.
	EndIf   
   	cNumNota := AllTrim(X5Descri())   	
   	If !ChkFolCHI(xFilial("SFP"),	cSerie,	cNumNota ,"1|2|3|4|8")
   		lRet:=.F.
   	EndIf
   	
	RestArea(aArea)	
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxEspxFo   บAutorณVendas CRM			 บ Data ณ  22/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerificar especies de formlarios validas que podem 		  บฑฑ 
ฑฑบ          ณser utilizadas na venda							          บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia  - F1CHI         					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpL1 := LjxEspxFo(@ExpC1,@ExpC2,@ExpC3,@ExpN4,@ExpL5       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da especie do formulario		              บฑฑ
ฑฑบ			 ณExpC2 - Numero do formulario		               			  บฑฑ
ฑฑบ			 ณExpC3 - Serie do formulario		               			  บฑฑ
ฑฑบ			 ณExpN4 - RECNO do Controle de formulario selecionado. (SFP)  บฑฑ
ฑฑบ			 ณExpL5 - Indica se esta sendo executada na importacao	      บฑฑ
ฑฑบ			 ณ		  orcamento no FRONTLOJA.						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Indica se a especie foi escolhida corretamente.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Function LjxEspxFo (_cEspecie,_cNumNota,_cSerieFo,_nRecnoFo,;
					lImport)
Local cEspecie	:= ""			//Especie escolhida 
Local cEspAux	:= "" 			//Especie
Local cSerieAux := ""           //Serie
Local cNumNota	:= ""			//Nota escolhida, se o usuario tiver permissao
Local cSerie	:= ""			//S้rie da especie escolhida	   
Local aArea		:= (GetArea()) 	// Salva a area
Local aEspecie	:= {}			//Array com as especies reservadas para a estacao	
Local lRet		:= .F.	  
Local nRecnoFo1	:= 0
Local nRecnoFo2	:= 0                     

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5 - Controle de Formulariosณ
//ณPaises: Chile / Colombia  - F1CHI     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"	

DEFAULT _cEspecie 	:= ""
DEFAULT _cNumNota	:= ""
DEFAULT _cSerieFo	:= ""
DEFAULT _nRecnoFo	:= 0
DEFAULT lImport		:= .F.

If !lLocR5
	Return lRet
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar na tabela SL6 se os tipos de documento Boleta,  ณ
//ณBoleta Exenta, Factura ou Factura Exenta estใo reservados ณ
//ณpara a estacao 											 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SL6")
DbSetOrder(3)
If DbSeek(xFilial("SL6")+cEstacao)
	Do While SL6->L6_ESTACAO == cEstacao
		If (SL6->L6_ESPFO) $ "1|2|3|4"
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe a reserva de serie estiver associada a um ณ
			//ณformulario, verificar se o mesmo eh valido.  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ChkFolCHI(SL6->L6_FILFO,	SL6->L6_SERIE,	NIL	,"1|2|3|4",;
							@nRecnoFo1,	.T.)
											
		   		
		   		Aadd(aEspecie,{SL6->L6_ESPFO,SL6->L6_SERIE,nRecnoFo1})			
			EndIf			
		EndIf
		SL6->(DbSkip())
	End
EndIf
                                       
If Len(aEspecie) >= 1	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExibir tela para o usuario escolher a especie do documento fiscal ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		    	
    If !LjxTelaEsp(@cEspecie,@cNumNota,aEspecie,@cSerie,;
    				@nRecnoFo2,lImport)
    	lRet:= .F.                                     
    Else
    	lRet:= .T.
    EndIf	    	
Else
	lRet:= .F.	
Endif   

_cEspecie := cEspecie
_cNumNota := cNumNota 
_cSerieFo := cSerie
_nRecnoFo := nRecnoFo2

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxNextNum  บAutorณVendas CRM			 บ Data ณ  23/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvancar a numeracao do formulario			                  บฑฑ 
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI          					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpC1 := LjxNextNum(@ExpC1) 		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Numero do  documento fiscal (velho/novo)            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNIL										                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function LjxNextNum (_cNumNota)
Local cNumNota 		:= ""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5 - Controle de Formulariosณ
//ณPaises: Chile / Colombia  - F1CHI     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lCFolLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL" 
DEFAULT _cNumNota 	:= ""

If lCFolLocR5 .AND. LjProfile(26)    
    cNumNota:= SomaIt(_cNumNota)     
    If MsgYesNo (STR0034 + _cNumNota + STR0035 +  cNumNota + " ? ")//"Deseja alterar o n๚mero do formulแrio "#" para "
    	_cNumNota:= cNumNota
    EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxDadosFo  บAutorณVendas CRM			 บ Data ณ 08/04/11    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os dados do contr. formulario de acordo com o RECNO บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI          					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLjxTesFo(ExpN1,@ExpC2,@ExpC3,@ExpC4,@ExpC5)                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Numero do RECNO do Formulario (SFP)  			      บฑฑ
ฑฑบ          ณExpC2 - Codigo da especie do formulario   				  บฑฑ
ฑฑบ          ณExpC3 - Sigla  da especie do formulario            		  บฑฑ
ฑฑบ          ณExpC4 - Descricao da especie do formulario 				  บฑฑ
ฑฑบ          ณExpC5 - Serie do formulario 				  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNIL						                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/FrontLoja                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Function LjxDadosFo (nRecNo,_cEspCod,_cEspSigla,_cEspDesc,;
					_cSerie)

Local aArea:= GetArea()
Local lLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"

DEFAULT nRecNo 		:= 0		//RECNO do registro do formularios
DEFAULT _cEspCod 	:= ""		//Codigo da especie do formulario
DEFAULT _cEspSigla 	:= ""		//Sigla da especie do formularios (1=FCT;2=FCX;3=BLT;4=BLX;5=GDP;6=NDC;7=NDI;8=NCC;9=NCI;A=NCX)
DEFAULT _cEspDesc 	:= ""		//Descricao da Especie (TABELA 42)
DEFAULT _cSerie		:= ""		//Serie

If !lLocR5
	Return NIL
EndIf

If nRecNo == 0 
	Return Nil
EndIf

DbSelectArea("SFP")
SFP-> (DbGoto (nRecNo))

_cEspCod 	:= SFP->FP_ESPECIE
_cEspSigla 	:= LjxSiglaFo (_cEspCod)

DbSelectArea("SX5")
DbSetOrder(1)
If !DbSeek(xFilial()+"42"+_cEspSigla)
	Help(" ",1,"LJ010SERIE")
	lRet:=.F.	   
Else
	_cEspDesc := AllTrim(X5_DESCRI)
EndIf

_cSerie:= SFP->FP_SERIE

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxRecnoFo  บAutorณVendas CRM			 บ Data ณ 13/04/11    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o RECNO do contr. formulario de acordo com a serie. บฑฑ
ฑฑบ		     ณRelease 11.5 - Controle de Formularios 					  บฑฑ
ฑฑบ		     ณPaises: Chile /Colombia - F1CHI          					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpN1 := LjxRecnoFo(ExpC1)   		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Serie do Formulario               				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpN1 - RECNO da tabela SFP                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/FrontLoja                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Function LjxRecnoFo (cSerie) 
Local aArea:= GetArea()
Local nRecno:= 0
Local lLocR5	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"

DEFAULT cSerie:= "" 

If !lLocR5
	Return nRecno
EndIf

DbSelectArea("SFP")

If DbSeek (xFilial("SFP")+SL1->L1_FILIAL+cSerie)
	nRecno := SFP->(RecNo())
EndIf

RestArea(aArea)

Return nRecno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxCrdCf  บAutor  ณVendas e CRM        บ Data ณ  10/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para adicionar ou mudar o conteudo da                บฑฑ
ฑฑบ          ณimpressao do comprovante de financiamento.                  บฑฑ
ฑฑบ          ณE executado para os dois tipos de comprovantes OFF-LINE  e  บฑฑ
ฑฑบ          ณON-LINE.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ ExpA1 - Array com o texto que sera impresso                บฑฑ
ฑฑบ          ณ ExpN2 - Valor total do SL1                                 บฑฑ
ฑฑบ          ณ ExpN3 - Dias informados no SE4                             บฑฑ
ฑฑบ          ณ ExpN4 - Parcelas                                           บฑฑ
ฑฑบ          ณ ExpN5 - Valor da parcela                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Array com o texto que sera impresso                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaCRD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjxCrdCf(aComp, nVlrTot, nDiasSe4, nQtdFin, nParcFin, nAcrsFin)

Local nPosParc 		:= 0 									//Posicao das parcelas no array de texto
Local nPosVlrTot	:= 0 									//Posicao do valor total no array de texto
Local cMvFiliais	:= SuperGetMV("MV_FILACRS",,"01")   	//Filiais que trabalham com o conceito de acrescimo.  
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)				//Verifica as filiais da empresa que trabalharam com acrescimento separado
Local lR5           := GetRpoRelease("R5")    				//Indica se o release e 11.5

Default aComp		:= {} 									//Texto que sera impresso no comprovante
Default nVlrTot		:= 0 									//Valor Total do SL1
Default nDiasSe4	:= 0 									//Dias para pagto do SE4
Default nQtdFin		:= 0 									//Parcelas             
Default nParcFin	:= 0 									//Valor da Parcela
Default nAcrsFin	:= 0 									//Porcentagem do Acrescimo

If nAcrsFin > 0
	nParcFin := nParcFin + nAcrsFin
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe trabalhar com o conceito de acrescimo separado, ณ
//ณimprime comprovante de financiamneto               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (lVerEmpres .AND. cFilAnt $ cMvFiliais) .OR. (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o comprovante nas linhas de valor total e parcelas com outro textoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	//Linha do comprovante onde e informado o numero de parcelas	
	nPosParc 	:= Ascan(aComp,STR0064) 	//"Parcela"
	
	//Linha do comprovante onde e informado o valor total
	nPosVlrTot 	:= Ascan(aComp,STR0065)		//"Valor"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe for pagamento a prazo e nใo utilizar oณ
	//ณconceito de dias para pagamento a vista  ณ
	//ณimprime cupom com mensagem diferente     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nDiasSe4 == 0
		If nPosParc > 0
			aComp[nPosParc]:= 	"         "+STR0071 	//"Para pagto a prazo em "
		Endif
		If nPosVlrTot > 0
			aComp[nPosVlrTot]  :=  	"        "+ Alltrim(STR(nQtdFin,0)) + STR0069 + STR0070 + ;	//" parcelas de "###"R$ "
									Alltrim(Transform(nParcFin,PesqPict("SL2","L2_VLRITEM")))
		Endif
	Else
		If nPosParc > 0
			aComp[nPosParc]:= 	" "+STR0066 + Alltrim(STR(nDiasSe4,0)) + STR0067 + STR0070 +   ;	//"Pagto a vista em ate "###" dias "###"R$ "
									Alltrim(Transform(nVlrTot,PesqPict("SL1","L1_VLRTOT")))
		Endif
		If nPosVlrTot > 0
			aComp[nPosVlrTot]  :=  	"    "+STR0068 + Alltrim(STR(nQtdFin,0)) + STR0069 + STR0070 + ;	//" ou em "###" parcelas de "###"R$ "
									Alltrim(Transform(nParcFin,PesqPict("SL2","L2_VLRITEM")))
		Endif
    Endif

EndIf

Return(aComp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxRecver บAutor  ณVendas e CRM        บ Data ณ  10/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que verifica se o E4_AGRACRS estแ habilitado,       บฑฑ
ฑฑบ          ณ se o E4_LIMACRS tem informacao. Caso sim, modifica o       บฑฑ
ฑฑบ          ณ aTitulos somente o valor com o acrescimo.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1 - aTitulos de entrada pelo Paramixb  	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - aTitulos alterado                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA/FRONTLOJA                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjxRecver(aTitulo)

Local cMv1Dup		:= SuperGetMV("MV_1DUP")				//Como esta as sequencias das duplicatas
Local cF2FormPg		:= ""									//Forma de pagamento
Local nX			:= 0									//Contador de For
Local nI			:= 0									//Contador de For
Local cAliasF2		:= "SF2"								//Alias SF2
Local cFilialSF2	:= ""									//Filial do SF2
Local aContrato		:= {}									//Contratos
Local oSvc			:= Nil									//WebService
Local aRetContr		:= {}									//Retorno do WebService
Local lRet			:= .F.									//Retorno do WebService
Local lWS			:= (nModulo == 23 .or. (nModulo == 12 .AND. LjxBGetPaf()[2]))										// Indica se ้ pdv

Default aTitulo     := {}									//Array com os titulos a receber do cliente

//    aTitulo           aContrato
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ2-  Prefixo     ณณ2-  Contrato    ณ
//ณ3-  NumTitulo   ณณ3-  Prefixo     ณ
//ณ4-  Parcela     ณณ4-  NumTitulo   ณ
//ณ5-  Vencimento  ณณ5-  Parcela     ณ
//ณ6-  Valor       ณณ6-  FilTit      ณ
//ณ7-  VlrMulta    ณณ7-  VlsAcres    ณ
//ณ8-  VlrJuros    ณณ8-  Cliente     ณ
//ณ9-  VlrDesconto ณณ9-  Loja        ณ
//ณ10- VlrRecebido ณณ10- Vencimento  ณ
//ณ11- Tipo        ณภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ณ12- Contrato    ณ                    
//ณ13- Cliente     ณ                    
//ณ14- Loja        ณ                     
//ณ15- FilTit      ณ                    
//ณ16- NumRecno    ณ
//ณ17- VlrAcres    ณ
//ณ18- Conceito Acrณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If Len(aTitulo) > 0
	For nX := 1 To Len(aTitulo)
		If AllTrim(cMv1Dup) == AllTRim(aTitulo[nX][4]) 
			Aadd(	aContrato,{	.F., 				aTitulo[nX][12],	aTitulo[nX][2],		aTitulo[nX][3],;
								aTitulo[nX][4],		aTitulo[nX][15],	aTitulo[nX][17],	aTitulo[nX][13],;
								aTitulo[nX][14],	aTitulo[nX][5]})
		EndIf
		aTitulo[nX][10]	+= aTitulo[nX][17]
	Next nX
EndIf

If Len(aContrato) > 0
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria o metodo WSANALISAREC ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If lWS
		oSvc := WSANALISAREC():New()
		iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autentica็ใo do Web Service
		oSvc :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/ANALISAREC.apw"	
		     
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cria o array dentro do metodo ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oSvc:OWSAANALISE:OWSVERARRAY 					:= ANALISAREC_ARRAYOFWSANALISE():New()
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE 		:= Array( Len(aContrato) )
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAntes de chamar o metodo, atribui os valores ณ
		//ณas propriedades (passagem de parametros)     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
		For nX := 1 To Len(aContrato)
	
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX] := ANALISAREC_WSANALISE():New()
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:LMARCADO	:=	aContrato[nX][1]	
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CCONTRATO	:=	aContrato[nX][2]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CPREFIXO	:=	aContrato[nX][3]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CTITULO	:=	aContrato[nX][4]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CPARCELA	:=	aContrato[nX][5]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CFILIAL	:=	aContrato[nX][6]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:NVLRACR	:=	aContrato[nX][7]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CCLIENTE	:=	aContrato[nX][8]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CLOJA		:=	aContrato[nX][9]
			oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:DVENCTO	:=	aContrato[nX][10]
		Next nX
	
		//"Aguarde...Verificando prazo..."
		LJMsgRun( STR0072,, { || lRet := oSvc:GETRECVER() } ) 
	                                                                 
		If !lRet 
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"					
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
				Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			Else
				//"Sem comunica็ใo com o WebService!"+"Atencao"
				MsgStop(STR0002,STR0003)
			EndIf
		Else
	
			For nX := 1 to Len( oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE )
				aAdd( aRetContr, { oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE[nX]:LVERDADE, oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE[nX]:CCONTRATO } )
			Next nX 
		Endif
	Else
		aRetContr := WSLJRVERIF( aContrato )
	EndIf

	If Len(aRetContr) > 0
		For nX := 1 To Len(aRetContr)
			If aRetContr[nX][1]
				aEval( aTitulo,{|x| IIf(x[12] == aRetContr[nX][2],x[18] := .T.,"")})
			EndIf
		Next nX
	EndIf
EndIf	

Return(aTitulo)    
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxRecAlt   บAutor  ณVendas e CRM      บ Data ณ  10/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca todos os item do aTitulos, se o cliente quiser quitarบฑฑ
ฑฑบ          ณ o contrato. Este controle eh feito pela posicao [18] do    บฑฑ
ฑฑบ          ณ aTitulos.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLjxRecAlt(ExpN1,ExpA1) 	                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Total com dos titulos a receber      				  บฑฑ     
ฑฑบ          ณExpA1 - Array com os titulos a receber      				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA1 - Array com os titulos a receber                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/FrontLoja                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function LjxRecAlt(nTotal, aTitulo)

Local nX			:= 0							//Controle de For
Local nY			:= 0							//Controle de For
Local lAltArray		:= .T.							//Altera array?
Local cMv1Dup		:= SuperGetMV("MV_1DUP")		//Como esta as sequencias das duplicatas
Local aVerCont		:= {}							//Verifica os contratos
Local aRetorno		:= {}							//Retorno do PE
Local nAux			:= 0							//Auxiliar

Default nTotal		:= 0							//Total com dos titulos a receber do cliente
Default aTitulo		:= {}							//Array com os titulos a receber do cliente

//Estrutura do array aTitulo:
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ2-  Prefixo     ณ
//ณ3-  NumTitulo   ณ
//ณ4-  Parcela     ณ
//ณ5-  Vencimento  ณ
//ณ6-  Valor       ณ
//ณ7-  VlrMulta    ณ
//ณ8-  VlrJuros    ณ
//ณ9-  VlrDesconto ณ
//ณ10- VlrRecebido ณ
//ณ11- Tipo        ณ
//ณ12- Contrato    ณ
//ณ13- Cliente     ณ
//ณ14- Loja        ณ
//ณ15- FilTit      ณ
//ณ16- NumRecno    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMarca todos os item do aTitulos, se o cliente quiser quitarณ
//ณo contrato. Este controle eh feito pela posicao [18] do    ณ
//ณarray aTitulos.                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aTitulo) > 0
	Ascan( aTitulo, {|x| IIf( x[18] .AND. x[1] .AND. x[4] == cMv1Dup, Aadd(aVerCont,{x[12]}),"") } )
	If Len(aVerCont) > 0	
		For nX := 1 To Len(aVerCont)
			For nAux := 1 To Len(aTitulo)
				If aTitulo[nAux][12] == aVerCont[nX][1]
					If !aTitulo[nAux][1]
						lAltArray := .F. 
					EndIf
				EndIf
			Next nAux		
			If lAltArray					
				For nY := 1 To Len(aTitulo)
					If aVerCont[nX][1] == aTitulo[nY][12]
						aTitulo[nY][10]	:= aTitulo[nY][10] - aTitulo[nY][17]
	                	nTotal 	-= aTitulo[nY][17]
	                EndIf
				Next nY
	            lAltArray := .T.
            EndIf
		Next nX
	EndIf
EndIf

Aadd(aRetorno,nTotal)
Aadd(aRetorno,aTitulo)

Return (aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjxRecSele  บAutor  ณVendas e CRM      บ Data ณ  10/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca todos os item do aTitulos, se o cliente quiser quitarบฑฑ
ฑฑบ          ณ o contrato. Este controle eh feito pela posicao [18] do    บฑฑ
ฑฑบ          ณ aTitulos.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLjxRecSele(ExpA1,ExpO1) 	                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1 - Array com os titulos a receber      				  บฑฑ     
ฑฑบ          ณExpO1 - Objeto do listbox                 				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA1 - Array com os titulos a receber                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/FrontLoja                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function LjxRecSele(aTitulo, oTit)

Local lNaoAcresc	:= .F.				//Tem direito a desconto do acrescimo.
Local nX       		:= 0                //Controle de contador
Local cTitulo  		:= ""              	//Numero 
Local cParcela 		:= ""              	//Parcela
Local lRet			:= .T.             	//Retorno

Default aTitulo		:= {}				//Array com os titulos a receber do cliente
Default oTit		:= Nil		    	//Objeto do ListBox

cTitulo  := aTitulo[oTit:nAt][2]+aTitulo[oTit:nAt][3]
cParcela := aTitulo[oTit:nAt][4]

//Estrutura do array aTitulo:
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ2-  Prefixo     ณ
//ณ3-  NumTitulo   ณ
//ณ4-  Parcela     ณ
//ณ5-  Vencimento  ณ
//ณ6-  Valor       ณ
//ณ7-  VlrMulta    ณ
//ณ8-  VlrJuros    ณ
//ณ9-  VlrDesconto ณ
//ณ10- VlrRecebido ณ
//ณ11- Tipo        ณ
//ณ12- Contrato    ณ
//ณ13- Cliente     ณ
//ณ14- Loja        ณ
//ณ15- FilTit      ณ
//ณ16- NumRecno    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

For nX := 1 To Len( aTitulo )
	If cTitulo == aTitulo[nX][2] + aTitulo[nX][3]
		If aTitulo[nX][4] < cParcela
			If !aTitulo[nX][1]
				lRet := .F.
			EndIf
		ElseIf aTitulo[nX][4] > cParcela .And. lRet
			If aTitulo[nX][1]
				lRet := .F.
			EndIf
		EndIf
	EndIF
Next nX

lNaoAcresc 	:= aTitulo[oTit:nAt][18]

If lRet
	If lNaoAcresc
		cContrato	:= aTitulo[oTit:nAt][12]	
		If !Empty(cContrato)
			If !aTitulo[oTit:nAt][1]
				//"Deseja quitar todos os titulos do contrato: "+"Atencao"
				If MsgNoYes(STR0073 + cContrato + "?" , STR0003)		
					aEval( aTitulo, {|x| IIf( x[12] == cContrato, x[1] := .T.,"") } )
				Else
					aTitulo[oTit:nAt][1] := .T.	    				
				EndIf
		    Else
				aTitulo[oTit:nAt][1] := .F.	    	
			EndIf	    
		EndIf
	Else
		If !aTitulo[oTit:nAt][1]
			aTitulo[oTit:nAt][1] := .T.	    				
		Else
			aTitulo[oTit:nAt][1] := .F.	    					
		EndIf
	EndIf
Else
	aTitulo[oTit:nAt][1] := .F.
EndIf


Return(aTitulo)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJXEstVfe   บAutorณVendas Clientes     บ Data ณ  25/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona estoque por Produto,Filial,Local e retorna array  บฑฑ 
ฑฑบ          ณpara ser usado na apresentacao da tela					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpA1 := LJXPosEst( ExpA1, ExpN1, ExpC2 ) 		          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da Filial a consultar estoque                บฑฑ
ฑฑบ          ณExpC2 - Codigo do Produto a consultar estoque    	  		  บฑฑ
ฑฑบ          ณExpC3 - Codigo do Local a consultar estoque                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Array com informacoes do estoque do produto		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function LJXEstVfe(cFil, cProduto, cLocalProd)

//#VFE
Local aProdEst	:= {}	// Array de retorno da funcao com informacoes do estoque do produto
Local lContinua 	:= .T. // Retorno
                                            
DEFAULT cFil	 		:= "" 	// Codigo da Filial
DEFAULT cProduto		:= "" 	// Codigo do Produto
DEFAULT cLocalProd	:= "" 	// Codigo do Local

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz posicionamento do estoque do produtoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("SB2")
DbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL  
If !DbSeek(cFil + cProduto + cLocalProd)
	lContinua	:= .F.	
EndIf

DbSelectArea("SB9")
DbSetOrder(1)//B9_FILIAL+B9_COD+B9_LOCAL
If !DbSeek(cFil + cProduto + cLocalProd)
	lContinua	:= .F.	
EndIf

If lContinua
	Aadd(aProdEst, {SB1->B1_FILIAL	,;	//01 - Filial
					SB1->B1_COD		,;	//02 - Codigo do produto
					cLocalProd  	,;	//03 - Local do produto				 
					SB1->B1_UM		,;	//04 - Unidade de medida do Produto				 
					SB1->B1_GRUPO	,;	//05 - Grupo do produto
					SB1->B1_DESC	,;	//06 - Descricao do produto 
					SB9->B9_QINI	,;	//07 - Quantidade inicial do produto				
					SaldoSb2()		,;	//08 - Saldo atual do produto 
					SB0->B0_PRV1	,;	//09 - Preco 1 
					SB0->B0_PRV2	,;	//10 - Preco 2 
					SB0->B0_PRV3	,;	//11 - Preco 3 
					SB0->B0_PRV4	,;	//12 - Preco 4 
					SB0->B0_PRV5	,;	//13 - Preco 5 
					SB0->B0_PRV6	,;	//14 - Preco 6 
					SB0->B0_PRV7	,;	//15 - Preco 7 
					SB0->B0_PRV8	,;	//16 - Preco 8 
					SB0->B0_PRV9	})	//17 - Preco 9  
Else
	Aadd(aProdEst,{.F.})						
Endif

Return (aProdEst)

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSubtHora
Calcula o Numero de Horas entre dois tempos

@param  dDataIni    Data Inicial 
@param  cHoraIni    Horario Inicial
@param  dDataFim    Data Final
@param  cHoraFim    Horario Final
@param  lHrCont     Horario continuo
@author Varejo
@version P12
@since 23/02/2017
@return nHoras    Direfenca de horas entre datas
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function LjSubtHora(dDataIni, cHoraIni, dDataFim, cHoraFim, lHrCont)

Local nDias  := dDataFim - dDataIni
Local nHoras := LjHoraToInt(cHoraFim) - LjHoraToInt(cHoraIni)

//Horario Continuo. Ex. 10/10/2010 08:00 at้ 11/10/2010 17:00 como 32 horas. Quando .F. Considera apenas 8 hs dia 10 + 8hs dia 11 = 16hs
Default lHrCont := .T. //Considera horario continuo. 

If nDias > 0 .AND. lHrCont == .F.
    nHoras  := nHoras + (nHoras * nDias) 
Else
    nHoras := nHoras + (nDias * 24) 
EndIf

Return nHoras

//-------------------------------------------------------------------
/*/{Protheus.doc} LjHoraToInt
Soma dois Horarios

@param  cHora       Horario 
@param  nDigitos    Digitos
@author Varejo
@version P12
@since 23/02/2017
@return nRetorno  Soma das horas
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function LjHoraToInt(cHora, nDigitos)

Local nHoras    := 0
Local nMinutos  := 0                          
Local nExtDigit := 0
Local nRetorno  := 0 

nExtDigit := If(ValType(nDigitos) == "N", nDigitos - 2, 0) 
                    
nHoras   := Val(SubStr(cHora, 1, 2 + nExtDigit))
nMinutos := Val(SubStr(cHora, 4 + nExtDigit, 2)) / 60
nRetorno := nHoras+nMinutos

Return nRetorno

//--------------------------------------------------------
/*/{Protheus.doc} LjRateioHtl()
Efetua o rateio dos titulos a receber para hotelaria                       
@param aRegSE1		Array contendo Recnos dos titulos a receber

@author  alessandrosantos
@version P12.17
@since   08/09/2016
@return  Nil                                                                  
/*/
//--------------------------------------------------------

Function LjRateioHtl(aRegSE1)

Local aArea 	 	:= GetArea() //Salva areas
Local aAreaSE1 	:= SE1->(GetArea()) //Salva area SE1
Local aAreaMH3 	:= MH3->(GetArea()) //Salva area MH3
Local lMultiNat 	:= SuperGetMV("MV_MULNATR",, .F.) // Funcionalidade de MultiNatureza
Local nI 		  	:= 0 //Contador
Local nX			:= 0 //Contador
Local nTotRat		:= 0 //Somatorio Rateio
Local nValCC		:= 0 //Valor rateio por centro de custo
Local nValTit		:= 0 //Valor do titulo para o centro de custo
Local aNatRateio 	:= {} //Array natureza para rateio 
Local aCCRateio 	:= {} //Array centro de custo para rateio

Default aRegSE1 := {}

If lMultiNat //MultiNaturezas habilitado
	MH3->(dbSetOrder(1)) //MH3_FILIAL+MH3_SERRPS+MH3_DOCRPS
			
	For nI := 1 To Len(aRegSE1)
		If MH3->(dbSeek(xFilial("MH3") + SL1->L1_SERRPS + SL1->L1_DOCRPS))
			If !Empty(MH3->MH3_RATEIO)
				SE1->(dbGoTo(aRegSE1[nI]))
				
				//Altera Flag de multinatureza do titulo
				SE1->(RecLock("SE1", .F.))
				SE1->E1_MULTNAT = "1"
				SE1->(MsUnLock())
				
				//Gera array natureza
				aNatRateio := StrToArray(AllTrim(MH3->MH3_RATEIO), "#")																				 								
				
				//Grava rateio da natureza - SEV
				SEV->(Reclock("SEV", .T.))													
				SEV->EV_FILIAL 	:= xFilial("SEV")			
				SEV->EV_PREFIXO 	:= SE1->E1_PREFIXO			
				SEV->EV_NUM 		:= SE1->E1_NUM			
				SEV->EV_PARCELA 	:= SE1->E1_PARCELA			
				SEV->EV_CLIFOR 	:= SE1->E1_CLIENTE			
				SEV->EV_LOJA 		:= SE1->E1_LOJA			
				SEV->EV_TIPO 		:= SE1->E1_TIPO			
				SEV->EV_NATUREZ 	:= SE1->E1_NATUREZ			
				SEV->EV_VALOR 	:= SE1->E1_VALOR			
				SEV->EV_PERC 		:= 1	
				SEV->EV_IDENT		:= "1"
				SEV->EV_RECPAG	:= "R"	
				SEV->EV_RATEICC	:= "1"												
				SEV->(MsUnlock())								
												
				//Gera array centro de custo					
				aCCRateio 	:= {}
				nTotRat	:= 0
																
				For nX := 1 To Len(aNatRateio)
					aAdd(aCCRateio, StrToArray(AllTrim(aNatRateio[nX]), "*"))																																																																	
				Next nX
				
				//Grava rateio da centro de custo - SEZ
				For nX := 1 To Len(aCCRateio)
					SEZ->(Reclock("SEZ", .T.))								
					SEZ->EZ_FILIAL 	:= xFilial("SEZ")				
					SEZ->EZ_PREFIXO 	:= SE1->E1_PREFIXO				
					SEZ->EZ_NUM 		:= SE1->E1_NUM				
					SEZ->EZ_PARCELA 	:= SE1->E1_PARCELA				
					SEZ->EZ_CLIFOR 	:= SE1->E1_CLIENTE				
					SEZ->EZ_LOJA 		:= SE1->E1_LOJA				
					SEZ->EZ_TIPO 		:= SE1->E1_TIPO				
					SEZ->EZ_CCUSTO 	:= aCCRateio[nX][1]														
					SEZ->EZ_IDENT 	:= "1" 				
					SEZ->EZ_PERC 		:= Val(aCCRateio[nX][3]) / 100
					
					//Valor centro de custo														 
					nValTit := IIF(SE1->E1_TIPO $ "CC|CD", SE1->E1_VLRREAL, SE1->E1_VALOR)
					nValCC := Round(nValTit / 100 * Val(aCCRateio[nX][3]), TamSx3("E1_VALOR")[2])
					nTotRat += nValCC
					
					//Verifica se necessita de arredondamento para o ultimo registro
					If nX == Len(aCCRateio)
						If nTotRat > nValTit .And. nTotRat - nValTit < 0.05 //valor de rateio maior que o valor do titulo com tolerancia de 4 centavos
							nValCC -= nTotRat - nValTit //Diminui valor para corrigir arredondamento											
						ElseIf nValTit > nTotRat .And. nValTit - nTotRat < 0.05 //valor do titulo maior que valor do rateio com tolerancia de 4 centavos
							nValCC += nValTit - nTotRat //Aumenta valor para corrigir arredondamento
						EndIf
					EndIf
					
					SEZ->EZ_VALOR 	:= nValCC																									
					SEZ->EZ_NATUREZ 	:= SE1->E1_NATUREZ											
					SEZ->EZ_EC05DB 	:= aCCRateio[nX][2]
					SEZ->EZ_RECPAG	:= "R"
					SEZ->(MsUnlock())																																
				Next nX												 	
			EndIf	
		EndIf
	Next nI
EndIf	

//Restaura areas	
RestArea(aAreaSE1) 
RestArea(aAreaMH3) 
RestArea(aArea) 
	
Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} LjTrocoHtl()
Efetua a baixa dos adiantamentos da reserva quando existe troco                       
@param aRecRa		Array contendo Recnos dos RAs

@author  alessandrosantos
@version P12.17
@since   13/09/2016
@return  Nil                                                                  
/*/
//--------------------------------------------------------

Function LjTrocoHtl(aRecRa)

Local aArea  	  	:= GetArea()
Local aAreaSE1  	:= SE1->(GetArea())
Local nTrocoHtl 	:= SL1->L1_TROCO1 //Valor de troco hotel
Local cWhere		:= "" //Condicional da query
Local cAliasTmp 	:= GetNextAlias() //Alias Temporario
Local nI			:= 0 //Contador
Local nX			:= 0 //Contador
Local nVlrBaixa	:= 0 //Valor da baixa
Local aBaixa		:= {} //Array com informacoes do titulo a baixar
Local aRecSe1		:= aClone(aRecRa) //Copia dos Recnos de RAs
Local aCxFin		:= StrToArray(AllTrim(GetMv("MV_CXFIN")), "/") //Banco/Agencia/Conta
Local dDataBkp  	:= dDataBase //Backup da data atual
Local lRetTroco	:= .T.
Local cErroTroco	:= ""
Local aErroAuto	:= {} //Logs de erro do ExecAuto

Private lMsHelpAuto 		:= .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto 		:= .F. //Variavel que informa a ocorr๊ncia de erros no ExecAuto
Private lAutoErrNoFile 	:= .T. //for็a a grava็ใo das informa็๕es de erro em array para manipula็ใo da grava็ใo ao inv้s de gravar direto no arquivo temporแrio

Default aRecRa := {}

FCadMotBx("TRO", Padr("TROCO", 10), "ASNN") //Inclusao motivo de baixa

//Condicional da query
cWhere := "% "
cWhere += " E1_FILIAL = " + "'" + xFilial("SE1") + "'"
cWhere += " AND E1_CONHTL = " + "'" + SL1->L1_RESEHTL + "'"
cWhere += " AND E1_TIPO IN ('RA','NCC')"	
cWhere += " AND E1_SALDO > 0"	
cWhere += " AND SE1.D_E_L_E_T_ = ''"
cWhere += " %"

//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		R_E_C_N_O_, E1_EMISSAO	
	FROM %table:SE1% SE1							
		WHERE %exp:cWhere%		   			
EndSql	
		
//Posiciona no inicio do arquivo temporario
(cAliasTmp)->(dbGoTop())			

//Busca titulos RAs da reserva
While (cAliasTmp)->(!EOF())				
	If aScan(aRecSe1, {|x| x[2] == (cAliasTmp)->R_E_C_N_O_}) < 1 //Verifica se recno de RA ja esta na array
		aAdd(aRecSe1, {0, (cAliasTmp)->R_E_C_N_O_, SToD((cAliasTmp)->E1_EMISSAO)}) //Adiciona Ra no array para possivel baixa
	EndIf
			
	(cAliasTmp)->(dbSkip())
EndDo
	
//Fecha arquivo temporario			
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

//Verifica se existem saldos nos RAs para abater troco
For nI := 1 To Len(aRecSe1)					
	//Se nao houver mais saldo em troco, abandona laco pois necessidade foi atendida
	If nTrocoHtl <= 0
		Exit
	EndIf
	
	If lRetTroco			 
		dDataBase := aRecSe1[nI][3] //Altera data base para compensacao	
		SE1->(dbGoTo(aRecSe1[nI][2])) //Posiciona no RA
		
		//Se Ra possui saldo, efetua a baixa do troco
		If SE1->E1_SALDO > 0							
			//Valor da baixa
			If nTrocoHtl >= SE1->E1_SALDO  
				nVlrBaixa := SE1->E1_SALDO
				nTrocoHtl -= SE1->E1_SALDO //Diminui valor do troco
			Else
				nVlrBaixa := nTrocoHtl
				nTrocoHtl := 0 //Zera troco
			EndIf
									
			//Alimenta array da baixa
			aBaixa := {}		
			aAdd(aBaixa, {"E1_PREFIXO"	, SE1->E1_PREFIXO 									, Nil})	
			aAdd(aBaixa, {"E1_NUM"		, SE1->E1_NUM											, Nil})	
			aAdd(aBaixa, {"E1_PARCELA" 	, SE1->E1_PARCELA										, Nil})	
			aAdd(aBaixa, {"E1_TIPO"    	, SE1->E1_TIPO										, Nil})	
			aAdd(aBaixa, {"AUTMOTBX"  	, "TRO"												, Nil})	
			aAdd(aBaixa, {"AUTDTBAIXA"	, aRecSe1[nI][3]										, Nil})	
			aAdd(aBaixa, {"AUTDTCREDITO", aRecSe1[nI][3]										, Nil})	
			aAdd(aBaixa, {"AUTHIST"   	, "TROCO" + AllTrim(SE1->E1_CONHTL)				, Nil})	
			aAdd(aBaixa, {"AUTBANCO"  	, IIF(ValType(aCxFin[1]) == "C", Padr(aCxFin[1]  , TamSx3("E1_PORTADO")[1]), ""), Nil})	
			aAdd(aBaixa, {"AUTAGENCIA"  , IIF(ValType(aCxFin[2]) == "C", Padr(aCxFin[2]  , TamSx3("E1_AGEDEP")[1]) , ""), Nil})	
			aAdd(aBaixa, {"AUTCONTA"  	, IIF(ValType(aCxFin[3]) == "C", Padr(aCxFin[3]  , TamSx3("E1_CONTA")[1])  , ""), Nil})	
			aAdd(aBaixa, {"AUTVALREC"	, nVlrBaixa      										, Nil})	
									
			//Efetua baixa do Ra
			lMsErroAuto := .F.				
			MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se houveram erros durante a execucao da rotina automatica.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lMsErroAuto
				lRetTroco  := .F.
				cErroTroco := ""
				aErroAuto  := GetAutoGrLog()			
			  	
			  	For nX := 1 To Len(aErroAuto)
			  		cErroTroco += aErroAuto[nX] + "|"
			  	Next nX
			  	LjGravaLog(.F., SL1->L1_NUM, "Erro ExecAuto Fina070: " + cErroTroco)	
			EndIf
		EndIf					
	EndIf
Next nI

//Restaura data base
dDataBase := dDataBkp	

//Restaura a entrada da rotina                                    
RestArea(aAreaSE1)
RestArea(aArea)

Return lRetTroco

//--------------------------------------------------------
/*/{Protheus.doc} FCadMotBx()
Efetua a insercao de motivos de baixa no arquivo SIGAADV.MOT                       
@param cMot		Motivo da baixa
@param cNomMot		Descricao do motivo da baixa
@param cConfMot	Configuracoes do motivo da baixa

@author  alessandrosantos
@version P12.17
@since   14/09/2016
@return  Nil                                                                  
/*/
//--------------------------------------------------------

Static Function FCadMotBx(cMot,cNomMot, cConfMot)

Local aMotbx := ReadMotBx()
Local nHdlMot, nI, cFile := "SIGAADV.MOT"
Local lNovoByte	:= .F.
Local nStep := 19

Default cMot 		:= ""
Default cNomMot 	:= ""
Default cConfMot 	:= ""

If ExistFunc("LjMotBxS")
	lNovoByte := LjMotBxS()
EndIf
	
If ExistBlock("FILEMOT")
	cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
Endif
	
If Ascan(aMotbx, {|x| Substr(x,1,3) == Upper(cMot)}) < 1
	nHdlMot := FOPEN(cFile,FO_READWRITE)
	If nHdlMot <0
		HELP(" ",1,"SIGAADV.MOT")
		Final("SIGAADV.MOT")
	EndIf
	
	If lNovoByte
		nStep := 20
		//Ajusta se oo conte๚do virer com at้ 4 bytes
		cConfMot := cConfMot +  IIF(Len(cConfMot) = 4, "N", "")
	EndIf
	
	nTamArq:=FSEEK(nHdlMot,0,2)	// VerIfica tamanho do arquivo
	FSEEK(nHdlMot,0,0)			// Volta para inicio do arquivo

	For nI := 0 to  nTamArq step nStep // Processo para ir para o final do arquivo	
		xBuffer:=Space(nStep)
		FREAD(nHdlMot,@xBuffer,nStep)
    Next		
	
	fWrite(nHdlMot,PadR(cMot+cNomMot+cConfMot,nStep-2)+chr(13)+chr(10))	
	fClose(nHdlMot)		
EndIf	

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj140ExRAComp()
Rotina para Excluir a campensacao de RAs Hotelaria.                       

@author  alessandrosantos
@version P12.17
@since   14/09/2016                                                                 
/*/
//--------------------------------------------------------

Function Lj140ExRAComp()

Local aArea 	 		:= GetArea()
Local cWhere 	 		:= "" //Condicional da query
Local cAliasTmp 		:= GetNextAlias()
Local aEstorno 	 	:= {} //Array temporario de RAs para estorno
Local aEstornoTmp 	:= {} //Array temporario de RAs para estorno
Local aRecSE1	 		:= {SE1->(Recno())} //Recno do titulo a receber

//Condicional para a query		
cWhere := "%"
cWhere += " E5_FILIAL = '" + xFilial("SE5") + "'"
cWhere += " AND E5_PREFIXO = '" + SE1->E1_PREFIXO + "'"
cWhere += " AND E5_NUMERO = '" + SE1->E1_NUM + "'"
cWhere += " AND E5_PARCELA = '" + SE1->E1_PARCELA + "'"
cWhere += " AND E5_TIPO = '" + SE1->E1_TIPO + "'"
cWhere += " AND E5_CLIFOR = '" + SE1->E1_CLIENTE + "'"
cWhere += " AND E5_LOJA = '" + SE1->E1_LOJA + "'"
cWhere += " AND E5_DOCUMEN <> ''"
cWhere += " AND SE5.D_E_L_E_T_ = ''"   		   			
cWhere += "%"              											
			                                          
//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		E5_DOCUMEN		 
	FROM %table:SE5% SE5		 							
	WHERE %exp:cWhere% 			
EndSql

//Posiciona no inicio do arquivo
(cAliasTmp)->(dbGoTop())	

//Armazena RAs		
While (cAliasTmp)->(!Eof())
	aAdd(aEstornoTmp, (cAliasTmp)->E5_DOCUMEN)
										
	(cAliasTmp)->(dbSkip())
EndDo

If Len(aEstornoTmp) > 0
	aAdd(aEstorno, aEstornoTmp)
	
	//Atualiza saldo do cliente
	SE1->(dbGoTo(aRecSE1[1])) 
	AtuSaldup("-", SE1->E1_VALOR, SE1->E1_MOEDA, SE1->E1_TIPO,, SE1->E1_EMISSAO)
	
	//Estorna compensacao de RAs
	MaIntBxCR(3, aRecSE1,,,, {.T., .F., .F., .F., .F., .F.},, aEstorno)		
EndIf

//Fecha Arquivos temporarios
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

//Restaura areas
RestArea(aArea)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj140CancRat()
Rotina para Excluir rateios de hotelaria.                       

@author  alessandrosantos
@version P12.17
@since   14/09/2016                                                                 
/*/
//--------------------------------------------------------

Function Lj140CancRat()

//Deleta SEV
SEV->(dbSetOrder(1)) //EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ 

If SEV->(dbSeek(xFilial("SEV") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)) 
	While SEV->(!EOF()) .And. SEV->EV_FILIAL == xFilial("SEV") .And. SEV->EV_PREFIXO == SE1->E1_PREFIXO .And.; 
		SEV->EV_NUM == SE1->E1_NUM .And. SEV->EV_PARCELA == SE1->E1_PARCELA .And. SEV->EV_TIPO == SE1->E1_TIPO .And.; 
		SEV->EV_CLIFOR == SE1->E1_CLIENTE .And. SEV->EV_LOJA == SE1->E1_LOJA
				
		SEV->(RecLock("SEV", .F.))
		SEV->(dbDelete())
		SEV->(MsUnlock())				
		
		SEV->(dbSkip())
	EndDo
EndIf

//Deleta SEZ
SEZ->(dbSetOrder(1)) //EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_CCUSTO

If SEZ->(dbSeek(xFilial("SEZ") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)) 
	While SEZ->(!EOF()) .And. SEZ->EZ_FILIAL == xFilial("SEZ") .And. SEZ->EZ_PREFIXO == SE1->E1_PREFIXO .And.; 
		SEZ->EZ_NUM == SE1->E1_NUM .And. SEZ->EZ_PARCELA == SE1->E1_PARCELA .And. SEZ->EZ_TIPO == SE1->E1_TIPO .And.; 
		SEZ->EZ_CLIFOR == SE1->E1_CLIENTE .And. SEZ->EZ_LOJA == SE1->E1_LOJA
				
		SEZ->(RecLock("SEZ", .F.))
		SEZ->(dbDelete())
		SEZ->(MsUnlock())				
		
		SEZ->(dbSkip())
	EndDo
EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj140ExcTro()
Rotina para Excluir baixas efetuadas por troco - hotelaria                       

@author  alessandrosantos
@version P12.17
@since   14/09/2016                                                                 
/*/
//--------------------------------------------------------

Function Lj140ExcTro()

Local aArea 	 	:= GetArea() //Salva areas
Local aAreaSE1	:= SE1->(GetArea()) //Salva area SE1
Local cWhere 	 	:= "" //Condicional da query
Local cAliasTmp 	:= GetNextAlias() //Alias temporario
Local aTitulo		:= {} //Array com informacos do titulo a ter a baixa estornada

//Condicional para a query		
cWhere := "% "
cWhere += " E1_FILIAL = '" + xFilial("SE1") + "'" 
cWhere += " AND E1_CONHTL = '" + SL1->L1_RESEHTL + "'"
cWhere += " AND SE1.D_E_L_E_T_ = ''"
cWhere += " AND E5_RECPAG = 'P'"
cWhere += " AND E5_MOTBX = 'TRO'"
cWhere += " AND E5_HISTOR = 'TROCO'"
cWhere += " AND SE5.D_E_L_E_T_ = ''"  		   			
cWhere += " %"              											
	                                          
//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO 		 
	FROM %table:SE5% SE5	
	INNER JOIN %table:SE1% SE1	
	ON E5_FILIAL = E1_FILIAL
		AND E5_PREFIXO = E1_PREFIXO
		AND E5_NUMERO = E1_NUM
		AND E5_PARCELA = E1_PARCELA
		AND E5_TIPO = E1_TIPO
		AND E5_CLIFOR = E1_CLIENTE
		AND E5_LOJA = E1_LOJA  							
	WHERE %exp:cWhere% 			
EndSql

//Posiciona no inicio do arquivo
(cAliasTmp)->(dbGoTop())	

//Armazena RAs		
While (cAliasTmp)->(!Eof())
	SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
	
	//Posiciona no titulo para desfazer baixa
	If SE1->(dbSeek(xFilial("SE1") + (cAliasTmp)->E5_PREFIXO + (cAliasTmp)->E5_NUMERO + (cAliasTmp)->E5_PARCELA + (cAliasTmp)->E5_TIPO))
		aTitulo := {}
		aAdd(aTitulo, {"E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil})
		aAdd(aTitulo, {"E1_NUM"		, SE1->E1_NUM		, Nil})
		aAdd(aTitulo, {"E1_PARCELA"	, SE1->E1_PARCELA	, Nil})
		aAdd(aTitulo, {"E1_TIPO"  	, SE1->E1_TIPO	, Nil})
		aAdd(aTitulo, {"E1_CLIENTE"	, SE1->E1_CLIENTE	, Nil})
		aAdd(aTitulo, {"E1_LOJA"  	, SE1->E1_LOJA	, Nil})
		
		//Efetua a exclusao da baixa												
		MSExecAuto({|x,y| FINA070(x,y)}, aTitulo, 6)
	EndIf
											
	(cAliasTmp)->(dbSkip())
EndDo

//Fecha Arquivos temporarios
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

//Restaura areas
RestArea(aAreaSE1)
RestArea(aArea)

Return Nil

//----------------------------------------------------------------
/*/{Protheus.doc} Lj140DelSLX
Fun็ใo responsavel em deletar os cancelamentos anteriores quando  
uma venda esta sendo reinserida atraves de Mensagem Unica para nao
haver duplicidade de registros.                              

@param	 cMarca - Marca da integracao
@author  Varejo
@version P12
@since   10/02/2017
/*/
//----------------------------------------------------------------

Function Lj140DelSLX(cMarca)

Local cCancInt := ""

Default cMarca := ""

SLX->(dbSetOrder(1)) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA

//Se encontrou cancelamentos deleta pois havera nova insercao da venda
If SLX->(dbSeek(xFilial("SLX") + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE))
	While SLX->(!EOF()) .And. SLX->LX_FILIAL == xFilial("SLX") .And. SLX->LX_PDV == SL1->L1_PDV .And.;
		SLX->LX_CUPOM == SL1->L1_DOC .And. SLX->LX_SERIE == SL1->L1_SERIE
		
		RecLock("SLX", .F.)
		SLX->(dbDelete())
		SLX->(MsUnLock())
		
		SLX->(dbSkip())
	EndDo
	
	//Remove cancelamento de venda do De/Para - XXF
	cCancInt := IntCancExt(/*Empresa*/, /*Filial*/, SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_PDV, /*Versao*/)[2] //InternalId do cancelamento	
			
	CFGA070Mnt(cMarca, "SLX", "LX_CUPOM",, cCancInt, .T.)
EndIf

Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} LjxAtuchv
Fun็ใo atualiza a chave das tabelas dos libros ficais caso  o 
numero esteja inferior a 44.

@type function
@param dDataMov  - Data de gera็ใo do documento
@param cDoc		 - Numero do documento
@param cSerie	 - Serie do documento
@param cChvNFce  - Chave gravada na Tabela SFT
@param lAtuLivro - Atualiza as tabelas de livro fiscal  
@author  Rene Julian
@version P11.8
@since  30/08/2018
@return cRet - Retorno da chave do xml de cancelamento
/*/
//-------------------------------------------------	
Function LjxAtuchv(dDataMov , cDoc ,cSerie , cChvNFe , lAtuLivro ) 
Local cRet		:= ""		// Variavel de retorno da chave
Local aRetTSS	:= {}		// Array para Retorno do xml do TSS
Local cXMLProt	:= ""		// Variavel de cancelamento para o xml
Local aAreaSF3  := {}       //  Area da tabela SF3
Local aAreaSFT  := {}       // Area da tabela SFT

Default dDataMov  := CtoD("  /  /    ") 
Default cDoc   	  := ""
Default cSerie    := ""
Default cChvNFe   := ""
Default lAtuLivro := .F.

LJGrvLog(cDoc, "INICIO DA FUNวรO LjxAtuchv") 

If Len(AllTrim(cChvNFe)) < 44
	//Busca dados da nota fiscal a ser cancelada no TSS
	aRetTSS := LjRetNFCe(dDataMov , dDataMov , cSerie , cSerie , cDoc , cDoc )
	LJGrvLog(cDoc, "cChvNFe menor que 44 - cChvNFe: " , cChvNFe  )
	If Len(aRetTSS) > 0 .AND. aRetTSS[1]:OWSNFECANCELADA <> Nil
	
		cXMLProt:= aRetTSS[1]:oWSNFECANCELADA:cXMLProt
		
		If !Empty(cXMLProt)
			cChvNFe := LjxBChvTss(cXMLProt , cChvNFe , cDoc , cSerie )
			cRet := cChvNFe
			LJGrvLog(cDoc, "gerou a chave - cChvNFe: " , cChvNFe  )
		Else
			LJGrvLog(cDoc, "Xml de cancelamento Vazio cChvNFe: " , cChvNFe  )
		EndIf	
	EndIf
EndIf	

If lAtuLivro .and.  Len(AllTrim(cRet)) == 44 
	
	LJGrvLog(cDoc, "Vai Atualizar as tabelas dos livros fiscais"   )
	
	aAreaSF3 := SF3->( GetArea() )
	SF3->( DbSetOrder(5) )	//F3_FILIAL + F3_SERIE + F3_NFISCAL + F3_CLIEFOR + F3_LOJA + F3_IDENTFT
	If SF3->( DbSeek(xFilial("SF3")  + cSerie + cDoc ) )
		While SF3->( !EoF() ) .AND. ;
			xFilial("SF3") + cSerie + cDoc  == SF3->(F3_FILIAL+F3_SERIE+F3_NFISCAL)
			If RecLock("SF3", .F.)
				Replace SF3->F3_CHVNFE with cRet	// protocolo de autorizcao da NFC-e
				SF3->( MsUnlock() )
			Else
				LjGrvLog( "Documento: " +cDoc +  "- Serie: " + cSerie , "Falha ao alocar o registro SF3.R_E_C_N_O_: ", SF3->(Recno()) )
			EndIf
			SF3->( DbSkip() )
		End
	EndIf
	RestArea( aAreaSF3 )

	aAreaSFT := SFT->( GetArea() )
	SFT->( DbSetOrder(6) )	//FT_FILIAL + FT_TIPOMOV + FT_NFISCAL + FT_SERIE 
	If SFT->( DbSeek(xFilial("SFT") + "S" + cDoc + cSerie ) )										
		While SFT->( !EoF() ) .AND. ;
			xFilial("SFT") +  cDoc + cSerie == SFT->(FT_FILIAL+FT_NFISCAL+FT_SERIE)
			If RecLock("SFT", .F.)
				Replace SFT->FT_CHVNFE with cRet   // chave com o tamanho correto retornado pelo xml do TSS												
				SFT->( MsUnlock() )
			Else
				LjGrvLog( "Documento: " +cDoc +  "- Serie: " + cSerie , "Falha ao alocar o registro SFT.R_E_C_N_O_: ", SFT->(Recno()) )
			EndIf
			SFT->( DbSkip() )
		End
	EndIf
	RestArea( aAreaSFT )
	
Else
	LjGrvLog( "Documento: " +cDoc +  "- Serie: " + cSerie , "Problemas com o tamanho do retorno da chave ", SFT->(Recno()) )

EndIf

LJGrvLog(cDoc, "FIM DA FUNวรO LjxAtuchv") 

Return cRet
//----------------------------------------------------------
/*/{Protheus.doc} LjxBChvTss
Retorna a chave de cancelamento da nf cancelada pelo xml do TSS.
@type function
@param cXMLProt  - xml de retorno do TSS
@param cChvNFce  - Chave gravada na Tabela SFT
@param cDoc		 - Numero do documento
@param cSerie	 - Serie do documento
@author  Rene Julian
@version P11.8
@since  30/08/2018
@return cRet - retorno da chave de cancelamento
/*/
//-------------------------------------------------		
Function LjxBChvTss(cXMLProt,cChvNFce,cDoc,cSerie)
Local cRet 			:= "" // Retorno da chave da nfce 
Local oXMLAux		:= Nil
Local lRetAux		:= .F.
Local cEndXml		:= "http://www.portalfiscal.inf.br/nfe"

Default cXMLProt 	:= ""
Default cChvNFce 	:= ""

LJGrvLog(cDoc, "INICIO DA FUNวรO LjxBChvTss") 


If Empty(cChvNFce) .OR. Len(AllTrim(cChvNFce)) < 44	

	If !Empty(cXMLProt)
		//instancia um objeto da classe TXML Manager
		oXMLAux := TXMLManager():New()
		
		//executa o PARSE na string XML
		lRetAux := oXMLAux:Parse( cXMLProt )
		
		If lRetAux
			lRetAux := oXMLAux:XPathRegisterNS( "ns" , cEndXml  )
			If !lRetAux
				LJGrvLog(Nil, "ERRO AO REGISTRAR O NAMESPACE", oXMLAux:Error() )
			EndIf
		Else
			LJGrvLog(Nil, "ERRO AO EXECUTAR O METODO PARSE: ", oXMLAux:Error() )	
		EndIf	
		
		If lRetAux			
			cRet := oXMLAux:XPathGetNodeValue("/ns:retCancNFe/ns:infCanc/ns:chNFe")			
			If !Empty(cRet)
				 LjGrvLog( cDoc , "Chave recuperada do TSS Doc: "+cDoc + " Serie :"+cSerie + " Chave NFe :"+cRet )
			Else
				LjGrvLog( cDoc , "Nใo foi possivel recuperar a Chave do TSS. - Doc: "+cDoc + " Serie :"+cSerie + " Chave NFe :"+cRet ) 
			EndIf
		Else
			If !Empty( oXMLAux:Error() )
				LJGrvLog(Nil, "ERRO AO EXECUTAR O METODO PARSE: ", oXMLAux:Error() )
			ElseIf !Empty( oXMLAux:Warning() )
				LJGrvLog(Nil, "ADVERTENCIA AO EXECUTAR O METODO PARSE: ", oXMLAux:Warning() )
			EndIf
		EndIf	
	Else
		LJGrvLog(cDoc, "xml vazio cXMLProt nao foi possivel obter chave NFC-e." ) 	
	EndIf

Else 
   LjGrvLog( cDoc , "Documeto jแ possui Chave gravada Doc: "+cDoc + " Serie :"+cSerie + " Chave NFe :"+cChvNFce ) 
EndIf   

If oXMLAux <> Nil
	FreeObj(oXMLAux)
	oXMLAux := Nil
EndIf

LJGrvLog(cDoc, "Fim DA FUNวรO LjxBChvTss") 

Return cRet
