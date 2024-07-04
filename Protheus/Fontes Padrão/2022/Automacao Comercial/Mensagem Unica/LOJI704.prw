#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJI704.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.ch"
#INCLUDE "TOPCONN.CH"
 
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �IntegDef  �Autor  � Alan S. R. Oliveira  � Data �  07/03/18   ���
�������������������������������������������������������������������������������
��� Desc.    � Funcao de integracao com o adapter EAI para recebimento e    ���
���          � envio de informa��es de Reserva de Protdutos (ItemReserve)   ���
���          � utilizando o conceito de mensagem unica.                     ���
���������������������������������������������������������������������������͹��
��� Param.   � cXML - Variavel com conteudo xml para envio/recebimento.     ���
���          � nTypeTrans - Tipo de transacao. (Envio/Recebimento)          ���
���          � cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) ���
���������������������������������������������������������������������������͹��
��� Retorno  � aRet - Array contendo o resultado da execucao e a mensagem   ���
���          �        Xml de retorno.                                       ���
���          � aRet[1] - (boolean) Indica o resultado da execu��o da fun��o ���
���          � aRet[2] - (caracter) Mensagem Xml para envio                 ���
���������������������������������������������������������������������������͹��
��� Uso      � MATA430                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function LOJI704(xEnt,nTypeTrans,cTypeMessage,lJSon)

	Local lRet     	:= .T.
	Local cXMLRet  	:= ""
	Local cError	:= ""
	Local cWarning 	:= ""
	Local aRet		:= {}

	Private oXmlA704		:= Nil
	Private nCountA430		:= 0
	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile	:= .T.

	Default lJSon := .F.

	If lJSon
		//Desvio Objeto EAI
		Return LOJI704O(xEnt, nTypeTrans, cTypeMessage)
	EndIf	

	If nTypeTrans == TRANS_RECEIVE
		
		If cTypeMessage == EAI_MESSAGE_BUSINESS .OR. cTypeMessage == EAI_MESSAGE_RESPONSE
			oXmlA704 := XmlParser(xEnt, "_", @cError, @cWarning)
	
			If oXmlA704 <> Nil .And. Empty(cError) .And. Empty(cWarning)
				// Vers�o da mensagem
				If Type("oXmlA704:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXmlA704:_TOTVSMessage:_MessageInformation:_version:Text)
					cVersao := StrTokArr(oXmlA704:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := STR0008 //"Vers�o da mensagem n�o informada!"//@@
				EndIf
			Else
				lRet := .F.
				cXMLRet := STR0001 //"Falha ao manipular o XML"
			EndIf
			
			IF lRet
				If cVersao == "1"
					aRet := v1000(xEnt, nTypeTrans, cTypeMessage)
				Else
					lRet    := .F.
					cXmlRet := STR0005 //"A vers�o da mensagem informada n�o foi implementada!" //@@
				EndIf
			EndIf
	         
		ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
			aRet := v1000(xEnt, nTypeTrans, cTypeMessage, oXmlA704)
		EndIf
		
	ElseIf nTypeTrans == TRANS_SEND
		cXmlRet := "TRANS_SEND - NAO IMPLEMENTADO"
		lRet := .F.
	EndIf
	
	If lRet
		lRet    := aRet[1]
		cXMLRet := aRet[2]
	EndIf
	
	//Limpar os objetos ap�s � execu��o do adapter
	freeobj(oXmlA704)

Return {lRet,cXMLRet,"ITEMRESERVE"}

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
 Funcao de integracao com o adapter EAI para recebimento e envio de informa��es de Reserva de Produtos(SC0)
utilizando o conceito de mensagem unica. para Vers�o 1.000

@since 07/03/2018	
@version P12
@param	cTipoProd	- TYPE CHAR - tipo do produto selecionado
@return aDados		- ARRAY com os campos da tabela SX5, conforme 
					  sequ�ncia f�sica do DB
/*/
//-------------------------------------------------------------------
Static Function v1000( cXML, nTypeTrans, cTypeMessage )
	Local dReserve      := CTOD("  /  /  ")
	Local dReservevld   := CTOD("  /  /  ")
	Local cXMLRet		:= ""
	Local cMarca		:= ""
	Local cRequester    := ""
	Local cFilResp		:= ""
	Local cInternalId	:= ""
	Local cProd			:= ""
	Local cLocal 		:= ""
	Local cLote			:= ""
	Local cSubLote		:= ""
	Local cSerie		:= ""
	Local cLocaliz		:= ""
	Local cObs			:= ""
	Local cFilRes		:= ""
	Local aFilRes		:= ""
	Local cResult		:= ""
	Local cCompany		:= ""
	Local aCab			:= {}
	Local aItens		:= {}
	Local aItem			:= {}
	Local aItFil 		:= {} //Array com os Itens que ser�o processados pelo ExecAuto.
	Local AitIndex		:= {} //Array auxiliar para tratamento de indice.
	Local aResult 		:= {}
	Local aProd			:= {}
	Local nCount		:= 0
	Local nSC0Qtd		:= 0
	Local lRet			:= .T.
	
	Private nOpcx		:= 1//inclusao - 2//alteracao 3//exclusao
	Private lMsErroAuto := .F.
	Private aSaveSC0	:= SC0->(GetArea())
	Private aSave		:= GetArea()
	Private cTipo		:= ""
	Private cDocRes		:= ""
	
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			
			If lRet
				If Type("oXmlA704:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" .AND. !Empty(oXmlA704:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cMarca :=  oXmlA704:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				Else
					lRet    := .F.
					cXMLRet := STR0010//"Marca nao integrada ao Protheus, verificar a marca da integracao"
				EndIf
			Endif
			
			If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalID:Text") <> "U" .AND. !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalID:Text)
					cInternalId := oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalID:Text
			Endif
			
			If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyID:Text") <> "U" .AND. !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyID:Text)
				cCompany := oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyID:Text
			Endif
			
			SC0->( dbSetOrder( 1 ) )
			LjGrvLog("LOJI704","MONTAGEM CABE�ALHO","")
			IF lRet		
				If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveType:Text") <> "U" .AND. !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveType:Text)
					cTipo := PADR(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveType:Text, TamSX3("C0_TIPO")[1])
					
					If cTipo $ ("VD|CL|PD|LB|NF|LJ")
						Aadd( aCab, { "C0_TIPO",   cTipo,  Nil })
					Else
						lRet    := .F.
						cXMLRet := STR0012//"Tipo de Reserva n�o esta na Lista das Poss�veis: VD-Vendedor| CL-Cliente| PD-Pedido| LB-Libera��o |NF-Nota Fiscal| LJ-Loja"
					Endif
				Else
					lRet    := .F.
					cXMLRet := STR0011//"Tipo de Reserva n�o informado."				
				EndIf
			Endif
			
			If lRet
				If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentReserve:Text") <> "U" .AND. !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentReserve:Text)
					cDocRes := PADR( oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentReserve:Text, TamSX3("C0_DOCRES")[1])
					Aadd( aCab, { "C0_DOCRES", cDocRes , Nil })
				Else
					lRet    := .F.
					cXMLRet := STR0013//"Documento respons�vel pela reserva n�o informado."
				EndIf
			Endif
			
			If lRet
				If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Requester:Text") <> "U" .AND. !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Requester:Text)
					cRequester := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Requester:Text,TamSx3("C0_SOLICIT")[1])
					Aadd( aCab, { "C0_SOLICIT", cRequester , Nil })
				Else
					lRet    := .F.
					cXMLRet := STR0014//"Nome do Solicitante da Reserva n�o informado."
				EndIf
			Endif
			
			If lRet
				If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RequestBranch:Text") <> "U" .AND. !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RequestBranch:Text)
					
					cFilResp:= FWEAIEMPFIL( cCompany, oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RequestBranch:Text, cMarca )[2] 
					If !Empty(cFilResp) 
						Aadd( aCab, { "C0_FILRES", cFilResp , Nil })
					Else
						lRet    := .F.
						cXMLRet := STR0015 //"Filial Responsavel pela Reserva n�o existe no De/Para - Protheus."
					Endif
				Else
					lRet    := .F.
					cXMLRet := STR0015//"Filial respons�vel pela Reserva n�o informada."					
				EndIf
			Endif

			If lRet
				If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") <> "U" .And. !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
					If AllTrim(Upper(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "DELETE"
						cResult:= CFGA070Int(cMarca, "SC0", "C0_DOCRES", cInternalId)
						If Empty(cResult)
							lRet    := .F.
							cXMLRet := STR0021 //#"Evento incorreto, para exclusao � necess�rio informar o ID de uma reserva j� processada pelo Protheus."
						Else
							nOpcx   := 3
							aResult := Separa(cResult, "|")													
							If !ValType(aResult) == "A" .And. Len(aResult) > 0
								lRet    := .F.
								cXMLRet := STR0022 //#"ID da Reserv�o n�o localizado na tabela De/Para"
							Endif
						Endif 
					Elseif AllTrim(Upper(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "UPSERT"
						cResult:= CFGA070Int(cMarca, "SC0", "C0_DOCRES", cInternalId)
						LjGrvLog(Nil, "Retorno da fun��o CFGA070Int (DE/PARA) C0_DOCRES", cResult)
						aResult := Separa(cResult, "|")													
						If ValType(aResult) == "A" .And. Len(aResult) > 0 
							nOpcx := 2 //Update
						Else	
							nOpcx := 1 //Inclus�o
						Endif
						LjGrvLog(Nil, "Conteudo da variavel nOpcx (Legenda: 1=Inclusao; 2=Alteracao; 3=Exclusao)", nOpcx)
					Else
						lRet    := .F.
						cXMLRet := STR0023 //#"Evento Informado incorreto, apenas as Op��es de Upsert ou Delete est�o dispon�veis."
					EndIf
				Else
					lRet    := .F.
					cXMLRet := STR0024 //#"Evento nao informado!"
				EndIf
			EndIf
			
			If lRet
					
				If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item") <> "U"
						
					If ValType(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item) <> "A"
						XmlNode2Arr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item, "_Item")
					EndIf
				
					If Len(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item) < 1
						lRet    := .F.
						cXMLRet := STR0016//"N�o foram informados Itens para Reserva."
					Endif
					
					If lRet
						For nCount:= 1 To Len(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item)
							LjGrvLog("LOJI704","MONTAGEM ITENS","")
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_ItemInternalId:Text") <> "U"
		
								aProd := IntProInt(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ItemInternalId:Text, cMarca)
							
								If aProd[1]
									If Len(aProd[2]) > 1
										cProd := Padr(aProd[2][3], TamSx3("C0_PRODUTO")[1])
									Else
										lRet    := .F.
										cXMLRet := STR0025 + Alltrim(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ItemInternalId:Text) +STR0026+; //"Produto: " " n�o configurado"
										           STR0027 //"corretamento no cadastro De / Para. - XXF_INTVAL - Empresa | Filial | Codigo produto"
									Endif  	
								Else
									If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_ItemCode:Text") <> "U" 
										cProd := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ItemCode:Text, TamSx3("C0_PRODUTO")[1])
										DbSelectArea("SB1")
										SB1->(dBSetOrder(1))
										If !SB1->(dBSeek(XfILIAL("SB1")+cProd))
											cProd := ""
										Endif
									Endif
								Endif
							EndIf
							
							If !Empty(cProd)
								Aadd(aItem, {"C0_PRODUTO", cProd, Nil }) 
							Else
								lRet    := .F.
								cXMLRet := STR0017//"O produto n�o informado, ou c�digo n�o foi integrado."
								Exit
							Endif
							
							If lRet					
								If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_WarehouseInternalId:Text") <> "U"
									cLocal := ""
									If Empty(cLocal)
										If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_WarehouseCode:Text") <> "U"
											cLocal := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_WareHouseCode:Text,TamSx3("C0_LOCAL")[1])
										Endif
									Endif
								 	
								 	If !Empty(cLocal)   
										Aadd(aItem, {"C0_LOCAL", cLocal, Nil } )
									Else
									
										//Verifica o Armazem Padr�o do Produto, levando em considera��o
										//a configura��o do Indicador de Produtos (SBZ) - parametro MV_ARQPROD.
										cLocal	:=	RetFldProd(SB1->B1_COD,"B1_LOCPAD")
														
										Aadd(aItem, {"C0_LOCAL", cLocal, Nil } )
									Endif
								EndIf
							Endif
							
							If lRet
								If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_Quantity") <> "U"
									nSC0Qtd := Val(StrTran(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_Quantity:Text,",",".") )
									
									If nSC0Qtd > 0 
										Aadd(aItem, {"C0_QUANT", nSC0Qtd   ,  Nil })
									Else
										lRet    := .F.
										cXMLRet := STR0019//"Quantidade informada para Reserva precisa ser maior que Zero."
										Exit
									Endif
								Else
									lRet    := .F.
									cXMLRet := STR0020//"A TAG Quantity n�o foi informada e ela � obrigat�ria.
									Exit
								EndIf
								
									//Verifica se Existe Saldo Inicial do Produto, caso n�o tenha n�o poder� ser feita a Reserva
									DbSelectArea("SB2")
									SB2->(DbSetOrder(1))
									If !(SB2->(DbSeek(xFilial("SB2")+cProd+cLocal)))
										lRet := .F.
										cXMLRet := STR0029 +cProd+ STR0030 +cLocal+ STR0031 //"N�o existe Saldo Inicial para o produto:" " no armaz�m " " necess�rio cadastrar pela rotina de Saldo Inicial"
										Exit
									Endif								
							Endif
							
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_ReserveExpiration") <> "U"
								dReservevld := CTOD(SubStr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ReserveExpiration:Text, 9, 2 ) + '/'+;
											   		SubStr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ReserveExpiration:Text, 6, 2 ) + '/'+;
											   		SubStr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ReserveExpiration:Text, 1, 4 ) )
							Else	
								dReservevld := dDataBase
							EndIf
							
							Aadd(aItem, {"C0_VALIDA", dReservevld   ,  Nil })
							
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_IssueDateReserve") <> "U"
								dReserve := CTOD(SubStr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_IssueDateReserve:Text, 9, 2 ) + '/'+;
											   	 SubStr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_IssueDateReserve:Text, 6, 2 ) + '/'+;
											   	 SubStr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_IssueDateReserve:Text, 1, 4 ) )
							Else
								dReserve := dDataBase
							EndIf
							
							Aadd(aItem, {"C0_EMISSAO", dReserve   ,  Nil })
							
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_LotNumber") <> "U"
								cLote := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_LotNumber:Text,TamSx3("C0_LOTECTL")[1])
							Else
								cLote := ""
							EndIf
							
							Aadd(aItem, {"C0_LOTECTL", cLote   ,  Nil })
		
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_SubLotNumber") <> "U"
								cSubLote := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_SubLotNumber:Text,TamSx3("C0_NUMLOTE")[1])
							Else
								cSubLote := ""
							EndIf
							
							Aadd(aItem, {"C0_NUMLOTE", cSubLote   ,  Nil })
							
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_SeriesItem") <> "U"
								cSerie := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_SeriesItem:Text,TamSx3("C0_NUMSERI")[1])
							Else
								cSerie := ""
							EndIf
							
							Aadd(aItem, {"C0_NUMSERI", cSerie   ,  Nil })
							
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_AddressingItem") <> "U"
								cLocaliz := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_AddressingItem:Text,TamSx3("C0_LOCALIZ")[1])
							Else
								cLocaliz := ""
							EndIf
							
							Aadd(aItem, {"C0_LOCALIZ", cLocaliz   ,  Nil })
							
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_NoteReserveItem") <> "U"
								cObs := Padr(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_NoteReserveItem:Text,TamSx3("C0_OBS")[1])
							Else
								cObs := ""
							EndIf
		
							Aadd(aItem, {"C0_OBS", cObs   ,  Nil })
							
							If Type("oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item["+Str(nCount)+"]:_ReserveBranch") <> "U" .AND.;
							   !Empty(oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ReserveBranch:Text)
							   
							   	aFilRes:= FWEAIEMPFIL( cCompany, oXmlA704:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReserveItemType:_Item[nCount]:_ReserveBranch:Text, cMarca )
							   	If Len(aFilRes) > 1 .AND. !Empty(aFilRes[2])
							   	 	cFilRes := aFilRes[2]
									Aadd( aItem, { "C0_FILIAL", cFilRes , Nil })
									
								Else
									lRet    := .F.
									cXMLRet := STR0032 //"Filial onde ser� Reservado o Produto n�o existe no De/Para - Protheus."
								Endif
							Else
									lRet    := .F.
									cXMLRet := STR0033 //"A TAG ReserveBranch n�o foi informada e ela � obrigat�ria."
									Exit
							EndIf

							aAdd(aItens,aItem )
							
							If AScan( AitIndex,{|x| x[1] == cFilRes+cProd} ) == 0 
								
								aadd(AitIndex, {cFilRes+cProd,;
												cProd+cLote+cSubLote+cSerie+cLocaliz} )
								
								If Len(aItFil) == 0	.OR. AScan( aItFil,{|x| x[1] == cFilRes } ) == 0			
									aadd(aItFil,{cFilRes, aItens } )
								Else
									aadd(aItFil[AScan( aItFil,{|x| x[1] == cFilRes } )][2],aClone(aItens[1])) 
								Endif
								
							Else
								If AScan( AitIndex,{|x| x[2] == cProd+cLote+cSubLote+cSerie+cLocaliz} ) == 0
									//Como estamos utilizando um array multi-dimensional para facilitar no desmembramento
									//das filiais, nos casos onde fa�o uma adi��o no segundo n�vel do array preciso
									//efetuar um clone para reduzir um n�vel, sen�o ao incluir no Array de Itens da
									//Filial � criada uma nova dimens�o.
									//aadd(aItFil[AScan( aItFil,{|x| x[1] == cFilRes } )][2][Len(aItFil[AScan( aItFil,{|x| x[1] == cFilRes } )][2][2])+1],Aclone(aItens[1]) )
									aadd(AitIndex, {cFilRes+cProd,;
												cProd+cLote+cSubLote+cSerie+cLocaliz} )
												
									aadd(aItFil[AScan( aItFil,{|x| x[1] == cFilRes } )],aItens) 
									
								Else
									lRet    := .F.
									cXMLRet := STR0034 //"N�o � poss�vel reservar o mesmo produto mais de 1 vez."
									Exit
								Endif
							Endif
						
							aItem 		:= {}
							aItens		:= {}
							cProd		:= ""
							cLocal 		:= ""
							dReserve    := CTOD("  /  /  ")
							dReservevld := CTOD("  /  /  ")
							cLote		:= ""
							cSubLote	:= ""
							cSerie		:= ""
							cLocaliz	:= ""
							cObs		:= ""
							cFilRes		:= ""
							aFilRes     := {}
						Next nCount
					Endif
				Endif
			Endif
			
			
			If lRet
				lRet := EAI704RES(aCab,aITfil,aResult,@cXMLRet,cInternalId,cDocRes,cMarca)
			Endif
			
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			cXmlRet := "EAI_MESSAGE_RESPONSE - NAO IMPLEMENTADO"

		//WhoIs Message
		ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.000'
		EndIf
	EndIf
	
	RestArea(aSaveSC0)
	RestArea(aSave)
Return {lRet, cXMLRet, "ITEMRESERVE"}


//-------------------------------------------------------------------
/*/{Protheus.doc} ReserEai
 Funcao de retorno dos n�meros de Reservas Gerados ap�s a Integracao
@since 13/03/2018	
@version P12
@param	cTipoProd	- TYPE CHAR - tipo do produto selecionado
@return aDados		- ARRAY com os campos da tabela SX5, conforme 
					  sequ�ncia f�sica do DB
/*/
//-------------------------------------------------------------------

Function ReserEai(cEmp, cFil,cReser)

Local aRet 	 := {}
Local cWhere := ""
Local cAliasTmp 	:= GetNextAlias() //Alias temporario

//Condicional para a query		
cWhere := "%"
cWhere += " C0_FILIAL      = '" + cFil + "'"
cWhere += " AND C0_DOCRES  = '" + cReser + "'"
cWhere += " AND D_E_L_E_T_ = ' '"
cWhere += "%"
		
//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		C0_FILIAL, C0_NUM, COUNT(C0_NUM) QTDITEM
	FROM %table:SC0% (NOLOCK)
		WHERE %exp:cWhere%
	GROUP BY
		C0_FILIAL, C0_NUM
EndSql
		
(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario

Do While !(cAliasTmp)->(Eof())
	aAdd(aRet,{	(cAliasTmp)->C0_FILIAL,;
				(cAliasTmp)->C0_NUM,;
				(cAliasTmp)->QTDITEM} )
	(cAliasTmp)->(dbSkip()) 
Enddo

If Empty(aRet)
	aAdd(aRet,{	"",;
				"",;
				0} )
Endif
Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} VerifItem
 Funcao de retorno a Incid�ncia ou n�o do Item na Reserva
@since 13/03/2018	
@version P12
@param	cTipoProd	- TYPE CHAR - tipo do produto selecionado
@return aDados		- ARRAY com os campos da tabela SX5, conforme 
					  sequ�ncia f�sica do DB
/*/
//-------------------------------------------------------------------

Function VerifItem(cEmp, cFil,cReser,cProd,cLote,cSubLote,cSerie,cLocali)

Local lRet 	 	:= .F.
Local cWhere 	:= ""
Local cAliasTmp := GetNextAlias() //Alias temporario

//Condicional para a query		
cWhere := "%"
cWhere += "     C0_FILRES  = '" + cFil 	 + "' "
cWhere += " AND C0_DOCRES  = '" + cReser + "' "
cWhere += " AND C0_PRODUTO = '" + cProd  +"' "
cWhere += " AND C0_LOTECTL = '" +cLote	 +"' "
cWhere += " AND C0_NUMLOTE = '" +cSubLote+"' "
cWhere += " AND C0_LOCALIZ = '" +cLocali +"' "
cWhere += " AND C0_NUMSERI = '" +cSerie	 +"' "
cWhere += " AND D_E_L_E_T_ = ' '"
cWhere += "%"
		
//Executa a query
BeginSql alias cAliasTmp
	SELECT DISTINCT  
		C0_FILIAL, C0_NUM
	FROM %table:SC0%
		WHERE %exp:cWhere%
EndSql
		
(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario
Do While !(cAliasTmp)->(Eof())
	lRet := .T. 
	(cAliasTmp)->(DbSkip())
Enddo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EAI704RES
 
/*/
//-------------------------------------------------------------------
Function EAI704RES( aCab		, aITfil , aResult, cXMLRet     ,;
 					cInternalId	, cDocRes, cMarca , cDestination,;
					aProdRet    , lApi   )

    Local lRet			:= .T.
    Local nCount		:= 0
    Local nX			:= 0
    Local lDeleta 		:= IIF(nOpcx == 3, .T., .F.)
    Local aCabexc		:= {}
    Local cReserve		:= ""
    Local cFilBack      := cFilAnt

    Private lMsErroAuto := .F.

    Default cMarca 		 := ""
    Default cDestination := ""
    Default aProdRet	 := {}
    Default lApi         := .F.

    Begin Transaction
        
        //Efetua a exclus�o de todos os itens antes de continuar o processo
        If nOpcx <> 1
            LjGrvLog("LOJI704", "EFETUA EXCLUSAO DAS RESERVAS - RESERVA RESP: " + cDocRes)
            Lj704Delet(cDocRes, @cXMLRet)
        Endif
        
        //Se n�o for exclus�o incluir novamente as reservas
        If !lDeleta

            LjGrvLog("LOJI704", "INICIA PROCESSAMENTO DAS RESERVAS" + cDocRes)

            For nX:=1 To Len(aITfil)

                For nCount := 2 To Len(aITfil[nX])

                    aItens   := AClone(aITfil[nX][nCount])
                    cFilAnt	 := aITfil[nX][1]
                    aCabexc  := aClone(aCab)
                
                    cReserve := LOJA704(aCabexc, aItens, 1, @cXMLRet, @aProdRet)

                    If Empty(cReserve)
                        lRet := .F.
                        Exit
                    Endif
                Next nCount

                If !lRet
                    Exit
                EndIf
            Next nX
        EndIf

        If !lRet
            DisarmTransaction()

        ElseIf !lApi

            cDestination := cEmpAnt + "|" + xFilial('SC0') + "|" + cDocRes +"|"+ cTipo

            If nOpcx <> 2
                CFGA070Mnt(	cMarca      ,;
                            'SC0'       ,;
                            'C0_DOCRES' ,;
                            cInternalId ,;
                            cDestination,;
                            lDeleta     )
            Endif
        EndIf

    End Transaction

    If !lRet

        If Empty(cXMLRet)
            cXMLRet := "Erro na gera��o da reserva. (EAI704RES)"
        EndIf

    ElseIf !lApi

        //Monta xml com status do processamento da rotina automatica OK
        cXMLRet := "<ListOfInternalId>"
        cXMLRet +=    "<InternalId>"
        cXMLRet +=       "<Name>ItemReserveInternalId</Name>"
        cXMLRet +=       "<Origin>"+cInternalId+ "</Origin>"
        cXMLRet +=       "<Destination>"+ cDestination +"</Destination>"
        cXMLRet +=    "</InternalId>"
        cXMLRet += "</ListOfInternalId>"
    EndIf

    cFilAnt := cFilBack

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ReserItEai
 Funcao de retorno das Reservas por produto gerados ap�s a Integracao
@since 05/04/2018	
@version P12
@param	cFil	 - Filial da reserva
@param	cReserv	 - Documento da reserva
@param	cProduto - Codigo do produto reservado
@return aRet	 - Filial, c�digo e quantidade da reserva 					  
/*/
//-------------------------------------------------------------------
Function ReserItEai(cFil, cReser, cProduto, cLote, cSubLote, cLocaliz, cNumseri, nQtde, cNumRes, lQuant)

Local aRet 	 	:= {}
Local aSum      := {}
Local cWhere 	:= ""
Local cAliasTmp := GetNextAlias() //Alias temporario
Local cSGBD		:= AllTrim(Upper(TcGetDb()))
Local nX		:= 0
Local oTab2Array := Nil

Default cReser   := ""
Default cProduto := ""
Default cLote	 := ""
Default cSubLote := ""
Default cLocaliz := ""
Default cNumseri := ""
Default nQtde	 := 0
Default cNumRes	 := "" // -- Deve conter C0_Filial + '|' + C0_NUM
Default lQuant   := .T.


//Condicional para a query		
cWhere := "%"	
cWhere += " C0_DOCRES 	   = '" + cReser   + "'"
cWhere += " AND C0_PRODUTO = '" + cProduto + "'"
If !Empty(cLote)
	cWhere += " AND C0_LOTECTL = '" + cLote    + "'"
EndIf
If !Empty(cSubLote)
	cWhere += " AND C0_NUMLOTE = '" + cSubLote + "'"
EndIf
If !Empty(cLocaliz)
	cWhere += " AND C0_LOCALIZ = '" + cLocaliz + "'"
EndIf    
If !Empty(cNumseri)
	cWhere += " AND C0_NUMSERI = '" + cNumseri + "'"
EndIf

If nQtde > 0 .AND. lQuant
	cWhere += " AND C0_QTDORIG = " + cValToChar(nQtde)

	If !Empty(cNumRes)
		If AllTrim(SubStr(cNumRes,Len(cNumRes),1)) == ','
			cNumRes := SubStr(cNumRes,1,Len(cNumRes) - 1)
		EndIf
		
		If cSGBD 		$ "MSSQL"
			cWhere += " AND CONCAT(C0_FILIAL, '|', C0_NUM) NOT IN (" + cNumRes + ")"
		Else
			cWhere += " AND C0_FILIAL || '|' || C0_NUM NOT IN (" + cNumRes + ")"
		EndIf 
	EndIf
EndIf

If ValType(cFil) <> "U" .AND. Empty(cNumRes)
	cWhere += " AND C0_FILIAL = '" + cFil + "'"
EndIf

cWhere += " AND D_E_L_E_T_ = ' '"
cWhere += "%"
		
//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		C0_FILIAL, C0_NUM, C0_QTDORIG, C0_LOCAL, C0_LOTECTL, C0_NUMLOTE, C0_LOCALIZ, C0_NUMSERI, C0_FILRES
	FROM %table:SC0%
		WHERE %exp:cWhere%
EndSql

If FINDCLASS( "Table2Array" )
    oTab2Array :=  Table2Array():New(cAliasTmp)

    aSum := oTab2Array:SumUp("C0_QTDORIG" ,nQtde) 

    If Len(aSum) > 0
        For nX := 1 to Len(aSum)
            aAdd(aRet, Aclone(aSum[nX]))
        Next nX
    EndIF
EndIF

If Len(aSum) == 0
    aAdd(aRet,{	""  ,;
                ""  ,;
                0   ,;
                ""  ,;
                ""  } )
Endif

//Fecha arquivo temporario
(cAliasTmp)->( dbCloseArea() )

Return aRet

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
��� 	      � Lj704Delet � Autor � Alan Oliveira      � Data �  08/03/18   ���
����������������������������������������������������������������������������͹��
��� Descricao � Deleta Todas as Reservas vinculadas ao Documento Resposavel. ���
���           � Param.: nPos1 - Numero do Documento Responsavel pela Reserva ���
���           �         nPos2 - xml de Retorno para o EAI                    ���
���           �         nPos3 - Filial onde efetuou a Reserva                 ��
����������������������������������������������������������������������������͹��
��� Uso       � LOJA704                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function Lj704Delet(cDocRes, cXMLRet, cFilres)

    Local aArea     := GetArea()
    Local cWhere 	:= ""
    Local aItem  	:= {}
    Local aReservas := {}
    Local aCliente  := {}
    Local cAliasTmp := GetNextAlias()
    Local cRet		:= ""
    Local aXXF      := {"","",.F.}      //Chave para exclus�o da Tabela XXF 1 - Valor Externo
                                        // 								    2 - Valor Interno
                                        //								    3 - Exclus�o Realizada .F. OU .T. 
    Local cFilBkp   := cFilAnt
    Local nOpcxBkp  := nOpcx

    Default cDocRes := ""
    Default cXMLRet	:= ""
    Default cFilres := ""

    //Condicional para a query		
    cWhere := "%"	
    cWhere += " C0_DOCRES 	   = '" + cDocRes  + "'"
    cWhere += " AND D_E_L_E_T_ = ' '"
    cWhere += "%"
                
    //Executa a query
    BeginSql alias cAliasTmp
        SELECT 
            C0_DOCRES , C0_SOLICIT,C0_FILRES,C0_NUM,C0_PRODUTO,
            C0_QUANT,C0_LOCAL,C0_NUMLOTE,C0_LOTECTL,C0_LOCALIZ,
            C0_NUMSERI,C0_FILIAL,C0_VALIDA
        FROM %table:SC0% 
            WHERE %exp:cWhere%
    EndSql
            
    Do While !(cAliasTmp)->( Eof() )

        aItem  	  := {}
        aReservas := {}
        aCliente  := {}
        nOpcx     := 3                      //Variavel private utilizada dentro da fun��o Lj7GeraSC0 quando � integra��o
        dDtLimite := StoD( (cAliasTmp)->C0_VALIDA )
        
        Aadd(aCliente,{"EAILOJA704"	,.T.				 	 , Nil })
        Aadd(aCliente,{"C0_DOCRES" 	, (cAliasTmp)->C0_DOCRES , Nil })
        Aadd(aCliente,{"C0_SOLICIT"	, (cAliasTmp)->C0_SOLICIT, Nil })
        Aadd(aCliente,{"C0_FILRES"	, (cAliasTmp)->C0_FILRES , Nil })
        Aadd(aCliente,{"C0_NUM"		, (cAliasTmp)->C0_NUM	 , Nil })
        
        Aadd(aItem , "01")	  		                    //N�MERO DO ITEM
        Aadd(aItem , (cAliasTmp)->C0_PRODUTO)	        //C�DIGO DO PRODUTO
        Aadd(aItem , (cAliasTmp)->C0_QUANT)	            //QUANTIDADE
        Aadd(aItem , {   { (cAliasTmp)->C0_LOCAL ,;	    //LOCAL
                          0 }                   } )	    //QUANTIDADE EM ESTOQUE
        Aadd(aItem , (cAliasTmp)->C0_LOCAL)	            //LOCAL ONDE SERA FEITA A RESERVA
        Aadd(aItem , {   (cAliasTmp)->C0_NUMLOTE ,;     //SUBLOTE
                         (cAliasTmp)->C0_LOTECTL ,;     //LOTE
                         (cAliasTmp)->C0_LOCALIZ ,;     //ENDERECO
                         (cAliasTmp)->C0_NUMSERI } )    //SERIE

        Aadd(aReservas, aItem)
        
        LjGrvLog("Lj7GeraSC0", "Excluindo Reserva Integra��o", (cAliasTmp)->C0_NUM)

        cRet := Lj7GeraSC0(aReservas, dDtLimite , aCliente, cFilAnt, .F., .F., , @cXMLRet)

        LjGrvLog("Lj7GeraSC0", "Excluindo Reserva Integra��o - Retorno", cRet + " - " + cXMLRet)

        aXXF[1]  := (cAliasTmp)->C0_DOCRES
        aXXF[2]	 := cEmpAnt +"|"+ (cAliasTmp)->C0_FILRES +"|"+ (cAliasTmp)->C0_DOCRES + "|" + "LJ"

        (cAliasTmp)->( DbSkip() )
    EndDo
    (cAliasTmp)->( DbCloseArea() )

    If Empty(cXMLRet) .AND. Empty(cRet)
        aXXF[3] := .T.
    Endif

    FwFreeObj(aItem)
    FwFreeObj(aReservas)
    FwFreeObj(aCliente)

    cFilAnt := cFilBkp 
    nOpcx   := nOpcxBkp

    RestArea(aArea)

Return aXXF

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
��� 	      � LJ704ESTR � Autor � Alan Oliveira      � Data �  08/03/18   ���
����������������������������������������������������������������������������͹��
��� Descricao � Estorna as quantidades da Reservas Vinculadas ao pedido      ���
���           � para seguir o fluxo do  Faturamento.                         ���
����������������������������������������������������������������������������͹��
��� Uso       � LOJI704                                                ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function LJ704ESTR(aReserv,nOpcx,cDocRes,cFilres,cMarca)

Local nX	 := 0
Local aRet   := {}

Default aReserv := {}
Default nOpcx   := 3
Default cDocRes := ""
Default cFilres := ""

LjGrvLog("LJ704ESTR","Localizando Reserva, para Estorno")
//NOS CASOS DA RESERVA SER UTILIZADA PELO FATURAMENTO
//� NECESS�RIO DEIXAR A RESERVA SEM BAIXA. LEMBRANDO
//QUE � REALIZADA UMA RESERVA POR ITEM.
For nX:= 1 To Len(aReserv)
		DbSelectArea("SC0")
		SC0->(DbSetOrder(1))// C0_FILIAL+C0_NUM+C0_PRODUTO
		If SC0->(DbSeek(aReserv[nX][1]+aReserv[nX][2]))
			LjGrvLog("LJ704ESTR","Estornando reserva: "+SC0->C0_NUM)
		    SC0->( RecLock("SC0",.F.)  )    
			    	SC0->C0_QUANT   := SC0->C0_QTDORIG
					SC0->C0_QTDPED  := 0		
			SC0->(MsUnlock())
		Endif
Next nx

//EXCLUSAO DA RESERVA
If nOpcx == 5 .AND. !Empty(cDocRes)
	If ( FindFunction("Lj704Delet") )
		LjGrvLog("LJ704ESTR","Chamando fun��o de Exclus�o de Lj704Delet")
		aRet:= Lj704Delet(cDocRes,,cFilres)
		If aRet[3]
			LjGrvLog("LJ704ESTR","Reservas exclu�das, excluindo De/Para")
		  // Exclui o registro na tabela XXF (de/para)
		  CFGA070Mnt(cMarca, "SC0", "C0_DOCRES", aRet[1], aRet[2],.T.)
	    endif
	Endif
Endif 

Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
��� 	      � LJ704LRES � Autor � Alan Oliveira      � Data �  08/03/18   ���
����������������������������������������������������������������������������͹��
��� Descricao � Localiza N�mero do Documento respons�vel de uma reserva      ���
���           � valida.                                                      ���
����������������������������������������������������������������������������͹��
��� Uso       � LOJI704                                                ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function LJ704LRES(cFilres,cNumPed,cDocRes)

Local cAliasTmp := GetNextAlias()   //Alias temporario
Local cWhere    := ""

Default cNumPed := ""
Default cDocRes := ""

//O N�MERO DO DOCUMENTO RESPONS�VEL � UM PARA V�RIAS RESERVAS, 
//POR ISSO FA�O A PESQUISA EM APENAS UM ITEM.
cWhere := "%"
cWhere += "	C6_FILIAL 	  = '"+cFilres+"'"
cWhere += "AND C6_NUM     = '"+cNumPed+"'"
cWhere += "AND C6_RESERVA <> ' ' "
cWhere += "AND D_E_L_E_T_  = ' ' "
cWhere += "%"
//Executa a query
BeginSql alias cAliasTmp
	SELECT  
		C6_RESERVA
	FROM %table:SC6% 
		WHERE %exp:cWhere%
EndSql
			
(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario
//COMO ESTAMOS EFETUANDO A BUSCA PELOS REGISTROS DELETADOS
//VERIFICO A PRIMEIRA RESERVA VALIDA PARA PEGAR O N[UMERO DO 
//DOCUMENTO RESPONSAVEL.
If !(cAliasTmp)->(Eof())
	While !(cAliasTmp)->(Eof())
		DbSelectArea("SC0")
		SC0->(DbSetOrder(1))
		If(SC0->(DbSeek(cFilres+(cAliasTmp)->C6_RESERVA)))
			cDocRes := SC0->C0_DOCRES
			Exit
		Else
			LjGrvLog("LJ704LRES","N�o foi Localizada a reserva:"+cFilres+(cAliasTmp)->C6_RESERVA+" no Controle de Reservas")
			Return
		Endif
		(cAliasTmp)->(DbSkip())			
	Enddo
Else
	LjGrvLog("LJ704LRES","N�o foi localizado nenhuma reserva para o Pedido:"+cFilres+cNumPed)
Endif

Return
