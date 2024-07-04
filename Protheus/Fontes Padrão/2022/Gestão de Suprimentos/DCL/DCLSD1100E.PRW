#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSD1100E
Ponto de entrada exclusao de nota fiscal , estorna mov.int.
DE , gerado na inclusao da nota fiscal
Adaptação da função Sd1100E
@author jose.eulalio
@return Nil
@since 09/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSD1100E()
Local aArea 		:= GetArea()
Local aAreaSF5 	:= SF5->(GetArea())
Local aAreaSB1 	:= SB1->(GetArea())
Local aAreaDH4 	:= DH4->(GetArea())
Local aAreaDH5 	:= DH5->(GetArea())
Local cTipo         := "BO"
Private lMsErroAuto :=.F.

SetPrvt("CMSDALIAS,NMSDINDEX,NMSDRECNO,_LENTROU,_LFEZ,_QUANT")
SetPrvt("_TM,_EMISSAO,_COD,_UM,_TANQUE,_CF")
SetPrvt("_CLIENTE,_LOJA,_LOCAL,_NREDUZ,_DOC,_GRUPO")
SetPrvt("_CUSTO1,_NUMSEQ,_SEGUM,_QTSEGUM,_TIPO,_ESTORNO")
SetPrvt("_CHAVE,_DIF,_MENS,_DIFER,I,CTES")
SetPrvt("NQUANT,_CNUMFA,")

If SuperGetMv("MV_DCLNEW",.F.,.F.) 
	
	DbSelectArea("DH4")//Itens Documento de Entrada DCL
	DH4->(DbSetOrder(1))//DH4_FILIAL+DH4_DOC+DH4_SERIE+DH4_FORNEC+DH4_LOJA+DH4_ITEM
	
	If DH4->(DbSeek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM))) .And. DH4->DH4_ATUTNQ == 'S'
		
		DbSelectArea("DH5")//Complemento de produto DCL
		DH5->(DbSetOrder(1))//DH5_FILIAL+DH5_COD+DH5_CODSIM
		
		If DH5->(DbSeek(xFilial("DH5") + SD1->D1_COD))
			If	(SF1->F1_TIPO == "N" .OR. SF1->F1_TIPO == "D") .AND.;	//SO NOTAS DEVOLUCAO E NORMAL
			! Empty(DH4->DH4_DTENT) .AND. ;                          	//SO DATA ENTREGA PREENCHIDA
			DH5->DH5_PREQUI <> "S" .AND.;                           	//SO PRODUTOS APROPRIACAO DIRETA PRODUTO ACABADO
			! Empty(DH4->DH4_TANQ)                                   	//SO TANQUE PREENCHIDO
				
				DbSelectArea("DH9")
				DH9->(DbSetOrder(1))
				
				IF DH9->(DbSeek(DH4->DH4_FILIAL + Substr(DH4->DH4_DCPROV,1,4)))
					cTipo := DH9->DH9_TIPO
				ENDIF
				
				If  DH4->DH4_TDCARG =="02"   //NOTA NAO ACOMPANHA PRODUTO
					
					If (DH4->DH4_QTD20G - SD1->D1_QUANT) <> 0
						
						_QUANT := DH4->DH4_QTD20G - SD1->D1_QUANT
						
						DbSelectArea("SF5")
						SF5->(DbSetOrder(2))//F5_FILIAL+F5_MOVTANQ+F5_TIPO
						SF5->(DbSeek(xFilial("SF5") + Iif(Trim(SF1->F1_BOMDES)=="NFEB",cTipo,"DE") + "D"))
						
						_TMD:=SF5->F5_CODIGO
						SF5->(DbSeek(xFilial("SF5") + Iif(Trim(SF1->F1_BOMDES)=="NFEB",cTipo,"DE") + "R"))
						
						_TMR:=SF5->F5_CODIGO
						
						SF5->(dbSetOrder(1))//F5_FILIAL+F5_CODIGO
						
						lMsErroAuto:=.F.
						
						dbSelectArea("SD3")
						SD3->(DbSetOrder(17))//D3_FILIAL+D3_NFORP+D3_TPMOVAJ+D3_ESTORNO+DTOS(D3_EMISSAO)+D3_COD+D3_LOCAL+D3_TANQUE
						
						If SD3->(DbSeek(XFILIAL("SD3") + DH4->DH4_DCPROV + Iif(Trim(SF1->F1_BOMDES) == "NFEB",cTipo,"DE") + " "))
							
							_NUMSEQ:=SD3->D3_NUMSEQ
							lMsErroAuto:=.F.
	
							aVetor := {{"D3_NUMSEQ",SD3->D3_NUMSEQ,NIL},;
										{"D3_CHAVE",SD3->D3_CHAVE,NIL},;
										{"D3_COD",SD3->D3_COD,NIL},;
										{"INDEX",4,NIL}}  // {"INDEX",Ordem,NIL}
	
							MSExecAuto({|x,y| mata240(x,y)},aVetor,5) //Estorno 
	
							If lMsErroAuto
								MOSTRAERRO()
								Aviso(OemToAnsi("DCL - Aviso"),OemToAnsi("A exclusão do Documento de Entrada não será concluida devido aos erros apresentados."),{"Ok"}) 
								lContDCL := .F.
								Return()
							Endif
						Else
							aVetor := GetMovPro()
							Aadd(aVetor,{"D3_TM"			,IIF(_QUANT < 0,_TMD,_TMR)		,NIL})
							Aadd(aVetor,{"D3_QUANT"		,IIF(_QUANT < 0,-_QUANT,_QUANT)	,NIL})
							Aadd(aVetor,{"D3_LOCAL"		,GETMV("MV_BASEALM",.F.,"")			,NIL})
							Aadd(aVetor,{"D3_CODFOR"		,SD1->D1_FORNECE	,NIL})
							Aadd(aVetor,{"D3_LOJAFOR"	,SD1->D1_LOJA		,NIL})
							Aadd(aVetor,{"D3_TANQUE"		,DH4->DH4_TANQUE	,NIL})
							Aadd(aVetor,{"D3_NFORP"		,DH4->DH4_DCPROV	,NIL})
	
							MSExecAuto({|x,y| mata240(x,y)},aVetor,3) //Inclusao
	
							If lMsErroAuto
								MOSTRAERRO()
								Aviso(OemToAnsi("DCL - Aviso"),OemToAnsi("A exclusão do Documento de Entrada não será concluida devido aos erros apresentados."),{"Ok"}) 
								lContDCL := .F.
								Return()
							EndIf
						EndIf
					EndIf
					
					If DH4->DH4_QTD20G <> 0
						
						SF5->(DbSetOrder(2))//F5_FILIAL+F5_MOVTANQ+F5_TIPO
						
						SF5->(DbSeek(xFilial("SF5")+"PR"+"D"))
						_TMD := SF5->F5_CODIGO
						
						SF5->(DbSeek(xFilial("SF5")+"PR"+"R"))
						_TMR := SF5->F5_CODIGO
						
						SF5->(dbSetOrder(1))//F5_FILIAL+F5_CODIGO
						
						lMsErroAuto:=.F.
						
						aVetor := GetMovPro()
						Aadd(aVetor,{"D3_TM"			,_TMD				,NIL})
						Aadd(aVetor,{"D3_QUANT"		,DH4->DH4_QTD20G		,NIL})
						Aadd(aVetor,{"D3_LOCAL"		,SD1->D1_LOCAL		,NIL})
						Aadd(aVetor,{"D3_CODFOR"  	,SD1->D1_FORNECE	,NIL})
						Aadd(aVetor,{"D3_LOJAFOR" 	,SD1->D1_LOJA		,NIL})
						Aadd(aVetor,{"D3_TANQUE"   	,DH4->DH4_TANQUE		,NIL})
						Aadd(aVetor,{"D3_NFORP"   	,DH4->DH4_DCPROV	,NIL})
						
						MSExecAuto({|x,y| mata240(x,y)},aVetor,3) //Inclusao
	
						If lMsErroAuto
							MOSTRAERRO()
							Aviso(OemToAnsi("DCL - Aviso"),OemToAnsi("A exclusão do Documento de Entrada não será concluida devido aos erros apresentados."),{"Ok"}) 
							lContDCL := .F.
							Return()
						Else
							RecLock("SD3",.F.)
								SD3->D3_TEMPTAQ := DH4->DH4_TMPTAQ
								SD3->D3_TEMPAMO := DH4->DH4_TMPAMO
								SD3->D3_DENSA   := DH4->DH4_DENSID
								SD3->D3_FATCORR := DH4->DH4_FATCOR	
								SD3->D3_QTDAMB  := DH4->DH4_QTDAPU	
							MsUnlock()			
						EndIf
					EndIf
				ElseIf  DH4->DH4_TDCARG == "01" //Nota Acompanha Produto'
	
					SF5->(DbSetOrder(2))//F5_FILIAL+F5_MOVTANQ+F5_TIPO
					SF5->(DbSeek(xFilial("SF5")+"DE"+"R"))
					_TMR:=SF5->F5_CODIGO	
					
					SF5->(DbSeek(xFilial("SF5")+"DE"+"D"))
					_TMD:=SF5->F5_CODIGO
					
					SF5->(dbSetOrder(1))//F5_FILIAL+F5_CODIGO
					
					dbSelectArea("SD3")
					SD3->(DbSetOrder(17))//D3_FILIAL+D3_NFORP+D3_TPMOVAJ+D3_ESTORNO+DTOS(D3_EMISSAO)+D3_COD+D3_LOCAL+D3_TANQUE
					
					If SD3->(DbSeek(xFilial("SD3") + SD1->D1_DOC + "DE" + " "))
						
						While	SD3->D3_FILIAL == xFilial("SD3") .AND. SD1->D1_DOC == SD3->D3_NFORP .AND.;
						SD3->D3_TPMOVAJ	== "DE" .AND. SD3->D3_ESTORNO	== " "
							
							If  SD3->D3_COD  == SD1->D1_COD .AND. SD3->D3_LOCAL == SD1->D1_LOCAL .AND.;
							SD3->D3_CODFOR == SD1->D1_FORNECE .AND. SD3->D3_LOJAFOR == SD1->D1_LOJA
								
								_NUMSEQ := SD3->D3_NUMSEQ
								
								lMsErroAuto:=.F.
						
								aVetor:={	{"D3_NUMSEQ",SD3->D3_NUMSEQ,NIL},;
											{"D3_CHAVE",SD3->D3_CHAVE,NIL},;
											{"D3_COD",SD3->D3_COD,NIL},;
								          	{"INDEX",4,NIL}}  // {"INDEX",Ordem,NIL}
								            
								MSExecAuto({|x,y| mata240(x,y)},aVetor,5) //Estorno
	
								If lMsErroAuto
									MOSTRAERRO()
									Aviso(OemToAnsi("DCL - Aviso"),OemToAnsi("A exclusão do Documento de Entrada não será concluida devido aos erros apresentados."),{"Ok"}) 
									lContDCL := .F.
									Return()
								Endif
								Exit
							EndIf
							dbSkip()
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSF5)
RestArea(aAreaDH4)
RestArea(aAreaDH5)
RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMovPro
Retorna os dados da digitacao do Bombeio para gerar o movimento
provisorio conforme LBZ. Gravacao conforme TDCEA010.
@author jose.eulalio
@return aRet
@since 09/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetMovPro()
Local aRet			:= {}
Local aArea		:= GetArea()
Local aAreaDH9	:= DH9->(GetArea())

dbSelectArea("DH9")
DH9->(dbSetOrder(2))

If DH9->(dbSeek(xFilial("DH9") + SubStr(DH4->DH4_DCPROV,1,Len(DH9->DH9_CODIGO)) ))

	aRet	:=	{	{"D3_COD"		,DH9->DH9_COD		,NIL},;
					{"D3_DOC"  		,DH9->DH9_CODIGO	,NIL},;
					{"D3_EMISSAO"	,DH9->DH9_DATA		,NIL},;
					{"D3_OBS"		,DH9->DH9_OBS		,NIL}}

EndIf

RestArea(aAreaDH9)
RestArea(aArea)
		
Return aRet