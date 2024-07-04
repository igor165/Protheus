#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXFUNJ.CH"

#DEFINE CLR_HRED		255

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³LJEAICOMPANY³ Autor ³ Alan Oliveira ³ Data ³26/11/10  		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para identificar se deve gerar xml do contas a Rece-³±±
±±³          ³ ber. No processo de integracao Live Bematech x Protheus    ³±±
±±³          ³ apenas os títulos de um cliente (codigo Branch) no cadastro ±±
±±³          ³ De/Para empresas XXD quando incluidos na Matriz devem gerar ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ljeaicompany(SE1->E1_CLIENTE)                      		  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCliente - Código do cliente na geracao do contas a receber³±±
±±³          ³ 															  		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpL1 = .T.             									  		³±±
±±³          ³                                     						  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Integracao EAI - Live Bematech x Protheus			  			³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjEaiCompany(cCliente)

Local aCompany := SuperGetMv("MV_EAICOMP",,"")//Paramentro da Integracao EAI que deve ser preenchido para identificar a Matriz.
Local lRet     := .T.

If !Empty(aCompany)
	aCompany := StrTokArr(aCompany, "|")
	/*
	Referência
	Company
	Branch
	Empresa
	Filial
	*/

	If Len(aCompany) == 5
		   //APENAS TITULOS DE UMA BRANCH INCLUÍDO NA MATRIZ DEVEM GERAR XML
		If !Len(FWEAIEMPFIL(Padr(aCompany[2],12), Padr(cCliente,12),  PADR("BEMATECH",15))) > 0 .AND. aCompany[5] == Alltrim(cFilant) .OR.;
		   !aCompany[5] == Alltrim(cFilant)
			lRet 	 := .F.
		Endif
	Else
		lRet 	 := .F.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxjCsCoPr
Condição da CiaShop que pode ser inserida no adapter do envio de Produto.

@since   09/10/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjxjCsCoPr()

	Local lRetorno := .F.

	If INCLUI .Or. ALTERA
		lRetorno := !Empty( GetAdvFVal("ACV", "ACV_CATEGO", xFilial("ACV") + SB1->B1_COD, 5, "", .T.) )	.And.;
			   		!Empty( GetAdvFVal("SB5", "B5_ECFLAG" , xFilial("SB5") + SB1->B1_COD, 1, "", .T.) )
	Else
		lRetorno := .T.
	EndIf

Return lRetorno

//--------------------------------------------------------
/*/{Protheus.doc} LjxjPedBlq
Valida se deve gerar a credito bloqueado ou liberado para pedidos do varejo
@type function
@author  	rafael.pessoa
@since   	21/01/2019
@version 	P12
@param 		cOrcRes  , Caracter, Numero do orcamento da reserva
@param 		cBlCred  , Caracter, código do bloqueio passar por referencia
@param 		lCredito , Lógico  , Determina se o credito deve ser bloqueado, passar por referencia
@return	lRet - Retorna se o pedido deve ser bloqueado
/*/
//--------------------------------------------------------
Function LjxjPedBlq(cOrcRes, cBlCred, lCredito)

    Local aArea      := GetArea()
    Local aAreaSL1   := SL1->( GetArea() )
    Local aAreaSL4   := SL4->( GetArea() )
    Local aAreaSC5   := SC5->( GetArea() )
    Local aAreaSC6   := SC6->( GetArea() )
    Local cFormPgLib := ""
    Local lExistBlq  := .F.                                                              //Controla se existe forma com bloqueio
    Local lRet		 := .F.
    Local lECommerce := SuperGetMV("MV_LJECOMM", , .F.)
    Local lECCia 	 := SuperGetMV("MV_LJECOMO", , .F.) .And. Val(SC5->C5_PEDECOM) > 0   //Integração EC CiaShop
    Local lGeraSE1 	 := SuperGetMV("MV_LJECOMS", , .F.)                                  //Gera Contas a Receber
    Local lLj901AGAE := ExistFunc("Lj901AGAE")                                           //Função de Retorno da Administradora
    Local cOrcamto 	 := ""
    Local cStatusPed := ""

    Default cOrcRes  := ""
    Default cBlCred  := ""
    Default lCredito := .F.

    //Carrega informações do orçamento
    cOrcamto := Posicione("SL1", 1, xFilial("SL1") + cOrcRes, "L1_ORCRES")

    //E-commerce Rakuten
    //Para e-Commerce ira gravar com bloqueio de credito para Boleto(FI) e sem bloqueio para os demais.
    If lECommerce .And. !( Empty(cOrcRes) ) .And. ChkFile("MF5")

        MF5->( DbSetOrder(1) )  //MF5_FILIAL+MF5_ECALIA+MF5_ECVCHV

        If !( Empty(cOrcamto) ) .And. !( Empty(Posicione("MF5",1,xFilial("MF5")+"SL1"+xFilial("SL1")+cOrcamto,"MF5_ECPEDI")) )
            If (AllTrim(SL1->L1_FORMPG) == "FI") .And. (MF5->MF5_ECPAGO != "1")
                cBlCred  := "02"
                lCredito := .F.
            Else
                cBlCred  := "  "
                lCredito := .T.
            EndIf
        EndIf

    //E-commerce CiaShop Antiga
    ElseIf lECommerce .And. lECCia .And. lGeraSE1 .And. lLj901AGAE

        If Alltrim(Lj901AGAE()) == "FI"
            cBlCred  := "02"
            lCredito := .F.
        Else
            cBlCred  := "  "
            lCredito := .T.
        EndIf

    //Integração via Mensagem Única
    ElseIf !lECommerce .And. !lECCia .And. !Empty(cOrcamto) .And. Posicione("SL1", 1, xFilial("SL1") + cOrcamto, "L1_ORIGEM") == "N"

        //Retorna as formas de pagamentos que geram pedido de venda Liberado para a integração via MSU - Ex: FI|BOL
        cFormPgLib := LjxjIFPLI()

        //Parâmetro vazio, Bloqueia Pedidos
        If Empty(cFormPgLib)
            lExistBlq := .T.
        Else

            SL4->( DbSetOrder(1) )      //L4_FILIAL+L4_NUM+L4_ORIGEM
            If SL4->( DbSeek(xFilial("SL4") + cOrcamto) )
                While !SL4->( Eof() ) .And. SL4->L4_FILIAL == xFilial("SL4") .And. SL4->L4_NUM == cOrcamto

                    //Bloqueia o credito se não encontrar alguma forma do parametro
                    If !( AllTrim(SL4->L4_FORMA) $ cFormPgLib )
                        lExistBlq := .T.
                        Exit
                    EndIf

                    SL4->( DbSkip() )
                EndDo
            EndIf
        EndIf

        If lExistBlq
            cBlCred     := "02"     //C9_BLCRED
            cStatusPed  := "09"     //Pedido bloqueado
            lCredito    := .F.
            lRet 	    := .T.
        Else
            cBlCred     :=  "  "
            cStatusPed  := "01"     //Pedido liberado
            lCredito    := .T.
            lRet 	    := .F.
        EndIf

        //Atualiza status do Pedido
        If IsInCallStack("Lj7Pedido") .And. SC5->C5_STATUS <> cStatusPed
            RecLock("SC5", .F.)
                SC5->C5_STATUS := cStatusPed
            SC5->( MsUnLock() )
        EndIf

    EndIf

    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaSL4)
    RestArea(aAreaSL1)
    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxjSaleId
Retornar o InternalId da Venda do Varejo.
Atualiza TAG RetailSalesInternalId do adapter MATA410B - DOCUMENTTRACEABILITYORDER.
Uso MATI410B e MATI410BO.

@param cFilPed	- Filial do Pedido
@param cNumOrc	- Número do Orçamento

@retorno cRetSaleId	- Retornar o InternalId da Venda do Varejo.

@author	 Rafael Tenorio da Costa
@since 	 19/12/18
@version 1.0
/*/
//------------------------------------------------------------------
Function LjxjSaleId(cFilPed, cNumOrc)

	Local aRetSale 	 := {}
	Local cRetSaleId := ""

	//Venda Varejo que originou Pedido de Venda
	If !Empty(cNumOrc)
		aRetSale := LjXjSalRet(cNumOrc, cFilPed)

		If Len(aRetSale) > 0
			cRetSaleId := IntVendExt( , aRetSale[1], aRetSale[2], aRetSale[3], aRetSale[4])[2]
		EndIf
	EndIf

Return cRetSaleId

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxjSaleId
Retornar o InternalId da Venda do Varejo.
Atualiza TAG RetailSalesInternalId do adapter MATA410B - DOCUMENTTRACEABILITYORDER.
Uso MATI410B e MATI410BO.

@param cFilPed	- Filial do Pedido
@param cNumOrc	- Número do Orçamento

@retorno cRetSaleId	- Retornar o InternalId da Venda do Varejo.

@author	 Rafael Tenorio da Costa
@since 	 19/12/18
@version 1.0
/*/
//------------------------------------------------------------------
Function LjxjStaPed(cStatus)

	Local cSituacao := ""

	cStatus := AllTrim(cStatus)

	Do Case
		Case cStatus == "00"
			cSituacao := STR0001    //"Gerado"

		Case cStatus == "01"
			cSituacao := STR0002    //"Pedido liberado"

		Case cStatus == "05"
			cSituacao := STR0003    //"Em análise"

		Case cStatus == "09"
			cSituacao := STR0004    //"Pedido bloqueado"

		Case cStatus == "10"
			cSituacao := STR0005    //"Pagamento confirmado"

		Case cStatus == "11"
			cSituacao := STR0006    //"Faturado"

		Case cStatus == "15"
            cSituacao := STR0007    //"Empacotado"

		Case cStatus == "21"
			cSituacao := STR0008    //"Parcialmente enviado"

		Case cStatus == "30"
			cSituacao := STR0009    //"Enviado"

		Case cStatus == "31"
			cSituacao := STR0013    //"Entregue"

		Case cStatus == "90"
			cSituacao := STR0010    //"Cancelado"

		Case cStatus == "91"
			cSituacao := STR0011    //"Devolvido"

		OTherWise
			cSituacao := STR0012 + cStatus  //"Status indefinido: "
	End Case

Return cSituacao

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuLoja
Faz atualizações necessárias pelo Loja:
	- Envia mensagem unica de Rastreio de Pedido
	- Vincula Notas Fiscais de Presente com Nota Fiscal comum.
Uso MATA461

@param    aPedido    - matriz com os pedidos a serem vinculados

@author   Eduardo Vicente
@since    27.02.2013
@version  P11.5


ANTIGA FUNÇÃO A460VNCNF NO MATA461

/*/
//-------------------------------------------------------------------
Function LjxjAtLoja(aPedido)

Local aArea	      	:= GetArea()			 //Grava a area Atual
Local aAreaSC5    	:= SC5->( GetArea() )
Local aAreaSF2    	:= SF2->( GetArea() )
Local aAreaSL1	  	:= SL1->( GetArea() )
Local nA            := 0
Local nLenAPedido   := Len(aPedido)
Local cOrcamto      := ""                    //Obtem o numero do Orcamento original para posicionar na MF5 e gravar o Status de Despachado.
Local cNFIndice	    := ""                    //Indice para posiciona a Nota Fiscal original
Local cNFVinculada  := ""                    //Indice para vincular a Nota Fiscal original
Local cNFPai	    := ""                    //Numero Nota de Vinculo da Nota Fiscal de Presente com a Nota Fiscal Original
Local cSerPai	    := ""                    //Serie Nota de Vinculo
Local lIntegraEC    := SF2->( (ColumnPos("F2_ECVINC1") > 0) .And. (ColumnPos("F2_ECVINC2") > 0) )
Local lECCia		:= SuperGetMV("MV_LJECOMO",,.F.)        //Indica se é e-commerce CiaShop
Local cFiltro		:= ""					                //Filtro da SL1
Local lGerSE1 		:= SuperGetMv("MV_LJECOMS",.T., .F.)    //Gera Título de Contas a Receber
Local cStatusPed	:= AllTrim( SuperGetMv("MV_LJECST1",.F., "30") )
Local lECommerce 	:= SuperGetMV("MV_LJECOMM",,.F.)

Default aPedido   	:= {}

DbSelectArea("SF2")
DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

DbSelectArea("SC5")
DbSetOrder(1) //C5_FILIAL+C5_PEDIDO

For nA := 1 To nLenAPedido

	//Verifica se o pedido foi gerado pelo loja
	If SC5->( DbSeek(xFilial("SC5") + aPedido[nA][01]) ) .And. ( !Empty(SC5->C5_ORCRES) .Or. !Empty(SC5->C5_PEDECOM) )

		If !lECommerce

			RecLock("SC5", .F.)
				SC5->C5_STATUS  := "11"	//Faturado
			SC5->( MsUnLock() )

			//Mensagem de rastreio de pedido
			If FwHasEai("MATA410B", .T., , .T.)
				FwIntegDef("MATA410B")
			EndIf

		Else

			cNFIndice := xFilial("SF2")+SC5->C5_NOTA+SC5->C5_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJACLI  //Indice da NF Original

			If ChkFile("MF5")

			    cOrcamto := Posicione("SL1",1,xFilial("SL1")+SC5->C5_ORCRES,"L1_ORCRES")

			    If  !( Empty(cOrcamto) ) .And. !( Empty(Posicione("MF5",1,xFilial("MF5")+"SL1"+xFilial("SL1")+cOrcamto,"MF5_ECPEDI")) )
			    	If  MF5->( SoftLock("MF5") )
			    		MF5->MF5_ECSTAT := "17"  //Grava o Status de Despachado para enviar posteriormente ao e-Commerce.
			    		MF5->MF5_ECDTEX := " "   //Limpa a data para exportacao.
			    	    MF5->( MsUnLock() )
			    	EndIf
			    EndIf
			EndIf

			//Atualiza o Status EC Ciashop como 30  - Despachado
			If lECCia .AND. Val(SC5->C5_PEDECOM) > 0

				RecLock("SC5", .F.)
					SC5->C5_STATUS  := cStatusPed
					SC5->C5_VOLTAPS := ""
				SC5->( MsUnLock() )

		        If  SF2->( DbSeek(cNFIndice) )

					cFiltro := "L1_FILIAL == '" + xFilial("SL1") + "' .And. AllTrim(L1_PEDRES) == '" + Alltrim(SC5->C5_NUM) + "'"

					SL1->(DbSetOrder(1)) // L1_FILIAL+L1_NUM
					SL1->(DbSetFilter({ || &cFiltro }, cFiltro))

					If SL1->(!Eof())

						RecLock("SL1", .F.)
							SL1->L1_DOC 	:=  SF2->F2_DOC
							SL1->L1_SERIE 	:= SF2->F2_SERIE
							SL1->L1_EMISNF 	:= SF2->F2_EMISSAO
							If Empty(SL1->L1_PDV)
								SL1->L1_PDV := "."
							EndIf
						SL1->( MsUnLock() )

					   	If  lGerSE1 .AND. !Empty(SL1->L1_DOCPED) .AND. !Empty(SL1->L1_SERPED) .AND.  Empty( SF2->F2_PREFIXO) .AND. Empty(SF2->F2_DUPL)
							RecLock("SF2", .F.)
								SF2->F2_PREFIXO := SL1->L1_SERPED
								SF2->F2_DUPL := SL1->L1_DOCPED
							SF2->( MsUnLock() )
						EndIf

					EndIf

					SL1->(DbClearFilter())
		        EndIf

		        RestArea(aAreaSL1)
				RestArea(aAreaSF2)
			EndIf

			If  lIntegraEC
				If  !( Empty(SC5->C5_ECVINCU) )
					If  SC5->( dbSeek(SC5->C5_FILIAL+Alltrim(SC5->C5_ECVINCU)) )

						cNFVinculada := xFilial("SF2")+SC5->C5_NOTA+SC5->C5_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJACLI

						If  SF2->( DbSeek(cNFIndice) )   //Posiciona a NF Origenal e Grava os dados da NF Vinculada (NF Presente)
							RecLock("SF2",.F.)
							SF2->F2_ECVINC1	:= SC5->C5_NOTA
							SF2->F2_ECVINC2	:= SC5->C5_SERIE
							SF2->(MsUnlock())

							cNFPai	  := SF2->F2_DOC
							cSerPai	  := SF2->F2_SERIE

							If  SF2->( DbSeek(cNFVinculada) )  //Posiciona na NF Vinculada e grava os dados da NF Original.
								RecLock("SF2",.F.)
								SF2->F2_ECVINC1	:= cNFPai
								SF2->F2_ECVINC2	:= cSerPai
								SF2->(MsUnlock())
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

		EndIf

	EndIf

Next nA

RestArea(aAreaSF2)
RestArea(aAreaSC5)
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxjAtStTr
Atualiza status do pedido na transmissão da NFE.
Já esta posicionado no pedido.
Uso MATI461EAI

@author	 Rafael Tenorio da Costa
@since 	 17/01/19
@version 1.0
/*/
//------------------------------------------------------------------
Function LjxjAtStTr()

    Local lERakuten := SuperGetMV("MV_LJECOMM", , .F.)     //E-commerce Rakuten
    Local lECCia    := SuperGetMV("MV_LJECOMO", , .F.)     //E-commerce CiaShop 
	Local cStatus   := ""
    
    If lERakuten .Or. lECCia
        cStatus := AllTrim( SuperGetMv("MV_LJECST1", .F., "") )
    Else
        cStatus := "15" //Empacotado
    EndIf

	If !Empty(cStatus) .And. !Empty(SC5->C5_ORCRES)
		RecLock("SC5", .F.)
			SC5->C5_STATUS := cStatus
		SC5->( MsUnLock() )
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxjIFPLI
Retorna o conteudo do parâmetro MV_LJIFPLI, macro executando caso
seja necessário.

@author	 Rafael Tenorio da Costa
@since 	 27/03/19
@version 1.0
/*/
//------------------------------------------------------------------
Function LjxjIFPLI()

	Local cFormPgLib := AllTrim( SuperGetMv("MV_LJIFPLI", .F., "") )    //Define as formas de pagamentos que geram pedido de venda Liberado para a integração via MSU - Ex: FI|BOL
    Local cRetorno   := ""

    If SubStr(cFormPgLib, 1, 1) == "&"

        cFormPgLib := SubStr(cFormPgLib, 2)

        LjGrvLog("MV_LJIFPLI", "Executando função contida no parâmetro MV_LJIFPLI.", cFormPgLib, /*lCallStack*/)

        cRetorno := &(cFormPgLib)
    Else

        cRetorno := cFormPgLib
    EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxjMsgErr
Apresenta mensagem de erro e grava os logs

@author	 Rafael Tenorio da Costa
@since 	 27/03/19
@version 1.0
/*/
//------------------------------------------------------------------
Function LjxjMsgErr(cErro, cSolucao, cRotina)

    Local cDataHora := DtoC( Date() ) + " " + Time() + " "
    Local lGravaLog := .F.
    
    Default cSolucao := ""
    Default cRotina  := ProcName(1)

    Help("", 1, "HELP", cRotina, cErro, 1,,,,,, lGravaLog, {cSolucao})

    LjGrvLog(cRotina, cErro, /*xVar*/, /*lCallStack*/)

    Conout( NoAcento( cDataHora + cRotina + " - " + cErro) )

Return Nil

//-------------------------------------------------------
/*/{Protheus.doc} LjxjAdmFin
Valida a Adm Financeira, tentando localizar através do
Array padrão, se não houver a rotina cadastra automaticamente
na SX5 L9

@param   cNetworkDe - Conteúdo da Tag NetworkDestination
@return  lRet - se a rotina fez com sucesso
@author  Fabricio Panhan Costa
@since   27/03/2019
@version 1.0
/*/
//-------------------------------------------------------
Function LjxjAdmFin(cNetworkDe)

	Local aArea    := GetArea()
	Local aAreaSX5 := SX5->(GetArea())
	Local aAdmFin  := {}
	Local nPos     := 0
	Local lRet     := .T.

	Default cNetworkDe := ""

	aAdd(aAdmFin, {"56","Leader"})
	aAdd(aAdmFin, {"58","Gazincred"})
	aAdd(aAdmFin, {"59","Telenet"})
	aAdd(aAdmFin, {"61","Brasil Card"})
	aAdd(aAdmFin, {"62","E-Pharma"})
	aAdd(aAdmFin, {"63","Rede Total"})
	aAdd(aAdmFin, {"65","GAX 65"})
	aAdd(aAdmFin, {"66","Peralta"})
	aAdd(aAdmFin, {"68","Banese"})
	aAdd(aAdmFin, {"69","Resomaq"})
	aAdd(aAdmFin, {"70","Sysdata"})
	aAdd(aAdmFin, {"72","Big Card"})
	aAdd(aAdmFin, {"73","Data Tranfer"})
	aAdd(aAdmFin, {"75","Check Express"})
	aAdd(aAdmFin, {"76","Givex"})
	aAdd(aAdmFin, {"77","Vale Card"})
	aAdd(aAdmFin, {"78","Portal Card"})
	aAdd(aAdmFin, {"79","Banpara"})
	aAdd(aAdmFin, {"80","Softnex"})
	aAdd(aAdmFin, {"81","Supercard"})
	aAdd(aAdmFin, {"82","Getnet"})
	aAdd(aAdmFin, {"82","Somar"})
	aAdd(aAdmFin, {"83","Prevsaude"})
	aAdd(aAdmFin, {"84","Banco Pottencial"})
	aAdd(aAdmFin, {"85","Sophus"})
	aAdd(aAdmFin, {"86","Marisa"})
	aAdd(aAdmFin, {"87","MaxiCred"})
	aAdd(aAdmFin, {"88","Black Hawk"})
	aAdd(aAdmFin, {"89","Expansiva"})
	aAdd(aAdmFin, {"90","Sas/NT"})
	aAdd(aAdmFin, {"91","Leader"})
	aAdd(aAdmFin, {"93","Aura – Cetelem"})
	aAdd(aAdmFin, {"94","Cabal"})
	aAdd(aAdmFin, {"95","Credsystem"})
	aAdd(aAdmFin, {"97","Cartesys"})
	aAdd(aAdmFin, {"98","Cisa"})
	aAdd(aAdmFin, {"99","TrnCentre"})
	aAdd(aAdmFin, {"101","Cardco"})
	aAdd(aAdmFin, {"102","CheckCheck"})
	aAdd(aAdmFin, {"103","DaCasa"})
	aAdd(aAdmFin, {"104","Private Bradesco"})
	aAdd(aAdmFin, {"105","Platinum"})
	aAdd(aAdmFin, {"106","GwCel"})
	aAdd(aAdmFin, {"107","Check Express"})
	aAdd(aAdmFin, {"109","Usecred"})
	aAdd(aAdmFin, {"110","Serv_Voucher"})
	aAdd(aAdmFin, {"111","Tredenexx"})
	aAdd(aAdmFin, {"112","Cartão Presente"})
	aAdd(aAdmFin, {"113","Credishop"})
	aAdd(aAdmFin, {"114","Porto Seguro"})
	aAdd(aAdmFin, {"115","IBI"})
	aAdd(aAdmFin, {"116","WorkerCard"})
	aAdd(aAdmFin, {"118","Oboe"})
	aAdd(aAdmFin, {"119","Protege"})
	aAdd(aAdmFin, {"121","HotCard"})
	aAdd(aAdmFin, {"122","Banco Panamericano"})
	aAdd(aAdmFin, {"124","SigaCred"})
	aAdd(aAdmFin, {"125","Cielo"})
	aAdd(aAdmFin, {"127","Cartao Presente Marisa"})
	aAdd(aAdmFin, {"128","Cooplife"})
	aAdd(aAdmFin, {"130","Gcard"})
	aAdd(aAdmFin, {"131","Tcredit"})
	aAdd(aAdmFin, {"132","Siscred"})
	aAdd(aAdmFin, {"133","Foxwin Card"})
	aAdd(aAdmFin, {"134","Convcard"})
	aAdd(aAdmFin, {"135","SAV"})
	aAdd(aAdmFin, {"136","Expand Cards"})
	aAdd(aAdmFin, {"138","Qualicard"})
	aAdd(aAdmFin, {"140","Waapa"})
	aAdd(aAdmFin, {"141","SQCF"})
	aAdd(aAdmFin, {"142","Intellisys"})
	aAdd(aAdmFin, {"144","Accredito"})
	aAdd(aAdmFin, {"145","Comprocard"})
	aAdd(aAdmFin, {"146","Orgcard"})
	aAdd(aAdmFin, {"147","Minascred"})
	aAdd(aAdmFin, {"148","Farmacia Popular"})
	aAdd(aAdmFin, {"149","Fidelidade Mais"})
	aAdd(aAdmFin, {"152","Fortcard"})
	aAdd(aAdmFin, {"153","Paggo"})
	aAdd(aAdmFin, {"154","Smartnet"})
	aAdd(aAdmFin, {"155","Interfarmacia"})
	aAdd(aAdmFin, {"156","Valecon"})
	aAdd(aAdmFin, {"157","Cartao Evangélico"})
	aAdd(aAdmFin, {"158","Vegas Card"})
	aAdd(aAdmFin, {"159","Sccard"})
	aAdd(aAdmFin, {"160","Orbitall"})
	aAdd(aAdmFin, {"161","Icards"})
	aAdd(aAdmFin, {"162","Facil Card"})
	aAdd(aAdmFin, {"163","Fidelize"})
	aAdd(aAdmFin, {"164","Finamax"})
	aAdd(aAdmFin, {"165","Banco GE"})
	aAdd(aAdmFin, {"166","Unik"})
	aAdd(aAdmFin, {"167","TIVIT"})
	aAdd(aAdmFin, {"168","Validata"})
	aAdd(aAdmFin, {"169","Banescard"})
	aAdd(aAdmFin, {"171","Valeshop"})
	aAdd(aAdmFin, {"172","Somar Card"})
	aAdd(aAdmFin, {"173","Omnion"})
	aAdd(aAdmFin, {"174","Condor"})
	aAdd(aAdmFin, {"175","StandbyDup"})
	aAdd(aAdmFin, {"177","Marisa Sax Sysin"})
	aAdd(aAdmFin, {"178","Starfiche"})
	aAdd(aAdmFin, {"179","Ace Seguros"})
	aAdd(aAdmFin, {"180","Top Card"})
	aAdd(aAdmFin, {"181","Getnet"})
	aAdd(aAdmFin, {"182","UpSight"})
	aAdd(aAdmFin, {"183","MAR"})
	aAdd(aAdmFin, {"184","Funcional PBM"})
	aAdd(aAdmFin, {"185","Pharma System"})
	aAdd(aAdmFin, {"186","Neus"})
	aAdd(aAdmFin, {"187","Sicredi"})
	aAdd(aAdmFin, {"189","Nservices"})
	aAdd(aAdmFin, {"190","CSF"})
	aAdd(aAdmFin, {"192","Avista"})
	aAdd(aAdmFin, {"193","Algorix"})
	aAdd(aAdmFin, {"194","Amex"})
	aAdd(aAdmFin, {"195","Compremax"})
	aAdd(aAdmFin, {"196","Libercard"})
	aAdd(aAdmFin, {"197","Seicon"})
	aAdd(aAdmFin, {"199","SmartN"})
	aAdd(aAdmFin, {"203","Peela"})
	aAdd(aAdmFin, {"204","Nutrik"})
	aAdd(aAdmFin, {"205","GoldenFarma PBM"})
	aAdd(aAdmFin, {"206","Global Payments"})
	aAdd(aAdmFin, {"207","Elavon"})
	aAdd(aAdmFin, {"208","CTF"})
	aAdd(aAdmFin, {"209","Banestik"})
	aAdd(aAdmFin, {"214","Eletrozema"})
	aAdd(aAdmFin, {"215","Barigui"})
	aAdd(aAdmFin, {"801","CB Banco do Brasil"})
	aAdd(aAdmFin, {"802","CB Interchange"})
	aAdd(aAdmFin, {"803","CB Bank Boston"})
	aAdd(aAdmFin, {"804","CB Cef"})
	aAdd(aAdmFin, {"805","CB Bradesco"})
	aAdd(aAdmFin, {"806","CB Safra"})
	aAdd(aAdmFin, {"807","CB Santander"})
	aAdd(aAdmFin, {"808","CB_Hsbc"})
	aAdd(aAdmFin, {"809","CB Bancoob"})
	aAdd(aAdmFin, {"810","CB CorbanSe"})
	aAdd(aAdmFin, {"811","CB GXS"})
	aAdd(aAdmFin, {"812","CB Itau"})

    nPos := AScan(aAdmFin, {|x| x[1] == cNetworkDe})

    If nPos > 0
        DbSelectArea("SX5")
        SX5->( DbSetOrder(1) )
        If !SX5->( DbSeek(xFilial("SX5") + "L9" + cNetworkDe) )
            RecLock("SX5", .T.)
                X5_FILIAL  := xFilial("SX5")
                X5_TABELA  := "L9"
                X5_CHAVE   := cNetworkDe
                X5_DESCRI  := aAdmFin[nPos][2]
                X5_DESCSPA := aAdmFin[nPos][2]
                X5_DESCENG := aAdmFin[nPos][2]
            SX5->( MsUnlock() )
        EndIf
    Else
        lRet := .F.
    EndIf

    RestArea(aAreaSX5)
    RestArea(aArea)

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} LjITesDev
Busca a tes de Devolução a partir da origem
@type function
@author  	rafael.pessoa
@since   	11/04/2019
@version 	P12
@param 		cDocOri    , Caracter, Numero do documento
@param 		cSerieOri  , Caracter, Numero da serie
@param 		cItOri     , Caracter, Item Origem
@param 		cCliente   , Caracter, Codigo do Cliente
@param 		cLoja      , Caracter, Loja do Cliente
@param 		cProduto   , Caracter, codigo do produto

@return	cTesDev - Retorna a TES de Devolução a partir da nota de origem
/*/
//--------------------------------------------------------
Function LjITesDev( cDocOri , cSerieOri , cItOri , cCliente , cLoja ,cProduto)

Local cTesOri 	    := ""
Local cTesDev 	    := ""
Local lRet 	        := .F.

Default cDocOri     := ""	
Default cSerieOri   := ""	
Default cItOri      := ""
Default cCliente    := ""	
Default cLoja       := ""
Default cProduto    := ""

DbSelectArea("SD1")
DbSetOrder(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM 
If ( MsSeek(xFilial("SD1") + cDocOri + cSerieOri + cCliente + cLoja + cProduto + cItOri) )
    lRet    := .T.
    cTesOri := D1_TES
EndIf

If lRet
    DbSelectArea("SF4")
    SF4->( DbSetOrder(1) ) //F4_FILIAL+F4_CODIGO
    If 	SF4->( DbSeek(xFilial("SF4") + cTesOri ) )
        If SF4->(DbSeek(xFilial("SF4")+SF4->F4_TESDV))
            cTesDev := SF4->F4_CODIGO
        EndIf
    EndIf    
EndIf

Return cTesDev

//--------------------------------------------------------
/*/{Protheus.doc} LjxAddFil
AddCampos todos os Campos Faltantes no model
@type function
@author  	rafael.tenório
@since   	05/06/2019
@version 	P12
@return	    ViewDef - View do modelo
/*/
//--------------------------------------------------------
Function LjxAddFil(cTable, oStruct, nType)

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local cField    := ""

Default oStruct := Nil
Default nType   := 0

If SX3->( DbSeek(cTable) )

    While SX3->X3_ARQUIVO == cTable
        cField := AllTrim(SX3->X3_CAMPO)
        If !oStruct:HasField(AllTrim(cField))

            If nType == 1 //Model 	
                oStruct:AddField(RetTitle(cField), "", cField, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
            ElseIf nType == 2 //View
                oStruct:AddField(cField, SX3->X3_ORDEM, RetTitle(cField), "", {}, SX3->X3_TIPO, SX3->X3_PICTURE, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
            EndIf
        EndIf
    
        SX3->( DbSkip() )
    EndDo

EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} LJPesqCP()
Tela de pesquisa de condição de pagamento, disponibilizada
no Venda Assistida, chamada no X3_F3 do campo LQ_CONDPG
@type Function

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return Lógico, retorno .T.
/*/
//------------------------------------------------------------------
Function LJPesqCP()

Local oButConf
Local oVlrVend
Local oVlrDesc
Local oVlrAcrs
Local oVlrTot
Local oTcCond
Local oTcParc
Local oFont2 		:= TFont():New("Courier New",,020,,.T.,,,,,.F.,.F.)
Local oFont4 		:= TFont():New("Courier New",,020,,.T.,,,,,.F.,.F.)
Local oVlrDescScr															// Objeto do valor de desconto na Tela
Local oVlrVendScr															// Objeto do valor da Venda na Tela
Local oVlrAcrsScr    														// Objeto do valor de Acréscimo na Tela
Local oVlrTotScr     														// Objeto do valor de Total na Tela
Local oNegTela
Local aItens    	:= {}
Local aParcelas 	:= {}
Local aParcAux  	:= {}  	// Armazena todas as parcelas para todas as condições de pagamento

Local cVlrVenda 	:= "" 	// variável valor da Venda na Tela
Local cVlrDesc  	:= "" 	// variável valor da desconto na Tela
Local cVlrAcres 	:= "" 	// variável valor Acréscimo na Tela
Local cVlrTotal 	:= "" 	// variável do valor de Total na Tela
Local nAuxTot   	:= 0  	// Variável que controla valor da venda vindo da Venda Assistida
Local nVlrParcela 	:= 0	// Variável que armazena o Valor Líquido
Local nVlrSoma  	:= 0  	// Auxiliar do Frete
Local nValorAtu		:= 0

/*
Cadastro SXB para utilização da funcionalidade

XB_ALIAS	XB_TIPO	XB_SEQ	XB_COLUNA	XB_DESCRI	XB_DESCSPA	XB_DESCENG	XB_CONTEM	XB_WCONTEM
LJCNDP		   1	01	       RE		Pesquisa 	Pesquisa	Pesquisa   	   SE4
LJCNDP		   2	01	       01										     LJPESQCP()
LJCNDP		   5	01					                                     LJRETSE4()

SX3 - Basta alterar o campo X3_F3 do LQ_CONDPG para LJCNDP .
*/

Lj7SetKeys(.F.) 				// Desabilita as teclas de atalho
Lj7ZeraPgtos() 					// Zera parcelas para evitar erros de montagem de parcelas
nAuxTot     := Lj7T_Total( 2 )
aAtuVlrTot  := AtuValorTot() 	// Alimenta a variável que informará o valor total antes da negociação
nVlrParcela := aAtuVlrTot[1]
nVlrSoma	:= aAtuVlrTot[2]

DEFINE MSDIALOG oNegTela TITLE STR0032 FROM 000, 000  TO 500, 890 COLORS 0, 16777215 PIXEL									//Negociação do Pagamento
oTcCond := TCBrowse():New (015,007,280,150,Nil,Nil,Nil,oNegTela,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)	//Cond. Pgto
oTcParc := TCBrowse():New (015,292,150,150,Nil,Nil,Nil,oNegTela,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)	// Parcelas
@ 225, 350 BUTTON oButConf PROMPT STR0020 	SIZE 045, 015 ACTION (ConfSrc(oTcCond, oNegTela, @cVlrTotal)) OF oNegTela PIXEL 			// Confirmar

@ 180, 010 SAY oVlrVend    PROMPT STR0021 	SIZE 100, 007 OF oNegTela FONT oFont2 COLORS 0, 16777215  PIXEL					//Valor da Venda:
@ 180, 110 SAY oVlrVendScr PROMPT cVlrVenda			 	SIZE 080, 007 OF oNegTela FONT oFont4 COLORS CLR_HRED 	 PIXEL

@ 205, 010 SAY oVlrDesc    PROMPT STR0022 	SIZE 100, 007 OF oNegTela FONT oFont2 COLORS 0, 16777215  PIXEL					//Valor do Desconto:
@ 205, 110 SAY oVlrDescScr PROMPT cVlrDesc			 	SIZE 080, 007 OF oNegTela FONT oFont4 COLORS CLR_HRED 	 PIXEL

@ 230, 010 SAY oVlrAcrs    PROMPT STR0023	SIZE 100, 007 OF oNegTela FONT oFont2 COLORS 0, 16777215  PIXEL 				//Valor do Acréscimo:
@ 230, 110 SAY oVlrAcrsScr PROMPT cVlrAcres			 	SIZE 080, 007 OF oNegTela FONT oFont4 COLORS CLR_HRED     PIXEL

@ 180, 295 SAY oVlrTot     PROMPT STR0024 	SIZE 100, 007 OF oNegTela FONT oFont2 COLORS 0, 16777215 PIXEL					//Valor Total:
@ 180, 360 SAY oVlrTotScr  PROMPT cVlrTotal			 	SIZE 080, 007 OF oNegTela FONT oFont4 COLORS CLR_HRED     PIXEL

//Adiciona Cabeçalho da Condição de Pagamento
oTcCond:AddColumn(TCColumn():New(STR0014, {|| aItens[oTcCond:nAt,1]  },,,,"LEFT"   ,020,.F.,.F.,,,,.F.,))					//Código
oTcCond:AddColumn(TCColumn():New(STR0015, {|| aItens[oTcCond:nAt,2]  },,,,"LEFT",130,.F.,.F.,,,,.F.,))						//Condição
oTcCond:AddColumn(TCColumn():New(STR0016, {|| aItens[oTcCond:nAt,3] },,,,"LEFT",040,.F.,.F.,,,,.F.,))						//Vlr. Parcela
oTcCond:AddColumn(TCColumn():New(STR0017, {|| aItens[oTcCond:nAt,4] },,,,"LEFT",040,.F.,.F.,,,,.F.,))						//Vlr. Total
oTcCond:AddColumn(TCColumn():New(STR0018, {|| aItens[oTcCond:nAt,5] },,,,"LEFT",035,.F.,.F.,,,,.F.,))						//Vlr. Minimo

//Adiciona Cabeçalho das Parcelas
oTcParc:AddColumn(TCColumn():New(STR0025, {|| aParcelas[oTcParc:nAt,1] },,,,"LEFT"   ,025,.F.,.F.,,,,.F.,))					//Data
oTcParc:AddColumn(TCColumn():New(STR0026, {|| aParcelas[oTcParc:nAt,2] },,,,"LEFT"  ,060,.F.,.F.,,,,.F.,))					//Valor
oTcParc:AddColumn(TCColumn():New(STR0027, {|| aParcelas[oTcParc:nAt,3] },,,,"LEFT"  ,020,.F.,.F.,,,,.F.,))					//Pgto
oTcParc:AddColumn(TCColumn():New(STR0028, {|| aParcelas[oTcParc:nAt,4] },,,,"LEFT" ,010,.F.,.F.,,,,.F.,))					//Parc.

AtuCondScr(@oTcCond	, @aItens	, @oTcParc	, @aParcelas, @oVlrDescScr	, @oVlrVendScr	, @oVlrAcrsScr, @oVlrTotScr,;
		   nAuxTot	, @cVlrVenda, @cVlrDesc	, @cVlrAcres, @cVlrTotal	, nVlrSoma		, nVlrParcela , @aParcAux, nValorAtu) 																										// Alimenta itens da Condição de Pagamento e Parcelas
oTcCond:bLDblClick  := {|| ConfSrc(oTcCond, oNegTela, cVlrTotal)}  																	// Ação no Duplo Clique
oTcCond:bSeekChange := {|| AtuParcelas(oTcParc		, aParcelas	, Nil			, oTcCond	, oVlrDescScr	, oVlrVendScr,;
									   oVlrAcrsScr	, oVlrTotScr, nAuxTot		, cVlrVenda	, cVlrDesc		, cVlrAcres	 ,;
									   cVlrTotal	, nVlrSoma	, nVlrParcela	, aParcAux	, nValorAtu)} 							// Ação na movimentação com mouse
oTcCond:bDrawSelect := {|| AtuParcelas(oTcParc		, aParcelas	, Nil			, oTcCond	, oVlrDescScr	, oVlrVendScr,;
									   oVlrAcrsScr	, oVlrTotScr, nAuxTot		, cVlrVenda	, cVlrDesc		, cVlrAcres	 ,;
									   cVlrTotal	, nVlrSoma	, nVlrParcela	, aParcAux	, nValorAtu)}							// Ação na movimentação das linhas com o teclado

ACTIVATE MSDIALOG oNegTela CENTERED

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} AtuVlrSrc()
Atualiza totalizadores da tela. 
@type Function

@param nValorAtu, numérico, Valor atual da venda

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return nil, retorno nulo
/*/
//------------------------------------------------------------------
Static Function  AtuVlrSrc(nValorAtu, oVlrDescScr	, oVlrVendScr	, oVlrAcrsScr, oVlrTotScr, nAuxTot	  ,;
						   cVlrVenda, cVlrDesc		, cVlrAcres		, cVlrTotal	 , nVlrSoma	 , nVlrParcela,;
						   aParcAux)

Local aRet	:= {}

cVlrVenda := TransValScr(nAuxTot)
cVlrTotal := TransValScr(nValorAtu)

If nAuxTot = nValorAtu
	cVlrDesc  := TransValScr(0)
	cVlrAcres := TransValScr(0)
	
Elseif nValorAtu > nAuxTot
	cVlrDesc  := TransValScr(0)
	cVlrAcres := TransValScr(nValorAtu-nAuxTot)
Else
	cVlrDesc  := TransValScr(nAuxTot-nValorAtu)
	cVlrAcres := TransValScr(0)
Endif

oVlrDescScr:CCAPTION := cVlrDesc
oVlrVendScr:CCAPTION := cVlrVenda
oVlrAcrsScr:CCAPTION := cVlrAcres
oVlrTotScr:CCAPTION  := cVlrTotal

oVlrDescScr:ReFresh()
oVlrVendScr:ReFresh()
oVlrAcrsScr:ReFresh()
oVlrTotScr:ReFresh()

aRet := {cVlrVenda, cVlrDesc, cVlrAcres, cVlrTotal}

Return(aRet)

//------------------------------------------------------------------
/*/{Protheus.doc} AtuCondScr()
Alimenta Itens do box da Condição de Pagamento
@type Function

@param oTcCond	, objeto, Objeto Condições
@param aItens	, array, Itens
@param oTcParc	, objeto, Objeto Parcelas
@param aParcelas, array, Parcelas

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return nil, retorno nulo
/*/
//------------------------------------------------------------------
Static Function AtuCondScr(oTcCond		, aItens	, oTcParc	 , aParcelas, oVlrDescScr, oVlrVendScr	,;
						   oVlrAcrsScr	, oVlrTotScr, nAuxTot	 , cVlrVenda, cVlrDesc	 , cVlrAcres	,;
						   cVlrTotal	, nVlrSoma	, nVlrParcela, aParcAux , nValorAtu)
Local aSe4       := {}
Local aRet	     := {}
Local nx	     := 1
Local ny		 := 1
Local aAreaSE4   := SE4->(GetArea())
Local nVlrAcrsFi := 0
Local nTotParc	 := 0
Local nLinha	 := 0
//Local lRecarga   := Alltrim(M->LR_PRODUTO) == GetMV("MV_LJPFID")

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek(xFilial("SE4")) // Pociciona no primeiro registo indexado ( não se usa GoTop()! )

While !SE4->(EOF()) .And. SE4->E4_FILIAL == xFilial("SE4") // Se no futuro precisar filtrar alguma regra, é só acrescentar a lógica

/*/
Estamos liberando essa primeira versão sem a funcionalidade de verificação 
do tipo da condição de pagamento (Compras, Vendas Recebimento ou todas).
Isso porque estamos no aguardo da inclusão de dois campos (SE4->E4_TOLVIN e SE4->E4_COMVEN)
pela equipe do financeiro. Assim que os campos forem incluidos, basta retirar os comentários.
/*/


/*	
	If !lRecebe .and. SE4->E4_COMVEN == "V" .and. VAL(SE4->E4_CODIGO) < 401 .or. !lRecebe .and. SE4->E4_COMVEN == "X" .and. VAL(SE4->E4_CODIGO) < 401;
	   .or. !lRecebe .and. SE4->E4_COMVEN == "R" .and. lRecarga .and. VAL(SE4->E4_CODIGO) < 401
	   
			Aadd(aSe4,{SE4->E4_CODIGO,SE4->E4_DESCRI,SE4->E4_INFER})

	Elseif lRecebe .and. SE4->E4_COMVEN == "R" .or. lRecebe .and. SE4->E4_COMVEN == "X"
*/
		Aadd(aSe4,{SE4->E4_CODIGO,SE4->E4_DESCRI,SE4->E4_INFER})

//	Endif
	SE4->(DBSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array de retorno aRet   	  				³
//³[1][1] - Data Vencimento   				³
//³[1][2] - Valor da Parcela  				³
//³[1][3] - Forma de Pagamento				³
//³[1][4] - Array             				³
//³[1][5] - Vazio             				³
//³[1][6] - Moeda             				³
//³[1][7] - DataBase          				³
//³[1][8] - Vlr Acres.Não Func				³
//³Para calcular acréscimo usar nVlrAcrsFi  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aSe4) > 0
	For nx := 1 To Len(aSe4)
		// A Função Lj7CalcPgt retorna exatamente como as parcelas ficarão de acordo com a condição de pagamento, sem alterar o apgtos
		aRet  := Lj7CalcPgt( nVlrParcela , aSe4[nx][1] , {} , nVlrSoma , NIL , NIL , NIL , 0 ,	NIL , NIL , NIL , @nVlrAcrsFi )
		If Len(aRet) > 0
			For ny := 1 To Len(aRet)
				nTotParc += aRet[ny][2] // soma o valor de todas as parcelas para uma única condição de pagamento
				Aadd(aParcAux,{aRet[ny][1],aRet[ny][2],aRet[ny][3],ny,nx})  // adiciona todas as parcelas para todas as condições
			Next ny
			//Adiciona a linha da condição de pagamento - BOX 1
			Aadd(aItens,{aSe4[nx][1],aSe4[nx][2],TransValScr(aRet[1][2]),TransValScr(nTotParc), TransValScr(aSe4[nx][3]), nx }) // Vencimento / Descr. Condição ,Vlr 1 Parcela , Vlr Total, Lim.Inferior
			nTotParc := 0
		Endif
		
	Next nx
Endif

If Len(aItens) == 0  // Tratamento para quando não há condição cadastrada ou valor da parcela a ser pago é igual a 0
	Aadd(aParcAux,{Date(),nTotParc,"",1,1})  // adiciona todas as parcelas para todas as condições
	Aadd(aItens,{"","",TransValScr(nTotParc), TransValScr(nTotParc),"",1 }) // Vencimento / Descr. Condição ,Vlr 1 Parcela , Vlr Total, Lim. Inferior
Endif
// Monta no objeto os itens com base na pesquisa acima
If Len(aItens) > 0
	oTcCond:SetArray(aItens)
	oTcCond:bLine := {||{ aItens[oTcCond:nAt,01],;
	aItens[oTcCond:nAt,02],;
	aItens[oTcCond:nAt,03],;
	aItens[oTcCond:nAt,04],;
	aItens[oTcCond:nAt,05] } }
	
	oTcCond:Refresh()
	
	nLinha := oTcCond:NAT   // Linha Atual
	
	// Função que atualiza o BOX 2 das parcelas
	AtuParcelas(@oTcParc	, @aParcelas, nLinha	, oTcCond	, @oVlrDescScr	, @oVlrVendScr	, @oVlrAcrsScr,;
	 			@oVlrTotScr	, @nAuxTot	, @cVlrVenda, @cVlrDesc	, @cVlrAcres	, @cVlrTotal	, @nVlrSoma   ,;
				@nVlrParcela, aParcAux	, @nValorAtu)
Endif

RestArea(aAreaSE4)

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} TransValScr()
Função que transforma os valores para R$ 0,00
@type Function

@param nValor, numérico, Valor atual da venda

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return cNewVlr, retorno Novo valor
/*/
//------------------------------------------------------------------
Static Function TransValScr(nValor)
Local cNewVlr	:= ""

cNewVlr := SuperGetMV("MV_SIMB1") + " " + Alltrim(TransForm(nValor,PesqPict("SL1","L1_VLRTOT",,2)))

Return cNewVlr

//------------------------------------------------------------------
/*/{Protheus.doc} AtuParcelas()
Função que atualiza as parcelas de acordo com o item 
posicionado no BOX 1 - condição de pagamento
@type Function

@param oTcParc, objeto, Objeto parcelas
@param aParcelas, array, Array que contém as parcelas
@param nLinha, numérico, Linha
@param oTcCond, objeto, Objeto Condição de pagamento

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return cNewVlr, retorno Novo valor
/*/
//------------------------------------------------------------------
Static Function AtuParcelas(oTcParc		, aParcelas	, nLinha	 , oTcCond	, oVlrDescScr, oVlrVendScr	,;
						    oVlrAcrsScr	, oVlrTotScr, nAuxTot	 , cVlrVenda, cVlrDesc	 , cVlrAcres	,;
							cVlrTotal	, nVlrSoma  , nVlrParcela, aParcAux , nValorAtu)

Local aRet		:= {}
Local nPos 		:= 0
Local nx		:= 0
Local nVlrParc  := 0

If ValType(nLinha) != "N"
	nLinha := oTcCond:nAt
Endif

// Pesquisa necessária para garantir que foi encontrada a parcela correspondente. Apenas para proteção
nPos := Ascan(aParcAux, { |x| x[5] == oTcCond:AARRAY[nLinha][6]})

If nPos > 0
	
	aParcelas := {} 					// Variável responsável por demonstrar as parcelas para cada condição de pagamento
	
	For nx := 1 To Len(aParcAux) 		// Varre todas as parcelas para todas as condições de pagamento
		If aParcAux[nx][5] = nLinha 	// Só adiciona as parcelas vinculadas ao item da condição selecionado
			Aadd(aParcelas,{aParcAux[nx][1],TransValScr(aParcAux[nx][2]),aParcAux[nx][3],aParcAux[nx][4] } ) // Data ; Valor parcela ; Forma Pgto ; Numero Parcela
			nVlrParc += aParcAux[nx][2] // Soma o valor de cada parcela para futuro controle de acréscimo e desconto
		Endif
	Next nx
	// Monta o objeto as parcelas
	If Len(aParcelas) > 0
		oTcParc:SetArray(aParcelas)
		oTcParc:bLine := {||{ aParcelas[oTcParc:nAt,01],;
		aParcelas[oTcParc:nAt,02],;
		aParcelas[oTcParc:nAt,03],;
		aParcelas[oTcParc:nAt,04] } }
		oTcParc:Refresh()
	Endif
	
Endif

aRet := AtuVlrSrc(nVlrParc		, @oVlrDescScr	, @oVlrVendScr	, @oVlrAcrsScr	, @oVlrTotScr, @nAuxTot		,;
				  @cVlrVenda	, @cVlrDesc	 	, @cVlrAcres	, @cVlrTotal	, @nVlrSoma	 , @nVlrParcela	,;
		  		  aParcAux		, @nValorAtu)																	// Atualiza os totalizadores da tela

Return(aRet)

//------------------------------------------------------------------
/*/{Protheus.doc} ConfSrc()
Atualiza a variável de memória na confirmação da tela
@type Function

@param oTcCond	, objeto, Objeto Condições
@param aItens	, array, Itens
@param oTcParc	, objeto, Objeto Parcelas
@param aParcelas, array, Parcelas

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return nil, retorno nulo
/*/
//------------------------------------------------------------------
Static Function ConfSrc(oTcCond, oNegTela, cVlrTotal)

Local cCondE4	:= ""
Local nVlraux	:= 0
Local lOk		:= .F.
Local nValor	:= Val(Substr(cVlrTotal,3,Len(cVlrTotal)))
Local nTamUser 	:= 25                           // Tamanho do campo do usuario
Local cCaixaSup	:= Space(25)					// Caixa superior

cCaixaSup := PadR( cCaixaSup, nTamUser, " " )

/*/
Estamos liberando essa primeira versão sem a funcionalidade de verificação 
de tolerancia de limite inferior da condição de pagamento.
Isso porque estamos no aguardo da inclusão de dois campos (SE4->E4_TOLVIN e SE4->E4_COMVEN)
pela equipe do financeiro. Assim que os campos forem incluidos, basta retirar os comentários.
/*/

	
If Len(oTcCond:AARRAY) > 0
	
	cCondE4 := oTcCond:AARRAY[oTcCond:NAT][1]

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+cCondE4))
		If SE4->E4_INFER <> 0 // Existe Validação para o Limite mínimo
			If nValor <= SE4->E4_INFER
				nVlraux := SE4->E4_INFER - nValor
				/*
				If nVlraux <= SE4->E4_TOLVIN // Se a Diferença estiver dentro do limite estabelecido, chama o Superior do Caixa
					If FWAuthSuper(@cCaixaSup)    // Deixa o tratamento para obter qual o superior autorizou pronto para alguma necessidade no futuro.
						lOk := .T.
					Else
						Alert(STR0033) //Senha do Superior inválida
					Endif
				Else
				*/
					Alert(STR0029 + SuperGetMV("MV_SIMB1") + Alltrim(Str(SE4->E4_INFER)) + " " + STR0031) // Atenção! Esta condição de pagamento só poderá ser usada para vendas com um total maior que 
					
				/*
				Endif
				*/
			Else
				lOk := .T.
			Endif
		Else
			lOk := .T.
		Endif
	Endif
	
	If lOk
		M->LQ_CONDPG := cCondE4
		oNegTela:End()
	Endif

Endif
Return lOk

//------------------------------------------------------------------
/*/{Protheus.doc} LJRETSE4()
Função que retorna da Pesquisa para o get da condição de pagamento
@type Function

@param cReadVar	, caracter, Código da condição de pagamento

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return Carácter, Codigo da condição de pagamento
/*/
//------------------------------------------------------------------
Function LJRETSE4()

Local cReadVar := &(ReadVar())

oPgtos:SetFocus()
Lj7SetKeys(.T.)

Return cReadVar

//------------------------------------------------------------------
/*/{Protheus.doc} AtuValorTot()
Função que o Valor das Parcelas considerando a NCC usada
@type Function

@author Marcos Iurato Junior
@since 16/09/2019
@version P12.1.25

@return Nil, Nulo
/*/
//------------------------------------------------------------------
Static Function AtuValorTot()

Local aRet			:= {}
Local nVlrPago  	:= 0
Local nValAbISS 	:= 0
Local nVlrSub		:= 0
Local nSobraNCC		:= 0
Local nValFrete		:= 0


nVlrPago := nNCCUsada + If( LJ220AbISS(), MaFisRet(,'NF_VALISS'), 0 ) // Considera a NCC selecionada

If LJ220AbISS()
	nValAbISS := MaFisRet(,'NF_VALISS')
EndIf

nVlrSub  := LJ7T_SubTotal(2) - nValAbISS

If nNCCUsada - nVlrSub > 0
	nSobraNCC := nVlrSub
Else
	nSobraNCC := nNCCUsada
EndIf

nVlrParcela := nVlrSub - LJ7T_DescV( 2 ) - nSobraNCC
nValFrete   := Lj7CalcFrete()
nVlrSoma    := nValFrete

If nNCCUsada >= (nVlrSub + nValFrete)
	nVlrSoma  := 0
EndIf

aRet := {nVlrParcela, nVlrSoma}

Return (aRet)

/*/{Protheus.doc} LjXjSalRet(cNumOrc)
Busca Venda Varejo que gerou o Pedido de Venda

@param	cNumPed	Numero do Orcamento Varejo

@author Everson S. P. Junior
@since 20/02/2020
@version 12
/*/

Function LjXjSalRet(cNumOrc, cFilorc)

Local cWhere 	:= ""
Local cAliasTmp := GetNextAlias() //Alias temporario
Local aRet   	:= {"","","",""}
Local aArea		:= GetArea()
Local aAreaSL1	:= SL1->(GetArea())

Default cNumOrc:= ""
Default cFilorc:= "" 

LjGrvLog("LjXjSalRet" , "Processo similar ao A410BRETAIL")
LjGrvLog("LjXjSalRet" , "Parametro cNumOrc "+cNumOrc)
LjGrvLog("LjXjSalRet" , "Parametro cFilorc "+cFilorc)
LjGrvLog("LjXjSalRet" , "Chamada QUERY")

//Busca informações do cumpom pai
//Condicional para a query		
if SL1->(DbSeek(xFilial("SL1")+cNumOrc)) .AND. !Empty(SL1->L1_SITUA)// cNumOrc for o numero do orçamento Pai deve achar os dados pela L1_ORCRES
	cWhere := "%"
	cWhere += " L1_FILRES = '"  + cFilorc + "'"
	cWhere += " AND L1_ORCRES = '" + cNumOrc + "'"
	cWhere += " AND D_E_L_E_T_ = ''"
	cWhere += "%"	
else //cNumOrc for o numero do orçamento Filha deve achar os dados pelo L1_NUM
		
	cWhere := "%"
	cWhere += " L1_FILIAL = '"  + Iif(Empty(cFilorc),xFilial("SL1"),cFilOrc) + "'"
	cWhere += " AND L1_NUM = '" + cNumOrc + "'"
	cWhere += " AND D_E_L_E_T_ = ''"
	cWhere += "%"
endIf


//Executa a query
BeginSql alias cAliasTmp
	SELECT
	L1_NUM,L1_FILRES, L1_ORCRES
	FROM %table:SL1%
	WHERE %exp:cWhere%
EndSql
		
(cAliasTmp)->(dbGoTop())
		
LjGrvLog("LjXjSalRet" , "QUERY executada "+GetLastQuery()[2])
//Busca informacoes da Venda Varejo
If (cAliasTmp)->(!EOF())

	LjGrvLog("LjXjSalRet" , "L1_FILRES:= " + (cAliasTmp)->L1_FILRES )
	LjGrvLog("LjXjSalRet" , "L1_ORCRES:= " + (cAliasTmp)->L1_ORCRES )
	
	SL1->(dbSetOrder(1)) //L1_FILIAL+L1_NUM
	If SL1->(dbSeek(xFilial("SL1",(cAliasTmp)->L1_FILRES) + (cAliasTmp)->L1_ORCRES))
		aRet[1] := SL1->L1_FILIAL
		aRet[2] := SL1->L1_SERPED
		aRet[3] := SL1->L1_DOCPED
		
		LjGrvLog("LjXjSalRet" , "aRet[1]:= " + SL1->L1_FILIAL )
		LjGrvLog("LjXjSalRet" , "aRet[2]:= " + SL1->L1_SERPED )
		LjGrvLog("LjXjSalRet" , "aRet[3]:= " + SL1->L1_DOCPED )
		                                			
		//Busca informacoes do pdv, pois ao criar o orçamento filho
		//o número do pdv é apagado no orçamento pai.
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
		If(SL1->(DbSeek(xFilial("SL1")+(cAliasTmp)->L1_NUM)))
			aRet[4] := SL1->L1_PDV
			LjGrvLog("LjXjSalRet" , "cNumOrc:= " + cNumOrc )
			LjGrvLog("LjXjSalRet" , "aRet[4]:= " + SL1->L1_PDV )
		Endif
	Endif		
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->(dbCloseArea())
EndIf


RestArea(aAreaSL1)
RestArea(aArea)
	
Return aRet 

/*/{Protheus.doc} LjJConPedP
	Para confirmar quando tenho pedido de venda pendente

	@type  Function
	@author Julio.Nery
	@since 14/08/2020
	@version P12
	@param param, param_type, param_descr
	@return lRet, lógico, valida se o registro foi confirmado
/*/
Function LjJConPedP()
Local cCadastro := STR0034
Local cLog		:= ""
Local lL1Ecflag := .F.
Local lL1OrcRes	:= .F.
Local lisBlind	:= isblind()
Local lRet		:= .F.
Local oDlg		:= NIL
Local nOpca		:= 0
Local aAreaSL1	:= {}

//Somente o orçamento filho deve ser liberado, por isso, avalio o L1_ORCRES
lL1Ecflag := AllTrim(SL1->L1_ECFLAG) == "P"
lL1OrcRes := !Empty(AllTrim(SL1->L1_ORCRES))
lRet      := lL1Ecflag .And. lL1OrcRes

If lRet
	If lisBlind
		nOpca := 1
	Else 
		DEFINE MSDIALOG oDlg TITLE cCadastro From 3,0 TO 18,80 OF oMainWnd
			
			@ 35, 005 TO 100, 110 OF oDlg PIXEL
			@ 35, 112 TO 100, 225 OF oDlg PIXEL
			@ 35, 227 TO 100, 315 OF oDlg PIXEL

			//Quadro 1
			@ 40,008 Say STR0035 SIZE 30, 07	OF oDlg PIXEL	// "Orçamento:"
			@ 40,038 MSGet SL1->L1_NUM 	When .F. SIZE 30, 08	OF oDlg PIXEL

			@ 52,008 Say STR0036 SIZE 30, 07	OF oDlg PIXEL	// 'Documento:'
			@ 52,038 MSGet SL1->L1_DOC When .F.	 SIZE 30, 08	OF oDlg PIXEL
			
			@ 64, 008 SAY xPadL( STR0037, 36 )	SIZE 30, 07	OF oDlg PIXEL	// Pedido:
			@ 64, 038 MSGET SL1->L1_DOCPED When .F.	 SIZE 30, 08	OF oDlg PIXEL

			@ 76, 008 SAY xPadL( STR0038, 36 )	 SIZE 30, 07	OF oDlg PIXEL	// Serie Pedido:
			@ 76, 038 MSGET SL1->L1_SERPED When .F.	 SIZE 30, 08	OF oDlg PIXEL

			@ 88, 008 SAY xPadL( STR0039, 24 )		 SIZE 30, 07	OF oDlg PIXEL	// Cliente:
			@ 88, 038 MSGET SL1->L1_CLIENTE When .F.	 SIZE 30, 08	OF oDlg PIXEL

			//Quadro 2
			@ 40, 115 SAY xPadL( STR0040, 66 ) SIZE 66, 7 OF oDlg PIXEL // Total de Mercadorias:
			@ 40, 170 MSGET SL1->L1_VLRTOT When .F. Picture "@E 999,999.99"	SIZE 46, 08 OF oDlg PIXEL
			
			@ 52, 115 SAY xPadL( STR0041, 25 ) SIZE 25, 7 OF oDlg PIXEL	// "Líquido:"
			@ 52, 170 MSGET SL1->L1_VLRLIQ When .F. Picture "@E 999,999.99"	SIZE 46, 08 OF oDlg PIXEL

			@ 64, 115 SAY xPadL( STR0042, 36 ) SIZE 36, 7 OF oDlg PIXEL	// Desconto:
			@ 64, 170 MSGET SL1->L1_DESCONT When .F. Picture "@E 999,999.99"	SIZE 46, 08 OF oDlg PIXEL

			//Quadro 3
			@ 40, 230 SAY xPadL( STR0043, 28 ) SIZE 25, 7 OF oDlg PIXEL	// "Emissão:"
			@ 40, 260 MSGET SL1->L1_EMISSAO  When .F.							SIZE 46, 08 OF oDlg PIXEL

			@ 52, 230 SAY xPadL( STR0044, 28 ) SIZE 25, 7 OF oDlg PIXEL	// Validade:
			@ 52, 260 MSGET SL1->L1_DTLIM  When .F.							SIZE 46, 08 OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()}) CENTERED
	EndIf

	If nOpca == 1
		If lRet
			BEGIN TRANSACTION
				Reclock("SL1",.F.)
				REPLACE SL1->L1_ECFLAG WITH "O"
				SL1->(MsUnlock())
				
				//#"Efetuado a liberação do pedido pendente (proveniente da integração)"
				LjGrvLog(SL1->L1_NUM,STR0045, {SL1->L1_NUM,SL1->(Recno())}) 
				Conout(STR0045)

			    //Chama o envio da mensagem DocumentTraceAbilityOrderRetail
                If FwHasEai("LOJI701A",.T.,,.T.)
					LjGrvLog("LOJXFUNJ", "Gera mensagem de Rastreio de Pedido Retira. Pedido Liberado (LOJI701A)")
					FwIntegDef("LOJI701A",,,, "LOJI701A")	
				EndIf

				aAreaSL1 := SL1->(GetArea())

				//Atualiza o pedido pai tambem
				SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
				If SL1->(DBSeek(SL1->L1_FILIAL+SL1->L1_ORCRES))
					Reclock("SL1",.F.)
					REPLACE SL1->L1_ECFLAG WITH "O"
					SL1->(MsUnlock())
					LjGrvLog(SL1->L1_NUM,"Orçamento Pai alterado para O", {SL1->L1_NUM,SL1->(Recno())})
					Conout("Orçamento " +  SL1->L1_NUM + " (orçamento pai da reserva) - campo L1_ECFLAG alterado para O")
					If AliasInDic("MHQ").AND.  ExistFunc("RmiExeGat") .AND. ExistFunc("SHPStatus")
						DbSelectArea("MHQ")
						If (!Empty(SL1->L1_UMOV) .AND. !Empty(Posicione("MHQ",7,xFilial("MHQ")+SL1->L1_UMOV,"MHQ_CHVUNI")) )
							SHPStatus("packaged")
						EndIf	
						MHQ->(DBCLOSEAREA())
					EndIf
				EndIf

				RestArea(aAreaSL1)
				
			END TRANSACTION			
		Else
			If !lisBlind
				MsgStop(STR0046 + "[" + SL1->L1_NUM + "]") //#"Falha na tentativa de atualização do pedido pendente - Orçamento (L1_NUM)"
			Endif
			LjGrvLog(SL1->L1_NUM,STR0047, { SL1->L1_NUM,SL1->(Recno()) }) //#"Falha na tentativa de atualização do pedido pendente"
		EndIf
	Else
		lRet := .F.
	EndIf
Else

    If !lL1Ecflag .And. lL1OrcRes
        //# "Não é possivel confirmar 'Pedido Pendente' pois o Orçamento não está Pendente (L1_ECFLAG diferente de 'P')"
        cLog := STR0048
    ElseIf !lL1OrcRes
        //# "Orçamento não necessita ser liberado"
        cLog := STR0050
    EndIf

	If !Empty(AllTrim(cLog))
		If !lisBlind
			MsgStop(cLog)
		EndIf
		ConOut(cLog)
		LjGrvLog( NIL, cLog)
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} LjMa500NCC
	Função Varejo para Tratativa após geração de NCC depois da Eliminação de Resíduo
	Função vinda do Ma500NCC() de Mata500.prx da pasta Materiais
	Entra somente se MV_NCCRESI habilitado
	Registro da tabela SC5 virá no Recno correto (já ponteirado)

	@type  Function
	@author marisa.cruz
	@since 22/10/2020
	@version P12
	@param aRegAuto , array, Cadeia de campos SE1
	@param cPedido  , Carácter, Número do Pedido de Venda
	@param cParcela , Carácter, Número da Parcela gerada
	@param nVlrNCC  , Numérico, Valor da NCC gerada
	@param lPosSe5	, Logico	, Indica se eh necessrio posicionar na SC5
	@param aDadosSC5, Array		, Dados para posicionamento na SC5
	@return nil
/*/
Function LjMa500NCC(aRegAuto,cPedido,cParcela,nVlrNCC, lPosSC5, aDadosSC5)

Local cFilRes		:= ""								//Filial Orc. Reserva
Local cOrcRes		:= ""								//Orc. Reserva
Local cSerPed		:= ""								//Série Doc. Pedido
Local cDocPed		:= ""								//Doc. Pedido
Local nE3Base		:= ""								//Base SE3 anterior
Local nE3Comis		:= ""								//Comissão SE3 anterior
Local nFatorComi	:= 0								//Fator de Comissão
Local nNCCResul		:= 0								//Divisão de Valor de NCC por % Comissão Emissão ou Baixa
Local aAreas		:= {}        
Local lMVComiDev 	:= SuperGetMV("MV_COMIDEV",,.F.)	//Permite devolução da comissão
Local lMultVend     := SuperGetMv("MV_LJTPCOM",,"1" ) == "2"	//Se Comis. Vendas por Item. Nesta função, contemplará somente Comissão de vendas por Orçamento (valor 1)

Default aRegAuto := {}
Default cPedido  := ""
Default cParcela := ""
Default nVlrNCC  := 0
Default lPosSC5	 := .F.
Default aDadosSC5 := {}

LjGrvLog( cPedido, "ID_INICIO TRATATIVA APOS ELIMINACAO DE RESIDUO" )
LjGrvLog( cPedido, "Comiss. Vend. Item :", lMultVend)
LjGrvLog( cPedido, "Gera Comissão Dev. :", lMVComiDev)
LjGrvLog( cPedido, "Parcela            :", cParcela)
LjGrvLog( cPedido, "Valor NCC          :", nVlrNCC)

If lPosSC5
	SC5->(DbSetOrder(3)) // C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
	SC5->(dbSeek( xFilial("SC5", aDadosSC5[01] ) + aDadosSC5[02] + aDadosSC5[03] + cPedido ))
EndIf

// Armazena as condicoes das tabelas.
aAdd(aAreas, SC5->(GetArea()))
aAdd(aAreas, SL1->(GetArea()))
aAdd(aAreas, SE3->(GetArea()))
aAdd(aAreas, GetArea())

//Atualizo Base e Valor das Comissões
If lMVComiDev .AND. !lMultVend .AND. !Empty(SC5->C5_ORCRES)
	LjGrvLog( cPedido, "PEDIDO TEM ORCAMENTO DE RESERVA", SC5->C5_ORCRES)
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))		//L1_FILIAL+L1_NUM
	If SL1->(DbSeek(xFilial("SL1")+SC5->C5_ORCRES)) .AND. SL1->L1_TIPO = "P"			//Pesquiso Orçamento Filho
		LjGrvLog( cPedido, "ORCAMENTO DE RESERVA", SL1->L1_FILRES + " " + SL1->L1_ORCRES)
		cFilRes := SL1->L1_FILRES
		cOrcRes := SL1->L1_ORCRES
		If SL1->(DbSeek(SL1->L1_FILRES+SL1->L1_ORCRES)) .AND. SL1->L1_TIPO = "P"		//Efetuando consulta com Orçamento Pai utilizando filial+orçamento
			LjGrvLog( cPedido, "PEDIDO DE ORIGEM", SL1->L1_DOCPED + "/" + SL1->L1_SERPED)
			cSerPed := SL1->L1_SERPED
			cDocPed := SL1->L1_DOCPED
			DbSelectArea("SE3")
			SE3->(DbSetOrder(1))		//E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA

			IF SE3->(DbSeek(xFilial("SE3")+PadR(cSerPed,TamSX3("E3_SERIE")[1])+cDocPed))	//Pesquiso Documento gerado a partir do Orçamento Pai
				While !(SE3->(EOF())) .AND.;
							SE3->E3_FILIAL = xFilial("SE3") .AND.;
							SE3->E3_SERIE = cSerPed .AND.;
							SE3->E3_NUM = cDocPed 

					LjGrvLog( cPedido, "HÁ COMISSAO GERADA")
					LjGrvLog( cPedido, "Vendedor                   :", SE3->E3_VEND)
					LjGrvLog( cPedido, "Origem                     :", SE3->E3_ORIGEM)
					LjGrvLog( cPedido, "Gerado por Emissao ou Baixa:", SE3->E3_BAIEMI)

					If SE3->E3_ORIGEM $ "LB" .AND. Empty(SE3->E3_DATA) 								//Origem Loja (Emissão) ou Baixa
						nFatorComi := LjFatComi(SE3->E3_VEND, SE3->E3_BAIEMI)
						nE3Base    := SE3->E3_BASE
						nE3Comis   := SE3->E3_COMIS
						nNCCResul  := (nVlrNCC*nFatorComi)
						LjGrvLog( cPedido, "Fator de Comissao         :", nFatorComi)
						LjGrvLog( cPedido, "Valor NCC com Fator aplic.:", nNCCResul)

						If SE3->E3_BASE >= nNCCResul
							RecLock("SE3",.F.)
							If (nE3Base - nNCCResul) == 0
								SE3->(DbDelete())
								LjGrvLog( cPedido, "BASE ANTERIOR             :", nE3Base)
								LjGrvLog( cPedido, "Base  Comis. = 0 e Valor Comis = 0 - Registro deletado" )
							Else
								SE3->E3_BASE  := nE3Base - nNCCResul
								SE3->E3_COMIS := (nE3Base - nNCCResul) * (SE3->E3_PORC/100)
								LjGrvLog( cPedido, "COMISSAO VENDEDOR ALTERADO:", SE3->E3_VEND)
								LjGrvLog( cPedido, "BASE ANTERIOR             :", nE3Base)
								LjGrvLog( cPedido, "COMISSAO ANTERIOR         :", nE3Comis)
								LjGrvLog( cPedido, "BASE ATUAL                :", SE3->E3_BASE)
								LjGrvLog( cPedido, "COMISSAO ATUAL            :", SE3->E3_COMIS)
							EndIf
							SE3->(MsUnlock())

						Else
							LjGrvLog( cPedido, "COMISSAO VENDEDOR NAO ALTERADO! BASE ANTERIOR:", SE3->E3_BASE)
						EndIf

					ElseIf !(SE3->E3_ORIGEM $ "LB")
						LjGrvLog( cPedido, "COMISSAO VENDEDOR NAO ALTERADO! NAO TEM ORIGEM LOJA OU BAIXA", SE3->E3_ORIGEM)
					ElseIf !Empty(SE3->E3_DATA)
						LjGrvLog( cPedido, "COMISSAO VENDEDOR NAO ALTERADO! COMISSAO PAGA!!", SE3->E3_DATA)
						MsgAlert( STR0051 + CRLF + CRLF +;													//"A comissão do vendedor já foi paga. Deverá ser revista!"
						          PadR(STR0052,20) + ": " + SE3->E3_NUM + "/" + SE3->E3_SERIE + CRLF +;		//"Documento"
								  PadR(STR0053,20) + ": " + SE3->E3_VEND + CRLF + ;							//"Vendedor"
								  PadR(STR0054,20) + ": " + DTOC(SE3->E3_DATA) ;							//"Data do Pagto"
								   ) 
					EndIf

					SE3->(DbSkip())
				EndDo
			Else
				LjGrvLog( cPedido, "COMISSAO NAO ENCONTRADA")
			EndIf
		EndIf
	EndIf

EndIf

// Restaura as condicoes anteriores das tabelas.
aEval(aAreas, {|aArea| RestArea(aArea)})

LjGrvLog( cPedido, "ID_FIM TRATATIVA APOS ELIMINACAO DE RESIDUO")

Return nil


/*/{Protheus.doc} LjFatComi
	Função Varejo para Retornar a % de Comissão de Emissão ou Baixa localizando o seu Vendedor

	@type  Function
	@author marisa.cruz
	@since 22/10/2020
	@version P12
	@param cCodVend , Carácter, Código do Vendedor
	@param cTpEmiBx , Carácter, E-Emissão ou B-Baixa
	@return nRet     , Numérico, Fator de multiplicacao: Se 100%, retorna 1. Se 25%, retorna 0.25
/*/

Static Function LjFatComi(cCodVend, cTpEmiBx)

Local nRet := 1		//Fator 1
Local aAreas := {}

Default cCodVend := ""
Default cTpEmiBx := ""	//Emissão ou Baixa

aAdd(aAreas, SA3->(GetArea()))
aAdd(aAreas, GetArea())

DbSelectArea("SA3")

If SA3->(DbSeek(xFilial("SA3")+cCodVend))
	If cTpEmiBx = "E"
		nRet := SA3->A3_ALEMISS / 100
	ElseIf cTpEmiBx = "B"
		nRet := SA3->A3_ALBAIXA / 100
	EndIf
EndIf

// Restaura as condicoes anteriores das tabelas.
aEval(aAreas, {|aArea| RestArea(aArea)})

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LjMa500CRs
	Cancelamento de Reservas SC0 via função a430Reserv()
	Assim, exclui os campos L2_RESERVA e C6_RESERVA
	Aqui, o SC5/SC6 deverão estar posicionados no registro corrente.
	Baseado nas funções LJ140ExcOrc() do Loja140 e LjRefazSC0() do Loja701E.

	@type  Function
	@author marisa.cruz
	@since 01/07/2021
	@version P12
	@param cMsgErro , Carácter, Parâmetro de Referência - qual erro é retornado se lRet for False
	@return lRet     , Numérico, Fator de multiplicacao: Se 100%, retorna 1. Se 25%, retorna 0.25
/*/
//----------------------------------------------------
Function LjMa500CRs(cMsgErro)

Local cQuery 		:= ""
Local lECCia      	:=  !Empty(SL1->L1_ECPEDEC)
Local lECCiaRes 	:= lECCia .AND. SuperGetMv("MV_LJECOM0", , .F.)
Local lRet			:= .F.
Local lRetLocal		:= .T.
Local cArea 		:= GetArea()
Local cAliasQry		:= ""
Local cAliasQry2	:= ""
Local cNumReserva 	:= ""
Local nRecnoFilho	:= 0
Local cFilFilho		:= 0
Local cOrcFilho		:= 0
Local cFilPai		:= 0
Local cOrcPai		:= 0
Local cProduto 		:= ""
Local cL2FilRes		:= ""
Local cL2OrcRes		:= ""

Default cMsgErro := ""

cNumReserva := SC6->C6_RESERVA
cProduto	:= SC6->C6_PRODUTO

//Procura pelo SL2 do Orcamento (Pai)
cL2FilRes := SC5->C5_FILIAL
cL2OrcRes := SC5->C5_ORCRES

//Procura pelo SL1 do Orcamento (Filho)
cAliasQRY  := GetNextAlias()

cQuery := "SELECT L2_FILIAL FILFILHO, L2_NUM ORCFILHO"
cQuery += "  FROM " + RetSQLName("SL2") + " SL2  "
cQuery += "  INNER JOIN " + RetSQLName("SL1") + " SL1  "
cQuery += "  ON L1_FILIAL = L2_FILIAL"
cQuery += "  AND L1_NUM = L2_NUM"
cQuery += "  WHERE L2_FILIAL  = '"+cL2FilRes+"'"
cQuery += "  AND L2_NUM  = '"+cL2OrcRes+"'"
cQuery += "  AND L2_RESERVA = '"+cNumReserva+"'"
cQuery += "   AND SL1.D_E_L_E_T_ = ' '"
cQuery += "   AND SL2.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)			

If (cAliasQRY)->(!EoF())
	
	cFilFilho	:= (cAliasQRY)->FILFILHO
	cOrcFilho	:= (cAliasQRY)->ORCFILHO
	
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
	SL1->(DbSeek(cFilFilho+cOrcFilho))
	
	cFilPai		:= SL1->L1_FILRES
	cOrcPai		:= SL1->L1_ORCRES
	
	//----------------------------------------------------
	//Atualiza o SL2 (Filho) com o codigo da nova reserva
	//----------------------------------------------------
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	If SL2->(DbSeek(cFilFilho+cOrcFilho+SC6->C6_ITEM+cProduto))
		nRecnoFilho := SL2->(Recno())
	EndIf
	
	//----------------------------------------------------
	//Atualiza o SL2 (Pai) com o codigo da nova reserva
	//----------------------------------------------------
	If nRecnoFilho <> 0
		cAliasQRY2 := GetNextAlias()
		cQuery := " SELECT L2_FILIAL, L2_RESERVA, L2_LOJARES , L2_PRODUTO , L2_ITEM "
		cQuery += " FROM " + RetSQLName("SL2") + " SL2 "
		cQuery += " WHERE L2_FILIAL = '"  + cFilPai      + "' "
		cQuery += " AND L2_RESERVA =  '"  + cNumReserva  + "' "
		cQuery += " AND L2_PRODUTO =  '"  + cProduto     + "' "
		cQuery += " AND L2_ORCRES  =  '"  + cL2OrcRes    + "' "
		cQuery += " AND SL2.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY2,.T.,.T.)		
		
		If (cAliasQRY2)->(!EoF())
			SL2->(DbSetOrder(5)) //L2_FILIAL+L2_RESERVA+L2_LOJARES+L2_PRODUTO+L2_ITEM
			If SL2->(DbSeek((cAliasQRY2)->L2_FILIAL+(cAliasQRY2)->L2_RESERVA+(cAliasQRY2)->L2_LOJARES+(cAliasQRY2)->L2_PRODUTO+(cAliasQRY2)->L2_ITEM))

				//Deleção SC0
				//Exclui a reserva de Estoque
				dbSelectArea("SC0")
				SC0->(dbSetOrder(1))
				If SC0->(DbSeek(xFilial("SC0")+cNumReserva))  // Atenção caso altere este trecho, faça a manutenção tbm na função: A430DelMvc
					While lRetLocal .And. ( !SC0->(Eof()) ) .And. (SC0->(C0_FILIAL+C0_NUM) == xFilial("SC0")+cNumReserva)
						SC0->(RecLock("SC0",.F.))  //Ajuste para estornar o B2_RESERVA
						//Item Liberado tem que voltar o SC0->C0_QTDPED para a quantidade do item
						If lECCiaRes .AND. SC0->C0_TIPO  = "LB" .AND. SC0->C0_QTDPED = 0
						
							LjGrvLog( SL1->L1_NUM, "Voltando a quantidade em Pedido")
							SC0->C0_QTDPED := SL2->L2_QUANT
						EndIf
						SC0->C0_QUANT  += SC0->C0_QTDPED
						SC0->C0_QTDPED -= SC0->C0_QUANT
						SC0->(MsUnlock())
					
						lRetLocal := a430Reserv({3,C0_TIPO,C0_DOCRES,C0_SOLICIT,C0_FILRES},;
							cNumReserva,;
							SC0->C0_PRODUTO,;
							SC0->C0_LOCAL,;
							SC0->C0_QUANT,;
							{	SC0->C0_NUMLOTE,;
							SC0->C0_LOTECTL,;
							SC0->C0_LOCALIZ,;
							SC0->C0_NUMSERI})
						SC0->(MsUnLock())
						If !lRetLocal
							cMsgErro := STR0055 + SC6->C6_NUM + "/" + SC6->C6_ITEM + STR0057	//"Pedido "###" : Falha ao excluir reserva na tabela SC0."
							lRet := .F.
						Else
							lRet := .T.
						EndIf
						SC0->(dbSkip())
					EndDo
				Else
					cMsgErro := STR0055 + SC6->C6_NUM + "/" + SC6->C6_ITEM + STR0058 + cNumReserva + STR0059	//"Pedido "###" : Nao encontrado "###" na tabela SC0."
					lRet := .F.
				EndIf

				If lRet
					//Deleta campo de reserva do Orçamento Pai
					RecLock("SL2", .F.)
					SL2->L2_RESERVA := ""
					SL2->L2_LOJARES := ""
					SL2->(MsUnLock())

					//Deleta campo de reserva do Orçamento Filho
					SL2->(DbGoto(nRecnoFilho))
					RecLock("SL2", .F.)
					SL2->L2_RESERVA := ""
					SL2->L2_LOJARES := ""
					SL2->(MsUnLock())

					//Este registro já encontra-se posicionado
					RecLock("SC6",.F.)
					SC6->C6_RESERVA := ""
					SC6->(MsUnLock())
				EndIf

			EndIf		
		Endif

		(cAliasQRY2)->(DbCloseArea())
	Else
		cMsgErro := STR0055 + SC6->C6_NUM + "/" + SC6->C6_ITEM + STR0060	//"Pedido "###" não localizado na tabela SL2."
	EndIf

EndIf

(cAliasQRY)->(DbCloseArea())
RestArea( cArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LjMa500Chk

Se Loja e C6_RESERVA preenchido, além de MV_LJPVLIB = 2,
avisar o cliente que há uma reserva associada e se deseja
realmente eliminar resíduo.

@param Nil
@return lRet, lógico, Retorno da Confirmação do Cliente, se necessário

@author marisa.cruz
@since 02.07.2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function LjMa500Chk()

Local cLjPvLib	:= SuperGetMV("MV_LJPVLIB",,"1")
Local cArea 	:= GetArea()
Local aPed 		:= {}
Local cMsg 		:= ""
Local nX 		:= 0
Local cQuery 	:= ""
Local cQry		:= ""
Local lRet 		:= .T.

If cLjPvLib = "2"

	cQuery := "SELECT SC6.C6_NUM,SC6.C6_ITEM,SC6.C6_RESERVA,SC5.C5_ORCRES  FROM "
	cQuery += RetSqlName("SC6")+" SC6 "
	cQuery += "INNER JOIN " + RetSqlName("SC5")+ " SC5 "
	cQuery += "ON SC5.C5_NUM = SC6.C6_NUM "
	cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
	cQuery += "SC6.C6_OK = '" + ThisMark() + "' AND "
	cQuery += "SC6.C6_RESERVA<>' ' AND "
	cQuery += "SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
	cQuery += "SC5.C5_ORCRES<>' ' AND "
	cQuery += "SC6.D_E_L_E_T_<>'*' AND "
	cQuery += "SC5.D_E_L_E_T_<>'*'"

	cQuery := ChangeQuery(cQuery)
	cQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
	
	WHILE !(cQry)->(Eof())
		aAdd(aPed,C6_NUM+" Item "+C6_ITEM)
		(cQry)->(DbSkip())
	EndDo

	(cQry)->(dbCloseArea())

	If Len(aPed) > 0
		cMsg := ""
		For nX := 1 to Len(aPed)
			If nX > 1
				cMsg += ", "
			EndIf
			cMsg += aPed[nX]
		Next
		If !MsgYesNo(STR0062;									//"O(s) pedido(s) têm reservas associadas. Deseja eliminar resíduo assim mesmo ?"
					+chr(13)+chr(13)+STR0063 + cMsg,;			//"Pedido(s): "
					STR0061)									//"Atenção"
			lRet := .F.
		EndIf
	EndIf

EndIf
RestArea(cArea)

Return lRet
