#INCLUDE "PROTHEUS.CH"

#DEFINE MB_ICONASTERISK 64

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLMT100LO
Confirmar o item da NF. Entrada  
@return   Nil

@author   TOTVS
@since    30.04.2014
@version  P11
/*/
//-------------------------------------------------------------------
Function DCLMT100LO(lRec)
Local _aArea			:= GetArea()
Local _aAreaSF5		:= SF5->(GetArea())
Local _aAreaDH6		:= DH6->(GetArea())
Local _aAreaSD3		:= SD3->(GetArea())
Local aAreaDH4		:= DH4->(GetArea())
Local _lRet			:= .T.
Local nPosLocal		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_LOCAL"})
Local _nPosCod		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_COD"})
Local _nPosQtd		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_QUANT"})
Local _nPosCF			:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CF"})
Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local _nPosDel		:= Len(aHeader) + 1
Local _Mens			:= ""
Local _Mens1			:= ""
Local cMens2			:= ''

Default lRec 	:= .T.//verifica se foi chamada na recursividade

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

DH4->(DbSetOrder(1)) //DH4_FILIAL+DH4_DOC+DH4_SERIE+DH4_FORNEC+DH4_LOJA+DH4_ITEM
If DH4->(DbSeek(xFilial("DH4") + cNFiscal + cSerie + cA100For + cLoja + aCols[N,nPosItem]))
	If aCols[N,_nPosCod] == DH4->DH4_CODPRO
		If SD1->(Deleted())
			RecLock("DH4",.F.)
				DH4->(dbDelete())
			DH4->(MsUnLock())
		Else
			IF DH4->DH4_ATUTNQ == "S" .And. !(aCols[n,_nPosDel]) 
				IF EMPTY(DH4->DH4_TANQUE)
					_Mens += "-> Tanque Invalido"+CHR(10)
					_lRet := .F.
				ENDIF
				IF CTIPO<>"D" .AND. CTIPO<>"N"
					_Mens += "-> Somente Tipo de notas Normal e Devolucao deve atualizar tanque"+CHR(10)
					_lRet := .F.
				ENDIF
				
				IF DH4->DH4_DTENT <= GETMV("MV_ULMES")
					_Mens += "-> Data de Entrega Anterior a Fechamento de Estoque"+CHR(10)
					_lRet := .F.
				ENDIF
			
				IF ! (DH6->(msSeek(xFilial("DH6")+ DH4->DH4_TANQUE + aCols[N,_nPosCod])))
					_Mens += "-> Tanque Nao Cadastrado para este Produto" + CHR(10)
					_lRet := .F.
				ENDIF
			
				SF5->(DbSetOrder(2))	
				IF DH4->DH4_TDCARG <> "01" .AND. DH4->DH4_TDCARG <> "02"
					_Mens:= "-> Tipo descarga deve ser 01-Nota Acompanha Produto/02-Nota nao acompanha produto"+CHR(10)
					_lRet := .F.
				ELSE
					IF DH4->DH4_TDCARG == "01"
						IF ! (SF5->(msSeek(xFilial("SF5")+"DE"+"R"))) .OR. ! (SF5->(msSeek(xFilial("SF5")+"DE"+"D")))
							_Mens += "-> Movimentos para Ajustes de Descarga Nao Cadastrados "+CHR(10)
							_lRet := .F.
						ENDIF
						IF DH4->DH4_QTD20G <= 0
							_Mens += "Quantidade apurada 20 graus Nao informada"+CHR(10)
							_lRet := .F.
						ENDIF
						
						IF ALLTRIM(ALLTRIM(aCols[N,_nPosCF])) $ SuperGetMV('MV_DCLCFOR',.F.,"")
							
							D35->(DBSETORDER(2))
							IF ! D35->(DBSEEK(XFILIAL('D35')+ca100For+cLoja))
								_lRet := .F.
								_Mens+='Fornecedor nao encontrado no cadastro de cessionarias (D35) '+CHR(10)
							ELSE
								IF aCols[N,nPosLocal]<>D35->D35_LOCAL
									_lRet := .F.
									_Mens+='Armazem Invalido!!!  Armazem do Cessionario : '+D35->D35_LOCAL+ ' Armazem digitado: '+aCols[N,nPosLocal]+CHR(10)
								ENDIF
							ENDIF
						ENDIF
					ELSE
						
						IF DH4->DH4_QTD20G <= 0
							_Mens += "Quantidade apurada 20 graus Nao informada"+CHR(10)
							_lRet := .F.
						ENDIF
						
						IF ! (SF5->(msSeek(xFilial("SF5")+"PR"+"R"))) .OR. ! (SF5->(msSeek(xFilial("SF5")+"PR"+"D")))
							_Mens += "-> Movimentes para Estorno de Bombeio Nao Cadastrados "+CHR(10)
							_lRet := .F.
						ENDIF
						
						IF ! (SF5->(msSeek(xFilial("SF5")+"BO"+"R"))) .OR. ! (SF5->(msSeek(xFilial("SF5")+"BO"+"D")))
							_Mens += "-> Movimentes para Ajustes de Bombeio Nao Cadastrados "+CHR(10)
							_lRet := .F.
						ENDIF
						DBSELECTAREA("SD3")
						SD3->(DbSetOrder(16))	
						IF  ! SD3->(DbSeek(xFilial("SD3")+ DH4->DH4_DCPROV + "PR"+" "))
							_Mens1:=_Mens1+"Movimento provisorio com esta ORP nao encontrado "+CHR(10)
							_Mens1:=_Mens1+"Confirma geracao de perda de bombeio no total do item da nota fiscal"+CHR(10)
							IF MsgYesNo(_Mens1)
							ELSE
								_lRet := .F.
								_Mens += "Nota nao confirmada"
							ENDIF
						ELSE
							
							IF DH4->DH4_QTD20G <> SD3->D3_QUANT
								_Mens+='Quantidade da Nota nao pode ser diferente da Quantidade do movimento provisorio (SD3)  '+CHR(10)
								_lRet := .F.
							ENDIF
							
							
							IF ALLTRIM(aCols[N,_nPosCF]) $ SuperGetMV('MV_DCLCFOR',.F.,"")
								
								IF ! EMPTY(DH4->DH4_DCPROV)
									D35->(DBSETORDER(2))
									IF ! D35->(DBSEEK(XFILIAL('D35')+ca100For+cLoja))
										_lRet := .F.
										_Mens+='Fornecedor nao encontrado no cadastro de cessionarias (D35) '+CHR(10)
									ELSE
										IF Substr(DH4->DH4_DCPROV,5,2)<>D35->D35_LOCAL
											_lRet := .F.
											_Mens+='Armazem do cessionario: '+D35->D35_LOCAL+ ' Diferente da ORP: '+Substr(DH4->DH4_DCPROV,5,2)+CHR(10)
										ENDIF
									ENDIF
								ENDIF
							ENDIF
						ENDIF
						
						IF SD3->D3_COD <> aCols[N,_nPosCod]
							_Mens += "-> Produto invalido para esta ORP "+CHR(10)
							_lRet := .F.
						ENDIF
			
						IF SD3->D3_LOCAL <> aCols[N,nPosLocal]
							_Mens += "-> Local invalido para esta ORP!! o armazem deve ser igual ao final do nr. da Orp. "+CHR(10)
							_lRet := .F.
						ENDIF
						
					ENDIF
					SF5->(dbSetOrder(1))
				ENDIF
				IF ! _lRet
					MessageBox(_Mens,"Dados Incorretos",MB_ICONASTERISK)
				ENDIF
				
				IF _lRet
					_lRet:= DCLEA10MARG()
				Endif
				
			ENDIF
		EndIf
	Else
		cMens2 := 'Produto está divergente do complemento DCL ' + CHR(10)
		cMens2 += 'Item: ' + DH4->DH4_ITEM + CHR(10)
		cMens2 += 'Produto: ' + DH4->DH4_CODPRO + CHR(10)
		cMens2 += 'Deseja alterar o Produto do Complemento DCL?' + CHR(10)
		cMens2 += 'Obs.: os outros campos não serão alterados no Complemento DCL' + CHR(10)
		IF MsgYesNo(cMens2)
			RecLock("DH4",.F.)
				DH4->DH4_CODPRO := aCols[N,_nPosCod] 
			DH4->(MsUnLock())
			//Chama a função novamente para realizar as novas validações
			DCLMT100LO(.T.)
		ELSE
			_lRet := .F.
			Help(,,"DCLMT100LO",,'Mantenha o produto ' + DH4->DH4_CODPRO ,1,0,,,,,,{''})
		ENDIF
		
	EndIf
EndIf


If _lRet .And. !lRec
	
	// Nao Permite Volume de Entrada + Volume em estoque ser maior 
	//que o declarado no Campo: A5XVOLMAX - Tabela SA5.
	
	_lRet:= DCLEA10VMAX(GDFieldGet("D1_COD"),ca100For,cLoja,GDFieldGet("D1_LOCAL"),"1",aCols[N,_nPosQtd])
ENDIF

DH6->(RestArea(_aAreaDH6))
SF5->(RestArea(_aAreaSF5))
SD3->(RestArea(_aAreaSD3))
DH4->(RestArea(aAreaDH4))
RestArea(_aArea)
	
RETURN(_lRet)

