#INCLUDE "DCLSD1100I.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSD1100I
Ponto de entrada da nota fiscal de entrada que gera movimentacao de estoque para equalizacao de estoque.  
Adaptação da função Sd1100I
@author jose.eulalio
@return Nil
@since 09/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSD1100I()
Local aArea 	  	:= GetArea()
Local aAreaSF5 	:= SF5->(GetArea())
Local aAreaSB1 	:= SB1->(GetArea())
Local lRateio		:= SuperGetMV("MV_RATBOMB",.F., .F.)
Local cTipo		:= "BO"
Local cTamDoc		:= Replicate(" ",TamSx3("D1_DOC")[1])
Local cTamSerie	:= Replicate(" ",TamSx3("D1_Serie")[1])
Local cChave		:= ""

Private _aOpcoes	:= {OemToAnsi(STR0001),; //"NFEB-NF de Bombeio atualiza o almoxarifado base (MV_BASEALM)"
					   OemToAnsi(STR0002)} //"NFED-NF de Descarga atualiza o almoxarifado corrente da nota fical"
Private _nOpcao		:= 1
Private lMsErroAuto	:= .F.

SaveInter() // Salva variaveis publicas

SetPrvt("CMSDALIAS,NMSDINDEX,NMSDRECNO,_LENTROU,_LFEZ,_QUANT")
SetPrvt("_TM,_EMISSAO,_COD,_UM,_TANQUE,_CF")
SetPrvt("_CLIENTE,_LOJA,_LOCAL,_NREDUZ,_DOC,_GRUPO")
SetPrvt("_CUSTO1,_NUMSEQ,_SEGUM,_QTSEGUM,_TIPO,_ESTORNO")
SetPrvt("_CHAVE,_DIF,_MENS,_DIFER,I,CTES")
SetPrvt("NQUANT,_CNUMFA,")

If SuperGetMv("MV_DCLNEW",.F.,.F.)

	If oModelDcl <> NIL
	
		If oModelDcl:VldData()
	  		oModelDcl:CommitData()
		EndIf
		
		oModelDcl:DeActivate()
		oModelDcl:Destroy()
		oModelDcl := NIL
	EndIf	
	
	DbSelectArea("DH4")//Itens Documento de Entrada DCL
	DH4->(DbSetOrder(1))//DH4_FILIAL+DH4_DOC+DH4_SERIE+DH4_FORNEC+DH4_LOJA+DH4_ITEM
	
	//Atualizada numero do Documento e Serie no Complemento DCL
	If SF1->F1_FORMUL == "S" .And. DH4->(DbSeek(SD1->(D1_FILIAL) + cTamDoc + cTamSerie + SD1->(D1_FORNECE + D1_LOJA)))
		cChave := SD1->(D1_FILIAL) + cTamDoc + cTamSerie + SD1->(D1_FORNECE + D1_LOJA + D1_COD)
		While !DH4->(EoF()) .And. SD1->(D1_FILIAL) + cTamDoc + cTamSerie + SD1->(D1_FORNECE + D1_LOJA + D1_COD) == cChave
			RecLock("DH4",.F.)
			DH4->DH4_DOC		:= SD1->D1_DOC
			DH4->DH4_SERIE	:= SD1->D1_SERIE
			MsUnlock()
			DH4->(DbSkip())
		EndDo
	EndIf
	
	//Executa o Ponto de Entrada se "Atualiza tanque?" for igual a "SIM"
	If DH4->(DbSeek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM))) .And. DH4->DH4_ATUTNQ == 'S'
		
		dbSelectArea("SD1")
		dbSelectArea("SF1")
		
		Reclock("SF1",.F.)
		If !(Empty(DH4->DH4_DCPROV))
	   		SF1->F1_BOMDES := "NFEB" 
	   		DH9->(dbSetOrder(2)) // DH9_FILIAL + DH9_CODIGO
	   		If DH9->(dbSeek(SD1->D1_FILIAL + SubStr(DH4->DH4_DCPROV,1,4)))
				cTipo := DH9->DH9_TIPO
	   		EndIf
		Else
			SF1->F1_BOMDES := "NFED"
		EndIf	
		SF1->(MSUnlock())
		
		//NOTAS FISCAIS ENTRADA DE BOMBEIO - SO PROCESSA SE ATUALIZA ESTOQUE
		DbSelectArea("DH5")//Complemento de produto DCL
		DH5->(DbSetOrder(1))//DH5_FILIAL+DH5_COD+DH5_CODSIM
		If DH5->(DbSeek(xFilial("DH5") + SD1->D1_COD))
			If	(SF1->F1_TIPO == "N" .OR. SF1->F1_TIPO == "D") .AND.;	//SO NOTAS DEVOLUCAO E NORMAL
				! Empty(DH4->DH4_DTENT) .AND. ;                         //SO DATA ENTREGA PREENCHIDA
				DH5_PREQUI <> "S" .AND.;                           		//SO PRODUTOS APROPRIACAO DIRETA PRODUTO ACABADO
				! Empty(DH4->DH4_TANQ)                                  //SO TANQUE PREENCHIDO
				
				If  DH4->DH4_TDCARGA == "02" 								//RECEBIMENTO

					//VERIFICA SE PEDIDO EXISTE NO CADASTRO SD3 MOV.INTERNO
					dbSelectArea("SD3")
					SD3->(DbSetOrder(17))//D3_FILIAL+D3_NFORP+D3_TPMOVAJ+D3_ESTORNO+DTOS(D3_EMISSAO)+D3_COD+D3_LOCAL+D3_TANQUE
					
					_PROV := 0
					If SD3->(DbSeek(xFilial() + DH4->DH4_DCPROV + "PR" + " "))
						
						_PROV := SD3->D3_QUANT
						
						aVetor := {	{"D3_NUMSEQ"	,SD3->D3_NUMSEQ	,NIL},;
										{"D3_CHAVE"	,SD3->D3_CHAVE	,NIL},;
										{"D3_COD"		,SD3->D3_COD		,NIL},;
						            	{"INDEX"		,4					,NIL}}
	
						MSExecAuto({|x,y| MATA240(x,y)},aVetor,5) // Estorno
						If lMsErroAuto
							MostraErro()
							Aviso(OemToAnsi(STR0006),OemToAnsi(STR0007),{"Ok"}) // "A inclusão do Documento de Entrada não será concluida devido aos erros apresentados."
							lContDCL := .F.
							Return()
						EndIf
					EndIf
					
					_DIFER := _PROV - SD1->D1_QUANT
					If _DIFER <> 0
						
						If SF1->F1_BOMDES == "NFEB"
							
							//GERA MOVIMENTACAO INTERNA DA DIFERENCA DO BOMBEIO
							DbSelectArea("SF5")
							SF5->(DbSetOrder(2))//F5_FILIAL+F5_MOVTANQ+F5_TIPO
							SF5->(DbSeek(xFilial("SF5") + cTipo + "R"))
							_TMR := SF5->F5_CODIGO
							
							SF5->(DbSeek(xFilial("SF5") + cTipo + "D"))
							_TMD := SF5->F5_CODIGO
							
							SF5->(dbSetOrder(1))//F5_FILIAL+F5_CODIGO
							
							lMsErroAuto := .F.
							
							dbSelectArea("SD3")
							
							aVetor := {	{"D3_TM"     	,IIf(_Difer > 0,_TMD,_TMR)							,NIL},;
											{"D3_COD"    	,SD1->D1_COD											,NIL},;
											{"D3_QUANT"  	,IIf(_Difer < 0,(_Difer*-1),_Difer)				,NIL},;
											{"D3_LOCAL"  	,IIf(!lRateio,GETMV("MV_BASEALM"),SD1->D1_LOCAL)	,NIL},;
											{"D3_DOC"    	,SD1->D1_DOC											,NIL},;
											{"D3_EMISSAO"	,SD1->D1_DTDIGIT										,NIL},;
											{"D3_CODFOR"	,SD1->D1_FORNECE										,NIL},;
											{"D3_LOJAFOR"	,SD1->D1_LOJA											,NIL},;
											{"D3_TANQUE"	,DH4->DH4_TANQUE										,NIL},;
											{"D3_NFORP"	,DH4->DH4_DCPROV										,NIL},;
											{"D3_TPMOMAJ" ,cTipo,												NIL}}
	
							MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) //Inclusao
							If lMsErroAuto
								MostraErro()
								Aviso(OemToAnsi(STR0006),OemToAnsi(STR0007),{"Ok"}) // "A inclusão do Documento de Entrada não será concluida devido aos erros apresentados."
								lContDCL := .F.
								Return()
							EndIf
						ElseIf  Trim(SF1->F1_BOMDES) == "NFED"

							//GERA MOVIMENTACAO INTERNA DA DIFERENCA DA DESCARGA
							SF5->(DbSetOrder(2))//F5_FILIAL+F5_MOVTANQ+F5_TIPO
							SF5->(msSeek(xFilial("SF5")+"PR"+"R"))
							_TMR := SF5->F5_CODIGO
							
							SF5->(msSeek(xFilial("SF5")+"PR"+"D"))
							_TMD := SF5->F5_CODIGO
							
							SF5->(dbSetOrder(1))
							
							lMsErroAuto := .F.
							
							dbSelectArea("SD3")
							
							aVetor := {	{"D3_TM"     ,IIf(_Difer>0,_TMD,_TMR)				,NIL},;
											{"D3_COD"    ,SD1->D1_COD							,NIL},;
											{"D3_QUANT"  ,IIf(_Difer<0,(_Difer*-1),_Difer)	,NIL},;
											{"D3_LOCAL"  ,SD1->D1_LOCAL							,NIL},;
											{"D3_DOC"  	 ,SD1->D1_DOC							,NIL},;
											{"D3_EMISSAO",SD1->D1_DTDIGIT						,NIL},;
											{"D3_CODFOR"	,SD1->D1_FORNECE						,NIL},;
											{"D3_LOJAFOR"	,SD1->D1_LOJA							,NIL},;
											{"D3_TANQUE"	,DH4->DH4_TANQUE						,NIL},;
											{"D3_NFORP"	,DH4->DH4_DCPROV						,NIL},;
											{"D3_TPMOMAJ" ,"DE"									,NIL}}
	
							MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) //Inclusao

							If lMsErroAuto
								MostraErro()
								Aviso(OemToAnsi(STR0006),OemToAnsi(STR0007),{"Ok"}) // "A inclusão do Documento de Entrada não será concluida devido aos erros apresentados."
								lContDCL := .F.
								Return()
							EndIf
						EndIf
					EndIf
				ElseIf DH4->DH4_TDCARGA == "01"
					_DIFER := DH4->DH4_QTD20G - SD1->D1_QUANT
					If _DIFER <> 0
						
						SF5->(DbSetOrder(2))//F5_FILIAL+F5_MOVTANQ+F5_TIPO
						SF5->(DbSeek(xFilial("SF5") + "DE" + "R"))
						_TMR := SF5->F5_CODIGO
						
						SF5->(DbSeek(xFilial("SF5") + "DE" + "D"))
						_TMD := SF5->F5_CODIGO
						
						SF5->(dbSetOrder(1))
						
						lMsErroAuto := .F.
						
						dbSelectArea("SD3")
						
						aVetor := {	{"D3_TM"     ,IIf(_Difer > 0,_TMD,_TMR)				,NIL},;
										{"D3_COD"    ,SD1->D1_COD							,NIL},;
										{"D3_QUANT"  ,IIf(_Difer < 0,(_Difer*-1),_Difer)	,NIL},;
										{"D3_LOCAL"  ,SD1->D1_LOCAL							,NIL},;
										{"D3_DOC"    ,SD1->D1_DOC							,NIL},;
										{"D3_EMISSAO",SD1->D1_DTDIGIT						,NIL},;
										{"D3_TANQUE"	,DH4->DH4_TANQUE						,NIL},;
										{"D3_NFORP"	,DH4->DH4_DCPROV						,NIL},;
										{"D3_TPMOMAJ" ,"DE"									,NIL}}
						
						MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) //Inclusao
						
						If lMsErroAuto
							MostraErro()
							Aviso(OemToAnsi(STR0006),OemToAnsi(STR0007),{"Ok"}) // "A inclusão do Documento de Entrada não será concluida devido aos erros apresentados."
							lContDCL := .F.
							Return()
						EndIf
	
						Reclock("SD3")
							SD3->D3_NFORP   := SD1->D1_DOC
							SD3->D3_CODFOR  := SD1->D1_FORNECE
							SD3->D3_LOJAFOR := SD1->D1_LOJA
						MSUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestInter()//Recupera as variáveis públicas

SB1->(RestArea(aAreaSB1))
SF5->(RestArea(aAreaSF5))
RestArea(aArea)

Return ()
