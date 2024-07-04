#Include "Protheus.Ch"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��                            	
���Programa  �DCIMensal �Autor  �Sueli               � Data �  25.05.06    ���
��������������������������������������������������������������������������͹��
���Desc.     �DCI Mensal - Declaracao de Controle de Internacao Mensal     ���
���          �para Zona Franca de Manaus								   ��� 
��������������������������������������������������������������������������͹��
���Uso       �                                                             ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function DCIMensal(cAls,lIndiv)
  
Local lRet := .T.
Private cIndSFT	:= "" 

Default lIndiv	 := .F.

If MontPainel(lIndiv)
	Processa({||ProcessaReg(@cAls,lIndiv)})
Else
	lRet := .F.
Endif

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Funcao	 �ProcessaReg �Autor  �Sueli C. dos Santos � Data �  19/04/06   ���
���������������������������������������������������������������������������͹��
���Desc.     � Faz o processamento de forma a montar os arquivos temporarios���
���          �para carregar os Registros do Arquivo.                     	���
���������������������������������������������������������������������������͹��
���Uso       � MATA909                                                  	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function ProcessaReg(cAls,lIndiv)

Private aCfp := {}
Private cIndSFT	:= ""

/*
�����������������������������������������������������������������������Ŀ
�Parametros															    �
�mv_par01 - Data Inicial       ?     									�
�mv_par02 - Data Final         ?   										�
�������������������������������������������������������������������������
*/
PRIVATE	dDtIni	 :=	mv_par01
PRIVATE	dDtFim	 :=	mv_par02

Default lIndiv	 := .F.

//������������������������������������������������������������������������Ŀ
//�L� a Wizard com as perguntas                                          �
//��������������������������������������������������������������������������

If !lIndiv
	xMagLeWiz("DCIMENSAL",@aCfp,.T.)
Else
	xMagLeWiz("DCIINDIVI",@aCfp,.T.)  //com outro nome
EndIf

//���������������������������������Ŀ
//� Cria arquivos temporarios       �
//�����������������������������������
CRTemp(@cAls)

//��������������������������������������������������������������Ŀ
//� Monta arquivo de Trabalho                                    �
//����������������������������������������������������������������
MontaTrab(lIndiv)

return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �ApagTemp    �Autor  � Sueli C.dos Santos � Data �  19/04/06  ���
�������������������������������������������������������������������������͹��
���Desc.    � Apaga arquivos temporarios criados para gerar o arquivo     ���
���         � Magnetico                                                   ���
�������������������������������������������������������������������������͹��
���Uso      � MATA909                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function ApagTemp(cAls)

If File(cAls+GetDBExtension())
	dbSelectArea("R00")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cAls+GetDBExtension())
	dbSelectArea("R01")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cals+GetDBExtension())
	dbSelectArea("R11")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif 

If File(cAls+GetDBExtension())
	dbSelectArea("R12")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif 

If File(cAls+GetDBExtension())
	dbSelectArea("R13")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cAls+GetDBExtension())
	dbSelectArea("R14")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         

If File(cAls+GetDBExtension())
	dbSelectArea("R21")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cAls+GetDBExtension())
	dbSelectArea("R31")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         

If File(cAls+GetDBExtension())
	dbSelectArea("R32")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         
   
If File(cAls+GetDBExtension())
	dbSelectArea("R33")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         
 
If File(cAls+GetDBExtension())
	dbSelectArea("R34")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         

If File(cAls+GetDBExtension())
	dbSelectArea("R35")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         
If File(cAls+GetDBExtension())
	dbSelectArea("R36")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         
If File(cAls+GetDBExtension())
	dbSelectArea("R41")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Function� MontaTrab  �Autor  �Sueli C.Santos      � Data �  25/04/06   ���
�������������������������������������������������������������������������͹��
���Desc.   �Armazena as informacoes nos arquivos temporarios para depois  ���
���        �gerar arquivo texto.                                          ���
�������������������������������������������������������������������������͹��
���Uso     � MATA909                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MontaTrab(lIndiv)

LOCAL cCNPJ		:=	""
Local cAliasSFT	:= "SFT"
Local cInsumo		:= ""
Local cLocal		:= ""
Local cPessoa		:= ""
Local cNDI 		:= ""
Local cNADICAO	:= ""
Local cNITEMAD	:= ""
Local lSigaEIC	:= (GetNewPar("MV_EASY",.F.)=="S")		//Integracao com SIGAEIC
Local aSigaEIC	:= {}
Local cTpImp := ""

#IFDEF TOP
	Local nSFT	   := 0
#ENDIF

Default lIndiv   := .F.


If lSigaEIC
	DbSelectArea("SWN")
	DbSelectArea("SW6")	
	lFieldEic := SWN->(FieldPos('WN_DOC')) <> 0 .And. SWN->(FieldPos('WN_ADICAO')) <> 0 .And. SWN->(FieldPos('WN_SEQ_ADI')) <> 0 .AND. SW6->(FieldPos('W6_DSI')) <> 0
EndIf


DbSelectArea("CD5")
CD5->(DbSetOrder(4))


#IFDEF TOP
	If TcSrvType() <> "AS/400"
	    cAliasSFT:= "aMontaTrab"
	   	lQuery    := .T.
		aStruSFT  := SFT->(dbStruct())
		cQuery := "SELECT SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_DTCANC,SFT.FT_ESPECIE, "
		cQuery += "SFT.FT_TIPO,SFT.FT_CFOP,SFT.FT_ESTADO,SFT.FT_VALCONT,SFT.FT_BASEICM, "
		cQuery += "SFT.FT_VALICM,SFT.FT_ISENICM,SFT.FT_OUTRICM,SFT.FT_ICMSRET, "
		cQuery += "SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_NFISCAL,SFT.FT_EMISSAO, "
		cQuery += "SFT.FT_SERIE," 
		cQuery += "CASE WHEN SFT.FT_TIPOMOV = 'S' THEN '1'
		cQuery += "     WHEN SFT.FT_TIPOMOV = 'E' THEN '2' ELSE '' END AS TIPOMOV,"
		cQuery += "SFT.FT_PRODUTO, SFT.FT_ITEM,"
		cQuery += "SFT.FT_TRFICM, SFT.FT_QUANT, SFT.FT_PRCUNIT, SFT.FT_VALIPI, 
		cQuery += "SFT.FT_VALPIS, SFT.FT_VALCOF,SFT.FT_TOTAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SFT") + " SFT "
		cQuery += "WHERE "
		cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "

        If !lIndiv
			cQuery += "SFT.FT_ENTRADA >= '"+DTOS(dDtIni)+"' AND "
			cQuery += "SFT.FT_ENTRADA <= '"+DTOS(dDtFim)+"' AND "
        Else
	        cQuery += "SFT.FT_ENTRADA = '"+aCfp[3][01]+"' AND "
			cQuery += "SFT.FT_NFISCAL = '"+aCfp[3][02]+"' AND "
			cQuery += "SFT.FT_SERIE = '"+aCfp[3][03]+"' AND "
			cQuery += "SFT.FT_CLIEFOR = '"+aCfp[3][04]+"' AND "
			cQuery += "SFT.FT_LOJA = '"+aCfp[3][05]+"' AND "
        EndIf
		
		cQuery += "SFT.FT_TIPOMOV IN ('S','E') AND "
		cQuery += "SFT.FT_TIPO NOT IN ('B','D') AND "
		cQuery += "SFT.FT_DTCANC = ' ' AND "
		cQuery += "SFT.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY TIPOMOV

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT,.T.,.T.)

		For nSFT := 1 To Len(aStruSFT)
			If aStruSFT[nSFT][2] <> "C" 
				TcSetField(cAliasSFT,aStruSFT[nSFT][1],aStruSFT[nSFT][2],aStruSFT[nSFT][3],aStruSFT[nSFT][4])
			EndIf
		Next nSFT

	Else
#ENDIF
		dbSelectArea(cAliasSFT)
		cIndSFT	:=	CriaTrab(NIL,.F.)
		cChave	:=	IndexKey()
		cFiltro	:=	"FT_FILIAL=='"+xFilial("SFT")+"'"

		cFiltro	+=	".And. DTOS(FT_ENTRADA)>='"+DTOS(dDtIni)+"'.AND.DTOS(FT_ENTRADA)<='"+DTOS(dDtFim)+"'"


	   IndRegua(cAliasSFT,cIndSFT,cChave,,cFiltro,"DTREF")
#IFDEF TOP
	Endif
#ENDIF

//����������������������Ŀ
//�Registro Header - R00 �
//������������������������
HeaderMensal(lIndiv)

If (cAliasSFT)->TIPOMOV == '2'
   	SA2->(dbSetOrder(1))
    SA2->(dbSeek(xFilial("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
    cCNPJ := aFisFill(aRetDig(SA2->A2_CGC,.F.),14)
    cPessoa := IIf(SA2->A2_TIPO=="J","1","2")
Else
	SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
    cCNPJ := aFisFill(aRetDig(SA1->A1_CGC,.F.),14)
    cPessoa := IIf(SA1->A1_PESSOA=="J","1","2")
EndIf

//Registro R01
DadosMensais(lIndiv,cAliasSFT, cCNPJ, cPessoa)

If (cAliasSFT)->(Eof())
	Alert("Notas Fiscais n�o encontradas!")
EndIf

While (cAliasSFT)->(!Eof())//.and. xFilial("SF3")==(cAliasSFT)->FT_FILIAL

	cMesRef := SUBSTR(DtoS((cAliasSFT)->FT_ENTRADA),1,6)  //verifica o mes corrente
	
	If (cAliasSFT)->TIPOMOV == '2'
	   	SA2->(dbSetOrder(1))
	    SA2->(dbSeek(xFilial("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
	    cCNPJ := aFisFill(aRetDig(SA2->A2_CGC,.F.),14)
	    cPessoa := IIf(SA2->A2_TIPO=="J","1","2")
	Else
		SA1->(dbSetOrder(1))
	    SA1->(dbSeek(xFilial("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
	    cCNPJ := aFisFill(aRetDig(SA1->A1_CGC,.F.),14)
	    cPessoa := IIf(SA1->A1_PESSOA=="J","1","2")
	EndIf
	//Tratamento para quando houver integracao com o SIGAEIC
	If lSigaEIC											
		aSigaEIC	:= (cAliasSFT)->(FisGetEIC(xFilial("SFT"),FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA))		

		If lFieldEic
			nPosDoc := aScan(aSigaEIC, {|x| AllTrim(x[2]) == 'WN_DOC' })
			nPosAdic := aScan(aSigaEIC, {|x| AllTrim(x[2]) == 'WN_ADICAO' })
			nPosSeqAdic := aScan(aSigaEIC, {|x| AllTrim(x[2]) == 'WN_SEQ_ADI' })
			nPosTpImp := aScan(aSigaEIC, {|x| AllTrim(x[2]) == 'W6_DSI' })
			
			cNDI 		:= aSigaEIC[nPosDoc,1]
			cNADICAO	:= aSigaEIC[nPosAdic,1]				
			cNITEMAD	:= aSigaEIC[nPosSeqAdic,1]
			cTpImp		:= IIF(aSigaEIC[nPosTpImp,1]== '1',"1","0")
		EndIF												
	ElseIf CD5->(DbSeek(xFilial("CD5")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ITEM))
		cNDI 		:= CD5->CD5_NDI
		cNADICAO	:= CD5->CD5_NADIC
		cNITEMAD	:= CD5->CD5_SQADIC
		cTpImp		:= CD5->CD5_TPIMP							
	Endif	


	If (cAliasSFT)->TIPOMOV == '1'
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
			If SB1->B1_ORIGEM == "0"
				IF !R41->(dbSeek(cMesRef+SB1->B1_COD))						
					RecLock("R41",.T.)                              
					R41->DTREF	:=	cMesRef	 
					R41->CDPROD := SB1->B1_COD //Codigo interno do Produto					
				ELSE
					RecLock("R41",.F.) 		
				ENDIF                                                       
				R41->NFITEM := Val((cAliasSFT)->FT_ITEM)
				R41->QTDUNI := (cAliasSFT)->FT_QUANT
				R41->VUNIT := (cAliasSFT)->FT_PRCUNIT
				R41->QTDNCM := (cAliasSFT)->FT_QUANT
				
				R41->CDNCM := Val(SB1->B1_POSIPI)
				R41->DESC  := SB1->B1_DESC  //Descricao do Produto   
				SAH->(dbSetOrder(1))
				SAH->(dbSeek(xFilial("SAH")+AllTrim (SB1->B1_UM)))
				R41->UNIMED :=SAH->AH_DESCPO  //Unidade de Medida 
				R41->VTOTUN += (cAliasSFT)->FT_PRCUNIT
				R41->QTPROD += (cAliasSFT)->FT_QUANT//Qtde total do produto na unidade comercializada
				R41->QTPRODE += (cAliasSFT)->FT_QUANT
				R41->(MsUnlock())
			ElseIf SB1->B1_ORIGEM <> "0"

				cLocal := ALLTRIM(STR(IIf((cAliasSFT)->FT_ESTADO == "AM",1,IIf((cAliasSFT)->FT_ESTADO $ "AC/AP/AM/RO/RR",3,IIf((cAliasSFT)->FT_ESTADO $"AC/AP/RO/RR",4,2)))))
				IF !R11->(dbSeek(cMesRef+SB1->B1_COD+cLocal))
					RecLock("R11",.T.)
					R11->DTREF	:=	cMesRef
					R11->CODINT := SB1->B1_COD
					R11->DEST := cLocal
				ELSE
					RecLock("R11",.F.)
				ENDIF
				R11->NFITEM := Val((cAliasSFT)->FT_ITEM)
				R11->CODNCM := Val(SB1->B1_POSIPI)
				R11->DESC   := SB1->B1_DESC
				R11->CDDEST := IIf((cAliasSFT)->FT_ESTADO == "AM",1,IIf((cAliasSFT)->FT_ESTADO $ "AC/AP/AM/RO/RR",3,IIf((cAliasSFT)->FT_ESTADO $"AC/AP/RO/RR",4,2)))
				R11->QUNTOT := (cAliasSFT)->FT_QUANT
				R11->QTOT   := (cAliasSFT)->FT_QUANT 					 
				SAH->(dbSetOrder(1))
				// Unidade do produto
				SAH->(dbSeek(xFilial("SAH")+AllTrim (SB1->B1_UM)))
				R11->UNIMED  :=SAH->AH_DESCPO
				// Unidade comercializada
				SAH->(dbSeek(xFilial("SAH")+AllTrim (SB1->B1_UM)))
				R11->UNIDADE := SAH->AH_DESCPO
				R11->QUANTID := (cAliasSFT)->FT_QUANT
				R11->VALUNIT := (cAliasSFT)->FT_PRCUNIT
				R11->IPIDESTA := (cAliasSFT)->FT_VALIPI
				R11->(MsUnlock())

				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD)) 
				cInsumo:= IIF(Empty(SB5->B5_PINSUMO),"N",SB5->B5_PINSUMO)                
						
				cLocal := STR(IIf((cAliasSFT)->FT_ESTADO == "AM",1,IIf((cAliasSFT)->FT_ESTADO $ "AC/AP/AM/RO/RR",3,IIf((cAliasSFT)->FT_ESTADO $"AC/AP/RO/RR",4,2)))) //Locasl de destino (1 - Amazonia Ocidental)  
						
				IF SB1->B1_DCI <> "1"
					IF !R31->(dbSeek(cMesRef+SB1->B1_COD+Alltrim(cLocal)))
						RecLock("R31",.T.)                              
						R31->DTREF	:=	cMesRef						
						R31->DEST := Alltrim(cLocal)
						R31->CDPROD := SB1->B1_COD
					ELSE
						RecLock("R31",.F.) 		
					ENDIF                          
		
					R31->DESC   := SB1->B1_DESC 
					R31->NFITEM := Val((cAliasSFT)->FT_ITEM)
					R31->QUANT  := (cAliasSFT)->FT_QUANT
					R31->VALUNIT  := (cAliasSFT)->FT_PRCUNIT
					SAH->(dbSetOrder(1))
					SAH->(dbSeek(xFilial("SAH")+AllTrim (SB1->B1_UM)))
					R31->UNIMED  :=SAH->AH_DESCPO
					R31->DNCM := Val(SB1->B1_POSIPI)
					R31->DESTINO := 1
					R31->QDEST   += IIF((cAliasSFT)->FT_ESTADO == "AM",(cAliasSFT)->FT_QUANT,0) //Se Destino=1 informar a quantidade internada do produto, senao preencher com zeros
					R31->DESTINO2 := 2
					R31->QDEST2  += IIF(!((cAliasSFT)->FT_ESTADO $ "AC/AP/AM/RO/RR"),(cAliasSFT)->FT_QUANT,0) //Se Destino=2, informar a quantidade internada do produto, senao preencher com zeros                                     
					R31->DESTINO3 := 3
					R31->QDEST3 += IIF((cAliasSFT)->FT_ESTADO $ "AC/AP/AM/RO/RR",(cAliasSFT)->FT_QUANT,0) //Se Destino=3, informar a quantidade internada do produto, senao preencher com zeros                                     
					R31->DESTINO4 := 4
					R31->QDEST4  += IIF((cAliasSFT)->FT_ESTADO $"AC/AP/RO/RR",(cAliasSFT)->FT_QUANT,0)//Se Destino=4, informar a quantidade internada do produto, senao preencher com zeros                                     
					R31->(MsUnlock())

					IF !R32->(dbSeek(cMesRef+SB1->B1_COD))						
						RecLock("R32",.T.)                              
						R32->DTREF	:=	cMesRef	
						R32->CDPROD := SB1->B1_COD //Codigo interno do Produto					
					ELSE
						RecLock("R32",.F.) 		
					ENDIF    
								
					R32->CDISUM := SB1->B1_COD //Codigo interno do Insumo
					R32->CDNCM  := Val(SB1->B1_POSIPI)
					R32->DNCM  := SB1->B1_DESC//Descricao Insumo
					SAH->(dbSetOrder(1))
					SAH->(dbSeek(xFilial("SAH")+AllTrim (SB1->B1_UM)))
					R32->UNIMED  := SAH->AH_DESCPO  //Unidade de Medida
					R32->QTINSUM += (cAliasSFT)->FT_QUANT //Qtde do Insumo
					R32->(MsUnlock())
						
					IF !R33->(dbSeek(cMesRef+SB1->B1_COD))						
						RecLock("R33",.T.)                              
						R33->DTREF	:=	cMesRef
						R33->CDISUM := SB1->B1_COD //Codigo interno do Insumo						
					ELSE
						RecLock("R33",.F.) 		
					ENDIF    
													
					R33->QTOTINS  += (cAliasSFT)->FT_QUANT//Qtde total do Insumo
					R33->LOCDEST  := R31->DESTINO //Local de Destino ,de cada Local informado do Reg 31
					R33->QTINSD  += (cAliasSFT)->FT_QUANT//Qtde total do Insumo internado para o Local de Destino
					R33->(MsUnlock())
				
				ElseIf SB1->B1_DCI == "1"
					If !R21->(dbSeek(cMesRef+SB1->B1_COD+Alltrim(cLocal)))
						RecLock("R21",.T.)    
						R21->DTREF	:=	cMesRef                          
						R21->CDDEST  := Alltrim(cLocal)
						R21->CDPROD := SB1->B1_COD
					Else
						RecLock("R21",.F.) 		
					Endif                          
					SAH->(dbSetOrder(1))
					SAH->(dbSeek(xFilial("SAH")+AllTrim (SB1->B1_UM)))
					R21->NRITEM 	:= Val((cAliasSFT)->FT_ITEM) // GRAZI
					R21->DCRE      	:= IIF(!Empty(SB1->B1_DCRE),val(SB1->B1_DCRE),0) 
					R21->DCR		:= IIF(Empty(SB1->B1_DCRE),val(SB1->B1_DCR),0) 
					R21->DESC 		:= SB1->B1_DESC 
					R21->VUNDOL		:= IIF(!Empty(SB1->B1_DCR),SB1->B1_DCRII,0) 
					R21->CREDUCAO	:= IIF(!Empty(SB1->B1_DCR),SB1->B1_COEFDCR,0) 
					R21->QTDPROD 	+= (cAliasSFT)->FT_QUANT
					R21->QUANT  	+= (cAliasSFT)->FT_QUANT
					R21->UNIMED 	:= IIF(!Empty(SB1->B1_DCR),SAH->AH_DESCPO,"")
					R21->VPIS		+= (cAliasSFT)->FT_VALPIS
					R21->VCOFINS 	+= (cAliasSFT)->FT_VALCOF 
					R21->QTDPROD 	+= (cAliasSFT)->FT_QUANT
					R21->(MsUnlock())
				EndIf
			EndIf	       										
		EndIf
	Else
		R11->(DbSetOrder(1))
		lR11 := R11->(dbSeek(cMesRef+(cAliasSFT)->FT_PRODUTO))
		R31->(DbSetOrder(1))
		lR31 := R31->(dbSeek(cMesRef))		
		
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO)) .And. !SB1->B1_ORIGEM=="0" 
		 	SB5->(dbSetOrder(1))
   			SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))      							 
			If SB5->B5_PINSUMO <> "1" .AND. !(cTpImp $ "0/1") .And. lR11
				IF !R12->(dbSeek(cMesRef+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_ITEM))						
					RecLock("R12",.T.)                              
					R12->DTREF		:=	cMesRef	
					R12->NF2   	:= (cAliasSFT)->FT_NFISCAL
					R12->SERIE		:= SerieNfId("SFT",2,"FT_SERIE")
				ELSE
					RecLock("R12",.F.) 		
				ENDIF  
								  
			  	//���������������������������������������������������������������Ŀ
				//�Verifica se o documento de entrada ulitizado e uma Nota FIscal �
				//�����������������������������������������������������������������
	           	R12->CNPJFOR := Val(cCNPJ)
				R12->NF := (cAliasSFT)->FT_NFISCAL
				R12->NRITEMNOTA:=val((cAliasSFT)->FT_ITEM)
				R12->EMISSAO:= val(Dtos((cAliasSFT)->FT_EMISSAO))
				R12->CFOP := Val((cAliasSFT)->FT_CFOP)
				R12->DL288 := IF(Empty(SB5->B5_BENDL),"N",SB5->B5_BENDL)
				R12->OBSOLE := If(R12->DL288=="S","S","N")
				R12->QUANT:= (cAliasSFT)->FT_QUANT
				R12->VLUNIT :=  If(R12->DL288=="S" .AND. R12->OBSOLE=="N",(cAliasSFT)->FT_PRCUNIT,0)
				R12->VLOBSOLE := If(R12->OBSOLE=="S" ,(cAliasSFT)->FT_TOTAL,0)
				R12->(MsUnlock())		
			EndIf
			If SB5->B5_PINSUMO == "1" .AND. !(cTpImp $ "0/1") .And. lR31

				IF !R34->(dbSeek(cMesRef+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE))						
					RecLock("R34",.T.)                              
					R34->DTREF	:=	cMesRef	
					R34->NF2 	:= (cAliasSFT)->FT_NFISCAL
					R34->SERIE	:= (cAliasSFT)->FT_SERIE
				ELSE
					RecLock("R34",.F.) 		
				ENDIF  
			  	//���������������������������������������������������������������Ŀ
				//�Verifica se o documento de entrada ulitizado e uma Nota FIscal �
				//�����������������������������������������������������������������
              	R34->CNPJFOR := Val(cCNPJ)  
           		R34->NF := (cAliasSFT)->FT_NFISCAL
				R34->NRITEMNOTA:=val((cAliasSFT)->FT_ITEM)
				R34->EMISSAO:= val(DtoS((cAliasSFT)->FT_EMISSAO))
				R34->CFOP := Val((cAliasSFT)->FT_CFOP)
				R34->DL288 := IF(Empty(SB5->B5_BENDL),"N",SB5->B5_BENDL)
				R34->QTINSUMO:= (cAliasSFT)->FT_QUANT
				R34->VLUNIT :=  (cAliasSFT)->FT_PRCUNIT  //Valor Unitario Insumo
				R34->CDISUM := SB1->B1_COD //Codigo interno do Insumo
				R34->LOCDEST := R33->LOCDEST //Local de Destino ,de cada Local informado do Reg 33
				R34->(MsUnlock())		

			EndIf
			If	SB5->B5_PINSUMO <> "1" .AND. cTpImp $ "0" .And. lR11
				//������������������������������������������������������Ŀ
				//�Verifica se o documento de entrada ulitizado e uma DI �
				//��������������������������������������������������������				
				IF !R13->(dbSeek(cMesRef))						
					RecLock("R13",.T.)                              
					R13->DTREF	:=	cMesRef						
				ELSE
					RecLock("R13",.F.) 		
				ENDIF  
				R13->NDI			:= STRZERO(Val(cNDI),10)
				R13->NDIANT			:= Replicate("0",15)
				R13->NADICAO		:= cNADICAO
				R13->NITEMAD		:= Left(cNITEMAD,2)
				R13->DL288			:= IIf(!Empty(SB5->B5_BENDL), SB5->B5_BENDL, "N")
				R13->OBSOLE			:= IIf(AllTrim(R13->DL288) == "S", "S", "N")
				R13->QUANT			:= (cAliasSFT)->FT_QUANT
				R13->VUNIT			:= (cAliasSFT)->FT_PRCUNIT
				R13->SUSPPISCOF		:= "N"												
				R13->(MsUnlock())											  			  
			EndIf
			If SB5->B5_PINSUMO == "1" .AND. cTpImp $ "0" .And. lR31
				//�����������������������������������������������������Ŀ
				//�Verifica se o documento de entrada ulitizado e um DI �
				//�������������������������������������������������������				
				IF !R35->(dbSeek(cMesRef))						
					RecLock("R35",.T.)                              
					R35->DTREF	:=	cMesRef						
				ELSE
					RecLock("R35",.F.) 		
				ENDIF  
			  	R35->NDI := VAL(STRZERO(Val(cNDI),10))
				R35->DL288 := "N"
				R35->SUSPPISCOF := "N"
				R35->CDISUM := SB1->B1_COD
				R35->(MsUnlock())	  
			EndIf
			If SB5->B5_PINSUMO <> "1" .AND. cTpImp $ "1" .And. lR11	
				IF !R14->(dbSeek(cMesRef))						
					RecLock("R14",.T.)                              
					R14->DTREF	:=	cMesRef						
				ELSE
					RecLock("R14",.F.) 		
				ENDIF  	      			
				R14->SUSPPISCOF:= "N"
				R14->(MsUnlock())
			EndIf
			If SB5->B5_PINSUMO == "1" .AND. cTpImp $ "1" .And. lR31
				//������������������������������������������������������Ŀ
				//�Verifica se o documento de entrada ulitizado e um DSI �
				//��������������������������������������������������������	
				IF !R36->(dbSeek(cMesRef))						
					RecLock("R36",.T.)                              
					R36->DTREF	:=	cMesRef						
				ELSE
					RecLock("R36",.F.) 		
				ENDIF  	      			
				R36->NDSI := VAL(STRZERO(Val(cNDI),10))
				R36->CDISUM := SB1->B1_COD		
				R36->SUSPPISCOF:= "N"
				R36->(MsUnlock())	  

			EndIf	
	    EndIf
	Endif
	(cAliasSFT)->( dbSkip() )          
EndDo

If lQuery
    dbSelectArea(cAliasSFT)
	dbCloseArea()
 	Ferase(cIndSFT+OrdBagExt())
	dbSelectArea("SFT")
	RetIndex("SFT")
Endif	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao  �CRTemp      �Autor  �Sueli C. Santos     � Data �  25.05.06   ���
�������������������������������������������������������������������������͹��
���Desc.   �Cria todos os arquivos temporarios necessarios a geracao da   ���
���        �DS                                                            ���
�������������������������������������������������������������������������͹��
���Uso     �                                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CRTemp(cAls)                        

LOCAL aCampos	:=	{}

//�������������������������������������������������������������������������������������`�
//�Aten��o ao alterar, pois existem 2 arquivos .INI que utilizam essa mesma estrutura, �
//�o DCIMENSAL.ini e o DCIINDIV.ini                                                    �
//�������������������������������������������������������������������������������������`�

//�������������������������Ŀ       	
//�Registro Header - R00	�
//���������������������������
AADD(aCampos,{"DTREF"	,"N"	,006,0})
AADD(aCampos,{"NRINSES"	,"N"	,014,0})
AADD(aCampos,{"SERIE"	,"C"	,005,0})
AADD(aCampos,{"NFISCAL"	,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"CNPJINT" ,"N"	,014,0})
AADD(aCampos,{"VERS"    ,"C"    ,005,0}) 

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R00")
IndRegua("R00",cAls,"DTREF")    

//�������������������������Ŀ
//�Registro DCI Mensal - R01�
//���������������������������
aCampos	:=	{}
AADD(aCampos,{"DTREF"   ,"N"	,006,0})
AADD(aCampos,{"CNPJINT" ,"N"	,014,0}) 
AADD(aCampos,{"NRINSES"	,"N"	,014,0})
AADD(aCampos,{"SERIE"	,"C"	,005,0})
AADD(aCampos,{"NFISCAL"	,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"DTEMISS"	,"C"	,008,0})
AADD(aCampos,{"DTSAIDA"	,"C"	,008,0})
AADD(aCampos,{"CODCFOP"	,"C"	,004,0})
AADD(aCampos,{"TPPESSOA","C"	,001,0})
AADD(aCampos,{"CPFCNPJ"	,"C"	,014,0})
AADD(aCampos,{"UFDEST"	,"C"	,002,0})
AADD(aCampos,{"INTERNAC","C"	,001,0})
AADD(aCampos,{"NBCO"	,"N"	,003,0})
AADD(aCampos,{"NAG" 	,"N"	,004,0})
AADD(aCampos,{"NCC"	    ,"C"	,019,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R01")
IndRegua("R01",cAls,"DTREF")

//�������������������������������������Ŀ
//�Registro Dados do Produto Local - R11�
//���������������������������������������  

aCampos	:=	{}
AADD(aCampos,{"DTREF"   ,"C"	,006,0})
AADD(aCampos,{"NFITEM"  ,"N"	,003,0})
AADD(aCampos,{"CODNCM"  ,"N"	,008,0})
AADD(aCampos,{"CODINT"  ,"C"	,015,0})
AADD(aCampos,{"DEST"    ,"C"	,001,0}) 
AADD(aCampos,{"CDDEST"  ,"N"	,001,0}) 
AADD(aCampos,{"DESC"    ,"C"    ,045,0})
AADD(aCampos,{"TXJTEC"  ,"C"	,253,0}) 
AADD(aCampos,{"ALIQTEC" ,"N"	,005,2}) 
AADD(aCampos,{"TXIPI"   ,"C"	,253,0})
AADD(aCampos,{"ALIQIPI" ,"N"	,005,2})
AADD(aCampos,{"UNIDADE"	,"C"	,020,0}) 
AADD(aCampos,{"QUANTID"	,"N"	,014,0}) 
AADD(aCampos,{"QUNTOT"  ,"N"	,014,5})
AADD(aCampos,{"VALUNIT"	,"N"	,020,0})
AADD(aCampos,{"IPIDESTA","N"	,015,0})
AADD(aCampos,{"QTOT"    ,"N"	,014,5})
AADD(aCampos,{"UNIMED"	,"C"	,020,0}) 

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R11")
IndRegua("R11",cAls,"DTREF+CODINT+DEST")

//����������������������������������������������������������Ŀ
//�Registro de Nota Fiscal de Aquisi��o/ Produto Local - R12 �
//������������������������������������������������������������
aCampos	:=	{}
AADD(aCampos,{"DTREF"       ,"C"	,006,0})
AADD(aCampos,{"CNPJFOR"     ,"N"	,014,0})
AADD(aCampos,{"SERIE"       ,"C"	,005,0})
AADD(aCampos,{"NF"   		,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"NF2"   		,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"NRITEMNOTA" 	,"N"	,003,0})
AADD(aCampos,{"EMISSAO"  	,"N"	,008,0})
AADD(aCampos,{"CFOP"    		,"N"	,004,0})
AADD(aCampos,{"DL288"   		,"C"	,001,0})
AADD(aCampos,{"OBSOLE"		,"C"	,001,0}) 
AADD(aCampos,{"QUANT"		,"N"	,014,5})
AADD(aCampos,{"VLUNIT"		,"N"	,020,7}) 
AADD(aCampos,{"VLOBSOLE"		,"N"	,015,2})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R12")  
IndRegua("R12",cAls,"DTREF+NF2+SERIE")


//�������������������������������Ŀ
//�Registro DI/Produto Local - R13�
//���������������������������������
aCampos	:=	{} 
AADD(aCampos,{"DTREF"   	,"C"	,006,0})
AADD(aCampos,{"NDI"			,"C"	,010,0})
AADD(aCampos,{"NDIANT"		,"C"	,015,0})
AADD(aCampos,{"NADICAO"		,"C"	,003,0})
AADD(aCampos,{"NITEMAD"		,"C"	,002,0})
AADD(aCampos,{"DL288"		,"C"	,001,0})
AADD(aCampos,{"OBSOLE"		,"C"	,001,0})
AADD(aCampos,{"QUANT"		,"N"	,014,5})
AADD(aCampos,{"VUNIT"		,"N"	,020,7})
AADD(aCampos,{"MOEDANEG"	,"N"	,003,0})
AADD(aCampos,{"VFRETE"	 	,"N"	,020,7})
AADD(aCampos,{"MOEDFRETE" 	,"N"	,003,0})
AADD(aCampos,{"VSEGURO"		,"N"	,020,7})
AADD(aCampos,{"MOEDSEG"		,"N"	,003,0})
AADD(aCampos,{"VTOBSOL"		,"N"	,015,2})
AADD(aCampos,{"SUSPPISCOF"	,"C"	,001,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R13")
IndRegua("R13",cAls,"DTREF")


//����������������������������������Ŀ
//�Registro DSI/ Produto Local - R14 �
//������������������������������������
aCampos	:=	{}  
AADD(aCampos,{"DTREF"		,"C"	,006,0})
AADD(aCampos,{"NDSI"     	,"N"	,010,0})
AADD(aCampos,{"NDSIANT"		,"N"	,015,0})
AADD(aCampos,{"NRBEM"  		,"N"	,003,0})
AADD(aCampos,{"QUANT" 		,"N"	,014,5})
AADD(aCampos,{"VUNIT"   	,"N"	,020,7})
AADD(aCampos,{"MOEDNEG"    	,"N"	,003,0})
AADD(aCampos,{"VLFRETE"   	,"N"	,020,7})
AADD(aCampos,{"MOEDFRETE"	,"N"	,003,0}) 
AADD(aCampos,{"VSEGURO"		,"N"	,020,7})
AADD(aCampos,{"MOEDSEG"	    ,"N"	,003,0}) 
AADD(aCampos,{"SUSPPISCOF"	,"C"	,001,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R14")  
IndRegua("R14",cAls,"DTREF")

//�����������������������������������������������������Ŀ
//�Registro Produto Local da DCI Mensal/PI com PPB - R21�
//�������������������������������������������������������  

aCampos	:=	{}
AADD(aCampos,{"DTREF"   ,"C"	,006,0})
AADD(aCampos,{"NRITEM"  ,"N"	,003,0}) 
AADD(aCampos,{"CDDEST"  ,"C"	,001,0}) 
AADD(aCampos,{"DCRE"    ,"N"    ,010,0})
AADD(aCampos,{"CDPROD"  ,"C"	,015,0}) //Codigo interno do Produto
AADD(aCampos,{"DCR "    ,"N"	,009,0}) 
AADD(aCampos,{"DESC"    ,"C"	,045,0}) //Descricao do Produto
AADD(aCampos,{"VUNDOL" 	,"N"	,020,7}) // Valor Unitario do produto em dolar
AADD(aCampos,{"CREDUCAO","N"	,005,2})// Coeficiente de Reducao do produto 
AADD(aCampos,{"QTDPROD"	,"N"	,014,0}) 
AADD(aCampos,{"QUANT"	,"N"	,014,5})
AADD(aCampos,{"UNIMED"	,"C"	,020,0})
AADD(aCampos,{"VPIS"	,"N"	,020,7}) //Valor PIS/PASEP a ser recolhido
AADD(aCampos,{"VCOFINS"	,"N"	,020,7}) 	                                     

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R21")
IndRegua("R21",cAls,"DTREF+CDPROD+CDDEST")

//�����������������������������������������������������Ŀ
//�Registro Produto Local da DCI Mensal/PI sem PPB - R31�
//�������������������������������������������������������  
aCampos	:=	{}
AADD(aCampos,{"DTREF"   ,"C"	,006,0})
AADD(aCampos,{"NFITEM"  ,"N"	,003,0}) 
AADD(aCampos,{"CDPROD"  ,"C"	,015,0}) //Codigo interno do Produto
AADD(aCampos,{"DESC"    ,"C"	,045,0}) //Descricao do Produto
AADD(aCampos,{"UNIMED"  ,"C"    ,020,0}) //Unidade de Medida
AADD(aCampos,{"DNCM"    ,"N"	,008,0})
AADD(aCampos,{"QUANT"	,"N"	,014,0})
AADD(aCampos,{"VALUNIT" ,"N"	,020,0})
AADD(aCampos,{"DEST"	,"C"	,001,0}) //Locasl de destino (1 - Amazonia Ocidental)
AADD(aCampos,{"DESTINO"	,"N"	,001,0}) //Locasl de destino (1 - Amazonia Ocidental)
AADD(aCampos,{"QDEST"	,"N"	,014,5}) //Se Destino=1 informar a quantidade internada do produto, senao preencher com zeros
AADD(aCampos,{"DESTINO2","N"	,001,0}) //Local de Destino (2 - Demais Regioes) 
AADD(aCampos,{"QDEST2"	,"N"	,014,5}) //Se Destino=2, informar a quantidade internada do produto, senao preencher com zeros
AADD(aCampos,{"DESTINO3","N"	,001,0}) //Local de Destino (3 - ALC situada dentro da Amazonia Ocidental) 
AADD(aCampos,{"QDEST3"	,"N"	,014,5}) //Se Destino=3, informar a quantidade internada do produto, senao preencher com zeros
AADD(aCampos,{"DESTINO4","N"	,001,0}) //Local de Destino (4 - ALC situada fora da Amazonia Ocidental) 
AADD(aCampos,{"QDEST4"	,"N"	,014,5}) //Se Destino=4, informar a quantidade internada do produto, senao preencher com zeros

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R31")
IndRegua("R31",cAls,"DTREF+CDPROD+DEST")

//����������������������������������������������������������Ŀ
//�Registro Matriz Produto/Insumo do Item da DCI Mensal - R32�
//������������������������������������������������������������  

aCampos	:=	{}
AADD(aCampos,{"DTREF"   ,"C"	,006,0})
AADD(aCampos,{"FILLER1" ,"N"	,003,0}) 
AADD(aCampos,{"CDPROD"  ,"C"	,015,0}) //Codigo interno do Produto
AADD(aCampos,{"CDISUM"  ,"C"	,015,0}) //Codigo interno do Insumo
AADD(aCampos,{"CDNCM"   ,"N"	,008,0}) 
AADD(aCampos,{"DNCM"    ,"C"	,045,0}) //Descricao Insumo
AADD(aCampos,{"UNIMED"  ,"C"   ,020,0}) //Unidade de Medida
AADD(aCampos,{"QTINSUM"	,"N"	,014,5}) //Qtde do Insumo

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R32")
IndRegua("R32",cAls,"DTREF+CDPROD")

//���������������������������������������Ŀ
//�Registro Insumo do Produto Local - R33 �
//�����������������������������������������
aCampos	:=	{}  
AADD(aCampos,{"DTREF"   ,"C"	,006,0})
AADD(aCampos,{"FILLER1" ,"N"	,003,0}) 
AADD(aCampos,{"CDISUM"  ,"C"	,015,0}) //Codigo interno do Insumo
AADD(aCampos,{"QTOTINS" ,"N"	,014,5}) //Qtde total do Insumo
AADD(aCampos,{"LOCDEST" ,"N"	,001,0}) //Local de Destino ,de cada Local informado do Reg 31
AADD(aCampos,{"TXTEC"   ,"C"   ,253,0}) //Divergencia TEC
AADD(aCampos,{"ALIQTEC"	,"N"	,005,2}) //Divergencia de Aliquota TEC
AADD(aCampos,{"TXIPI"   ,"C"   ,253,0}) //Divergencia IPI
AADD(aCampos,{"ALIQIPI"	,"N"	,005,2}) //Divergencia de Aliquota IPI
AADD(aCampos,{"QTINSD"  ,"N" 	,014,5}) //Qtde total do Insumo internado para o Local de Destino

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R33")  
IndRegua("R33",cAls,"DTREF+CDISUM")
                                                                     


//�����������������������������������������Ŀ
//�Registro NF/Insumo do Produto Local - R34�
//�������������������������������������������
aCampos	:=	{}
AADD(aCampos,{"DTREF"       ,"C"	,006,0})
AADD(aCampos,{"CNPJFOR"     ,"N"	,014,0})
AADD(aCampos,{"SERIE"       ,"C"	,005,0})
AADD(aCampos,{"NF"   		,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"NF2"   		,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"NRITEMNOTA" 	,"N"	,003,0})
AADD(aCampos,{"EMISSAO"  	,"N"	,008,0})
AADD(aCampos,{"CFOP"    	,"N"	,004,0})
AADD(aCampos,{"DL288"   	,"C"	,001,0})
AADD(aCampos,{"QTINSUMO"	,"N"	,014,5})
AADD(aCampos,{"VLUNIT"	    ,"N"	,020,7}) //Valor Unitario Insumo
AADD(aCampos,{"CDISUM"      ,"C"	,015,0}) //Codigo interno do Insumo
AADD(aCampos,{"LOCDEST"     ,"N"	,001,0}) //Local de Destino ,de cada Local informado do Reg 33
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R34")
IndRegua("R34",cAls,"DTREF+NF2+SERIE")


//�������������������������������Ŀ
//�Registro DI/Produto Local - R35�
//���������������������������������
aCampos	:=	{} 
AADD(aCampos,{"DTREF"   	,"C"	,006,0})
AADD(aCampos,{"NDI"			,"N"	,010,0})
AADD(aCampos,{"NDIANT"		,"N"	,015,0})
AADD(aCampos,{"NADICAO"		,"N"	,003,0})
AADD(aCampos,{"NITEMAD"		,"N"	,002,0})
AADD(aCampos,{"DL288"		,"C"	,001,0})
AADD(aCampos,{"QUANT"		,"N"	,014,5})
AADD(aCampos,{"VUNIT"		,"N"	,020,7})
AADD(aCampos,{"MOEDANEG"	,"N"	,003,0})
AADD(aCampos,{"VFRETE"	 	,"N"	,020,7})
AADD(aCampos,{"MOEDFRETE" 	,"N"	,003,0})
AADD(aCampos,{"VSEGURO"		,"N"	,020,7})
AADD(aCampos,{"MOEDSEG"		,"N"	,003,0})
AADD(aCampos,{"CDISUM"      ,"C"	,015,0}) //Codigo interno do Insumo
AADD(aCampos,{"LOCDEST"     ,"N"	,001,0}) //Local de Destino ,de cada Local informado do Reg 33
AADD(aCampos,{"SUSPPISCOF"	,"C"	,001,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R35")
IndRegua("R35",cAls,"DTREF")


//����������������������������������Ŀ
//�Registro DSI/ Produto Local - R36 �
//������������������������������������
aCampos	:=	{}  
AADD(aCampos,{"DTREF"		,"C"	,006,0})
AADD(aCampos,{"NDSI"     	,"N"	,010,0})
AADD(aCampos,{"NDSIANT"		,"N"	,015,0})
AADD(aCampos,{"NRBEM"  		,"N"	,003,0})  
AADD(aCampos,{"QUANT" 		,"N"	,014,5})
AADD(aCampos,{"CDISUM"      ,"C"	,015,0}) //Codigo interno do Insumo
AADD(aCampos,{"LOCDEST"     ,"N"	,001,0}) //Local de Destino ,de cada Local informado do Reg 33
AADD(aCampos,{"VUNIT"   	,"N"	,020,7})
AADD(aCampos,{"MOEDNEG"    	,"N"	,003,0})
AADD(aCampos,{"VLFRETE"   	,"N"	,020,7})
AADD(aCampos,{"MOEDFRETE"	,"N"	,003,0}) 
AADD(aCampos,{"VSEGURO"		,"N"	,020,7})
AADD(aCampos,{"MOEDSEG"	    ,"N"	,003,0}) 
AADD(aCampos,{"SUSPPISCOF"	,"C"	,001,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R36")  
IndRegua("R36",cAls,"DTREF")


//�����������������������������������������������������Ŀ
//�Registro Produto Local da DCI Mensal/PI sem PPB - R41�
//�������������������������������������������������������  
aCampos	:=	{}
AADD(aCampos,{"DTREF"   ,"C"	,006,0})
AADD(aCampos,{"NFITEM"  ,"N"	,003,0}) 
AADD(aCampos,{"CDNCM"   ,"N"	,008,0}) 
AADD(aCampos,{"CDPROD"  ,"C"	,015,0}) //Codigo interno do Produto
AADD(aCampos,{"DESC"    ,"C"	,045,0}) //Descricao do Produto
AADD(aCampos,{"UNIMED"  ,"C"    ,020,0}) //Unidade de Medida 
AADD(aCampos,{"QTDUNI"	,"N"	,014,0}) 
AADD(aCampos,{"QTDNCM"  ,"N"	,014,0})
AADD(aCampos,{"VUNIT"   ,"N"	,020,0})
AADD(aCampos,{"VTOTUN"  ,"N"	,015,2})
AADD(aCampos,{"QTPROD"  ,"N"	,014,5}) //Qtde total do produto na unidade comercializada
AADD(aCampos,{"QTPRODE" ,"N"	,014,5}) //Qtde total do produto na unidade de estatistica do NCM

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R41")
IndRegua("R41",cAls,"DTREF+CDPROD")

Return  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MontPainel� Autor �Sueli C. dos Santos    � Data �25.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Preparacao do wizard para auxilio das informacoes necessa-  ���
���          � rias na composicao do meio-magnetico.                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aWizard -> Array contendo as informacoes do wizard.         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MontPainel(lIndiv)

//������������������������Ŀ
//�Declaracao das variaveis�
//��������������������������
Local aTxtPre 		:= {}
Local aPaineis 		:= {}
Local cTitObj1		:= ""
Local cTitObj2		:= ""       
Local nPos			:= 0
Local lRet			:= .F.

Default	lIndiv		:= .F.

//���������������������������������������������������������������������Ŀ
//�            CUIDADO AO INCLUIR NOVO CAMPO NA WIZARD                  �
//�                                                                     �
//�Ao incluir nova posi��o da Wizard, avaliar se deve aparecer tanto na �
//�DCI - Mensal quanto na DCI - Individual, e se a nova posi��o n�o     �
//�altera as j� existentes em ambas as op��es.                          �
//�����������������������������������������������������������������������

If !lIndiv
	//�����������������������������������������Ŀ
	//�Monta wizard com as perguntas necessarias�   
	//�������������������������������������������
	AADD(aTxtPre,"Processamento da DCI Mensal - ZFM")
	AADD(aTxtPre,"")
	AADD(aTxtPre,"Preencha Corretamente as Informa��es Solicitadas.")
	AADD(aTxtPre,"Informa��es Necessarias para o Preenchimento Autom�tico da                DCI-Mensal - ZFM.")
	
	//����������������������������������������Ŀ
	//�Painel com as informacoes necessarias   �
	//������������������������������������������        
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],"Processamento da DCI Mensal")
	aAdd(aPaineis[nPos],"Dados de Identifica��o dos Registros DCI Mensal.")
	aAdd(aPaineis[nPos],{})
 
Else
	//�����������������������������������������Ŀ
	//�Monta wizard com as perguntas necessarias�   
	//�������������������������������������������
	AADD(aTxtPre,"Processamento da DCI Individual - ZFM")
	AADD(aTxtPre,"")
	AADD(aTxtPre,"Preencha Corretamente as Informa��es Solicitadas.")
	AADD(aTxtPre,"Informa��es Necessarias para o Preenchimento Autom�tico da                DCI-Individual - ZFM.")
	
	//����������������������������������������Ŀ
	//�Painel com as informacoes necessarias   �
	//������������������������������������������        
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],"Processamento da DCI Individual")
	aAdd(aPaineis[nPos],"Dados de Identifica��o dos Registros DCI Individual.")
	aAdd(aPaineis[nPos],{})
EndIf
 
cTitObj1 :=	"Numero do Banco ?" 		//Cfp[1][01]
cTitObj2 :=	"Numero da Agencia ?"   	//Cfp[1][02]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"XXX", 1,,,,3}) 
aAdd(aPaineis[nPos][3],{2, ,"XXXX", 1,,,,4}) 
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Numero da Conta Corrente ?" //Cfp[1][03]   
cTitObj2 :=	""  
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"XXXXXXXXXXXXXXXXXXX", 1,,,,19}) 
aAdd(aPaineis[nPos][3],{0,,"",,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

If !lIndiv
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],"Processamento da DCI Mensal")
	aAdd(aPaineis[nPos],"Dados de Identifica��o da Vers�o DCI Mensal.")
	aAdd(aPaineis[nPos],{})
Else
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],"Processamento da DCI Individual")
	aAdd(aPaineis[nPos],"Dados de Identifica��o da Vers�o DCI Individual.")
	aAdd(aPaineis[nPos],{})
EndIf

cTitObj1 := "Vers�o da DCI(XX.XX):"       //Cfp[2][01]
cTitObj2 := ""
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"XXXXX", 1,,,,5}) 
aAdd(aPaineis[nPos][3],{0, ,"", ,,,,}) 
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

If lIndiv  
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],"Processamento da DCI Individual")
	aAdd(aPaineis[nPos],"Preencha as informa��es da Nota Fiscal")
	aAdd(aPaineis[nPos],{})

	cTitObj1 := "Data"       //Cfp[3][01]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{2, ,"@!", 3,,,,TAMSX3("A1_COD")[1]}) 
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,}) 

	cTitObj1 := "Nota Fiscal"       //Cfp[3][03]
	cTitObj2 := "S�rie"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,9}) 
	aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,3}) 
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,}) 

	cTitObj1 := "Cliente/Fornecedor"       //Cfp[3][05]
	cTitObj2 := "Loja"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,TamSX3("A1_COD")[1]}) 
	aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,TamSX3("A1_LOJA")[1]}) 

EndIf

If !lIndiv
	lRet := xMagWizard(aTxtPre,aPaineis,"DCIMENSAL")
Else
	lRet := xMagWizard(aTxtPre,aPaineis,"DCIINDIVI")
EndIf

Return(lRet)                                           
   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Function  �HeaderMensal    �Autor  �Sueli C. Santos     � Data �  26/05/2006 ���
�������������������������������������������������������������������������͹��
���Desc.     �Header Mensal.                 							  ���
���          �Contem informacoes sobre o contribuinte e informacoes gerais���
���          �sobre o documento fiscal. R00 							  ���
�������������������������������������������������������������������������͹��
���Uso       � DCIMensal                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HeaderMensal(lIndiv)
Default	lIndiv := .F.

RecLock("R00",.T.)   
R00->DTREF	    := Val(SUBSTR(DTOS(dDtIni),1,6))              
R00->CNPJINT	:= Val(SM0->M0_CGC)
R00->VERS       := Alltrim(aCfp[2][01])

If lIndiv
	R00->NRINSES	:= Val(SM0->M0_INSC)
	R00->NFISCAL    := Alltrim(aCfp[3][02])
	R00->SERIE      := Alltrim(aCfp[3][03])
EndIf

MSUnlock()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Function  |DadosMensais �Autor  �Sueli C. Santos  � Data �  26/05/2006 ���
�������������������������������������������������������������������������͹��
���Desc.     �Header Mensal.                 							  ���
���          �Contem informacoes sobre o contribuinte e informacoes gerais���
���          �sobre o documento fiscal. R01 							  ���
���          �sobre o documento fiscal. R01 							  ���
�������������������������������������������������������������������������͹��
���Uso       � DCIMensal                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DadosMensais(lIndiv, cAliasSFT, cCNPJ, cPessoa)
Local cDestino	:= SuperGetMv("MV_ESTADO",.F.,"")

Default	lIndiv 		:= .F.
Default cAliasSFT 	:= ""


RecLock("R01",.T.)
R01->DTREF	    :=	Val(SUBSTR(DTOS(dDtIni),1,6))
R01->CNPJINT	:= Val(SM0->M0_CGC)
R01->NBCO       := Val(Alltrim(aCfp[1][01]))
R01->NAG        := Val(Alltrim(aCfp[1][02]))
R01->NCC        := Alltrim(aCfp[1][03])

If lIndiv .And. !Empty(cAliasSFT)

	If Substr((cAliasSFT)->FT_CFOP,1,1)>="5"
    	cDestino := (cAliasSFT)->FT_ESTADO
    EndIf

	R01->NRINSES        := Val(SM0->M0_INSC)
	R01->SERIE        	:= Alltrim(aCfp[3][03])
	R01->NFISCAL        := Alltrim(aCfp[3][02])
	R01->DTEMISS        := Alltrim(aCfp[3][01])
	R01->DTSAIDA        := Alltrim(aCfp[3][01])
 	R01->CODCFOP        := Alltrim( (cAliasSFT)->FT_CFOP )
 	R01->TPPESSOA       := Alltrim( cPessoa )
 	R01->CPFCNPJ       	:= Alltrim( cCNPJ )
 	R01->UFDEST        	:= Alltrim( cDestino )
 	R01->INTERNAC		:= Iif( cDestino$"AC/AP/AM/RO/RR","S","N"  )
EndIf

MSUnlock()

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Function  |Dcigat	   �Autor  �Natalia Antonucci� Data �  06/07/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��a que verifica se os campos NR-DCRE e NR-DCR do produto���
���	         �est�o preenchidos.									   	  ���
���          �cCond = Descri��o do campo onde esta chamando a Fun��o      ���
�������������������������������������������������������������������������͹��
���Uso       � DCIMensal                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Dcigat(cCond)
Local oModel := FwModelActivate() //Carrega o �ltimo model ativado

Default cCond := ""

//Inverter os campos para apagar o campo correto
If cCond == "DCRE"
	cCond:= "DCR"
ElseIf cCond == "DCR"
	cCond:= "DCRE"
EndIf

If (cCond == "DCRE" .Or. cCond == "DCR") .And. !Empty(M->B1_DCR) .And. !Empty(M->B1_DCRE)
	If MsgYesNo("Campo NR-"+Alltrim(cCond)+" esta preenchido dejesa apagar?","ATENCAO!!!")
		//Verifica se o cadastro de produto est� sendo executado via MVC
		If ValType(oModel) == "O" .And. oModel:CanSetValue("SB1MASTER","B1_"+cCond)
			oModel:LoadValue("SB1MASTER","B1_"+cCond,CriaVar("B1_"+cCond))
		Else
			M->&("B1_"+cCond) := CriaVar("B1_"+cCond)
		EndIf
	EndIf
EndIf

Return .T.